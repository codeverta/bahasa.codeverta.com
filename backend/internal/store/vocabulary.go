package store

import (
	"fmt"
	"sort"
	"strings"
	"time"

	"bahasa-master-backend/internal/domain"
)

type vocabularyAttemptState struct {
	result       *domain.VocabularyAttemptResult
	attempt      domain.VocabularyAttempt
	userID       string
	correct      map[string]string
	explanations map[string]string
	answers      map[string]domain.VocabularyAnswerFeedback
}

func (s *MemoryStore) VocabularyLevels(userID string) []domain.VocabularyLevel {
	s.mu.RLock()
	defer s.mu.RUnlock()
	result := make([]domain.VocabularyLevel, 0, len(s.vocabulary))
	for _, level := range s.vocabulary {
		if PremiumLevel(level.Level) {
			level.RequiredTier = domain.TierPremium
		}
		lessons := make([]domain.VocabularyLessonSummary, 0, len(level.Lessons))
		total := 0
		for _, lesson := range level.Lessons {
			asset, questionCount := "", len(lesson.Words)
			if len(lesson.Words) > 0 {
				asset = lesson.Words[0].ImageAsset
			}
			if level.Level == "N5" {
				questionCount *= 3
			}
			progress := s.progress[userID][lesson.ID]
			total += progress.Completion
			lessons = append(lessons, domain.VocabularyLessonSummary{
				ImageAsset: asset, ImageURL: s.assetURLLocked(asset), QuestionCount: questionCount,
				ID: lesson.ID, Order: lesson.Order, Title: lesson.Title,
				Description: lesson.Description, WordCount: len(lesson.Words),
				BestScore: progress.Completion, Completed: progress.Completed,
			})
		}
		percentage := 0
		if len(lessons) > 0 {
			percentage = total / len(lessons)
		}
		result = append(result, domain.VocabularyLevel{
			Level: level.Level, Title: level.Title, Description: level.Description,
			SourceName: level.SourceName, SourceURL: level.SourceURL, SourceLicense: level.SourceLicense,
			RequiredTier: level.RequiredTier, Progress: percentage, Lessons: lessons,
		})
	}
	return result
}

func (s *MemoryStore) VocabularyLesson(userID, lessonID string) (domain.VocabularyLesson, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	level, lesson := s.findVocabularyLessonLocked(lessonID)
	if lesson == nil {
		return domain.VocabularyLesson{}, ErrNotFound
	}
	progress := s.progress[userID][lessonID]
	words := append([]domain.VocabularyWord(nil), lesson.Words...)
	for i := range words {
		if words[i].ImageAsset != "" {
			words[i].ImageURL = s.assetURLLocked(words[i].ImageAsset)
		}
	}
	return domain.VocabularyLesson{
		ID: lesson.ID, Level: level.Level, Title: lesson.Title,
		Description: lesson.Description, BestScore: progress.Completion,
		Completed: progress.Completed,
		ImageURL:  s.assetURLLocked("assets/images/vocabulary/study-journey.webp"),
		Words:     words,
	}, nil
}

func (s *MemoryStore) StartVocabularyAttempt(userID, lessonID string) (domain.VocabularyAttempt, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	level, lesson := s.findVocabularyLessonLocked(lessonID)
	if lesson == nil {
		return domain.VocabularyAttempt{}, ErrNotFound
	}
	options := make([]domain.QuizOption, 0, len(lesson.Words))
	for _, word := range lesson.Words {
		options = append(options, domain.QuizOption{ID: word.ID, Text: word.Meaning})
	}
	questions := make([]domain.VocabularyQuestion, 0, len(lesson.Words))
	correct := make(map[string]string, len(lesson.Words))
	explanations := make(map[string]string, len(lesson.Words))
	for index, word := range lesson.Words {
		questionID := lesson.ID + "-q" + fmt.Sprint(index+1)
		rotated := append([]domain.QuizOption(nil), options...)
		shiftOptions(rotated, index)
		questions = append(questions, domain.VocabularyQuestion{
			ID: questionID, Prompt: fmt.Sprintf("Apa arti %s (%s)?", word.Term, word.Reading), Options: rotated,
		})
		correct[questionID] = word.ID
		explanations[questionID] = fmt.Sprintf("%s berarti %s. %s Contoh: %s — %s", word.Term, word.Meaning, word.Note, word.Example, word.ExampleMeaning)
	}
	if level.Level == "N5" {
		questions, correct, explanations = s.n5VocabularyQuestionsLocked(lesson)
	}
	id := fmt.Sprintf("vocab-attempt-%d", s.attemptID.Add(1))
	attempt := domain.VocabularyAttempt{
		ID: id, LessonID: lessonID, Questions: questions,
		ImageURL:  s.assetURLLocked("assets/images/vocabulary/quiz-mastery.webp"),
		StartedAt: time.Now().UTC(),
	}
	s.vocabAttempts[id] = &vocabularyAttemptState{
		attempt: attempt, userID: userID, correct: correct,
		explanations: explanations, answers: map[string]domain.VocabularyAnswerFeedback{},
	}
	return attempt, nil
}

