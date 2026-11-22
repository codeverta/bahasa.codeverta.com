package store

import (
	"crypto/rand"
	"database/sql"
	"encoding/binary"
	"encoding/json"
	"errors"
	"fmt"
	"strings"
	"sync"
	"sync/atomic"
	"time"

	"gorm.io/gorm"
	"gorm.io/gorm/clause"

	"bahasa-master-backend/internal/database"
	"bahasa-master-backend/internal/domain"
)

var (
	ErrNotFound           = errors.New("resource not found")
	ErrInvalid            = errors.New("invalid input")
	ErrPremium            = errors.New("premium entitlement required")
	ErrInvalidCredentials = errors.New("invalid email or password")
	ErrReviewEmailLogin   = errors.New("play review account must use email and password")
	ErrSessionNotFound    = errors.New("session not found")
)

type account struct {
	ID             string
	Email          string
	DisplayName    string
	PhotoURL       string
	CustomPhotoURL string
	// CustomDisplayName is the name the user typed in the app. It wins over
	// the Google name, which is refreshed on every Google sign-in.
	CustomDisplayName string `json:",omitempty"`
	Timezone          string
	PasswordHash      []byte
	GoogleSub         string
}

type MemoryStore struct {
	// Admin-tunable XP limits; zero means the default (see SetXPRules).
	xpRepeatCap, ankiStreakCards int
	purchases            map[string]domain.Purchase
	billingTokens        map[string]string
	billingEnabled       bool
	mu                   sync.RWMutex
	gamification         map[string]*gamificationState
	userAnkiDecks        map[string]*userAnkiDeckRecord
	userAnkiDeckRequests map[string]string
	gamificationDB       *sql.DB
	ormDB                *gorm.DB
	ormWriter            *gorm.DB
	persistenceConn      *sql.Conn
	persistenceLockName  string
	persistenceClosed    bool
	persistenceStop      chan struct{}
	gamificationNow      func() time.Time
	profiles             map[string]domain.Profile
	progress             map[string]map[string]domain.LessonProgress
	categories           []domain.LearningCategory
	tracks               []domain.LearningTrack
	plans                []domain.Plan
	attemptID            atomic.Uint64
	accounts             map[string]account
	playReviewEmail      string
	adminLoginEmail      string
	playReviewUserID     string
	sessions             map[string]string
	vocabulary           []domain.VocabularyLevelContent
	vocabAttempts        map[string]*vocabularyAttemptState
	assetBaseURL         string
	lb                   *leaderboardState
}

func (s *MemoryStore) SetAssetBaseURL(value string) {
	s.mu.Lock()
	s.assetBaseURL = strings.TrimRight(strings.TrimSpace(value), "/")
	s.mu.Unlock()
}

func NewMemoryStore() *MemoryStore {
	result := &MemoryStore{
		purchases:            map[string]domain.Purchase{},
		billingTokens:        map[string]string{},
		profiles:             map[string]domain.Profile{},
		gamification:         map[string]*gamificationState{},
		userAnkiDecks:        map[string]*userAnkiDeckRecord{},
		userAnkiDeckRequests: map[string]string{},
		gamificationNow:      time.Now,
		progress:             map[string]map[string]domain.LessonProgress{},
		categories:           seedCategories(),
		tracks:               seedTracks(),
		plans:                seedPlans(),
		accounts:             map[string]account{},
		sessions:             map[string]string{},
		vocabulary:           seedVocabulary(),
		vocabAttempts:        map[string]*vocabularyAttemptState{},
		lb:                   newLeaderboardState(),
	}
	var nonce [8]byte
	if _, err := rand.Read(nonce[:]); err != nil {
		panic(err)
	}
	result.attemptID.Store(binary.LittleEndian.Uint64(nonce[:]) >> 1)
	result.seedDemoAccount()
	for i := range result.categories {
		if result.categories[i].ID == "vocabulary" {
			result.categories[i].LessonCount = 0
			for _, level := range result.vocabulary {
				result.categories[i].LessonCount += len(level.Lessons)
			}
		}
	}
	return result
}

func (s *MemoryStore) Dashboard(userID string) domain.Dashboard {
	dashboard := domain.Dashboard{
		IsAuthenticated: userID != "",
		DailyGoal:       domain.DailyGoal{TargetMinutes: 20},
		Categories:      s.Categories(),
		Tracks:          s.Tracks(""),
		Plans:           s.Plans(),
	}
	if userID == "" {
		return dashboard
	}
	profile := s.Profile(userID)
	dashboard.Profile = &profile
	dashboard.DailyGoal.StreakDays = profile.StreakDays
	dashboard.DailyGoal.MinutesLearned = s.Gamification(userID).MinutesToday
	dashboard.Achievements = s.Achievements(userID)
	return dashboard
}

func todayMinutes(items []domain.LessonProgress) int {
	const secondsPerMinute = 60
	minutes := 0
	today := time.Now().UTC()
	for _, item := range items {
		if item.UpdatedAt.Year() == today.Year() && item.UpdatedAt.YearDay() == today.YearDay() {
			minutes += item.LastPosition / secondsPerMinute
		}
	}
	return minutes
}

