package store

import (
	"errors"

	"gorm.io/gorm"
)

// SharedDatabase exposes the MariaDB handle to independent tables (such as
// error diagnostics) that do not go through the cached account-state writer.
// No account or purchase state is exposed.
func (s *MemoryStore) SharedDatabase() (*gorm.DB, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	if s.ormDB == nil || s.persistenceClosed {
		return nil, errors.New("MariaDB persistence is unavailable")
	}
	return s.ormDB, nil
}