func (s *MemoryStore) AssetURL(key string) string {
	s.mu.RLock()
	defer s.mu.RUnlock()
	return s.assetURLLocked(key)
}

func (s *MemoryStore) assetURLLocked(key string) string {
	if key == "" {
		return ""
	}
	key = strings.TrimLeft(key, "/")
	if strings.HasPrefix(key, "assets/images/") && strings.HasSuffix(key, ".png") {
		key = strings.TrimSuffix(key, ".png") + ".webp"
	}
	url := s.assetBaseURL + "/" + key
	if strings.HasPrefix(key, "assets/images/") {
		// Bump assetImageVersion whenever images are re-encoded under the same
		// file name, so app caches keyed by URL fetch the new file.
		url += "?v=" + assetImageVersion
	}
	return url
}

// assetImageVersion 2 = full-resolution images restored after the 2026-10-22
// compression (commit 177f67e) made them blurry.
const assetImageVersion = "2"

func (s *MemoryStore) AnswerVocabularyQuestion(userID, attemptID, questionID, optionID string) (domain.VocabularyAnswerFeedback, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	state, ok := s.vocabAttempts[attemptID]
	if !ok || state.userID != userID {
		return domain.VocabularyAnswerFeedback{}, ErrNotFound
	}
	correctOption, ok := state.correct[questionID]
	if !ok || strings.TrimSpace(optionID) == "" {
		return domain.VocabularyAnswerFeedback{}, ErrInvalid
	}
	validOption := false
	for _, question := range state.attempt.Questions {
		if question.ID != questionID {
			continue
		}
		for _, option := range question.Options {
			if option.ID == optionID {
				validOption = true
				break
			}
		}
	}
	if !validOption {
		return domain.VocabularyAnswerFeedback{}, ErrInvalid
	}
	if existing, answered := state.answers[questionID]; answered {
		return existing, nil
	}
	feedback := domain.VocabularyAnswerFeedback{
		QuestionID: questionID, Correct: optionID == correctOption,
		CorrectOptionID: correctOption, Explanation: state.explanations[questionID],
	}
	state.answers[questionID] = feedback
	return feedback, nil
}

func (s *MemoryStore) CompleteVocabularyAttempt(userID, attemptID string) (domain.VocabularyAttemptResult, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	state, ok := s.vocabAttempts[attemptID]
	if !ok || state.userID != userID {
		return domain.VocabularyAttemptResult{}, ErrNotFound
	}
	if state.result != nil {
		return *state.result, nil
	}
	if len(state.answers) != len(state.attempt.Questions) {
		return domain.VocabularyAttemptResult{}, ErrInvalid
	}
	correct := 0
	for _, feedback := range state.answers {
		if feedback.Correct {
			correct++
		}
	}
	score := correct * 100 / len(state.attempt.Questions)
	passed := score >= 80
	if s.progress[userID] == nil {
		s.progress[userID] = map[string]domain.LessonProgress{}
	}
	previous := s.progress[userID][state.attempt.LessonID]
	best := previous.Completion
	if score > best {
		best = score
	}
	progress := domain.LessonProgress{
		LessonID: state.attempt.LessonID, Completion: best,
		LastPosition: len(state.attempt.Questions) * 60,
		Completed:    previous.Completed || passed, UpdatedAt: time.Now().UTC(),
	}
	now := s.gamificationNow().UTC()
	progress.UpdatedAt = now
	gain, err := s.recordStudyLocked(userID, studyEvent{ID: "vocabulary:" + attemptID, Kind: "lesson", Subject: "vocabulary", LessonID: state.attempt.LessonID, Score: score, Answered: len(state.answers), Seconds: int(now.Sub(state.attempt.StartedAt).Seconds()), At: now, Progress: &progress})
	if err != nil {
		return domain.VocabularyAttemptResult{}, err
	}
	result := domain.VocabularyAttemptResult{
		AttemptID: attemptID, LessonID: state.attempt.LessonID, Score: score,
		Correct: correct, Total: len(state.attempt.Questions), Passed: passed,
		BestScore: best, Progress: s.vocabularyProgressLocked(userID), CanRetry: true,
		XP: &gain,
	}
	state.result = &result
	return result, nil
}

