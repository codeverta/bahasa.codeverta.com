# Bahasa Master Backend

Backend Go untuk guest catalog, email login, Google OAuth, revocable session,
learning progress, entitlement Lifetime Access, plans, profile, achievement, XP,
leaderboard, AI chat, dan flashcard (Anki).

Kontrak seluruh endpoint tersedia di [`openapi.yaml`](./openapi.yaml) dan dapat
dibuka dengan Swagger Editor atau dipakai untuk menghasilkan API client.

Panduan Docker Compose production ada di [Deploy backend dengan Docker](../docs/backend-docker.md).

Sinkronkan seluruh asset lokal ke Tencent COS dari folder `backend`:

```powershell
go run ./cmd/assetsync -source assets -prefix assets
```

Credential dibaca dari `.env`; secret tidak pernah dikirim ke aplikasi.
Secara default object asset diberi ACL `public-read` agar dapat ditampilkan oleh
mobile app. Gunakan `-public-read=false` untuk bucket yang dilayani melalui URL
bertanda tangan atau CDN private.

Folder `backend/assets/` saat ini kosong: aset Jepang sudah dihapus dan aset
Bahasa Master (gambar, audio) ditambahkan di fase berikutnya. Tanpa
`ASSET_BASE_URL` atau `COS_BUCKET_URL`, backend menyajikan isinya di
`/assets/images/...`; aplikasi memakai origin `API_BASE_URL`. Untuk CDN, atur
`ASSET_BASE_URL` ke origin CDN dengan object prefix `assets`. Gambar yang
diunggah admin dikompresi sebagai JPEG maksimal 200 KiB.
Foto profil diperkecil menjadi JPEG maksimal 512 px/200 KiB dan disimpan sebagai objek `public-read`
di `profile/avatars/`. Upload memakai `COS_BUCKET_URL`, `COS_SECRET_ID`, dan
`COS_SECRET_KEY` yang sama; URL publik memakai `ASSET_BASE_URL` jika diatur,
atau `COS_BUCKET_URL` sebagai fallback. Foto lama dibersihkan setelah penggantian
profil atau saat akun dihapus.
Panduan build APK kecil: [Android app size](../docs/android-app-size.md).

Dokumentasi lengkap:

- [Panduan mengirim push notification: panel admin, setup Firebase, dan troubleshooting](../docs/panduan-kirim-push-notification.md)
- [Backend Developer Guide](../docs/backend-development.md)
- [Gamifikasi: XP, streak, achievements, dan database permanen](../docs/gamification.md)
- [Lifetime Rp99.000, Google Play, App Store, dan penghapusan akun](../docs/lifetime-billing.md)
- [Authentication and Google OAuth Setup](../docs/authentication.md)
- [Offline account and premium recovery](../docs/offline-access.md)

## Requirements

- Minimum: **Go 1.22**
- Tested: **Go 1.26.5 windows/amd64**
- Google OAuth: Web OAuth Client ID dari Google Cloud

## Database

Backend memakai GORM dan wajib terhubung ke MariaDB di port 3306. Konfigurasi `DB_*` dibaca
dari `.env`. Lihat [setup MariaDB dan migrasi data](../docs/mariadb.md).

## Environment

Backend otomatis membaca `backend/.env` ketika dijalankan dari root project atau
folder backend. File tersebut diabaikan Git. Contoh konfigurasi ada di
[`backend/.env.example`](.env.example); untuk server, sesuaikan akun MariaDB dan
credential integrasi dengan nilai milik server. Jangan menaruh rahasia ke Git.

## Quick start

```powershell
cd backend
go test ./...
go run ./cmd/api
```

Server default: `http://localhost:8080`

Demo account:

```text
Email: demo@bahasa.codeverta.com
Password: Demo123!
```

Login dan gunakan bearer token:

