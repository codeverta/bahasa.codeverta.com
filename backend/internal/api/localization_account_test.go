package api

import (
	"encoding/json"
	"strings"
	"testing"

	"bahasa-master-backend/internal/store"
)

func decodeAccountPayload(t *testing.T, raw string) any {
	t.Helper()
	decoder := json.NewDecoder(strings.NewReader(raw))
	decoder.UseNumber()
	var payload any
	if err := decoder.Decode(&payload); err != nil {
		t.Fatalf("decode %q: %v", raw, err)
	}
	return payload
}

func marshalAccountPayload(t *testing.T, payload any) string {
	t.Helper()
	raw, err := json.Marshal(payload)
	if err != nil {
		t.Fatal(err)
	}
	return string(raw)
}

func normalizeAccountJSON(t *testing.T, raw string) string {
	t.Helper()
	return marshalAccountPayload(t, decodeAccountPayload(t, raw))
}

// encodeAccountValue returns value as the middleware would see it: marshalled
// to JSON and decoded with UseNumber.
func encodeAccountValue(t *testing.T, value any) any {
	t.Helper()
	return decodeAccountPayload(t, marshalAccountPayload(t, value))
}

func TestTranslateAccountPayloadCases(t *testing.T) {
	tests := []struct {
		name    string
		path    string
		input   string
		want    string
		changed bool
	}{
		{
			name: "gamification achievements by id",
			path: "/v1/me/gamification",
			input: `{"data":{"xp":120,"level":1,"timezone":"Asia/Tokyo","achievements":[
				{"id":"first-lesson","name":"First Step","description":"Lulus satu kuis lesson dengan nilai minimal 80%","icon":"footprints","progress":1,"target":1,"unlockedAt":"2026-01-02T03:04:05Z"},
				{"id":"lessons-10","name":"Pelajar Tekun","description":"Lulus 10 lesson berbeda","icon":"book","progress":2,"target":10},
				{"id":"custom","name":"Pelajar Tekun","description":"Lulus 10 lesson berbeda","icon":"book","progress":2,"target":10}]}}`,
			want: `{"data":{"xp":120,"level":1,"timezone":"Asia/Tokyo","achievements":[
				{"id":"first-lesson","name":"First Step","description":"Pass one lesson quiz with a score of at least 80%.","icon":"footprints","progress":1,"target":1,"unlockedAt":"2026-01-02T03:04:05Z"},
				{"id":"lessons-10","name":"Dedicated Learner","description":"Pass 10 different lessons.","icon":"book","progress":2,"target":10},
				{"id":"custom","name":"Pelajar Tekun","description":"Lulus 10 lesson berbeda","icon":"book","progress":2,"target":10}]}}`,
			changed: true,
		},
		{
			name:    "achievements array",
			path:    "/v1/me/achievements",
			input:   `{"data":[{"id":"streak-7","name":"7-Day Streak","description":"Selesaikan kuis atau ujian selama 7 hari berturut-turut","icon":"flame","progress":3,"target":7},{"id":"all-subjects","name":"Serba Bisa","description":"Lulus lesson di keempat bidang","icon":"star","progress":1,"target":4}]}`,
			want:    `{"data":[{"id":"streak-7","name":"7-Day Streak","description":"Complete a quiz or exam for 7 consecutive days.","icon":"flame","progress":3,"target":7},{"id":"all-subjects","name":"All-Rounder","description":"Pass lessons in all four subjects.","icon":"star","progress":1,"target":4}]}`,
			changed: true,
		},
		{
			name:    "profile keeps user-entered values",
			path:    "/v1/me/profile",
			input:   `{"data":{"id":"u1","displayName":"Pelajar Tekun","email":"a@example.com","target":"JLPT N5","level":1,"xp":10,"streakDays":2,"entitlement":{"tier":"free","isLifetime":false}}}`,
			want:    `{"data":{"id":"u1","displayName":"Pelajar Tekun","email":"a@example.com","target":"JLPT N5","level":1,"xp":10,"streakDays":2,"entitlement":{"tier":"free","isLifetime":false}}}`,
			changed: false,
		},
		{
			name:    "progress is unchanged",
			path:    "/v1/me/progress/vocabulary-n5-1",
			input:   `{"data":{"lessonId":"vocabulary-n5-1","completion":100,"lastPosition":3,"completed":true,"updatedAt":"2026-01-02T03:04:05Z"}}`,
			want:    `{"data":{"lessonId":"vocabulary-n5-1","completion":100,"lastPosition":3,"completed":true,"updatedAt":"2026-01-02T03:04:05Z"}}`,
			changed: false,
		},
		{
			name:    "plans features",
			path:    "/v1/plans",
			input:   `{"data":[{"id":"free","name":"Free","billingType":"free","priceIdr":0,"features":["JLPT N5–N4 dasar","Daily practice","Progress dasar","Fitur baru yang belum dikenal"],"recommended":false},{"id":"premium-lifetime","name":"Lifetime Access","billingType":"lifetime","priceIdr":99000,"features":["Materi N3–N1 yang tersedia","Seluruh tes yang tersedia","Restore pembelian","Sekali bayar tanpa perpanjangan"],"recommended":true}]}`,
			want:    `{"data":[{"id":"free","name":"Free","billingType":"free","priceIdr":0,"features":["Basic JLPT N5–N4","Daily practice","Basic progress","Fitur baru yang belum dikenal"],"recommended":false},{"id":"premium-lifetime","name":"Lifetime Access","billingType":"lifetime","priceIdr":99000,"features":["Available N3–N1 materials","All available tests","Restore purchases","One-time payment with no renewal"],"recommended":true}]}`,
			changed: true,
		},
		{
			name:    "billing status is unchanged",
			path:    "/v1/billing",
			input:   `{"data":{"productId":"bahasa_master_lifetime","accountToken":"token","priceIdr":99000,"billingType":"lifetime","platforms":["android","ios"],"entitlement":{"tier":"premium","isLifetime":true}}}`,
			want:    `{"data":{"productId":"bahasa_master_lifetime","accountToken":"token","priceIdr":99000,"billingType":"lifetime","platforms":["android","ios"],"entitlement":{"tier":"premium","isLifetime":true}}}`,
			changed: false,
		},
		{
			name:    "pricing is unchanged",
			path:    "/v1/pricing",
			input:   `{"data":{"lifetimePriceIdr":99000}}`,
			want:    `{"data":{"lifetimePriceIdr":99000}}`,
			changed: false,
		},
		{
			name:    "auth session is unchanged",
			path:    "/v1/auth/login",
			input:   `{"data":{"token":"abc","user":{"id":"u1","displayName":"Budi","target":"JLPT N5","entitlement":{"tier":"free","isLifetime":false}}}}`,
			want:    `{"data":{"token":"abc","user":{"id":"u1","displayName":"Budi","target":"JLPT N5","entitlement":{"tier":"free","isLifetime":false}}}}`,
			changed: false,
		},
		{
			name:    "app update policy is unchanged",
			path:    "/v1/app-update-policy",
			input:   `{"data":{"android":{"enabled":true,"latestBuild":2,"message":"Perbarui aplikasi sekarang."}}}`,
			want:    `{"data":{"android":{"enabled":true,"latestBuild":2,"message":"Perbarui aplikasi sekarang."}}}`,
			changed: false,
		},
		{
			name:    "anki credits",
			path:    "/v1/anki/credits",
			input:   `{"data":{"repository":"https://github.com/mistval/kotoba","revision":"r1","license":"MIT","notice":"Data dan arti mengikuti sumber Kotoba. Sebagian deck memuat atribusi sumber pihak ketiga pada detailnya. Tautan media eksternal tetap mengikuti ketersediaan penyedianya."}}`,
			want:    `{"data":{"repository":"https://github.com/mistval/kotoba","revision":"r1","license":"MIT","notice":"Data and meanings follow the Kotoba source. Some decks include third-party source attribution in their details. External media links remain subject to their providers' availability."}}`,
			changed: true,
		},
		{
			name:    "anki study session",
			path:    "/v1/anki/decks/words-nature/study",
			input:   `{"data":{"title":"Alam","level":"","requiredTier":"free","instructions":"Susun huruf menjadi kata.","deckId":"words-nature","cards":[{"index":0,"front":"Alam","answers":["自然"],"meaning":"Alam","version":1,"intervals":{"again":"1 menit","hard":"±2 jam","good":"1 hari","easy":"4 hari"}}],"stats":{"seen":0,"due":0,"new":1}}}`,
			want:    `{"data":{"title":"Alam","level":"","requiredTier":"free","instructions":"Susun huruf menjadi kata.","deckId":"words-nature","cards":[{"index":0,"front":"Alam","answers":["自然"],"meaning":"Alam","version":1,"intervals":{"again":"1 min","hard":"±2 hr","good":"1 day","easy":"4 days"}}],"stats":{"seen":0,"due":0,"new":1}}}`,
			changed: true,
		},
		{
			name:    "personal anki study session keeps the user title",
			path:    "/v1/anki/decks/user-abc/study",
			input:   `{"data":{"title":"Alam","instructions":"Ingat jawaban sebelum membalik kartu; cocokkan dengan semua jawaban yang tersedia.","deckId":"user-abc","cards":[]}}`,
			want:    `{"data":{"title":"Alam","instructions":"Recall the answer before flipping the card; compare it with all available answers.","deckId":"user-abc","cards":[]}}`,
			changed: true,
		},
		{
			name:    "branding default tagline",
			path:    "/v1/branding",
			input:   `{"data":{"appName":"Bahasa Master","tagline":"Selangkah lebih dekat dengan Jepang","iconUrl":"","splashUrl":"","backgroundColor":"#FAFAFA"}}`,
			want:    `{"data":{"appName":"Bahasa Master","tagline":"One step closer to Japan","iconUrl":"","splashUrl":"","backgroundColor":"#FAFAFA"}}`,
			changed: true,
		},
		{
			name:    "branding custom tagline",
			path:    "/v1/branding",
			input:   `{"data":{"appName":"Selangkah","tagline":"Belajar setiap hari","backgroundColor":"#FAFAFA"}}`,
			want:    `{"data":{"appName":"Selangkah","tagline":"Belajar setiap hari","backgroundColor":"#FAFAFA"}}`,
			changed: false,
		},
		{
			name:    "paths outside the account groups",
			path:    "/v1/meow",
			input:   `{"data":{"achievements":[{"id":"first-lesson","name":"First Step","description":"Lulus satu kuis lesson dengan nilai minimal 80%"}]}}`,
			want:    `{"data":{"achievements":[{"id":"first-lesson","name":"First Step","description":"Lulus satu kuis lesson dengan nilai minimal 80%"}]}}`,
			changed: false,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			payload := decodeAccountPayload(t, tt.input)
			if changed := translateAccountPayload(tt.path, payload); changed != tt.changed {
				t.Fatalf("changed = %v, want %v", changed, tt.changed)
			}
			if got, want := marshalAccountPayload(t, payload), normalizeAccountJSON(t, tt.want); got != want {
				t.Fatalf("payload mismatch\n got: %s\nwant: %s", got, want)
			}
			// A second pass must be a no-op.
			if translateAccountPayload(tt.path, payload) {
				t.Fatalf("second translation pass reported a change")
			}
		})
	}
}

