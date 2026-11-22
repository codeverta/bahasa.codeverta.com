package anki

import "testing"

// Runs before any test registers fixture decks.
func TestEmptyDefaultCatalog(t *testing.T) {
	if decks, err := List("", ""); err != nil || len(decks) != 0 {
		t.Fatalf("expected empty default deck set, got %d (%v)", len(decks), err)
	}
	if _, err := Get("missing"); err != ErrNotFound {
		t.Fatalf("expected ErrNotFound, got %v", err)
	}
	if _, err := ReadCard("missing", 0); err != ErrNotFound {
		t.Fatalf("expected ErrNotFound, got %v", err)
	}
	if Revision() == "" {
		t.Fatal("missing revision")
	}
}

func TestRegisterAddsAReadableDeck(t *testing.T) {
	RegisterTestDecks()
	RegisterTestDecks()
	deck, err := Get("n5")
	if err != nil || deck.CardCount != 40 || !deck.Available {
		t.Fatalf("fixture deck = %+v, %v", deck, err)
	}
	card, err := ReadCard("n5", 39)
	if err != nil || card.Front != "kata 40" {
		t.Fatalf("card = %+v, %v", card, err)
	}
	if _, err = ReadCard("n5", 40); err != ErrNotFound {
		t.Fatalf("out of range read: %v", err)
	}
	if err = Register(Deck{ID: "n5"}, []Card{{Front: "x", Answers: []string{"y"}}}); err == nil {
		t.Fatal("duplicate deck accepted")
	}
}
