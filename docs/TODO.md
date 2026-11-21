# Bahasa Master — Todolist Pengerjaan

Aplikasi belajar Bahasa Indonesia untuk orang asing (BIPA), di-fork dari
Nihongo Master v2.1.1 (Flutter + Go + MariaDB).

## Keputusan yang sudah disepakati

| # | Topik | Keputusan |
|---|---|---|
| 1 | Target pengguna | Orang asing yang belajar Bahasa Indonesia (BIPA) |
| 2 | Identitas | Nama **Bahasa Master**, package `com.codeverta.bahasa`, domain `bahasa.codeverta.com` |
| 3 | Git | Repo baru, satu initial commit "fork from nihongo v2.1.1", remote GitHub baru |
| 4 | Backend | Terpisah total: backend Go, DB MariaDB, service, dan domain API sendiri |
| 5 | Akun pihak ketiga | Semua baru (Firebase, AdMob, OAuth client, listing store, produk IAP); akun developer Google/Apple tetap sama |
| 6 | Platform | Android dulu, iOS setelah konten MVP stabil |
| 7 | Fitur khas Jepang | Dihapus (bukan disembunyikan): jobs, ssw, map, manga, kana, kanji, furigana, JLPT/NAT/JFT, Jisho |
| 8 | Bahasa UI | Inggris saat rilis; arsitektur siap multi-bahasa |
| 9 | Lokalisasi | Migrasi ke Flutter `gen-l10n` (ARB, `en` sebagai template) |
| 10 | Kurikulum | BIPA 1–7 sebagai struktur, dengan label CEFR pendamping |
| 11 | Modul MVP | Survival phrases, Vocabulary, Grammar, Flashcard, Quiz per level — **BIPA 1–2 saja**, dengan audio |
| 12 | Konten | Draf AI (Claude) mengikuti silabus BIPA resmi, direview penutur asli/guru BIPA; semua original |
| 13 | Monetisasi | Model sama (gratis + iklan + rewarded unlock + Lifetime + double XP); Lifetime tier USD sekitar $9.99 |
| 14 | Fitur sekunder | AI Chat (tutor percakapan) masuk MVP; Kamus dan News ditunda ke fase 2 |
| 15 | Audio | Google Cloud TTS `id-ID`, dibuat sekali di awal (pre-generated); ElevenLabs opsional untuk dialog unggulan |
| 16 | Situs | Landing, privacy, terms, dan hapus akun di `bahasa.codeverta.com`, berbahasa Inggris, dari template nihongo |
| 17 | Docs | Pertahankan dan sesuaikan dokumen infrastruktur; hapus dokumen konten Jepang |
| 18 | Fitur generik | XP/streak, leaderboard, offline, in-app update, push, dan in-app review dibawa apa adanya |

---

## Fase 0 — Setup repo

- [ ] `git init`, `.gitignore` sudah ikut; initial commit "fork from nihongo v2.1.1"
- [ ] Buat repo GitHub baru, push `main`
- [ ] Salin `backend/.env.example` ke `backend/.env`, isi nilai baru (jangan pakai secret nihongo)
- [ ] Pastikan `flutter pub get`, `go build ./...`, dan `dart run.dart` jalan sebelum perubahan apa pun (baseline)

## Fase 1 — Rebranding dan identifier

- [ ] Android: `namespace` dan `applicationId` di `android/app/build.gradle.kts` → `com.codeverta.bahasa`
- [ ] Android: pindahkan folder Kotlin `android/app/src/main/kotlin/com/codeverta/nihongomaster` → `.../codeverta/bahasa`, perbarui `package`
- [ ] Android: label app di `AndroidManifest.xml` → "Bahasa Master"
- [ ] iOS: bundle id di `ios/Runner.xcodeproj` (Runner + RunnerTests), `CFBundleDisplayName` dan `CFBundleName` di `Info.plist`
- [ ] macOS: `com.example.nihongoMaster` → `com.codeverta.bahasa` (atau hapus platform desktop yang tidak dipakai: linux/macos/windows)
- [ ] Dart: `name: nihongo_master` → `bahasa_master` di `pubspec.yaml`, ganti semua `package:nihongo_master/` (sekitar 245 file), reset `version` ke `1.0.0+1`
- [ ] Go: `module nihongo-master-backend` → `bahasa-master-backend` di `backend/go.mod` dan sekitar 158 file import
- [ ] Ganti "Nihongo Master" (sekitar 80 file) dan `nihongo.codeverta.com` / `nihongomaster.app` di kode, `lib/core/branding/app_branding.dart`, `lib/core/widgets/legal_links.dart`, `backend/internal/api/site/*`, dan `admin_dashboard.*`
- [ ] Ikon app, splash, dan aset branding baru (`assets/`, `docs/app-branding.md`)
- [ ] `DB_NAME=nihongo` → `bahasa` di `.env.example` dan konfigurasi
- [ ] Grep akhir: `nihongo`, `Nihongo`, `nihongomaster`, `JLPT`, dan `furigana` harus nol (kecuali catatan atribusi fork)

