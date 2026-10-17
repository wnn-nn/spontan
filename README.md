# PROYEK SPONTAN — SPONSORSHIP PLATFORM MAHASISWA
**Practical Challenge: Workflow Pembuatan Event**

---

## 📁 Struktur Direktori Proyek

Proyek ini dipisahkan secara rapi menjadi dua komponen:
```
tbpmobindividu/
├── backend/                # Server RESTful API (Node.js, Express, MySQL/MariaDB)
│   ├── src/
│   │   ├── config/         # Koneksi Pool MySQL
│   │   ├── constants/      # Kategori & Target Audience Baku
│   │   ├── controllers/    # Auth, Reference, Event (Transaksi Atomik)
│   │   ├── middleware/     # Verifikasi JWT Bearer Token
│   │   ├── routes/         # Routing API
│   │   ├── scripts/        # Inisialisasi Database (initDb.js)
│   │   └── server.js       # Express App Entry Point
│   ├── .env                # Konfigurasi Database & Port
│   └── package.json
│
├── mobile/                 # Aplikasi Mobile (Flutter Android / Multiplatform)
│   ├── lib/
│   │   ├── core/           # AppColors, ApiConstants, ApiService, AuthStorage
│   │   ├── models/         # UserModel, EventModel, ReferenceDataModel
│   │   ├── screens/        # LoginScreen, RegisterScreen, EventListScreen, CreateEventScreen
│   │   └── main.dart
│   └── pubspec.yaml
│
└── prd_spontan_v1.1.md     # Blueprint & Spesifikasi Lengkap
```

---

## 🚀 Panduan Menjalankan Aplikasi

### 1. Menjalankan Backend (Node.js + MySQL)

1. Pastikan service **MySQL / MariaDB** (misal via XAMPP atau Laragon) sudah berjalan.
2. Buka terminal dan masuk ke folder `backend`:
   ```bash
   cd backend
   ```
3. Sesuaikan konfigurasi database pada file `.env` jika username/password MySQL Anda berbeda:
   ```env
   PORT=5000
   DB_HOST=localhost
   DB_USER=root
   DB_PASSWORD=
   DB_NAME=spontan_db
   ```
4. Jalankan perintah inisialisasi database (ini akan otomatis membuat database `spontan_db`, tabel-tabel, dan 1 user demo):
   ```bash
   npm run init-db
   ```
   *User demo siap pakai:*
   * Email: `dhyva@student.unand.ac.id`
   * Password: `password123`
5. Jalankan server backend:
   ```bash
   npm start
   ```
   *(Server akan aktif di `http://localhost:5000`)*

---

### 2. Menjalankan Frontend Flutter

> ⚠️ **Catatan Penting:** Perintah `flutter run` harus dijalankan **di dalam folder `mobile`**, bukan di root direktori utama.

1. Buka terminal baru dan masuk ke direktori `mobile`:
   ```bash
   cd mobile
   ```
2. Jalankan aplikasi ke emulator Android, Chrome, atau perangkat fisik:
   ```bash
   flutter run
   ```

---

## 🧪 Pengujian Alur Workflow (Input → State → Validation → Feedback → Navigation → Result)

1. **Login:** Masuk menggunakan akun demo `dhyva@student.unand.ac.id` / `password123` (atau daftar akun baru).
2. **EventListScreen:** Menampilkan daftar kegiatan yang tersimpan di backend.
3. **Tekan Tombol "Buat Event":** Membuka `CreateEventScreen`.
4. **Validasi 8 Field:**
   * Judul & Deskripsi: Wajib diisi (tidak boleh spasi saja).
   * Kategori: Wajib memilih 1 dari daftar baku backend.
   * Target Audience: Multi-select dengan FilterChips (minimal 1 pilihan).
   * Tanggal: Tanggal mulai & selesai (tanggal selesai $\ge$ tanggal mulai).
   * Lokasi: Wajib diisi.
   * Estimasi Peserta: Wajib angka integer $> 0$.
5. **Penyimpanan Atomik:** Menekan tombol "Buat Event" mengirimkan data dengan token JWT ke backend. Backend melakukan transaksi database atomik pada tabel `events` dan `event_target_audiences`.
6. **Result & Feedback:**
   * Objek `Event` dikembalikan ke `EventListScreen` melalui `Navigator.pop(context, createdEvent)`.
   * `EventListScreen` menampilkan notifikasi SnackBar hijau sukses.
   * Daftar event secara otomatis memuat ulang data terbaru dari database.
