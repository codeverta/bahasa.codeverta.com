package api_test

import (
	"net/http/httptest"
	"strings"
	"testing"
)

func TestGamificationAPIAuthenticatesAndIgnoresForgedProgress(t *testing.T) {
	server := newServer()
	for _, path := range []string{"/v1/me/gamification", "/v1/me/achievements"} {
		w := httptest.NewRecorder()
		server.ServeHTTP(w, httptest.NewRequest("GET", path, nil))
		if w.Code != 401 {
			t.Fatal("unauthenticated gamification access")
		}
	}
	token := login(t, server)
	request := func(method, path, body string) *httptest.ResponseRecorder {
		r := httptest.NewRequest(method, path, strings.NewReader(body))
		r.Header.Set("Authorization", "Bearer "+token)
		w := httptest.NewRecorder()
		server.ServeHTTP(w, r)
		return w
	}
	w := request("GET", "/v1/me/gamification", "")
	if w.Code != 200 || !strings.Contains(w.Body.String(), `"xp":0`) || !strings.Contains(w.Body.String(), `"timezone":"Asia/Jakarta"`) || strings.Contains(w.Body.String(), "unlockedAt") {
		t.Fatal("new account must not show dummy rewards", w.Body.String())
	}
	// Manual legacy completion must never grant XP or badges.
	request("PUT", "/v1/me/progress/fake-lesson", `{"completion":100,"lastPosition":9999}`)
	if w = request("GET", "/v1/me/gamification", ""); !strings.Contains(w.Body.String(), `"lessonsCompleted":0`) {
		t.Fatal("forged progress granted achievement")
	}
	if w = request("GET", "/v1/home", ""); !strings.Contains(w.Body.String(), `"streakDays":0`) {
		t.Fatal("dashboard streak")
	}
}