func TestTranslateAccountPayloadPreservesNumbers(t *testing.T) {
	payload := decodeAccountPayload(t, `{"data":[{"id":"xp-500","name":"Level Up","description":"Kumpulkan 500 XP","progress":120,"target":500}]}`)
	if !translateAccountPayload("/v1/me/achievements", payload) {
		t.Fatal("expected a change")
	}
	item := payload.(map[string]any)["data"].([]any)[0].(map[string]any)
	if number, ok := item["progress"].(json.Number); !ok || number.String() != "120" {
		t.Fatalf("progress = %#v, want json.Number 120", item["progress"])
	}
	if item["description"] != "Earn 500 XP." {
		t.Fatalf("description = %#v", item["description"])
	}
}

func TestTranslateAccountPayloadNeverPanicsOnUnexpectedShapes(t *testing.T) {
	newPayloads := func() []any {
		var deep any = "leaf"
		for i := 0; i < 100; i++ {
			deep = []any{deep}
		}
		return []any{
			nil, "text", json.Number("5"), true, []any{}, map[string]any{}, deep,
			[]any{nil, 3, "x", []any{map[string]any{"id": 5, "name": 7, "description": nil}}},
			map[string]any{
				"features": "x", "intervals": []any{1}, "categories": "x", "id": nil, "kind": 5, "title": 9,
				"personal": "yes", "sourceName": 3, "mode": 4, "name": 5, "tagline": 1, "notice": nil,
				"items": []any{nil}, "scope": 1, "reason": 2, "instructions": 3, "description": []any{},
				"sectors":    []any{nil, map[string]any{"id": 1}, map[string]any{"id": "railway", "label": 3}},
				"intervals2": map[string]any{"again": 1},
			},
			map[string]any{"intervals": map[string]any{"again": 1, "hard": nil, "good": []any{}}, "features": []any{1, nil, map[string]any{}}},
			map[string]any{"id": "first-lesson", "name": 1, "description": 2},
			map[string]any{"kind": "grammar", "title": 5, "lessonId": 7},
			map[string]any{"kind": "kanji", "title": "x", "lessonId": "kanji"},
			map[string]any{"kind": "kanji", "title": "x", "lessonId": "kanji-n-"},
		}
	}
	paths := []string{
		"", "/", "/v1", "/v1/me", "/v1/me/gamification", "/v1/me/achievements", "/v1/me/learning-history",
		"/v1/me/learning-history/kanji/kanji-n3-01", "/v1/plans", "/v1/pricing", "/v1/billing", "/v1/jobs",
		"/v1/jobs/meta", "/v1/jobs/sources", "/v1/anki/decks", "/v1/anki/credits", "/v1/branding",
		"/v1/auth/login", "/v1/manga", "/v1/app-update-policy",
	}
	for _, path := range paths {
		for index, payload := range newPayloads() {
			func() {
				defer func() {
					if recovered := recover(); recovered != nil {
						t.Fatalf("path %q payload %d panicked: %v", path, index, recovered)
					}
				}()
				if translateAccountPayload(path, payload) {
					t.Fatalf("path %q payload %d: unexpected change", path, index)
				}
			}()
		}
	}
}

