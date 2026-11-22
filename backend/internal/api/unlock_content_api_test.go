package api_test

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"bahasa-master-backend/internal/anki"
)

// Phase 2 of docs/rewarded-unlock-spec.md: Anki decks.

func gatedAds(extra string) string {
	return `{"enabled":true,"unlockRewarded":{"enabled":true,"unitId":"` + unlockUnit + `"},"unlockDailyCap":20,"unlockFallbackPerDay":5` + extra + `}`
}

func (e *unlockEnv) fallback(t *testing.T, kind, item string) {
	t.Helper()
	data := e.data(t, e.do(http.MethodPost, "/v1/unlocks/fallback", `{"kind":"`+kind+`","itemId":"`+item+`"}`), http.StatusOK)
	if data["unlocked"] != true {
		t.Fatalf("fallback %s/%s = %v", kind, item, data)
	}
}

func (e *unlockEnv) unlockRef(t *testing.T, response *httptest.ResponseRecorder) map[string]any {
	t.Helper()
	body := e.errorBody(t, response, http.StatusPaymentRequired)
	if body["unlockable"] != true {
		t.Fatalf("no ad offered: %v", body)
	}
	ref, _ := body["unlock"].(map[string]any)
	return ref
}

func (e *unlockEnv) unlockKeys(t *testing.T) map[string]bool {
	t.Helper()
	list := e.data(t, e.do(http.MethodGet, "/v1/unlocks", ""), http.StatusOK)
	keys := map[string]bool{}
	for _, item := range list["items"].([]any) {
		keys[item.(string)] = true
	}
	return keys
}

func lockedAnkiDecks(t *testing.T) []string {
	t.Helper()
	decks, err := anki.List("", "")
	if err != nil {
		t.Fatal(err)
	}
	var ids []string
	for _, deck := range decks {
		if deck.Level == "N3" {
			ids = append(ids, deck.ID)
		}
	}
	if len(ids) < 2 {
		t.Skip("needs two built-in N3 decks")
	}
	return ids
}

func TestAnAdOpensOneAnkiDeck(t *testing.T) {
	e := newUnlockEnv(t, gatedAds(""))
	decks := lockedAnkiDecks(t)
	deck, other := decks[0], decks[1]
	study := "/v1/anki/decks/" + deck + "/study"

	if ref := e.unlockRef(t, e.do(http.MethodGet, study, "")); ref["kind"] != "anki" || ref["itemId"] != deck {
		t.Fatalf("unlock ref = %v", ref)
	}
	if view := e.data(t, e.do(http.MethodGet, "/v1/anki/decks/"+deck, ""), http.StatusOK); view["locked"] != true {
		t.Fatalf("deck view before unlock = %v", view["locked"])
	}

	e.fallback(t, "anki", deck)

	if response := e.do(http.MethodGet, study, ""); response.Code != http.StatusOK {
		t.Fatalf("study an unlocked deck: %d %s", response.Code, response.Body.String())
	}
	if view := e.data(t, e.do(http.MethodGet, "/v1/anki/decks/"+deck, ""), http.StatusOK); view["locked"] != false {
		t.Fatalf("deck view after unlock = %v", view["locked"])
	}
	if response := e.do(http.MethodPost, "/v1/anki/decks/"+deck+"/review", `{}`); response.Code == http.StatusPaymentRequired {
		t.Fatalf("review of an unlocked deck was refused: %s", response.Body.String())
	}
	if response := e.do(http.MethodGet, "/v1/anki/decks/"+other+"/study", ""); response.Code != http.StatusPaymentRequired {
		t.Fatalf("another N3 deck opened: %d", response.Code)
	}
}

func TestAnkiAdOfferFollowsItsSwitch(t *testing.T) {
	e := newUnlockEnv(t, gatedAds(`,"unlockKinds":{"lessons":true,"anki":false}`))
	deck := lockedAnkiDecks(t)[0]
	body := e.errorBody(t, e.do(http.MethodGet, "/v1/anki/decks/"+deck+"/study", ""), http.StatusPaymentRequired)
	if _, offered := body["unlockable"]; offered {
		t.Fatalf("an ad was offered while Anki unlocks are switched off: %v", body)
	}
	if body := e.errorBody(t, e.do(http.MethodPost, "/v1/unlocks/intents", `{"kind":"anki","itemId":"`+deck+`"}`), http.StatusForbidden); body["code"] != "unlock_unavailable" {
		t.Fatalf("intent = %v", body)
	}
}

// watchAdFor runs the verified ad flow for any kind of item.
func (e *unlockEnv) watchAdFor(t *testing.T, kind, item, transaction string) map[string]any {
	t.Helper()
	intent := e.data(t, e.do(http.MethodPost, "/v1/unlocks/intents", `{"kind":"`+kind+`","itemId":"`+item+`"}`), http.StatusOK)
	nonce, _ := intent["nonce"].(string)
	if nonce == "" {
		t.Fatalf("intent = %v", intent)
	}
	if response := e.callback(e.userID, nonce, transaction); response.Code != http.StatusOK {
		t.Fatalf("callback %d", response.Code)
	}
	return e.data(t, e.do(http.MethodPost, "/v1/unlocks/claim", `{"nonce":"`+nonce+`"}`), http.StatusOK)
}
