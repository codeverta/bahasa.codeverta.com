package api_test

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"reflect"
	"testing"

	"github.com/google/uuid"
	"bahasa-master-backend/internal/api"
	"bahasa-master-backend/internal/database"
	"bahasa-master-backend/internal/domain"
	"bahasa-master-backend/internal/store"
)

func offlinePracticeServer(memory *store.MemoryStore, verifier fakeGoogleVerifier) http.Handler {
	server := api.NewServer(memory, verifier)
	server.ConfigureOfflinePracticeSigningKey("unit-test-offline-practice-signing-key")
	return server.Handler()
}

func TestOfflinePracticePackageIsSignedAndSyncIsServerScoredIdempotently(t *testing.T) {
	memory := store.NewMemoryStore()
	server := offlinePracticeServer(memory, fakeGoogleVerifier{})
	token := login(t, server)
	packageResponse := requestOfflinePractice(t, server, http.MethodGet, "/v1/offline/practice/vocabulary/n4-plans", token, nil)
	if packageResponse.Code != http.StatusOK {
		t.Fatalf("expected signed package, got %d: %s", packageResponse.Code, packageResponse.Body.String())
	}
	var packagePayload struct {
		Data domain.OfflinePracticePackage `json:"data"`
	}
	if err := json.Unmarshal(packageResponse.Body.Bytes(), &packagePayload); err != nil {
		t.Fatal(err)
	}
	practice := packagePayload.Data
	if practice.Manifest.SchemaVersion != 1 || practice.Manifest.UserID == "" || practice.Manifest.Signature == "" || practice.Manifest.ContentHash == "" || len(practice.Questions) != 4 {
		t.Fatalf("invalid signed package: %#v", practice.Manifest)
	}
	input := domain.OfflinePracticeSyncInput{AttemptID: uuid.NewString(), Package: practice}
	for _, question := range practice.Questions {
		input.Answers = append(input.Answers, domain.OfflinePracticeAnswer{QuestionID: question.ID, OptionID: question.CorrectOptionID})
	}
	body, err := json.Marshal(input)
	if err != nil {
		t.Fatal(err)
	}
	firstResponse := requestOfflinePractice(t, server, http.MethodPost, "/v1/offline/practice-attempts/sync", token, body)
	if firstResponse.Code != http.StatusOK {
		t.Fatalf("expected verified result, got %d: %s", firstResponse.Code, firstResponse.Body.String())
	}
	var firstPayload struct {
		Data domain.OfflinePracticeResult `json:"data"`
	}
	if err := json.Unmarshal(firstResponse.Body.Bytes(), &firstPayload); err != nil {
		t.Fatal(err)
	}
	if !firstPayload.Data.Verified || !firstPayload.Data.Passed || firstPayload.Data.Score != 100 || firstPayload.Data.BestScore != 100 {
		t.Fatalf("server did not verify the answer set: %#v", firstPayload.Data)
	}

	secondResponse := requestOfflinePractice(t, server, http.MethodPost, "/v1/offline/practice-attempts/sync", token, body)
	var secondPayload struct {
		Data domain.OfflinePracticeResult `json:"data"`
	}
	if err := json.Unmarshal(secondResponse.Body.Bytes(), &secondPayload); err != nil || secondResponse.Code != http.StatusOK {
		t.Fatalf("duplicate sync failed: %s %v", secondResponse.Body.String(), err)
	}
	if !reflect.DeepEqual(firstPayload.Data, secondPayload.Data) || memory.Gamification(database.DemoUserID).XP != 50 {
		t.Fatalf("duplicate attempt changed its result or reward: first=%#v second=%#v xp=%d", firstPayload.Data, secondPayload.Data, memory.Gamification(database.DemoUserID).XP)
	}
}

func TestOfflinePracticeRejectsChangedPackageAndOtherAccount(t *testing.T) {
	memory := store.NewMemoryStore()
	server := offlinePracticeServer(memory, fakeGoogleVerifier{})
	ownerToken := login(t, server)
	packageResponse := requestOfflinePractice(t, server, http.MethodGet, "/v1/offline/practice/vocabulary/n4-plans", ownerToken, nil)
	var packagePayload struct {
		Data domain.OfflinePracticePackage `json:"data"`
	}
	if err := json.Unmarshal(packageResponse.Body.Bytes(), &packagePayload); err != nil || packageResponse.Code != http.StatusOK {
		t.Fatalf("could not fetch package: %s %v", packageResponse.Body.String(), err)
	}
	practice := packagePayload.Data
	input := domain.OfflinePracticeSyncInput{AttemptID: uuid.NewString(), Package: practice}
	for _, question := range practice.Questions {
		input.Answers = append(input.Answers, domain.OfflinePracticeAnswer{QuestionID: question.ID, OptionID: question.CorrectOptionID})
	}

	changed := input
	changed.Package.Questions = append([]domain.OfflinePracticeQuestion(nil), practice.Questions...)
	changed.Package.Questions[0].Explanation += " edited"
	changedBody, _ := json.Marshal(changed)
	if response := requestOfflinePractice(t, server, http.MethodPost, "/v1/offline/practice-attempts/sync", ownerToken, changedBody); response.Code != http.StatusUnprocessableEntity {
		t.Fatalf("changed signed content was accepted: %d %s", response.Code, response.Body.String())
	}

	other, err := memory.AuthenticateGoogle(domain.GoogleIdentity{Subject: "offline-other-account", Email: "offline-other@example.com", DisplayName: "Other"})
	if err != nil {
		t.Fatal(err)
	}
	otherToken, err := memory.CreateSession(other.ID)
	if err != nil {
		t.Fatal(err)
	}
	body, _ := json.Marshal(input)
	if response := requestOfflinePractice(t, server, http.MethodPost, "/v1/offline/practice-attempts/sync", otherToken, body); response.Code != http.StatusUnprocessableEntity {
		t.Fatalf("another account used a signed package: %d %s", response.Code, response.Body.String())
	}
	if memory.Gamification(other.ID).XP != 0 {
		t.Fatal("rejected cross-account package awarded XP")
	}
}

func TestOfflinePracticeRequiresAuthAndPremiumEntitlement(t *testing.T) {
	server := offlinePracticeServer(store.NewMemoryStore(), fakeGoogleVerifier{})
	unauthenticated := requestOfflinePractice(t, server, http.MethodGet, "/v1/offline/practice/vocabulary/n4-plans", "", nil)
	if unauthenticated.Code != http.StatusUnauthorized {
		t.Fatalf("expected authentication, got %d", unauthenticated.Code)
	}
	token := login(t, server)
	locked := requestOfflinePractice(t, server, http.MethodGet, "/v1/offline/practice/vocabulary/n3-work", token, nil)
	if locked.Code != http.StatusPaymentRequired {
		t.Fatalf("free account received premium offline bank: %d %s", locked.Code, locked.Body.String())
	}
}

func requestOfflinePractice(t *testing.T, server http.Handler, method, path, token string, body []byte) *httptest.ResponseRecorder {
	t.Helper()
	request := httptest.NewRequest(method, path, bytes.NewReader(body))
	if token != "" {
		request.Header.Set("Authorization", "Bearer "+token)
	}
	request.Header.Set("Content-Type", "application/json")
	response := httptest.NewRecorder()
	server.ServeHTTP(response, request)
	return response
}
