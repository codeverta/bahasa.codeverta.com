package store

import (
	"fmt"

	"bahasa-master-backend/internal/anki"
	"bahasa-master-backend/internal/domain"
)

// RegisterTestVocabulary installs a small Indonesian vocabulary fixture and
// the fixture Anki decks. The production build ships no built-in vocabulary yet,
// so tests (in this and other packages) call it before creating a store. IDs
// keep the old shape because the XP, unlock and offline tests only care about
// "a free lesson" and "a premium-level lesson": n5-daily and n4-plans are free,
// n3-work, n3-health and n3-travel are premium when open access is off. It must run before the first
// NewMemoryStore.
func RegisterTestVocabulary() {
	vocabularySeed = fixtureVocabulary
	anki.RegisterTestDecks()
}

func fixtureWord(id, term, reading, meaning, example, exampleMeaning string) domain.VocabularyWord {
	return domain.VocabularyWord{
		ID: id, Term: term, Reading: reading, Meaning: meaning,
		Example: example, ExampleMeaning: exampleMeaning, Note: "Fixture note.",
		Examples: []domain.VocabularyExample{{Japanese: example, Reading: reading, Meaning: exampleMeaning}},
	}
}

func fixtureLevel(level string, lessonIDs ...string) domain.VocabularyLevelContent {
	content := domain.VocabularyLevelContent{Level: level, Title: "Fixture " + level, Description: "Fixture level", RequiredTier: domain.TierFree}
	for order, lessonID := range lessonIDs {
		content.Lessons = append(content.Lessons, fixtureLesson(lessonID, order+1))
	}
	return content
}

func fixtureLesson(lessonID string, order int) domain.VocabularyLessonContent {
	words := make([]domain.VocabularyWord, 0, 4)
	items := [][5]string{
		{"terima kasih", "tuh-ri-muh ka-sih", "thank you", "Terima kasih banyak.", "Thank you very much."},
		{"selamat pagi", "suh-la-mat pa-gi", "good morning", "Selamat pagi, Bu.", "Good morning, ma'am."},
		{"air", "a-ir", "water", "Saya minum air.", "I drink water."},
		{"makan", "ma-kan", "eat", "Kami makan nasi.", "We eat rice."},
	}
	for i, item := range items {
		words = append(words, fixtureWord(fmt.Sprintf("%s-w%d", lessonID, i+1), item[0], item[1], item[2], item[3], item[4]))
	}
	return domain.VocabularyLessonContent{ID: lessonID, Order: order, Title: "Fixture lesson", Description: "Fixture", Words: words}
}

func fixtureVocabulary() []domain.VocabularyLevelContent {
	return []domain.VocabularyLevelContent{
		fixtureLevel("N5", "n5-daily"),
		fixtureLevel("N4", "n4-plans", "n4-travel"),
		fixtureLevel("N3", "n3-work", "n3-health", "n3-travel"),
	}
}
