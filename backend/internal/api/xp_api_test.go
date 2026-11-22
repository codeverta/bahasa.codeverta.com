package api_test

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestRepeatXPCapIsValidatedAndKept(t *testing.T) {
	e := newUnlockEnv(t, `{"enabled":true,"xpRepeatDailyCap":40}`)
	save := func(body string) int {
		request := httptest.NewRequest(http.MethodPut, "/v1/admin/ads-config", strings.NewReader(body))
		request.Header.Set("Authorization", "Bearer ads-token")
		response := httptest.NewRecorder()
		e.handler.ServeHTTP(response, request)
		return response.Code
	}
	base := `"enabled":true,"banner":{"enabled":false,"unitId":""},"aiChatRewarded":{"enabled":false,"unitId":""}`
	if code := save(`{` + base + `,"xpRepeatDailyCap":5}`); code != http.StatusUnprocessableEntity {
		t.Fatalf("cap of 5: %d", code)
	}
	if code := save(`{` + base + `}`); code != http.StatusOK {
		t.Fatalf("save without the cap: %d", code)
	}
	public := httptest.NewRecorder()
	e.handler.ServeHTTP(public, httptest.NewRequest(http.MethodGet, "/v1/ads-config", nil))
	if !strings.Contains(public.Body.String(), `"xpRepeatDailyCap":40`) {
		t.Fatalf("an older dashboard must not reset the cap: %s", public.Body.String())
	}
}