func (s *MemoryStore) vocabularyProgressLocked(userID string) int {
	total, lessons := 0, 0
	for _, level := range s.vocabulary {
		for _, lesson := range level.Lessons {
			total += s.progress[userID][lesson.ID].Completion
			lessons++
		}
	}
	if lessons == 0 {
		return 0
	}
	return total / lessons
}

func (s *MemoryStore) findVocabularyLessonLocked(lessonID string) (*domain.VocabularyLevelContent, *domain.VocabularyLessonContent) {
	for levelIndex := range s.vocabulary {
		for lessonIndex := range s.vocabulary[levelIndex].Lessons {
			lesson := &s.vocabulary[levelIndex].Lessons[lessonIndex]
			if lesson.ID == lessonID {
				return &s.vocabulary[levelIndex], lesson
			}
		}
	}
	return nil, nil
}

func shiftOptions(options []domain.QuizOption, shift int) {
	if len(options) == 0 {
		return
	}
	shift %= len(options)
	rotated := append(options[shift:], options[:shift]...)
	copy(options, rotated)
	sort.SliceStable(options, func(i, j int) bool { return (i+shift)%2 < (j+shift)%2 })
}

// vocabularySeed lets tests install fixture courses. Production ships no
// built-in vocabulary yet: the Japanese courses were removed and the
// Indonesian curriculum arrives in a later phase.
var vocabularySeed func() []domain.VocabularyLevelContent

func seedVocabulary() []domain.VocabularyLevelContent {
	if vocabularySeed != nil {
		return vocabularySeed()
	}
	return []domain.VocabularyLevelContent{}
}

func (s *MemoryStore) n5VocabularyQuestionsLocked(lesson *domain.VocabularyLessonContent) ([]domain.VocabularyQuestion, map[string]string, map[string]string) {
	questions := make([]domain.VocabularyQuestion, 0, len(lesson.Words)*3)
	correct, explanations := map[string]string{}, map[string]string{}
	for kind := 0; kind < 3; kind++ {
		for i, w := range lesson.Words {
			id := fmt.Sprintf("%s-q%d", lesson.ID, len(questions)+1)
			texts := []string{}
			for _, other := range lesson.Words {
				switch kind {
				case 0:
					texts = append(texts, other.Meaning)
				case 1:
					if w.Term == w.Reading {
						texts = append(texts, other.Term)
					} else {
						texts = append(texts, other.Reading)
					}
				case 2:
					texts = append(texts, other.Example)
				}
			}
			options := []domain.QuizOption{{ID: id + "-o1", Text: texts[i]}}
			seen := map[string]bool{texts[i]: true}
			for offset := 1; len(options) < 4 && offset < len(texts); offset++ {
				text := texts[(i+offset)%len(texts)]
				if !seen[text] {
					seen[text] = true
					options = append(options, domain.QuizOption{ID: fmt.Sprintf("%s-o%d", id, len(options)+1), Text: text})
				}
			}
			if len(options) != 4 {
				panic("insufficient vocabulary choices")
			}
			correct[id] = options[0].ID
			shiftOptions(options, (i+kind)%4)
			prompt, label := fmt.Sprintf("Apa arti %s?", w.Term), "Arti kata"
			switch kind {
			case 1:
				prompt = fmt.Sprintf("Bagaimana cara membaca %s?", w.Term)
				label = "Cara baca"
				if w.Term == w.Reading {
					prompt = fmt.Sprintf("Mana penulisan bahasa Jepang untuk “%s”?", w.Meaning)
					label = "Penulisan kata"
				}
			case 2:
				prompt = fmt.Sprintf("Kalimat mana yang berarti:\n“%s”", w.ExampleMeaning)
				label = "Pemakaian kalimat"
			}
			q := domain.VocabularyQuestion{ID: id, Prompt: prompt, Options: options, Kind: label}
			if kind == 0 {
				q.ImageAsset = w.ImageAsset
				q.ImageURL = s.assetURLLocked(w.ImageAsset)
				q.ImagePanel = w.ImagePanel
				q.ImageDescription = "Ilustrasi petunjuk konteks kosakata"
			}
			questions = append(questions, q)
			explanations[id] = fmt.Sprintf("%s（%s）berarti %s.\n%s\n%s\n%s", w.Term, w.Reading, w.Meaning, w.Example, w.Examples[0].Reading, w.ExampleMeaning)
		}
	}
	return questions, correct, explanations
}
