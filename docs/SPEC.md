# Spec: Bahasa Master MVP (BIPA 1–2, Android)

> Status: `ready-for-agent`. Turunan dari keputusan di `docs/TODO.md`. Jadikan GitHub issue setelah repo GitHub dibuat.

## Problem Statement

Orang asing yang tinggal, bekerja, atau berwisata di Indonesia (ekspatriat, pelajar, pekerja Jepang/Korea/Tiongkok, wisatawan) tidak punya aplikasi belajar Bahasa Indonesia yang terstruktur mengikuti standar resmi BIPA. Aplikasi umum mengajarkan bahasa secara generik: tanpa jenjang yang jelas, tanpa frasa praktis untuk kehidupan sehari-hari di Indonesia, dengan audio yang tidak konsisten, dan tanpa partner latihan percakapan.

Dari sisi pemilik produk, sudah ada aplikasi belajar bahasa yang matang (Nihongo Master) dengan auth, gamifikasi, iklan, rewarded unlock, Lifetime billing, offline, flashcard, AI chat, dan pipeline rilis. Masalahnya, seluruh kode, konten, identitas, dan teks UI-nya terikat ke bahasa Jepang dan ke pengguna berbahasa Indonesia. Fondasi itu perlu diubah menjadi aplikasi baru yang terpisah, tanpa membawa kode dan konten Jepang.

## Solution

**Bahasa Master** adalah aplikasi Android dengan UI berbahasa Inggris yang mengajarkan Bahasa Indonesia untuk jenjang **BIPA 1–2** (dengan label CEFR pendamping). Pengguna:

- memilih tujuan belajar dan level awal saat onboarding;
- belajar lewat **Survival Phrases**, **Vocabulary**, dan **Grammar**, semuanya dengan audio penutur `id-ID`;
- menguji diri lewat **Quiz** per lesson dan per level;
- mengulang lewat **Flashcard** dengan jadwal review;
- berlatih percakapan dengan **AI Tutor** yang membalas dalam Bahasa Indonesia dan menjelaskan dalam bahasa Inggris;
- mendapat XP, streak, dan peringkat leaderboard;
- bisa belajar offline setelah mengunduh paket level.

Monetisasinya gratis dengan iklan dan rewarded unlock, plus pembelian sekali bayar **Lifetime** (tier USD sekitar $9.99) yang menghapus iklan, membuka semua konten, dan menaikkan batas AI Tutor.

Secara teknis, aplikasi ini adalah fork Nihongo Master yang sudah di-rebrand, dibersihkan dari fitur Jepang, dimigrasikan ke lokalisasi berbasis ARB, dengan model kurikulum BIPA. Backend, database, domain, dan semua akun pihak ketiganya terpisah dari Nihongo.

## User Stories

### Onboarding dan akun

1. As a new learner, I want to see the app entirely in English, so that I can use it before I know any Indonesian.
2. As a new learner, I want to sign in with my Google account, so that my progress is saved without creating a password.
3. As a new learner, I want to try the app without signing in first, so that I can decide whether it is worth an account.
4. As a new learner, I want to choose my learning goal (living, working, travelling, studying), so that the app highlights the most relevant material for me.
5. As a new learner, I want to choose my starting level (BIPA 1 or BIPA 2), so that I do not repeat material I already know.
6. As a new learner who is unsure of my level, I want a short placement quiz, so that the app can recommend BIPA 1 or BIPA 2.
7. As a new learner, I want to see each BIPA level labelled with its CEFR equivalent, so that I understand the level with a framework I already know.
8. As a new learner, I want to set a daily reminder time, so that I build a habit.
9. As a learner, I want to delete my account and data from inside the app and from the website, so that I stay in control of my personal data.
10. As a learner, I want to sign out and sign back in on another device, so that I keep my progress, XP, and purchases.

### Struktur kurikulum

11. As a learner, I want to see the curriculum organised as levels → units → lessons, so that I always know where I am and what comes next.
12. As a learner, I want each unit to have a clear theme (greetings, numbers and money, food, transport, work, family), so that what I learn is immediately useful.
13. As a learner, I want to see my completion progress per lesson, unit, and level, so that I stay motivated.
14. As a learner, I want a "Continue learning" entry on the home screen, so that I can resume exactly where I stopped.
15. As a learner, I want BIPA 3–7 shown as "coming soon", so that I know the app will grow with me.