## Fase 2 — Hapus fitur dan konten Jepang

Flutter (`lib/`):
- [ ] Hapus `features/jobs`, `features/ssw`, `features/map`, `features/manga`, `features/news` (News ditunda; ambil lagi dari repo nihongo di fase 2), `features/exam` (simulasi JLPT/NAT/JFT)
- [ ] Hapus `features/learn/kana`, `features/learn/kanji`
- [ ] Hapus `features/dictionary` (Jisho/kanjiapi); kamus Indonesia dibuat ulang di fase 2
- [ ] Hapus `shared/presentation/widgets/japanese_ruby_text.dart` dan toggle furigana (`core/settings/display_preferences.dart`, `display_settings_screen.dart`, `app_theme.dart`)
- [ ] Bersihkan rute dan menu di `core/routing/app_router.dart`, `main_scaffold.dart`, banner `home_banner_content.dart`, dan `ads_config.dart`
- [ ] Bersihkan `pubspec.yaml` dari asset Jepang (`assets/images/exams|ssw|jobs|explore`, `assets/map`, `assets/content/ssw`, `kana_strokes.json`, `backend/assets/images/vocabulary`) dan dependensi yang tidak terpakai lagi
- [ ] Hapus tes yang terkait fitur yang dihapus di `test/`

Backend (`backend/`):
- [ ] Hapus `internal/jobs`, `jobfetch`, `manga`, `news`, `places`, `prefinfo`, `dictionary`, dan `cmd/` sync terkait (news-sync, jobs-sync, manga-sync)
- [ ] Hapus konten Anki Jepang `internal/anki/resources` (sekitar 120 MB); pertahankan mekanisme deck dan jadwal review
- [ ] Hapus `internal/docs` (63 MB), `internal/api/english_*.go` (sekitar 7.7 MB), dan data simulasi/SSW/kanji/grammar di `internal/store`
- [ ] Hapus `data/irodori`, `data/kanji`, `data/jlpt`, `data/vocabulary`, `data/grammar`, `data/reading`, dan `assets/images/*` Jepang
- [ ] `internal/learningpdf`: buang font NotoSansJP (11 MB), ganti font Latin, atau tunda fiturnya
- [ ] Perbarui `openapi.yaml` dan `backend/README.md` sesuai endpoint yang tersisa

Repo:
- [ ] Hapus `output/`, `Claude outputs/`, `tmp/`, `create_scaffold.*`, dan dokumen konten Jepang di `docs/` (JLPT, kanji, grammar-n*, reading-n*, vocabulary-n*, ssw-*, jobs, manga, map, english-localization, `*-reference.json`)
- [ ] Sesuaikan dokumen infrastruktur yang dipertahankan dan tulis ulang `README.md`
- [ ] Pastikan `flutter analyze`, `flutter test`, dan `go test ./...` hijau setelah pembersihan

## Fase 3 — Lokalisasi (UI bahasa Inggris, ARB)

- [ ] Aktifkan `flutter gen-l10n` (`l10n.yaml`, `lib/l10n/app_en.arb` sebagai template)
- [ ] Pindahkan teks UI yang sekarang hard-coded dalam bahasa Indonesia ke key ARB berbahasa Inggris
- [ ] Hapus peta `_englishCopy`, `ui_english_*.dart`, `anki_english_part_*.dart`, `.localized(context)`, dan gate `ENGLISH_PUBLIC_RELEASE`
- [ ] Pisahkan dengan tegas: **teks UI** (ARB, bisa diterjemahkan) vs **konten pelajaran** (Bahasa Indonesia + terjemahan/penjelasan per bahasa UI)
- [ ] Siapkan skema konten agar field terjemahan bisa multi-bahasa (`translations: {en: ..., ja: ...}`), walau MVP hanya `en`
- [ ] Teks error dan notifikasi dari backend juga berbahasa Inggris, atau pakai key

## Fase 4 — Model kurikulum dan data

- [ ] Ganti enum dan level JLPT (N5–N1) dengan BIPA 1–7 + label CEFR, di Flutter (`features/learn/level_list`, onboarding, profil) dan backend
- [ ] Rancang skema JSON konten: unit → lesson → item (kosakata, frasa, pola grammar, soal quiz), lengkap dengan field audio
- [ ] Putuskan format penyimpanan mengikuti pola lama (JSON/Go `go:embed` di repo) dan endpoint API yang menyajikannya
- [ ] Adaptasi progres, XP, dan "continue learning" ke struktur level/lesson yang baru
- [ ] Perbarui offline download per level BIPA

## Fase 5 — Produksi konten MVP (BIPA 1–2)

