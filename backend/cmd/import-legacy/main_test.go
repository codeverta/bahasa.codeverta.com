package main

import (
	"bytes"
	"database/sql"
	"encoding/json"
	"os"
	"path/filepath"
	"testing"

	"bahasa-master-backend/internal/database"
	"bahasa-master-backend/internal/store"
	"bahasa-master-backend/internal/testdb"
)

func TestLegacyImportPreservesBlobsAndRejectsOverwrite(t *testing.T) {
	dsn := testdb.DSN(t)
	state := []byte(`{"XP":50,"Events":{},"Rewards":{},"Lessons":{},"Subjects":{},"Days":{},"Unlocked":{},"Exams":{}}`)
	tables := map[string]any{
		"gamification_users":   []map[string]any{{"user_id": "legacy-user", "state": state}},
		"accounts":             []map[string]any{},
		"billing_purchases":    []map[string]any{},
		"billing_tokens":       []map[string]any{},
		"deleted_demo":         []map[string]any{},
	}
	raw, err := json.Marshal(map[string]any{"version": 1, "tables": tables})
	if err != nil {
		t.Fatal(err)
	}
	path := filepath.Join(t.TempDir(), "export.json")
	if err := os.WriteFile(path, raw, 0600); err != nil {
		t.Fatal(err)
	}
	if err := importLegacy(dsn, path); err != nil {
		t.Fatal(err)
	}
	if err := importLegacy(dsn, path); err == nil {
		t.Fatal("nonempty target overwritten")
	}
	db, err := sql.Open("mysql", dsn)
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close()
	var actual []byte
	if err := db.QueryRow(`SELECT state FROM gamification_users WHERE user_id=?`, database.UserUUID("legacy-user")).Scan(&actual); err != nil || !bytes.Equal(actual, state) {
		t.Fatalf("legacy blob changed: %v", err)
	}
	s := store.NewMemoryStore()
	if err := s.EnableGamificationPersistence(dsn); err != nil {
		t.Fatal(err)
	}
	defer s.Close()
	if s.Gamification(database.UserUUID("legacy-user")).XP != 50 {
		t.Fatal("legacy XP not restored")
	}
}