### Survival Phrases

16. As an expat who just arrived, I want ready-to-use phrases grouped by situation (greetings, shopping, transport, eating out, emergencies, at the office), so that I can get through daily life quickly.
17. As a learner, I want every phrase to show the Indonesian text, an English translation, and a usage note (formal/informal, when to use it), so that I do not sound rude or odd.
18. As a learner, I want to tap a phrase and hear it spoken by a natural Indonesian voice, so that I can pronounce it correctly.
19. As a learner, I want to slow down the audio playback, so that I can hear each syllable.
20. As a learner, I want to add a phrase to my flashcards with one tap, so that I can review it later.
21. As a learner, I want to mark phrases as favourites, so that I can find the ones I need most quickly.

### Vocabulary

22. As a learner, I want to study vocabulary lesson by lesson, with the Indonesian word, part of speech, English meaning, and an example sentence, so that I learn words in context.
23. As a learner, I want to hear the audio for each word and example sentence, so that I can link spelling and sound.
24. As a learner, I want to see the root word and affixes where relevant (e.g. *makan* → *makanan*), so that I start to understand Indonesian word formation.
25. As a learner, I want vocabulary I have studied to flow into my flashcard reviews automatically, so that I do not forget it.

### Grammar

26. As a learner, I want grammar explained in plain English with Indonesian examples, so that I understand the rules without a teacher.
27. As a learner, I want BIPA 1–2 grammar covered (pronouns, *ini/itu*, *tidak* vs *bukan*, question words, time markers *sudah/sedang/akan/belum*, basic *ber-*, *me-*, and *di-* affixes, numbers, classifiers), so that I can build basic sentences.
28. As a learner, I want each grammar pattern to come with several example sentences and audio, so that I see the pattern used naturally.
29. As a learner, I want short practice questions right after each grammar point, so that I can confirm I understood it.

### Quiz

30. As a learner, I want a quiz at the end of each lesson, so that I can check what I learned.
31. As a learner, I want a level test at the end of each level, so that I know I am ready for the next one.
32. As a learner, I want several question types (multiple choice, listen-and-choose, translate EN→ID and ID→EN, arrange words), so that I practise reading, listening, and production.
33. As a learner, I want immediate feedback with the correct answer and a short explanation, so that I learn from mistakes.
34. As a learner, I want to see my score and the XP earned on a result screen, so that I feel progress.
35. As a learner, I want to retry wrong questions, so that I master the weak points.

### Flashcard

36. As a learner, I want default flashcard decks per level from the vocabulary and phrases, so that I can start reviewing right away.
37. As a learner, I want spaced-repetition scheduling (again / hard / good / easy), so that I review each card at the right time.
38. As a learner, I want to swipe through cards with audio on the Indonesian side, so that reviews are fast.
39. As a learner, I want to create my own cards and decks, so that I can add words I meet in daily life.
40. As a learner, I want to import and export decks, so that I can move my cards in and out of other flashcard tools.
41. As a learner, I want my reviews to sync when I am back online, so that offline reviews are not lost.

### AI Tutor

42. As a learner, I want to chat with an AI tutor in Indonesian, so that I can practise conversation without the fear of talking to a person.
43. As a learner, I want to pick a roleplay scenario (ordering food, taking a taxi, meeting a colleague, at the market), so that practice matches real situations.
44. As a learner, I want the tutor to adapt its language to my BIPA level, so that replies are understandable.
45. As a learner, I want my mistakes corrected with an English explanation, so that I know why something was wrong.
46. As a learner, I want to ask the tutor in English what a word or sentence means, so that I can get unstuck.
47. As a learner, I want the tutor to know which lesson I am on, so that it reuses vocabulary I have just learned.
48. As a free learner, I want a daily message allowance, so that I can try the tutor without paying.
49. As a Lifetime learner, I want a much higher tutor limit, so that I can practise as much as I need.

### Gamifikasi

