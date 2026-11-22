package api_test

import (
	"net/http"
	"net/url"
	"strconv"
	"testing"
)

// Double XP over HTTP (docs/ads-xp-spec.md, phase C). A graded vocabulary
// quiz is used as the completion.

// finishLesson passes one quiz of an N4 fixture lesson and returns the
// completion ID of its XP. Question i of the lesson is about word i, and the
// option ID of a word is the word's ID.
func (e *unlockEnv) finishLesson(t *testing.T, lesson string) string {
	t.Helper()
	attempt := e.data(t, e.do(http.MethodPost, "/v1/vocabulary/lessons/"+lesson+"/attempts", "{}"), http.StatusCreated)
	attemptID, _ := attempt["id"].(string)
	questions, _ := attempt["questions"].([]any)
	if attemptID == "" || len(questions) == 0 {
		t.Fatalf("attempt = %v", attempt)
	}
	for i, raw := range questions {
		questionID, _ := raw.(map[string]any)["id"].(string)
		body := `{"questionId":"` + questionID + `","optionId":"` + lesson + `-w` + strconv.Itoa(i+1) + `"}`
		e.data(t, e.do(http.MethodPost, "/v1/vocabulary/attempts/"+attemptID+"/answers", body), http.StatusOK)
	}
	data := e.data(t, e.do(http.MethodPost, "/v1/vocabulary/attempts/"+attemptID+"/complete", "{}"), http.StatusOK)
	id, _ := data["xp"].(map[string]any)["completionId"].(string)
	if id == "" {
		t.Fatalf("no completion id: %v", data)
	}
	return id
}

func boostItem(completionID string) string {
	return `{"kind":"xp-boost","itemId":"` + completionID + `"}`
}

func TestWatchingAnAdDoublesTheXPOfOneActivity(t *testing.T) {
	e := newUnlockEnv(t, "")
	completion := e.finishLesson(t, "n4-plans")

	claimed := e.watchAdFor(t, "xp-boost", completion, "tx-boost")
	xp, _ := claimed["xp"].(map[string]any)
	if claimed["unlocked"] != true || xp["awarded"] != float64(50) || xp["total"] != float64(100) {
		t.Fatalf("claim = %v", claimed)
	}
	if body := e.errorBody(t, e.do(http.MethodPost, "/v1/unlocks/intents", boostItem(completion)), http.StatusConflict); body["code"] != "boost_used" {
		t.Fatalf("second intent = %v", body)
	}
	// Double XP is not an unlock and does not use the unlock limit.
	list := e.data(t, e.do(http.MethodGet, "/v1/unlocks", ""), http.StatusOK)
	if items, _ := list["items"].([]any); len(items) != 0 || list["remaining"] != float64(20) {
		t.Fatalf("unlock list = %v", list)
	}
}

func TestDoubleXPHasNoFallbackAndNeedsTheSwitch(t *testing.T) {
	e := newUnlockEnv(t, "")
	completion := e.finishLesson(t, "n4-plans")
	if body := e.errorBody(t, e.do(http.MethodPost, "/v1/unlocks/fallback", boostItem(completion)), http.StatusForbidden); body["code"] != "boost_no_fallback" {
		t.Fatalf("fallback = %v", body)
	}
	if body := e.errorBody(t, e.do(http.MethodPost, "/v1/unlocks/intents", boostItem("vocabulary:never")), http.StatusUnprocessableEntity); body["code"] != "not_locked" {
		t.Fatalf("unknown completion = %v", body)
	}

	off := newUnlockEnv(t, `{"enabled":true,"xpBoostKinds":{"lessons":false,"exams":true,"practice":true}}`)
	offCompletion := off.finishLesson(t, "n4-plans")
	if body := off.errorBody(t, off.do(http.MethodPost, "/v1/unlocks/intents", boostItem(offCompletion)), http.StatusForbidden); body["code"] != "unlock_unavailable" {
		t.Fatalf("switched off = %v", body)
	}
}

func TestLifetimeClaimsDoubleXPWithoutAnAd(t *testing.T) {
	e := newUnlockEnv(t, "")
	completion := e.finishLesson(t, "n4-plans")
	path := "/v1/xp-boosts/" + url.PathEscape(completion) + "/free"
	if body := e.errorBody(t, e.do(http.MethodPost, path, ""), http.StatusPaymentRequired); body["code"] != "premium_required" {
		t.Fatalf("free claim without Lifetime = %v", body)
	}
	e.makeLifetime(t)
	data := e.data(t, e.do(http.MethodPost, path, ""), http.StatusOK)
	if data["xp"].(map[string]any)["awarded"] != float64(50) {
		t.Fatalf("free claim = %v", data)
	}
	if body := e.errorBody(t, e.do(http.MethodPost, path, ""), http.StatusConflict); body["code"] != "boost_used" {
		t.Fatalf("second free claim = %v", body)
	}
}

func TestDoubleXPDailyLimit(t *testing.T) {
	e := newUnlockEnv(t, `{"enabled":true,"xpBoostDailyCap":1}`)
	e.makeLifetime(t)
	first := e.finishLesson(t, "n4-plans")
	second := e.finishLesson(t, "n4-plans")
	e.data(t, e.do(http.MethodPost, "/v1/xp-boosts/"+url.PathEscape(first)+"/free", ""), http.StatusOK)
	if body := e.errorBody(t, e.do(http.MethodPost, "/v1/xp-boosts/"+url.PathEscape(second)+"/free", ""), http.StatusTooManyRequests); body["code"] != "boost_limit" {
		t.Fatalf("over the limit = %v", body)
	}
}