func (s *MemoryStore) Categories() []domain.LearningCategory {
	s.mu.RLock()
	defer s.mu.RUnlock()
	result := append([]domain.LearningCategory(nil), s.categories...)
	if openLearningAccess {
		for i := range result {
			result[i].RequiredTier = domain.TierFree
		}
	}
	return result
}

func (s *MemoryStore) Tracks(system string) []domain.LearningTrack {
	s.mu.RLock()
	defer s.mu.RUnlock()
	result := filterTracks(s.tracks, system)
	if openLearningAccess {
		for i := range result {
			result[i].RequiredTier = domain.TierFree
		}
	}
	return result
}

func (s *MemoryStore) Plans() []domain.Plan {
	s.mu.RLock()
	defer s.mu.RUnlock()
	return append([]domain.Plan(nil), s.plans...)
}

func (s *MemoryStore) Profile(userID string) domain.Profile {
	s.mu.Lock()
	defer s.mu.Unlock()
	profile := s.ensureProfileLocked(userID)
	profile.Entitlement = s.entitlementLocked(userID)
	canPurchase := userID != database.DemoUserID && (s.playReviewUserID == "" || userID != s.playReviewUserID)
	profile.CanPurchase = &canPurchase
	if profile.Timezone == "" {
		profile.Timezone = defaultStudyTimezone
	}
	if state := s.gamification[userID]; state != nil {
		profile.XP = state.XP
		profile.Level = 1 + state.XP/500
		profile.StreakDays, _ = studyStreaks(state, s.gamificationNow())
	}
	return profile
}

func (s *MemoryStore) UpdateStudyTimezone(userID, timezone string) (domain.Profile, error) {
	if !isValidStudyTimezone(timezone) {
		return domain.Profile{}, ErrInvalid
	}
	s.mu.Lock()
	defer s.mu.Unlock()
	profile := s.ensureProfileLocked(userID)
	profile.Timezone = timezone
	profile.Entitlement = s.entitlementLocked(userID)
	state := s.gamification[userID]
	if state == nil {
		state = newGamificationState()
	}
	nextState := *state
	nextState.Timezone = timezone
	if s.gamificationDB != nil {
		raw, err := json.Marshal(&nextState)
		if err != nil {
			return domain.Profile{}, err
		}
		if err = s.ormWriter.Clauses(clause.OnConflict{DoUpdates: clause.AssignmentColumns([]string{"state"})}).Create(&database.GamificationUser{UserID: userID, State: raw}).Error; err != nil {
			return domain.Profile{}, fmt.Errorf("persist study timezone: %w", err)
		}
	}
	updatedAccounts := make(map[string]account)
	for email, account := range s.accounts {
		if account.ID != userID {
			continue
		}
		account.Timezone = timezone
		if s.billingEnabled {
			raw, err := json.Marshal(account)
			if err != nil {
				return domain.Profile{}, err
			}
			if err = s.ormWriter.Clauses(clause.OnConflict{DoUpdates: clause.AssignmentColumns([]string{"state"})}).Create(&database.Account{ID: account.ID, Email: email, State: raw}).Error; err != nil {
				return domain.Profile{}, fmt.Errorf("persist account timezone: %w", err)
			}
		}
		updatedAccounts[email] = account
	}
	s.gamification[userID] = &nextState
	for email, account := range updatedAccounts {
		s.accounts[email] = account
	}
	s.profiles[userID] = profile
	return profile, nil
}

func (s *MemoryStore) UpdateProfile(userID, displayName, target string) (domain.Profile, error) {
	if strings.TrimSpace(displayName) == "" || strings.TrimSpace(target) == "" {
		return domain.Profile{}, ErrInvalid
	}
	s.mu.Lock()
	defer s.mu.Unlock()
	name := strings.TrimSpace(displayName)
	// Persist the edited name on the account so a later Google sign-in does
	// not replace it with the Google name.
	for email, existing := range s.accounts {
		if existing.ID != userID {
			continue
		}
		existing.CustomDisplayName = name
		if s.billingEnabled {
			raw, err := json.Marshal(existing)
			if err != nil {
				return domain.Profile{}, err
			}
			if err = s.ormWriter.Clauses(clause.OnConflict{DoUpdates: clause.AssignmentColumns([]string{"state"})}).Create(&database.Account{ID: existing.ID, Email: email, State: raw}).Error; err != nil {
				return domain.Profile{}, fmt.Errorf("persist display name: %w", err)
			}
		}
		s.accounts[email] = existing
	}
	profile := s.ensureProfileLocked(userID)
	profile.DisplayName = name
	profile.Target = strings.ToUpper(strings.TrimSpace(target))
	profile.Entitlement = s.entitlementLocked(userID)
	s.profiles[userID] = profile
	return profile, nil
}