50. As a learner, I want to earn XP for every finished activity, so that I feel rewarded for studying.
51. As a learner, I want a daily streak, so that I am motivated to study every day.
52. As a learner, I want to double the XP of a finished activity by watching a rewarded ad (or automatically as Lifetime), so that I can level up faster.
53. As a learner, I want weekly and all-time leaderboards, so that I can compare myself with other learners.
54. As a learner, I want achievements on my profile, so that I can see milestones I have reached.
55. As a learner, I want a streak reminder notification when I have not studied today, so that I do not lose my streak.

### Monetisasi dan unlock

56. As a free learner, I want most BIPA 1 content free, so that I can learn meaningfully without paying.
57. As a free learner, I want to unlock a locked lesson temporarily by watching a rewarded ad, so that I can continue without buying.
58. As a learner, I want to buy Lifetime once at a price shown in my local currency, so that I get everything with no subscription.
59. As a Lifetime learner, I want no ads, all content unlocked, double XP, and a higher AI limit, so that the purchase feels worth it.
60. As a Lifetime learner, I want to restore my purchase on a new device, so that I do not pay twice.
61. As a Lifetime learner, I want my entitlement to keep working offline, so that I can study on a plane.
62. As a free learner, I want ads that do not interrupt the middle of a lesson, so that learning is not frustrating.

### Offline

63. As a learner, I want to download a whole level (text and audio), so that I can study without internet.
64. As a learner, I want to see download size and progress, so that I can manage storage and data.
65. As a learner, I want quiz results and progress made offline to sync later, so that nothing is lost.

### Pengaturan dan sistem

66. As a learner, I want to adjust audio speed and autoplay in settings, so that the app fits how I learn.
67. As a learner, I want to be told when a new app version is available, so that I get fixes and new content.
68. As a satisfied learner, I want to be asked for a store review at a sensible moment, so that I can support the app without being nagged.
69. As a learner, I want UI text ready for other languages (Japanese, Korean, Chinese) in the future, so that I could later use the app in my native language.

### Website dan legal

70. As a prospective learner, I want a landing page that explains the app and links to the Play Store, so that I can decide to install it.
71. As a learner, I want to read the privacy policy and terms, so that I know how my data is used.
72. As Google Play and Google OAuth reviewers, we need a verified domain with privacy policy and an account-deletion page, so that the app can be approved.

### Operator dan pemilik produk

73. As the product owner, I want Bahasa Master fully separated from Nihongo Master (bundle id, backend, database, Firebase, AdMob, OAuth, IAP), so that an issue in one app never affects the other.
74. As the product owner, I want no Japanese code, content, assets, or naming left in the repository, so that the codebase stays small and maintainable.
75. As the product owner, I want curriculum content stored in a single structured format with English translations, so that it can be generated, reviewed, and extended easily.
76. As the product owner, I want a content-generation pipeline (Claude draft → JSON in the curriculum schema), so that BIPA content can be produced quickly.
77. As a native-speaker reviewer, I want to review generated content in a readable format with a checklist, so that I can approve or correct it efficiently.
78. As the product owner, I want audio pre-generated in batch with Google Cloud TTS (`id-ID`), so that audio quality is consistent and cost is paid once.
79. As the product owner, I want an automated check that every content item is complete (English translation, existing audio, valid quiz answers), so that broken content never ships.
80. As the operator, I want CI to build the Android release and deploy the API to the shared server as a separate `bahasa` target, so that releases are repeatable.
81. As the operator, I want an admin dashboard for push notifications, app updates, and diagnostics, so that I can operate the app like Nihongo Master.
82. As the operator, I want a health-check endpoint and its own system service, so that I can monitor the API separately.

## Implementation Decisions

### Identitas dan isolasi
- Nama app **Bahasa Master**, application/bundle id `com.codeverta.bahasa`, domain `bahasa.codeverta.com`, Dart package `bahasa_master`, Go module `bahasa-master-backend`, database `bahasa`. Versi direset ke `1.0.0+1`.
- Repo git baru dengan satu initial commit fork dari Nihongo v2.1.1. History Nihongo tidak dibawa.
- Semua akun pihak ketiga baru: Firebase (Analytics + FCM), AdMob app dan unit, Google OAuth client (web + Android), produk IAP `bahasa_master_lifetime`, upload keystore, dan key pair offline access. Akun developer Google Play dan Apple tetap sama.
- Backend berjalan sebagai service terpisah di server yang sama, lewat target deploy `bahasa` pada skrip deploy multi-app yang sudah ada, dengan port, service, dan health check sendiri.

