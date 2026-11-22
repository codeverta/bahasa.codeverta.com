package store

import (
	"errors"
	"bahasa-master-backend/internal/database"
	"bahasa-master-backend/internal/testdb"
	"testing"
	"time"
)

func TestLearningHistoryOrderingIsolationValidationAndScores(t *testing.T) {
	s := NewMemoryStore()
	user := database.DemoUserID
	now := time.Now().UTC().Add(-time.Minute)
	id := "n4-plans"
	first, err := s.SaveLearningActivity(user, "vocabulary", id, 1, now)
	if err != nil || first.Position != 1 || first.Title != "Fixture lesson" {
		t.Fatal(first, err)
	}
	if _, err = s.SaveLearningActivity(user, "vocabulary", id, 0, now.Add(-time.Second)); err != nil {
		t.Fatal(err)
	}
	if items := s.LearningHistory(user); len(items) != 1 || items[0].Position != 1 {
		t.Fatal("stale write changed position", items)
	}
	if _, err = s.SaveLearningActivity(user, "vocabulary", "n5-daily", 0, now.Add(time.Second)); err != nil {
		t.Fatal(err)
	}
	if items := s.LearningHistory(user); len(items) != 2 || items[0].LessonID != "n5-daily" {
		t.Fatal(items)
	}
	if len(s.LearningHistory("other")) != 0 {
		t.Fatal("history leaked")
	}
	for _, tc := range []struct {
		kind, id string
		position int
		at       time.Time
		expected error
	}{
		{"vocabulary", id, -1, now, ErrInvalid},
		{"vocabulary", id, 4, now, ErrInvalid},
		{"vocabulary", id, 0, time.Now().Add(time.Hour), ErrInvalid},
		{"vocabulary", id, 0, time.Time{}, ErrInvalid},
		{"kamus", id, 0, now, ErrNotFound},
		{"vocabulary", "missing", 0, now, ErrNotFound},
	} {
		if _, err = s.SaveLearningActivity(user, tc.kind, tc.id, tc.position, tc.at); !errors.Is(err, tc.expected) {
			t.Fatal(tc, err)
		}
	}
	previous := SetOpenLearningAccess(false)
	if _, err = s.SaveLearningActivity(user, "vocabulary", "n3-work", 0, now); !errors.Is(err, ErrPremium) {
		SetOpenLearningAccess(previous)
		t.Fatal("premium bypass", err)
	}
	SetOpenLearningAccess(previous)
	if s.Gamification(user).XP != 0 || len(s.Progress(user)) != 0 {
		t.Fatal("navigation awarded progress or XP")
	}
	passStudyLesson(t, s, user, "vocabulary", id)
	if items := s.LearningHistory(user); !items[1].Completed {
		t.Fatal("completion was not derived from graded progress", items)
	}
	s.vocabulary = nil
	if items := s.LearningHistory(user); items[1].Available {
		t.Fatal("removed material was not flagged", items)
	}
}

func TestLearningHistoryMariaDBRestartAndDeletion(t *testing.T) {
	dsn := testdb.DSN(t)
	user := database.DemoUserID
	s := NewMemoryStore()
	if err := s.EnableGamificationPersistence(dsn); err != nil {
		t.Fatal(err)
	}
	id := "n4-plans"
	if _, err := s.SaveLearningActivity(user, "vocabulary", id, 1, time.Now().UTC()); err != nil {
		t.Fatal(err)
	}
	if err := s.Close(); err != nil {
		t.Fatal(err)
	}
	restored := NewMemoryStore()
	if err := restored.EnableGamificationPersistence(dsn); err != nil {
		t.Fatal(err)
	}
	defer restored.Close()
	if items := restored.LearningHistory(user); len(items) != 1 || items[0].Position != 1 {
		t.Fatal(items)
	}
	if err := restored.DeleteAccount(user); err != nil {
		t.Fatal(err)
	}
	if len(restored.LearningHistory(user)) != 0 {
		t.Fatal("deleted history retained")
	}
}