// UpdateProfilePhoto replaces an account's uploaded photo URL. The Google
// account photo remains available as a fallback if the user later removes it.
func (s *MemoryStore) UpdateProfilePhoto(userID, photoURL string) (domain.Profile, string, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if userID == "" || userID == s.playReviewUserID || strings.TrimSpace(photoURL) == "" {
		return domain.Profile{}, "", ErrInvalid
	}
	var email string
	var account account
	for candidateEmail, candidate := range s.accounts {
		if candidate.ID == userID {
			email, account = candidateEmail, candidate
			break
		}
	}
	if email == "" {
		return domain.Profile{}, "", ErrNotFound
	}
	previousPhotoURL := account.CustomPhotoURL
	account.CustomPhotoURL = strings.TrimSpace(photoURL)
	if s.billingEnabled {
		raw, err := json.Marshal(account)
		if err != nil {
			return domain.Profile{}, "", err
		}
		if err = s.ormWriter.Clauses(clause.OnConflict{DoUpdates: clause.AssignmentColumns([]string{"state"})}).Create(&database.Account{ID: account.ID, Email: email, State: raw}).Error; err != nil {
			return domain.Profile{}, "", err
		}
	}
	s.accounts[email] = account
	profile := s.ensureProfileForAccountLocked(account)
	profile.Entitlement = s.entitlementLocked(userID)
	s.profiles[userID] = profile
	return profile, previousPhotoURL, nil
}

func (s *MemoryStore) Progress(userID string) []domain.LessonProgress {
	s.mu.RLock()
	defer s.mu.RUnlock()
	items := s.progress[userID]
	result := make([]domain.LessonProgress, 0, len(items))
	for _, item := range items {
		result = append(result, item)
	}
	return result
}

func (s *MemoryStore) SaveProgress(userID string, input domain.LessonProgress) (domain.LessonProgress, error) {
	if input.LessonID == "" || (strings.HasPrefix(input.LessonID, "grammar-") || strings.HasPrefix(input.LessonID, "kanji-") || strings.HasPrefix(input.LessonID, "reading-")) || input.Completion < 0 || input.Completion > 100 || input.LastPosition < 0 {
		return domain.LessonProgress{}, ErrInvalid
	}
	input.Completed = input.Completion == 100
	input.UpdatedAt = time.Now().UTC()

	s.mu.Lock()
	defer s.mu.Unlock()
	if _, lesson := s.findVocabularyLessonLocked(input.LessonID); lesson != nil {
		return domain.LessonProgress{}, ErrInvalid
	}
	if s.progress[userID] == nil {
		s.progress[userID] = map[string]domain.LessonProgress{}
	}
	s.progress[userID][input.LessonID] = input

	return input, nil
}

func (s *MemoryStore) Achievements(userID string) []domain.Achievement {
	return s.Gamification(userID).Achievements
}

func (s *MemoryStore) ensureProfileLocked(userID string) domain.Profile {
	if profile, ok := s.profiles[userID]; ok {
		return profile
	}
	profile := domain.Profile{
		ID:          userID,
		DisplayName: "Bahasa Learner",
		Email:       userID + "@example.local",
		Target:      "JLPT N5",
		Level:       1,
		XP:          0,
		StreakDays:  0,
		Entitlement: domain.Entitlement{Tier: domain.TierFree},
	}
	s.profiles[userID] = profile
	return profile
}

func filterTracks(tracks []domain.LearningTrack, system string) []domain.LearningTrack {
	if system == "" {
		return append([]domain.LearningTrack(nil), tracks...)
	}
	var result []domain.LearningTrack
	for _, track := range tracks {
		if strings.EqualFold(track.System, system) {
			result = append(result, track)
		}
	}
	return result
}

func seedCategories() []domain.LearningCategory {
	return []domain.LearningCategory{
		{ID: "vocabulary", Name: "Vocabulary", Description: "Kosakata tematik dengan spaced repetition", LessonCount: 240, RequiredTier: domain.TierFree},
		{ID: "grammar", Name: "Grammar", Description: "Grammar JLPT N5 sampai N1: pola, contoh kalimat, dan kuis", LessonCount: 196, RequiredTier: domain.TierFree},
		{ID: "reading", Name: "Reading", Description: "Reading JLPT N5 sampai N1: cerita, kosakata, dan kuis", LessonCount: 60, RequiredTier: domain.TierFree},
	}
}

func seedTracks() []domain.LearningTrack {
	return []domain.LearningTrack{}
}

func seedPlans() []domain.Plan {
	features := []string{"Materi N3–N1 yang tersedia", "Seluruh tes yang tersedia", "Restore pembelian", "Sekali bayar tanpa perpanjangan"}
	return []domain.Plan{
		{ID: "free", Name: "Free", BillingType: "free", PriceIDR: 0, Features: []string{"JLPT N5–N4 dasar", "Daily practice", "Progress dasar"}},
		{ID: "premium-lifetime", Name: "Lifetime Access", BillingType: "lifetime", PriceIDR: 99000, Features: features, Recommended: true},
	}
}