### Penghapusan modul
- Modul Flutter yang dihapus: jobs, ssw, map, manga, news, exam (JLPT/NAT/JFT), dictionary, learn/kana, learn/kanji, widget ruby/furigana, dan preferensi furigana.
- Modul backend yang dihapus: jobs, jobfetch, manga, news, places, prefinfo, dictionary, dokumen/terjemahan Inggris hasil generate, konten Anki Jepang, data simulasi/SSW/kanji/grammar/reading Jepang, font Jepang, dan command sync terkait.
- Dihapus, bukan disembunyikan di balik flag. Kalau nanti dibutuhkan, polanya bisa dilihat di repo Nihongo.

### Modul yang dipertahankan apa adanya (hanya ganti teks dan branding)
- Auth (Google Sign-In + demo account), billing/Lifetime (verifikasi purchase, offline lease), unlock/rewarded ads, ads (interstitial/completion), gamification (XP, streak, double XP, achievements), leaderboard, notifications (push + reminder lokal), offline cache, app update, app review, diagnostics, admin dashboard, dan media/imageopt.

### Lokalisasi
- Migrasi ke Flutter `gen-l10n` dengan ARB, `en` sebagai template. Peta terjemahan Indonesia→Inggris yang lama dan gate rilis bahasa Inggris dihapus.
- Pemisahan tegas antara **teks UI** (ARB, bisa diterjemahkan) dan **konten pelajaran** (Bahasa Indonesia sebagai materi, dengan terjemahan/penjelasan per bahasa UI).
- Field terjemahan di konten berbentuk map per locale (`translations: { en: ... }`). MVP hanya mengisi `en`, tapi bahasa UI tambahan tidak perlu mengubah skema.
- Backend memilih bahasa penjelasan konten dan pesan error berdasarkan header bahasa yang sudah dikirim app (mekanisme localized request header yang ada dipertahankan), dengan fallback `en`.

### Model kurikulum
- Level JLPT (N5–N1) diganti dengan **BIPA 1–7**, masing-masing punya label CEFR pendamping. MVP hanya mengaktifkan BIPA 1–2, level lain tampil sebagai "coming soon".
- Hierarki: **Level → Unit → Lesson → Item**. Jenis item: `phrase`, `vocab`, `grammar_point`, `quiz_question`. Survival Phrases adalah koleksi frasa per situasi, terpisah dari alur lesson tapi memakai jenis item yang sama.
- Bentuk data minimum (keputusan skema, bukan kode final):
  - Item frasa/kosakata: `id`, `level`, `text_id`, `translations{locale}`, `notes{locale}`, `part_of_speech?`, `root?`, `examples[] {text_id, translations, audio}`, `audio`, `tags[]`.
  - Grammar point: `id`, `level`, `title{locale}`, `explanation{locale}`, `examples[]`, `practice[]` (merujuk ke quiz question).
  - Quiz question: `id`, `type` (`multiple_choice` | `listen_choose` | `translate_en_id` | `translate_id_en` | `arrange_words`), `prompt`, `options[]`, `answer` (atau daftar jawaban yang diterima untuk soal terjemahan), `explanation{locale}`, `audio?`.
  - `id` stabil dan tidak pernah dipakai ulang, karena progres, flashcard, dan unlock merujuk ke `id` tersebut.
- Konten disimpan mengikuti pola lama: file terstruktur di repo, di-embed ke binary backend, lalu disajikan lewat API. Database hanya menyimpan data pengguna (akun, progres, XP, purchase, review flashcard), bukan kurikulum.
- Kontrak API kurikulum (bentuk, bukan path final): daftar level beserta status aktif dan progres pengguna; detail level berisi unit dan lesson; detail lesson berisi item; koleksi survival phrases per situasi; quiz untuk lesson/level; pencatatan hasil aktivitas yang mengembalikan XP yang didapat (memakai mekanisme learning activity dan XP yang ada); dan manifest paket offline per level (daftar item + URL audio + ukuran).
- Progres, "continue learning", dan aturan unlock dipetakan ulang ke `id` lesson BIPA.