- [ ] Susun silabus BIPA 1–2 (topik, kompetensi, daftar tema) mengacu ke standar BIPA resmi
- [ ] Survival phrases: sekitar 150–200 frasa per kategori (sapaan, belanja, transportasi, makan, darurat, kantor)
- [ ] Vocabulary BIPA 1–2: daftar kata + contoh kalimat + terjemahan Inggris
- [ ] Grammar BIPA 1–2: pola (imbuhan dasar me-/ber-/di-, kata tanya, negasi tidak/bukan, waktu sudah/sedang/akan, kata ganti, ini/itu, dll.) + penjelasan bahasa Inggris + contoh
- [ ] Bank soal quiz per lesson dan per level
- [ ] Deck flashcard default dari kosakata dan frasa
- [ ] Buat script/pipeline generator draf konten dengan Claude (output ke format JSON skema Fase 4)
- [ ] Review oleh penutur asli/guru BIPA, sertakan checklist review
- [ ] Generate audio dengan Google Cloud TTS `id-ID` (script batch, simpan sebagai asset backend, cache/CDN, ikut paket offline)

## Fase 6 — Adaptasi fitur app

- [ ] Onboarding: tujuan belajar (tinggal/kerja/wisata), level awal (BIPA 1/2 atau placement singkat), bahasa UI
- [ ] Home: banner, continue learning, dan artwork baru
- [ ] Learn: layar Survival Phrases (baru), Vocabulary, Grammar, dan Quiz pakai data baru, dengan pemutar audio
- [ ] Flashcard/Anki: deck default baru; import/export tetap
- [ ] AI Chat: ubah system prompt jadi tutor percakapan bahasa Indonesia (skenario roleplay, koreksi, penjelasan dalam bahasa Inggris), sesuaikan batas penggunaan Lifetime
- [ ] Gamifikasi, leaderboard, dan double XP: hanya ganti teks
- [ ] Rewarded unlock: petakan ulang konten terkunci ke lesson BIPA
- [ ] Profile: rewrite atribusi/lisensi (hapus atribusi JMdict, KANJIDIC, Irodori, dll.)
- [ ] Push notification: teks reminder dan streak dalam bahasa Inggris

## Fase 7 — Infrastruktur dan akun pihak ketiga

- [ ] Firebase project baru → `google-services.json` baru (`com.codeverta.bahasa`); analytics + FCM
- [ ] AdMob app baru → app ID di manifest, unit ID di config ads backend; hapus unit ID nihongo di `backend/internal/api/unlock_api_test.go`
- [ ] Google OAuth client baru (web + Android SHA-1) → `run.dart`, `.env`, dan variabel CI `GOOGLE_SERVER_CLIENT_ID`
- [ ] Play Console: app baru, produk IAP `bahasa_master_lifetime` (tier sekitar $9.99), service account verifikasi purchase
- [ ] Keystore upload Android baru
- [ ] Database MariaDB `bahasa` + user baru di server, jalankan migrasi
- [ ] Server: tambahkan target `bahasa` di `ops/deploy-api-from-ci` (sekarang `nihongo|fitapp`), service `bahasa-api.service`, port baru, health check `/healthz`
- [ ] Domain/DNS `bahasa.codeverta.com` + reverse proxy + TLS
- [ ] `docker-compose.backend.production.yml`: rename project, ganti port
- [ ] GitHub Actions: rename artifact/binary/concurrency group (`nihongo-*`), set secrets (keystore, deploy SSH) dan variables (`API_BASE_URL`, `GOOGLE_SERVER_CLIENT_ID`, `OFFLINE_ACCESS_PUBLIC_KEY` baru)
- [ ] Generate key pair offline access baru

## Fase 8 — Landing page dan legal

- [ ] Ganti konten `backend/internal/api/site/` dengan landing Bahasa Master (bahasa Inggris)
- [ ] Privacy policy, terms, dan halaman hapus akun (wajib untuk Play Store dan OAuth consent)
- [ ] OAuth consent screen: nama app, logo, domain terverifikasi

## Fase 9 — QA dan rilis Android

- [ ] Tes manual end-to-end: login Google, onboarding, belajar, audio, quiz, flashcard, AI chat, XP/streak, iklan, rewarded unlock, beli Lifetime (test track), offline, push
- [ ] `flutter test`, `go test ./...`, cek ukuran APK/AAB
- [ ] Listing Play Store: deskripsi (EN), screenshot, feature graphic, kategori Education, data safety form, content rating
- [ ] Internal testing → closed testing (minimal 12 tester selama 14 hari jika akun personal) → produksi

## Fase 10 — Pasca-MVP (backlog)

- [ ] Konten BIPA 3–7
- [ ] Reading (teks bertingkat)
- [ ] Simulasi ujian (UKBI)
- [ ] Kamus Indonesia–Inggris dari data terbuka + penjelasan kata oleh AI
- [ ] News Indonesia yang disederhanakan
- [ ] Bahasa UI tambahan: Jepang, Korea, Mandarin
- [ ] ElevenLabs untuk dialog unggulan
- [ ] Rilis iOS (bundle id, sertifikat, App Store listing, IAP Apple)