```powershell
$session = Invoke-RestMethod `
  -Method Post `
  -Uri http://localhost:8080/v1/auth/login `
  -ContentType application/json `
  -Body '{"email":"demo@bahasa.codeverta.com","password":"Demo123!"}'

$headers = @{
  Authorization = "Bearer $($session.data.token)"
}

Invoke-RestMethod `
  -Uri http://localhost:8080/v1/auth/me `
  -Headers $headers
```

Google OAuth aktif otomatis ketika `.env` berisi `GOOGLE_CLIENT_ID`. Nilai
tersebut harus sama dengan `GOOGLE_SERVER_CLIENT_ID` yang diberikan ke Flutter.
Lihat [panduan OAuth](../docs/authentication.md).

## Endpoint

| Access | Method | Path | Kegunaan |
|---|---|---|---|
| Public | GET | `/healthz` | Health check |
| Public | POST | `/v1/auth/login` | Email/password login |
| Public | POST | `/v1/auth/google` | Exchange verified Google ID token |
| Auth | POST | `/v1/auth/logout` | Revoke session |
| Auth | GET | `/v1/auth/me` | Restore session/user |
| Public/optional auth | GET | `/v1/home` | Dashboard guest atau user |
| Public | GET | `/v1/learning/categories` | Kategori pembelajaran |
| Public | GET | `/v1/learning/tracks` | Jalur belajar (kosong sampai kurikulum baru ditambahkan) |
| Public | GET | `/v1/plans` | Free, monthly, yearly, lifetime |
| Public | GET | `/v1/pricing` | Harga Lifetime Access yang ditampilkan aplikasi |
| Admin | GET/PUT | `/v1/admin/pricing` | Baca atau ubah harga Lifetime (kunci admin) |
| Auth | GET/PATCH | `/v1/me/profile` | Profil pengguna |
| Auth | GET | `/v1/me/progress` | Progress pengguna |
| Auth | PUT | `/v1/me/progress/{lessonID}` | Simpan progress |
| Auth | GET | `/v1/me/achievements` | Achievement pengguna |
| Auth | GET | `/v1/me/gamification` | XP, level, streak, statistik, dan 12 achievements dari aktivitas terverifikasi |
| Auth | GET | `/v1/vocabulary/levels` | Level, lesson, dan progress vocabulary (kosong sampai konten baru ditambahkan) |
| Auth | GET | `/v1/vocabulary/lessons/{lessonID}` | Konten pengajaran vocabulary |
| Auth | POST | `/v1/vocabulary/lessons/{lessonID}/attempts` | Mulai/retry kuis lesson |
| Auth | POST | `/v1/vocabulary/attempts/{attemptID}/answers` | Validasi jawaban dan feedback |
| Auth | POST | `/v1/vocabulary/attempts/{attemptID}/complete` | Nilai dan simpan progress |

## Quality checks

Harga tampilan Lifetime Access: [pengaturan Admin dan sinkronisasi harga store](../docs/lifetime-billing.md).

```powershell
go fmt ./...
go vet ./...
go test ./...
```

## Google Play: halaman kebijakan publik

Backend menyediakan HTML publik `/privacy-policy`, `/terms-of-service`, `/refund-policy`, `/delete-account`, `/support`, `/data-safety`, dan indeks `/legal`. Semua template dibundel dalam binary; tidak perlu server frontend tambahan. Kontak pengguna adalah `contact@codeverta.com`. Panduan URL dan pengisian Console ada di [Google Play setup](../docs/google-play-setup.md).

## Transfer deck Anki

Impor/ekspor APKG, CSV, dan JSON beserta media pribadi: lihat [panduan import/export](../docs/anki-import-export.md). Route transfer memerlukan autentikasi; persistence otomatis menambahkan tabel deck dan media pada MariaDB. Set deck bawaan saat ini kosong (`internal/anki/resources/catalog.json`); mekanisme deck pribadi, jadwal review, dan import/export tetap berjalan.