### Audio
- Dibuat sekali di awal dengan Google Cloud TTS suara `id-ID` lewat skrip batch, disimpan sebagai asset backend, dan disajikan lewat endpoint asset/media yang ada (dengan cache). Audio masuk ke paket offline.
- Satu file audio per teks Indonesia (item dan contoh). Item hanya menyimpan referensi audio, dan nama file diturunkan dari `id` item.
- ElevenLabs tidak termasuk MVP.

### Pipeline konten
- Silabus BIPA 1–2 disusun mengacu ke standar BIPA resmi. Semua konten original.
- Skrip generator memanggil Claude untuk membuat draf JSON sesuai skema di atas. Hasilnya direview penutur asli/guru BIPA (dalam format yang mudah dibaca, dengan checklist) sebelum di-merge.
- Volume target MVP: sekitar 150–200 survival phrases; kosakata, grammar point, dan bank soal secukupnya untuk BIPA 1–2.

### Fitur app
- **Onboarding**: tujuan belajar, level awal (BIPA 1/2 atau placement quiz singkat), dan waktu reminder. Shell onboarding yang lama dipakai ulang.
- **Home**: continue learning, banner, kartu menu (Phrases, Learn, Flashcards, AI Tutor), artwork baru.
- **Learn**: layar daftar level/unit/lesson memakai ulang komponen level list. Layar lesson menampilkan item dengan pemutar audio (kecepatan bisa diatur). Layar Survival Phrases baru.
- **Flashcard**: mekanisme deck, review terjadwal, swipe, offline review, dan import/export dipertahankan. Deck default per level dibuat dari kosakata dan frasa.
- **AI Tutor**: memakai modul AI chat yang ada. System prompt diganti menjadi tutor percakapan Bahasa Indonesia yang menyesuaikan level BIPA, mendukung skenario roleplay, mengoreksi dengan penjelasan bahasa Inggris, dan memakai konteks lesson aktif (mekanisme lesson context yang ada). Batas pesan harian free vs Lifetime mengikuti mekanisme yang ada.
- **Monetisasi**: gratis + iklan + rewarded unlock + Lifetime (tier USD sekitar $9.99, harga lokal otomatis dari store) + double XP. Sebagian besar BIPA 1 gratis, sisanya bisa dibuka dengan rewarded unlock atau Lifetime.
- **Profile**: atribusi/lisensi Jepang (JMdict, KANJIDIC, Irodori, dll.) dihapus dan diganti atribusi yang relevan.

### Website
- Landing, privacy policy, terms, dan halaman hapus akun berbahasa Inggris di `bahasa.codeverta.com`, memakai template situs yang disajikan backend.

### Infrastruktur dan CI
- Workflow rilis Android dan deploy API diganti namanya (artifact, binary, concurrency group) dan memakai secrets/variables baru.
- Rilis iOS tidak diaktifkan di MVP.

## Testing Decisions

### Prinsip
- Tes hanya memeriksa perilaku eksternal: request/response HTTP dan apa yang dilihat/dilakukan pengguna di layar. Tes tidak mengunci detail implementasi (struktur internal, nama fungsi privat, urutan pemanggilan).
- Pakai seam yang sudah ada. Tidak ada seam baru.
- Tes untuk modul yang dihapus ikut dihapus. Tes modul yang dipertahankan diperbarui untuk identitas baru (product ID, nama app, domain).

