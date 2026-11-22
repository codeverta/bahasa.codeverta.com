package store

import "testing"

func TestOpenLearningAccessUnlocksStudyForFreeAccounts(t *testing.T) {
	previous := SetOpenLearningAccess(true)
	t.Cleanup(func() { SetOpenLearningAccess(previous) })
	s := NewMemoryStore()
	if PremiumLevel("N3") || PremiumLevel("N1") {
		t.Fatal("N3-N1 lessons should be open")
	}
	if s.PremiumRequest("/v1/grammar/course", "N3", "", "") || s.PremiumRequest("/v1/vocabulary/lessons/n3-work", "N3", "n3-work", "") {
		t.Fatal("PremiumRequest should be false in open mode")
	}
}

func TestOpenLearningAccessCanBeSwitchedOff(t *testing.T) {
	previous := SetOpenLearningAccess(false)
	t.Cleanup(func() { SetOpenLearningAccess(previous) })
	s := NewMemoryStore()
	if !PremiumLevel("N3") {
		t.Fatal("gate should return when open access is off")
	}
	if !s.PremiumRequest("/v1/vocabulary/lessons/n3-work", "N3", "n3-work", "") {
		t.Fatal("premium-level lesson should be gated when open access is off")
	}
}