func TestEveryStoreAchievementHasEnglishText(t *testing.T) {
	items := store.NewMemoryStore().Achievements("account-localization-test")
	if len(items) == 0 {
		t.Fatal("store returned no achievements")
	}
	seen := map[string]bool{}
	for _, item := range items {
		seen[item.ID] = true
		if _, ok := accountAchievementEnglish[item.ID]; !ok {
			t.Errorf("achievement %q has no English translation", item.ID)
		}
	}
	for id := range accountAchievementEnglish {
		if !seen[id] {
			t.Errorf("translation table has stale achievement id %q", id)
		}
	}

	payload := encodeAccountValue(t, map[string]any{"data": items})
	if !translateAccountPayload("/v1/me/achievements", payload) {
		t.Fatal("expected a change")
	}
	translated := payload.(map[string]any)["data"].([]any)
	if len(translated) != len(items) {
		t.Fatalf("translated %d achievements, want %d", len(translated), len(items))
	}
	for index, raw := range translated {
		item := raw.(map[string]any)
		want := accountAchievementEnglish[items[index].ID]
		if item["name"] != want.Name || item["description"] != want.Description {
			t.Errorf("achievement %q = %q / %q, want %q / %q", items[index].ID, item["name"], item["description"], want.Name, want.Description)
		}
		if item["description"] == items[index].Description {
			t.Errorf("achievement %q description was not translated", items[index].ID)
		}
		if item["id"] != items[index].ID || item["icon"] != items[index].Icon {
			t.Errorf("achievement %q lost its id or icon", items[index].ID)
		}
	}
}

