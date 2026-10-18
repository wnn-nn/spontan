# BLUEPRINT & SPESIFIKASI TEKNIS APLIKASI SPONTAN (v1.1)
**Sponsorship Platform Mahasiswa Universitas Andalas**

---

| Dokumen | Deskripsi |
| :--- | :--- |
| **Nama File** | `prd_spontan_v1.1.md` |
| **Aplikasi** | SPONTAN (Sponsorship Platform Mahasiswa) |
| **Target Platform** | Android (min. Android 8.0 Oreo), Flutter Framework |
| **Tim Pengembang** | 1. Dhyva Aulia Hendri (2411521001) – Modul 1: Manajemen Event<br>2. Wanda Fitriardi (2411521004) – Modul 2: Kebutuhan & Proposal<br>3. Anggun Meika Candra (2411521012) – Modul 3: Matching, Rekomendasi & Tracking |
| **Status Dokumen** | Blueprint Pra-Pengkodean (Data, Validasi, State, Navigasi, Struktur Folder) |

---

## DAFTAR ISI
1. [Penetapan Field Entitas yang Digunakan](#1-penetapan-field-entitas-yang-digunakan)
2. [Atribut Wajib (Required) vs Opsional (Optional)](#2-atribut-wajib-required-vs-opsional-optional)
3. [Validasi Field & Aturan Bisnis (Business Logic)](#3-validasi-field--aturan-bisnis-business-logic)
4. [Arsitektur & Manajemen State Aplikasi](#4-arsitektur--manajemen-state-aplikasi)
5. [Alur Navigasi, Routing, & Result Handlers](#5-alur-navigasi-routing--result-handlers)
6. [Struktur Folder Proyek Flutter (Modular per Tim)](#6-struktur-folder-proyek-flutter-modular-per-tim)
7. [Spesifikasi Khusus Workflow: Pembuatan Event](#7-spesifikasi-khusus-workflow-pembuatan-event-practical-challenge)
8. [Kesimpulan & Kesiapan Implementasi Kode](#8-kesimpulan--kesiapan-implementasi-kode)


---

## 1. PENETAPAN FIELD ENTITAS YANG DIGUNAKAN

Berdasarkan PRD v1.1, berikut adalah seluruh data model yang benar-benar dipakai di aplikasi:

### 1.1 Entitas `User` (Mahasiswa)
Menyimpan data identitas mahasiswa Universitas Andalas yang login ke sistem (Single Role).
* `id_user` (String/Int): Identifier unik mahasiswa.
* `nama` (String): Nama lengkap mahasiswa.
* `email` (String): Email mahasiswa/kampus.
* `password` (String): Hash password (hanya saat registrasi/login).
* `nim` (String): Nomor Induk Mahasiswa Unand.
* `program_studi` (String): Jurusan/Program Studi mahasiswa.
* `foto_profil` (String?): URL atau path lokal foto profil.

### 1.2 Entitas `Event` (Modul 1 - Anggota 1)
Data kegiatan kampus yang diajukan untuk mendapatkan sponsor.
* `id_event` (String/Int): Identifier unik event.
* `id_pembuat` (String/Int): Relasi ke `User.id_user`.
* `judul` (String): Nama kegiatan/acara.
* `deskripsi` (String): Rincian penjelasan kegiatan, tujuan, dan latar belakang.
* `kategori` (String): Kategori baku acara (`Seminar`, `Kompetisi`, `PKM`, `Kegiatan Organisasi`, `Lainnya`).
* `target_audience` (String): Target audiens baku (`Mahasiswa`, `Pelajar (SMA/SMK)`, `Masyarakat Umum`, `Komunitas/Profesional`).
* `estimasi_peserta` (Int): Jumlah perkiraan peserta yang hadir.
* `lokasi` (String): Tempat penyelenggaraan (misal: "Auditorium Unand / Hybrid").
* `tanggal_mulai` (DateTime): Tanggal dimulainya acara.
* `tanggal_selesai` (DateTime): Tanggal berakhirnya acara.
* `poster_event` (String?): URL/Path gambar poster kegiatan.
* `status` (String): Status siklus hidup event (`aktif`, `selesai`, `draft`).
* `created_at` (DateTime): Waktu pembuatan event.

### 1.3 Entitas `KebutuhanSponsorship` (Modul 2 - Anggota 2)
Item kebutuhan spesifik yang dibutuhkan event dari pihak sponsor.
* `id_kebutuhan` (String/Int): Identifier unik kebutuhan.
* `id_event` (String/Int): Relasi ke `Event.id_event`.
* `jenis_kebutuhan` (String): Jenis baku (`Dana`, `Barang`, `Media Partner`, `Lainnya`).
* `deskripsi` (String): Rincian kebutuhan (misal: "Konsumsi 200 snack box", "Dana operasional hadiah", dsb.).
* `nilai_estimasi` (Double/Int): Nominal rupiah untuk jenis Dana, atau estimasi valuasi barang/kuantitas.
* `satuan_keterangan` (String?): Keterangan opsional (misal: "Rupiah", "Paket", "Slot").
* `status` (String): Status kebutuhan (`terbuka`, `terpenuhi`).

### 1.4 Entitas `Sponsor` (Master Data - Modul 3)
Data profil perusahaan/brand calon sponsor yang ada di sistem (read-only bagi mahasiswa).
* `id_sponsor` (String/Int): Identifier unik sponsor.
* `nama_brand` (String): Nama perusahaan/produk sponsor.
* `industri` (String): Sektor industri (misal: FMCG, Fintech, Edukasi, F&B, dsb.).
* `deskripsi` (String): Profil singkat sponsor.
* `logo` (String): URL/Asset path logo sponsor.
* `preferensi_kategori` (List<String>): Daftar kategori event yang disukai sponsor.
* `preferensi_target_audience` (List<String>): Daftar target audience yang disasar sponsor.
* `preferensi_jenis_sponsorship` (List<String>): Bentuk bantuan yang didukung sponsor (`Dana`, `Barang`, `Media Partner`, `Lainnya`).
* `kontak_email` (String?): Email humas/sponsorship perusahaan (untuk display info).

### 1.5 Entitas `MatchingScore` (Modul 3 - Anggota 3)
Hasil komputasi kecocokan antara sebuah event dengan calon sponsor.
* `id_matching` (String/Int): Identifier unik record matching.
* `id_event` (String/Int): Relasi ke `Event`.
* `id_sponsor` (String/Int): Relasi ke `Sponsor`.
* `score` (Int): Nilai total 0–100 ($P1 + P2 + P3$).
* `skor_kategori` (Int): Poin parameter kategori ($0$ atau $40$).
* `skor_audience` (Int): Poin parameter audience ($0$ atau $30$).
* `skor_kebutuhan` (Int): Poin parameter jenis kebutuhan ($0$ sampai $30$).
* `label` (String): Label kategori kecocokan (`Tinggi` [75-100], `Sedang` [50-74], `Rendah` [40-49]).
* `alasan_matching` (String): String terformat berisi ringkasan parameter yang terpenuhi.
* `catatan_kurang` (List<String>): Rincian kriteria yang belum cocok.
* `generated_at` (DateTime): Waktu terakhir skor dihitung.

### 1.6 Entitas `Proposal` (Modul 2 & 3 - Anggota 2 & 3)
Data pengajuan sponsorship yang dikirim mahasiswa ke sponsor tertentu.
* `id_proposal` (String/Int): Identifier unik proposal.
* `id_event` (String/Int): Relasi ke `Event`.
* `id_sponsor` (String/Int): Relasi ke `Sponsor`.
* `id_pengirim` (String/Int): Relasi ke `User` (mahasiswa).
* `isi_proposal` (String): Surat pengantar / cover letter / pesan mahasiswa ke sponsor.
* `file_dokumen` (String): File path / URL dokumen proposal (Format PDF).
* `status` (String): Status pengajuan (`draft`, `pending`, `accepted`, `rejected`, `cancelled`).
* `alasan_pembatalan` (String?): Catatan atau alasan pembatalan proposal yang diinputkan oleh mahasiswa saat membatalkan proposal berstatus pending (FR-M3-03).
* `tanggal_kirim` (DateTime?): Waktu proposal dikirim (diisi saat status berubah ke pending).
* `catatan_sponsor` (String?): Feedback atau alasan persetujuan/penolakan dari sponsor (berasal dari API).
* `status_diperbarui_pada` (DateTime?): Timestamp terakhir status diubah oleh API atau saat dibatalkan oleh mahasiswa.

### 1.7 Entitas `SponsorTersimpan` (Modul 3 - Anggota 3)
Bookmark sponsor sasaran yang disimpan mahasiswa per event untuk difollow-up.
* `id` (String/Int): Identifier unik bookmark.
* `id_user` (String/Int): Relasi ke `User`.
* `id_event` (String/Int): Relasi ke `Event`.
* `id_sponsor` (String/Int): Relasi ke `Sponsor`.
* `created_at` (DateTime): Waktu penyimpanan.

### 1.8 Entitas `Notifikasi` (Lintas Modul)
Riwayat notifikasi internal aplikasi.
* `id_notifikasi` (String/Int): Identifier unik notifikasi.
* `id_user` (String/Int): Relasi ke `User`.
* `judul` (String): Judul notifikasi (misal: "Proposal Diterima!").
* `pesan` (String): Isi teks notifikasi.
* `tipe` (String): Kategori notifikasi (`deadline_event`, `proposal_status`, `sponsor_matching`).
* `reference_id` (String?): ID entitas terkait (misal `id_proposal` atau `id_event`).
* `status_baca` (Bool): `true` jika sudah dibaca, default `false`.
* `created_at` (DateTime): Waktu notifikasi dibuat.

---

## 2. ATRIBUT WAJIB (REQUIRED) VS OPSIONAL (OPTIONAL)

Berikut pembagian ketat untuk form input pengguna:

| Modul / Form | Field | Status | Alasan / Catatan |
| :--- | :--- | :--- | :--- |
| **Auth - Registrasi** | `nama` | **Wajib** | Identitas pembuat event |
| | `nim` | **Wajib** | Validasi keaslian mahasiswa Unand |
| | `program_studi` | **Wajib** | Konteks akademik |
| | `email` | **Wajib** | Kredensial login & notifikasi |
| | `password` | **Wajib** | Autentikasi keamanan akun |
| | `foto_profil` | *Opsional* | Boleh menggunakan default avatar avatar |
| **Modul 1 - Form Event** | `judul` | **Wajib** | Identitas acara |
| | `deskripsi` | **Wajib** | Penjelasan event untuk calon sponsor |
| | `kategori` | **Wajib** | Kritis untuk komputasi Matching Score (P1: 40 poin) |
| | `target_audience` | **Wajib** | Kritis untuk komputasi Matching Score (P2: 30 poin) |
| | `estimasi_peserta` | **Wajib** | Metrik pertimbangan daya jangkau sponsor |
| | `lokasi` | **Wajib** | Tempat pelaksanaan |
| | `tanggal_mulai` | **Wajib** | Jadwal & batas perhitungan deadline H-7 |
| | `tanggal_selesai` | **Wajib** | Batas akhir rangkaian kegiatan |
| | `poster_event` | *Opsional* | Pendukung visual; jika kosong gunakan placeholder kategori |
| **Modul 2 - Form Kebutuhan** | `jenis_kebutuhan` | **Wajib** | Kritis untuk komputasi Matching Score (P3: 30 poin) |
| | `deskripsi` | **Wajib** | Rincian detail item yang dibutuhkan |
| | `nilai_estimasi` | **Kondisional** | **Wajib** jika jenis adalah `Dana`; *Opsional* jika `Barang`/`Media Partner` |
| | `satuan_keterangan` | *Opsional* | Tambahan pelengkap info |
| **Modul 2 - Form Proposal** | `id_event` & `id_sponsor` | **Wajib** | Relasi data pengajuan |
| | `isi_proposal` | **Wajib** | Surat pengantar singkat dari mahasiswa |
| | `file_dokumen` | **Wajib** | Berkas proposal lengkap (format PDF) |
| **Modul 3 - Form Pembatalan Proposal** | `alasan_pembatalan` | **Wajib** | Alasan pembatalan oleh mahasiswa saat memperbarui status proposal pending menjadi cancelled (FR-M3-03) |
| **Data Respon API** | `catatan_sponsor` | *Opsional* | Diisi dari API jika sponsor memberikan feedback saat update status |

---

## 3. VALIDASI FIELD & ATURAN BISNIS (BUSINESS LOGIC)

### 3.1 Validasi Input Form (Input-Level Validation)

#### A. Form Registrasi & Akun
1. **Email:** 
   - Wajib diisi.
   - Format regex email valid (`^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$`).
   - Disarankan domain mahasiswa Unand jika ingin dibatasi (misal format `@*.unand.ac.id` atau email aktif).
2. **NIM:**
   - Wajib diisi.
   - Harus angka numerik, tepat 10 digit (standar NIM Unand, contoh `2411521001`).
3. **Password:**
   - Wajib diisi, minimal 6 karakter.
   - Konfirmasi password harus identik (`password == confirmPassword`).
4. **Nama & Program Studi:**
   - Minimal 3 karakter, tidak boleh hanya whitespace.

#### B. Form Event (Modul 1)
1. **Judul Event:**
   - Wajib diisi, minimal 5 karakter, maksimal 100 karakter.
   - Dilengkapi validasi cerdas anti-gibberish & anti-simbol (TitleValidator).
2. **Deskripsi Event:**
   - Wajib diisi, minimal 20 karakter, maksimal 3000 karakter.
   - Dilengkapi validasi cerdas anti-spam & anti-placeholder (DescriptionValidator):
     - Memblokir teks yang sama persis dengan teks placeholder bawaan ("Jelaskan tujuan kegiatan, latar belakang...").
     - Memblokir huruf/karakter berulang berlebihan (misal `aaaaaa`, `zzzzzzzzz`).
     - Memblokir susunan huruf mati/konsonan berurutan yang tidak wajar ($\ge 6$ konsonan).
     - Memblokir ketikan keyboard row smash (misal `asdfghjkl`, `qwertyqwerty`, `zxcvbnm`).
     - Memblokir kata yang diulang berturut-turut atau mendominasi isi demi mengejar batas minimal karakter.
     - Minimal mengandung 10 huruf alfabet dan memiliki huruf vokal.
3. **Kategori Event:**
   - Wajib dipilih dari daftar baku: `Seminar`, `Kompetisi`, `PKM`, `Kegiatan Organisasi`, `Lainnya`. Tidak boleh teks bebas.
3. **Target Audience:**
   - Wajib dipilih dari daftar baku: `Mahasiswa`, `Pelajar (SMA/SMK)`, `Masyarakat Umum`, `Komunitas/Profesional`.
4. **Estimasi Peserta:**
   - Wajib berupa angka integer positif (`estimasi_peserta >= 10`).
5. **Tanggal Mulai & Selesai:**
   - `tanggal_mulai` tidak boleh sebelum hari ini (`tanggal_mulai >= DateTime.now() - 1 hari`).
   - `tanggal_selesai` harus sama dengan atau setelah `tanggal_mulai` (`tanggal_selesai >= tanggal_mulai`).
6. **Upload Poster Event (Kamera/Galeri):**
   - Format file didukung: `.jpg`, `.jpeg`, `.png`.
   - Ukuran maksimal: 5 MB.

#### C. Form Kebutuhan Sponsorship (Modul 2)
1. **Jenis Kebutuhan:**
   - Wajib dipilih dari daftar baku: `Dana`, `Barang`, `Media Partner`, `Lainnya`.
2. **Deskripsi Kebutuhan:**
   - Minimal 5 karakter, maksimal 250 karakter.
3. **Nilai Estimasi:**
   - Jika jenis = `Dana`: Wajib angka numerik $> 0$ (misal minimal Rp 50.000).
   - Jika jenis selain Dana: Opsional (dapat berupa nominal taksiran nilai barang).

#### D. Form Proposal Sponsorship (Modul 2)
1. **Isi Proposal / Pengantar:**
   - Wajib diisi, minimal 20 karakter, maksimal 1000 karakter.
2. **File Dokumen Proposal:**
   - Wajib diunggah melalui File Picker perangkat.
   - Wajib berekstensi `.pdf`.
   - Ukuran maksimal: 10 MB.

#### E. Form / Dialog Pembatalan Proposal (Modul 3 - FR-M3-03)
1. **Alasan Pembatalan:**
   - Wajib diisi saat mahasiswa memperbarui status proposal `pending` menjadi `cancelled`.
   - Minimal 5 karakter, maksimal 500 karakter.
   - Tidak boleh hanya berupa spasi kosong / whitespace.

---

### 3.2 Aturan Bisnis & Logika Sistem (Business Logic Rules)

1. **Aturan Edit Event (FR-M1-03):**
   - Event **TIDAK DAPAT diedit** jika sudah ada proposal berstatus `accepted` pada event tersebut.
   - Jika event berhasil diedit (terutama field `kategori` atau `target_audience`), sistem **otomatis menghitung ulang Matching Score** seluruh sponsor untuk event tersebut.
2. **Aturan Hapus Event (FR-M1-04):**
   - Event **TIDAK DAPAT dihapus** jika memiliki proposal aktif (berstatus `pending` atau `accepted`).
   - Hanya event berstatus draft atau yang proposalnya berstatus `rejected`/belum ada proposal yang boleh dihapus.
3. **Aturan Perubahan Kebutuhan Sponsorship (FR-M2-03):**
   - Setiap kali kebutuhan sponsorship ditambah, diubah jenisnya, atau dihapus, sistem **otomatis menghitung ulang Matching Score** (parameter P3).
4. **Aturan Hapus Proposal (FR-M2-04):**
   - Mahasiswa hanya dapat menghapus proposal yang masih berstatus `draft`.
5. **Aturan Pembatalan Proposal (FR-M3-03 & FR-M3-04):**
   - Mahasiswa hanya dapat membatalkan proposal yang masih berstatus `pending` (FR-M3-04).
   - Pembatalan proposal memperbarui status proposal menjadi `cancelled` serta **wajib menyertakan inputan alasan pembatalan** oleh mahasiswa (FR-M3-03).
   - Proposal yang sudah berstatus `accepted`, `rejected`, atau `cancelled` bersifat **final** dan tidak dapat dibatalkan atau diubah statusnya kembali oleh mahasiswa.
6. **Aturan Matching Score (PRD §2.8):**
   - Rumus: $\text{Score} = P1 + P2 + P3$
   - $P1$ (Kategori): $40$ jika match, $0$ jika tidak.
   - $P2$ (Target Audience): $30$ jika match, $0$ jika tidak.
   - $P3$ (Jenis Kebutuhan): $30 \times (\text{jenis cocok} / \text{total jenis event})$. Jika event belum memiliki kebutuhan sponsorship, $P3 = 0$.
   - **Ambang Tampil:** Hanya sponsor dengan $\text{Score} \ge 40$ yang muncul di daftar rekomendasi.
   - **Label:**
     - $75 - 100$: **Tinggi**
     - $50 - 74$: **Sedang**
     - $40 - 49$: **Rendah**
     - $< 40$: Tidak ditampilkan.
   - **Urutan Tampil:** Skor tertinggi ke terendah, lalu alfabet nama brand ($A-Z$).
7. **Aturan Status Proposal Berbasis API (PRD §2.9):**
   - Aplikasi mahasiswa membaca (*read-only*) status `accepted` dan `rejected` dari API.
   - Mahasiswa dapat memperbarui status proposal dari `pending` menjadi `cancelled` melalui aplikasi dengan menyertakan inputan alasan pembatalan (FR-M3-03).
   - Aplikasi mengambil update saat: (1) aplikasi baru dibuka, dan (2) pengguna melakukan *pull-to-refresh*.
   - Jika terdeteksi perubahan status dari `pending` ke `accepted`/`rejected`, sistem memicu Notifikasi Lokal dalam waktu $\le 5$ detik (NFR-05).
   - Jika API offline saat refresh, tampilkan Snackbar peringatan dan pertahankan data offline terakhir di layar (NFR-06).

---

## 4. ARSITEKTUR & MANAJEMEN STATE APLIKASI

Untuk kemudahan pengembangan kolaboratif 3 orang dan kebersihan kode, aplikasi menggunakan pola **Provider** (atau **Riverpod**) dengan pemisahan status UI baku (**UI State Pattern**).

### 4.1 Standar State UI (State Pattern)
Setiap controller/provider menggunakan enum atau sealed class untuk menangani siklus hidup tampilan:
```dart
enum ViewStatus { initial, loading, success, empty, error }
```
* **Initial:** State awal sebelum aksi dijalankan.
* **Loading:** Menampilkan indikator loading (shimmer skeleton atau spinner).
* **Success:** Data berhasil didapatkan dan siap dirender.
* **Empty:** Data berhasil diambil tetapi kosong (menampilkan ilustrasi & pesan ramah pengguna).
* **Error:** Terjadi kegagalan jaringan/validasi (menampilkan pesan kesalahan & tombol *Retry*).

---

### 4.2 Pemetaan State per Modul & Penanggung Jawab

#### A. Auth State (`AuthProvider`)
* **Variabel State:**
  * `currentUser`: Objek `User?` yang sedang login.
  * `isAuthenticated`: Boolean status login.
  * `authStatus`: `ViewStatus`.
  * `errorMessage`: Pesan error jika login/register gagal.
* **Method Aksi:**
  * `login(email, password)`
  * `register(UserRegistrationData)`
  * `logout()`
  * `checkAuthSession()`

#### B. Modul 1: Event State (`EventProvider` - Dhyva)
* **Variabel State:**
  * `myEvents`: List `Event` milik pengguna yang sedang login.
  * `selectedEvent`: Objek `Event?` yang sedang dibuka detailnya.
  * `eventStatus`: `ViewStatus`.
  * `actionStatus`: `ViewStatus` (untuk aksi create/update/delete).
  * `filterCategory`: Filter kategori event yang sedang aktif di UI.
* **Method Aksi:**
  * `fetchMyEvents()`: Mengambil seluruh event mahasiswa.
  * `getEventById(id)`: Mengambil detail lengkap 1 event.
  * `createEvent(Event)`: Menambah event baru $\rightarrow$ otomatis memicu matching.
  * `updateEvent(Event)`: Memperbarui data event (cek validasi FR-M1-03).
  * `deleteEvent(id)`: Menghapus event (cek validasi FR-M1-04).

#### C. Modul 2: Kebutuhan & Proposal State (`ProposalProvider` & `KebutuhanProvider` - Wanda)
* **Variabel State:**
  * `eventNeeds`: List `KebutuhanSponsorship` untuk event yang dipilih.
  * `myProposals`: List `Proposal` mahasiswa (dengan tab status: *Semua*, *Pending*, *Diterima*, *Ditolak*, *Draft*).
  * `selectedProposal`: Objek `Proposal?` detail.
  * `selectedFile`: File PDF yang dipilih dari file picker.
  * `proposalStatus`: `ViewStatus`.
  * `submitStatus`: `ViewStatus`.
* **Method Aksi:**
  * `fetchNeedsByEvent(idEvent)`
  * `addNeed(KebutuhanSponsorship)` $\rightarrow$ pemicu kalkulasi ulang matching.
  * `updateNeed(KebutuhanSponsorship)`
  * `deleteNeed(idNeed)`
  * `pickProposalDocument()`: Membuka FilePicker perangkat untuk memilih PDF.
  * `submitProposal(ProposalPayload)`: Mengirim proposal ke API dengan status awal `pending`.
  * `deleteDraftProposal(idProposal)`
  * `cancelPendingProposal(idProposal, alasanPembatalan)`: Memperbarui status proposal pending menjadi cancelled dengan menyertakan alasan pembatalan (FR-M3-03).

#### D. Modul 3: Matching & Tracking State (`MatchingProvider` & `TrackingProvider` - Anggun)
* **Variabel State:**
  * `recommendations`: List `MatchingScore` terurut untuk event aktif.
  * `savedSponsors`: List `SponsorTersimpan` milik mahasiswa.
  * `trackingList`: List proposal aktif yang sedang dipantau statusnya.
  * `matchingStatus`: `ViewStatus`.
  * `isRefreshing`: Boolean status saat pull-to-refresh.
* **Method Aksi:**
  * `calculateMatching(idEvent)`: Menjalankan kalkulasi rule-based P1, P2, P3 berdasarkan data event & kebutuhan.
  * `fetchRecommendations(idEvent)`: Mengambil daftar rekomendasi sponsor (Score $\ge 40$).
  * `toggleSaveSponsor(idEvent, idSponsor)`: Menambah/menghapus sponsor dari daftar sasaran (FR-M3-01).
  * `cancelProposal(idProposal, alasanPembatalan)`: Memperbarui status proposal pending menjadi cancelled serta menyimpan inputan alasan pembatalan ke backend (FR-M3-03 & FR-M3-04).
  * `refreshProposalStatuses()`: Memanggil endpoint API untuk mengambil status proposal terbaru, membandingkan status lama vs baru, dan memicu notifikasi jika ada perubahan status.

#### E. Modul Notifikasi (`NotificationProvider`)
* **Variabel State:**
  * `notifications`: List `Notifikasi`.
  * `unreadCount`: Integer jumlah notifikasi belum dibaca.
* **Method Aksi:**
  * `fetchNotifications()`
  * `markAsRead(idNotifikasi)`
  * `addSystemNotification(NotificationItem)`: Dijalankan ketika aplikasi mendeteksi perubahan status atau pengingat H-7.

---

## 5. ALUR NAVIGASI, ROUTING, & RESULT HANDLERS

Aplikasi menggunakan alur navigasi terpusat dengan `Named Routes` atau direct `MaterialPageRoute`.

### 5.1 Diagram Alur Layar (Screen Flow)

```
[Splash Screen]
      │
      ▼
(Cek Sesi Login) ──[Belum Login]──► [Login Screen] ◄──► [Register Screen]
      │                                    │
      ▼ [Sudah Login]                      ▼ [Sukses]
┌───────────────────────────────────────────────────────────────┐
│               MAIN NAVIGATION SCREEN (Bottom Nav)             │
│  ├── [Tab 1: Beranda]        ──► Ringkasan, Deadline H-7      │
│  ├── [Tab 2: Event Saya]     ──► List Event, FAB Tambah Event │
│  ├── [Tab 3: Rekomendasi]    ──► Matching Sponsor per Event   │
│  ├── [Tab 4: Tracking]       ──► Status Proposal (API Sync)   │
│  └── [Tab 5: Profil]         ──► Profil, Saved Sponsor        │
└──────────────────────────────┬────────────────────────────────┘
                               │
       ┌───────────────────────┼────────────────────────┐
       ▼                       ▼                        ▼
[Detail Event]           [Detail Sponsor]        [Detail Proposal]
 ├── Edit Event           ├── Rincian Skor P1-P3  ├── Info Status & Catatan
 ├── Kelola Kebutuhan     ├── Bookmark Sponsor    └── Batalkan Proposal (Dialog Input Alasan)
 └── Ajukan Proposal      └── Ajukan Proposal         └── Update Status: Cancelled
       │
       ▼
 [Form Kirim Proposal] ──► (Upload PDF) ──► (Kirim: Pending)
```

---

### 5.2 Rincian Rute, Parameter, & Return Value (Result Handlers)

| Nama Rute | Layar | Parameter Masuk (Args) | Nilai Balik (Navigator.pop Result) | Aksi Handler Setelah Pop |
| :--- | :--- | :--- | :--- | :--- |
| `/login` | `LoginScreen` | Tidak ada | `bool` (isSuccess) | Jika true, ganti root ke `/main` |
| `/register` | `RegisterScreen` | Tidak ada | `bool` (isSuccess) | Jika true, isi field email di login & tampilkan toast sukses |
| `/main` | `MainNavigationScreen`| `int? initialIndex` | - | Root layar setelah autentikasi |
| `/event-detail` | `EventDetailScreen` | `String idEvent` | `bool? isDataChanged` | Jika true, refresh list event di halaman induk |
| `/event-form` | `EventFormScreen` | `Event? existingEvent` | `bool? isSaved` | Jika true: SnackBar "Event berhasil disimpan" + reload event list |
| `/kebutuhan-form`| `KebutuhanFormScreen`| `String idEvent, Kebutuhan? item` | `bool? isSaved` | Jika true: SnackBar "Kebutuhan diperbarui" + reload matching score |
| `/sponsor-detail`| `SponsorDetailScreen`| `Sponsor sponsor, MatchingScore? score` | - | Aksi bookmark / lanjut ke form pengajuan proposal |
| `/proposal-form` | `ProposalFormScreen`| `Event event, Sponsor sponsor` | `bool? isSubmitted` | Jika true: SnackBar "Proposal berhasil diajukan!" $\rightarrow$ Navigasi ke Tab Tracking |
| `/proposal-detail`|`ProposalDetailScreen`| `String idProposal` | `bool? isCancelled` | Jika true: SnackBar "Proposal berhasil dibatalkan (Status: Cancelled)" + refresh data |
| `/notifications` | `NotificationScreen` | Tidak ada | - | Mark all as read saat dibuka |
| `/saved-sponsors`| `SavedSponsorsScreen`| Tidak ada | - | Tampilkan daftar sponsor sasaran |

---

## 6. STRUKTUR FOLDER PROYEK FLUTTER (MODULAR PER TIM)

Struktur folder mengadopsi arsitektur **Feature-First** (fitur modular) agar ketiga anggota tim dapat bekerja secara independen tanpa menimbulkan konflik file (*git merge conflict*).

```
lib/
│
├── main.dart                      # Entry point aplikasi, setup Provider & Theme
├── app.dart                       # Konfigurasi MaterialApp, routing, dan global theme
│
├── core/                          # Folder Bersama (Shared Core)
│   ├── constants/
│   │   ├── app_colors.dart        # Palet warna primer, sekunder, accent
│   │   ├── app_constants.dart     # Kategori baku, audience baku, bobot (P1=40, P2=30, P3=30)
│   │   └── api_endpoints.dart     # URL endpoint REST API / Mock API
│   ├── network/
│   │   ├── api_client.dart        # Http/Dio wrapper dengan error handling NFR-06
│   │   └── mock_data.dart         # Data mock sponsor, proposal, dan event untuk testing
│   ├── utils/
│   │   ├── date_formatter.dart    # Konversi DateTime ke format Indonesia (contoh: 12 Okt 2026)
│   │   ├── currency_formatter.dart# Format Rupiah (Rp 1.000.000)
│   │   └── validators.dart        # Validasi regex email, NIM, input required, file size
│   └── widgets/
│       ├── custom_button.dart     # Komponen tombol umum
│       ├── custom_text_field.dart # Komponen input form dengan validasi bawaan
│       ├── state_views.dart       # Widget Loading, EmptyState, dan ErrorView reusable
│       └── score_badge.dart       # Widget visual badge skor (Tinggi: Hijau, Sedang: Kuning, Rendah: Merah)
│
├── features/                      # Modul Fitur (Pembagian Tugas Anggota Tim)
│   │
│   ├── auth/                      # Otentikasi Mahasiswa
│   │   ├── data/
│   │   │   ├── auth_repository.dart
│   │   │   └── user_model.dart
│   │   └── presentation/
│   │       ├── auth_provider.dart
│   │       ├── login_screen.dart
│   │       └── register_screen.dart
│   │
│   ├── event/                     # MODUL 1: MANAJEMEN EVENT (Dhyva Aulia Hendri)
│   │   ├── data/
│   │   │   ├── event_model.dart
│   │   │   └── event_repository.dart
│   │   └── presentation/
│   │       ├── event_provider.dart
│   │       ├── event_list_screen.dart
│   │       ├── event_detail_screen.dart
│   │       ├── event_form_screen.dart
│   │       └── widgets/
│   │           ├── event_card.dart
│   │           └── date_picker_field.dart
│   │
│   ├── kebutuhan/                 # MODUL 2A: KEBUTUHAN SPONSORSHIP (Wanda Fitriardi)
│   │   ├── data/
│   │   │   ├── kebutuhan_model.dart
│   │   │   └── kebutuhan_repository.dart
│   │   └── presentation/
│   │       ├── kebutuhan_provider.dart
│   │       ├── kebutuhan_form_screen.dart
│   │       └── widgets/
│   │           └── kebutuhan_item_card.dart
│   │
│   ├── proposal/                  # MODUL 2B: PENGAJUAN PROPOSAL (Wanda Fitriardi)
│   │   ├── data/
│   │   │   ├── proposal_model.dart
│   │   │   └── proposal_repository.dart
│   │   └── presentation/
│   │       ├── proposal_provider.dart
│   │       ├── proposal_form_screen.dart      # Form upload dokumen PDF & submit
│   │       └── widgets/
│   │           └── file_picker_box.dart       # Komponen visual upload PDF
│   │
│   ├── matching/                  # MODUL 3A: MATCHING & REKOMENDASI (Anggun Meika Candra)
│   │   ├── domain/
│   │   │   └── matching_calculator.dart       # Algoritma Rule-based P1 (40) + P2 (30) + P3 (30)
│   │   ├── data/
│   │   │   ├── sponsor_model.dart
│   │   │   ├── matching_model.dart
│   │   │   └── matching_repository.dart
│   │   └── presentation/
│   │       ├── matching_provider.dart
│   │       ├── recommendation_list_screen.dart# Daftar rekomendasi sponsor terurut
│   │       ├── sponsor_detail_screen.dart     # Penjelasan skor & rincian kriteria
│   │       └── widgets/
│   │           ├── match_reason_card.dart     # Rincian parameter cocok/tidak cocok
│   │           └── sponsor_card.dart
│   │
│   ├── tracking/                  # MODUL 3B: TRACKING STATUS PROPOSAL (Anggun Meika Candra)
│   │   ├── presentation/
│   │   │   ├── tracking_provider.dart
│   │   │   ├── tracking_screen.dart           # Layar status proposal (Pending/Accepted/Rejected)
│   │   │   ├── proposal_detail_screen.dart    # Detail status, catatan sponsor dari API
│   │   │   └── widgets/
│   │   │       ├── status_timeline.dart       # Komponen visual progres pengajuan
│   │   │       └── status_badge.dart
│   │
│   ├── saved_sponsor/             # MODUL 3C: SPONSOR SASARAN/BOOKMARK (Anggun Meika Candra)
│   │   └── presentation/
│   │       ├── saved_sponsor_screen.dart
│   │       └── saved_sponsor_provider.dart
│   │
│   └── notification/              # NOTIFIKASI SISTEM
│       ├── data/
│       │   └── notification_model.dart
│       └── presentation/
│           ├── notification_provider.dart
│           ├── notification_screen.dart
│           └── widgets/
│               └── notification_item_tile.dart
│
└── presentation/                  # Main Shell / Navigasi Induk
    └── main_navigation_screen.dart# BottomNavigationBar (Beranda, Event, Rekomendasi, Tracking, Profil)
```

---

## 7. SPESIFIKASI KHUSUS WORKFLOW: PEMBUATAN EVENT (PRACTICAL CHALLENGE)

Bagian ini mendefinisikan secara spesifik implementasi alur **Pembuatan Event** yang menghubungkan Frontend Flutter, Backend Express.js, dan Database MySQL/MariaDB.

### 7.1 Rantai Alur Kerja (Workflow Chain)
```
Input (8 Field) ──► State (Controllers & Reactive Vars) ──► Validation (Form Validator & Date Logic)
       │
       ▼
Feedback (Loading / Error Banner) ──► API Call (POST /api/events with JWT) ──► Atomic DB Transaction
       │
       ▼
Result (Created Event Object) ──► Navigation Pop ──► EventListScreen Reload & SnackBar Success
```

### 7.2 Backend & Database Architecture

#### A. Stack Teknologi
* **Runtime & Framework:** Node.js + Express.js
* **Database:** MySQL / MariaDB (Driver: `mysql2` dengan connection pool & transaction support)
* **Keamanan:** `bcrypt` (password hashing) & `jsonwebtoken` (JWT access token)

#### B. Skema Database (DDL)
```sql
-- 1. Tabel users
CREATE TABLE users (
  id_user INT AUTO_INCREMENT PRIMARY KEY,
  nama VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2. Tabel events
CREATE TABLE events (
  id_event INT AUTO_INCREMENT PRIMARY KEY,
  id_pembuat INT NOT NULL,
  judul VARCHAR(150) NOT NULL,
  deskripsi TEXT NOT NULL,
  tanggal_mulai DATE NOT NULL,
  tanggal_selesai DATE NOT NULL,
  lokasi VARCHAR(150) NOT NULL,
  kategori VARCHAR(50) NOT NULL,
  estimasi_peserta INT NOT NULL,
  status ENUM('draft', 'aktif', 'selesai') DEFAULT 'draft',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_pembuat) REFERENCES users(id_user) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 3. Tabel event_target_audiences (Relasi 1:N Atomic)
CREATE TABLE event_target_audiences (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_event INT NOT NULL,
  target_audience VARCHAR(50) NOT NULL,
  UNIQUE KEY unique_event_audience (id_event, target_audience),
  FOREIGN KEY (id_event) REFERENCES events(id_event) ON DELETE CASCADE
) ENGINE=InnoDB;
```

#### C. Endpoint API Spesifik
1. `POST /api/auth/register`
   - Request Body: `{ nama, email, password }`
   - Response: `{ message: "Registrasi berhasil", user: { id_user, nama, email } }`
2. `POST /api/auth/login`
   - Request Body: `{ email, password }`
   - Response: `{ token: "jwt_access_token", user: { id_user, nama, email } }`
3. `GET /api/auth/me` (Protected with Bearer Token)
   - Response: `{ user: { id_user, nama, email } }`
4. `GET /api/reference-data`
   - Response:
     ```json
     {
       "categories": [
         "Seminar",
         "Kompetisi",
         "PKM",
         "Kegiatan Organisasi",
         "Lainnya"
       ],
       "targetAudiences": [
         "Mahasiswa",
         "Pelajar (SMA/SMK)",
         "Masyarakat Umum",
         "Komunitas/Profesional"
       ]
     }
     ```
5. `GET /api/events` (Protected with Bearer Token)
   - Mengambil seluruh event milik `id_pembuat` yang terautentikasi (beserta array `target_audiences`).
6. `POST /api/events` (Protected with Bearer Token)
   - Request Body:
     ```json
     {
       "judul": "Seminar Nasional AI & Karir 2026",
       "deskripsi": "Seminar teknologi untuk mahasiswa dan umum...",
       "kategori": "Seminar",
       "target_audiences": ["Mahasiswa", "Masyarakat Umum"],
       "tanggal_mulai": "2026-11-10",
       "tanggal_selesai": "2026-11-10",
       "lokasi": "Convention Hall Universitas Andalas",
       "estimasi_peserta": 250
     }
     ```
   - Aturan Backend:
     - `id_pembuat` diekstrak dari JWT token (`req.user.id_user`), BUKAN dari payload client!
     - `status` otomatis di-set ke `'draft'`.
     - Menggunakan **Database Transaction** (`START TRANSACTION`, `INSERT INTO events`, bulk `INSERT INTO event_target_audiences`, `COMMIT`). Jika salah satu gagal $\rightarrow$ `ROLLBACK`.

---

### 7.3 Frontend Flutter Implementation Details

#### A. Layar 1: `EventListScreen`
* **State:**
  * `events`: `List<Event>`
  * `isLoadingEvents`: `bool`
  * `eventsError`: `String?`
* **Elemen UI:**
  * Header / AppBar: "Event Saya" + Indikator User / Logout
  * Body:
    * Loading: `CircularProgressIndicator`
    * Error: Text error + tombol "Coba Lagi" (`onRetry`)
    * Empty: Ilustrasi "Belum ada event yang dibuat"
    * Success: `ListView.builder` menampilkan `EventCard` (Badge status `draft`, tanggal, kategori, chips audience, lokasi)
  * FloatingActionButton / Tombol: "Buat Event"
* **Aksi Navigasi:**
  ```dart
  final createdEvent = await Navigator.push<Event>(
    context,
    MaterialPageRoute(builder: (context) => const CreateEventScreen()),
  );
  if (createdEvent != null && mounted) {
    // 1. Tampilkan Feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Event "${createdEvent.judul}" berhasil dibuat!'),
        backgroundColor: Colors.green,
      ),
    );
    // 2. Refresh list dari API
    _fetchEvents();
  }
  ```

#### B. Layar 2: `CreateEventScreen`
* **State & Controllers:**
  * `final _formKey = GlobalKey<FormState>();`
  * `final _judulController = TextEditingController();`
  * `final _deskripsiController = TextEditingController();`
  * `final _lokasiController = TextEditingController();`
  * `final _pesertaController = TextEditingController();`
  * `String? _selectedCategory;`
  * `final Set<String> _selectedTargetAudiences = {};`
  * `DateTime? _startDate;`
  * `DateTime? _endDate;`
  * `bool _isLoadingReferenceData = false;`
  * `String? _referenceDataError;`
  * `bool _isSubmitting = false;`
  * `String? _submitError;`
* **Siklus Hidup (Lifecycle):**
  * `initState()`: Panggil `_loadReferenceData()` via `GET /api/reference-data`.
  * `dispose()`: Panggil `.dispose()` pada seluruh `TextEditingController`.
* **Form & Validation Logic:**
  1. *Kelompok 1: Informasi Event*
     * Judul: `value.trim().isEmpty ? 'Judul event wajib diisi' : null`
     * Deskripsi: `value.trim().isEmpty ? 'Deskripsi event wajib diisi' : null`
     * Kategori: Dropdown/Radio; validasi `_selectedCategory == null ? 'Pilih kategori event' : null`
     * Target Audience: FilterChips; validasi `_selectedTargetAudiences.isEmpty ? 'Pilih minimal satu target audience' : null`
  2. *Kelompok 2: Pelaksanaan Event*
     * Tanggal Mulai: DatePicker; validasi `_startDate == null ? 'Tanggal mulai wajib dipilih' : null`
     * Tanggal Selesai: DatePicker; validasi:
       * `_endDate == null ? 'Tanggal selesai wajib dipilih'`
       * `_endDate.isBefore(_startDate) ? 'Tanggal selesai tidak boleh lebih awal dari tanggal mulai'`
     * Lokasi: `value.trim().isEmpty ? 'Lokasi kegiatan wajib diisi' : null`
     * Estimasi Peserta: Number field; validasi `int.tryParse(value) == null || int.parse(value) <= 0 ? 'Masukkan bilangan bulat lebih dari 0' : null`
* **Submit Handler:**
  1. Trigger `if (!_formKey.currentState!.validate()) return;`
  2. Tambahan validasi chips audience & tanggal.
  3. Set state `_isSubmitting = true; _submitError = null;`
  4. Kirim request `POST /api/events` via HTTP Client dengan `Bearer Token`.
  5. Jika Gagal: Set state `_isSubmitting = false; _submitError = response.message;` (Form & isi controller TETAP UTUH).
  6. Jika Berhasil: `Navigator.pop(context, newEvent);`

---

## 8. KESIMPULAN & KESIAPAN IMPLEMENTASI KODE

Dengan spesifikasi workflow yang telah disempurnakan:
1. **Frontend Flutter** telah memiliki arsitektur form yang kokoh dengan validasi 8 field dan penanganan state yang bersih (`dispose()`, non-intrusif error retention).
2. **Backend Express.js** mengimplementasikan otentikasi JWT, referensi data dinamis, dan transaksi database MySQL secara atomik untuk mencegah inkonsistensi data relasi event dan target audience.
3. **Alur Navigasi & Result** terhubung langsung: `CreateEventScreen` $\rightarrow$ simpan backend $\rightarrow$ kembalikan `Event` via `Navigator.pop` $\rightarrow$ `EventListScreen` reload data dan menampilkan feedback visual kepada pengguna.