### Seam 1 — HTTP API backend (utama)
- Server dibuat dengan memory store dan verifier palsu, lalu diuji lewat handler HTTP dengan request rekaman (pola yang dipakai sekitar 41 tes API yang ada, misalnya tes billing, unlock, gamification, learning activity, AI chat, dan localization).
- Yang diuji dari seam ini:
  - Kurikulum: daftar level BIPA dengan label CEFR dan status aktif, detail level/unit/lesson, survival phrases per situasi, dan quiz.
  - Progres dan XP: mencatat hasil aktivitas, XP dan double XP, streak, dan continue learning.
  - Unlock: lesson terkunci untuk free user, rewarded unlock, dan Lifetime membuka semuanya.
  - Billing: verifikasi `bahasa_master_lifetime`, restore, offline lease, dan pencabutan.
  - AI Tutor: batas pesan free vs Lifetime dan konteks lesson ikut terkirim (dengan provider AI palsu).
  - Lokalisasi: penjelasan konten dan pesan error mengikuti header bahasa, dengan fallback `en`.
  - Offline: manifest paket level berisi semua item dan URL audio yang bisa diambil.
  - Legal/landing: halaman privacy, terms, dan hapus akun tersedia dengan branding baru.
- **Tes integritas konten** (juga lewat seam API): menelusuri semua level aktif → unit → lesson → item lewat endpoint, lalu memastikan setiap item punya terjemahan `en`, setiap referensi audio bisa diambil lewat endpoint asset, setiap jawaban quiz ada di antara opsinya (atau daftar jawaban terjemahan tidak kosong), dan semua `id` unik. Tes ini menjadi gerbang CI untuk konten hasil generate.

### Seam 2 — Widget test Flutter
- Widget dipompa di dalam `ProviderScope` dengan override provider/repository dan `GoRouter` uji (pola tes `test/features` yang ada, misalnya course actions, login flow, anki, home).
- Yang diuji:
  - Onboarding: pilih tujuan, level, placement quiz, dan reminder.
  - Navigasi level → unit → lesson.
  - Layar lesson dan survival phrases menampilkan teks, terjemahan, dan tombol audio.
  - Alur quiz: jawab, feedback, layar hasil dengan XP.
  - Layar unlock dan Lifetime.
  - Cakupan ARB: setiap key yang dipakai ada di template `en`. Ini pengganti tes cakupan terjemahan Inggris yang lama.
  - Tes branding: nama app dan link legal baru.
- Tes yang sudah ada untuk ads, gamification, unlock, offline, auth, app update, dan notifications dipertahankan dan disesuaikan.

## Out of Scope

- Konten BIPA 3–7.
- Modul Reading dan simulasi ujian (UKBI).
- Kamus Indonesia–Inggris (data terbuka + penjelasan AI) dan News Indonesia yang disederhanakan (fase 2).
- Bahasa UI selain Inggris (Jepang, Korea, Mandarin). Arsitekturnya disiapkan, isinya belum.
- Suara ElevenLabs.
- Rilis iOS (bundle, sertifikat, App Store listing, IAP Apple).
- Fitur PDF materi belajar (ditunda sampai ada font dan konten yang sesuai).
- Backend multi-app bersama Nihongo dan berbagi akun/pembelian antar aplikasi.
- Fitur khas Jepang apa pun (jobs, SSW, map, manga, kana, kanji, furigana, JLPT/NAT/JFT).

## Further Notes

- Urutan pengerjaan yang disarankan: setup repo → rebranding → hapus modul Jepang (pastikan analyze dan tes hijau) → migrasi ARB → model kurikulum dan API → pipeline konten + TTS → adaptasi layar → akun pihak ketiga dan infrastruktur → website → QA dan rilis. Detail checklist ada di `docs/TODO.md`.
- Migrasi teks UI ke ARB adalah pekerjaan terbesar di sisi Flutter, karena saat ini teks Indonesia ditulis langsung di banyak widget. Kerjakan per fitur, setelah modul Jepang dihapus, supaya jumlah teksnya sudah berkurang.
- Konten MVP butuh reviewer penutur asli/guru BIPA. Ini dependensi di luar kode yang perlu dijadwalkan lebih awal.
- Untuk akun developer personal, Play Store mensyaratkan closed testing minimal 12 tester selama 14 hari sebelum produksi.
- Setelah repo GitHub dibuat, publikasikan spec ini sebagai issue berlabel `ready-for-agent`. Konfigurasi issue tracker untuk skill Matt Pocock bisa diatur lewat `/setup-matt-pocock-skills`.