func TestEverySeededPlanFeatureHasEnglishText(t *testing.T) {
	plans := store.NewMemoryStore().Plans()
	if len(plans) == 0 {
		t.Fatal("store returned no plans")
	}
	for _, plan := range plans {
		for _, feature := range plan.Features {
			if _, ok := accountPlanFeatureEnglish[feature]; !ok {
				t.Errorf("plan %q feature %q has no English translation", plan.ID, feature)
			}
		}
	}
	payload := encodeAccountValue(t, map[string]any{"data": plans})
	translateAccountPayload("/v1/plans", payload)
	for index, raw := range payload.(map[string]any)["data"].([]any) {
		plan := raw.(map[string]any)
		if plan["id"] != plans[index].ID || plan["name"] != plans[index].Name || plan["billingType"] != plans[index].BillingType {
			t.Errorf("plan %q identity fields changed", plans[index].ID)
		}
		for featureIndex, feature := range plan["features"].([]any) {
			if feature != accountPlanFeatureEnglish[plans[index].Features[featureIndex]] {
				t.Errorf("plan %q feature %d = %q", plans[index].ID, featureIndex, feature)
			}
		}
	}
}

func TestTranslateAnkiInterval(t *testing.T) {
	tests := []struct {
		input   string
		want    string
		changed bool
	}{
		{"1 menit", "1 min", true},
		{"15 menit", "15 min", true},
		{"±3 jam", "±3 hr", true},
		{"1 hari", "1 day", true},
		{"12 hari", "12 days", true},
		{"hari", "hari", false},
		{"x hari", "x hari", false},
		{"±jam", "±jam", false},
		{"3 hari lagi", "3 hari lagi", false},
		{"", "", false},
		{"10 days", "10 days", false},
	}
	for _, tt := range tests {
		got, changed := translateAnkiInterval(tt.input)
		if got != tt.want || changed != tt.changed {
			t.Errorf("translateAnkiInterval(%q) = %q, %v; want %q, %v", tt.input, got, changed, tt.want, tt.changed)
		}
	}
}
