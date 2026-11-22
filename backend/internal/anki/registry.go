package anki

import "fmt"

// registered holds decks added with Register. They live in memory next to the
// embedded catalog, so the deck, review and import/export mechanism can be
// exercised while the default deck set is empty. Register is meant to run at
// start-up (or from a test init), before the catalog is read concurrently.
var registered = map[string][]Card{}

// Register adds an in-memory deck. The card count, chunk size and
// availability are derived from cards.
func Register(deck Deck, cards []Card) error {
	if deck.ID == "" || len(cards) == 0 {
		return fmt.Errorf("anki: deck needs an ID and at least one card")
	}
	if err := load(); err != nil {
		return err
	}
	for _, existing := range catalog.Decks {
		if existing.ID == deck.ID {
			return fmt.Errorf("anki: deck %q already exists", deck.ID)
		}
	}
	for i := range cards {
		cards[i].Index, cards[i].SourceIndex = i, i
	}
	deck.CardCount, deck.SourceCount, deck.ChunkSize, deck.Available = len(cards), len(cards), len(cards), true
	if deck.Description == "" {
		deck.Description = deck.Title
	}
	if deck.Instructions == "" {
		deck.Instructions = "Recall the answer before flipping the card."
	}
	registered[deck.ID] = cards
	catalog.Decks = append(catalog.Decks, deck)
	return nil
}

// RegisterTestDecks installs small Indonesian decks for tests in packages
// that exercise the deck mechanism: "wakayama" (120 cards), "n5" (free level)
// "n3" and "n3-extra" (a level that is premium when open access is off). It is safe to
// call more than once.
func RegisterTestDecks() {
	for _, fixture := range []struct {
		id, level string
		cards     int
	}{{"wakayama", "", 120}, {"n5", "N5", 40}, {"n3", "N3", 30}, {"n3-extra", "N3", 30}} {
		if _, err := Get(fixture.id); err == nil {
			continue
		}
		cards := make([]Card, fixture.cards)
		for i := range cards {
			cards[i] = Card{Front: fmt.Sprintf("kata %d", i+1), Answers: []string{fmt.Sprintf("word %d", i+1)}}
		}
		if err := Register(Deck{ID: fixture.id, Title: "Fixture " + fixture.id, Category: "fixture", Level: fixture.level}, cards); err != nil {
			panic(err)
		}
	}
}
