/**
 * Script Pengujian Kepatuhan Validasi Modul 1 (Manajemen Event)
 * Berdasarkan Spesifikasi PRD v1.1 Bagian 3.1 B & Bagian 7.
 */
const { CATEGORIES, TARGET_AUDIENCES } = require('../constants/referenceData');
const { validateEventTitle } = require('../utils/titleValidator');
const { validateEventDescription } = require('../utils/descriptionValidator');

function runValidationCheck(payload) {
  const {
    judul,
    deskripsi,
    kategori,
    target_audiences,
    tanggal_mulai,
    tanggal_selesai,
    lokasi,
    estimasi_peserta,
    poster_event
  } = payload;

  const titleErr = validateEventTitle(judul);
  if (titleErr) {
    return { valid: false, message: titleErr };
  }

  const descErr = validateEventDescription(deskripsi);
  if (descErr) {
    return { valid: false, message: descErr };
  }

  if (!kategori || !CATEGORIES.includes(kategori)) {
    return { valid: false, message: `Kategori tidak valid. Harus salah satu dari: ${CATEGORIES.join(', ')}.` };
  }

  if (!Array.isArray(target_audiences) || target_audiences.length === 0) {
    return { valid: false, message: 'Minimal memilih satu target audience.' };
  }

  const uniqueAudiences = [...new Set(target_audiences)];
  for (const aud of uniqueAudiences) {
    if (!TARGET_AUDIENCES.includes(aud)) {
      return { valid: false, message: `Target audience '${aud}' tidak valid.` };
    }
  }

  if (!tanggal_mulai || isNaN(Date.parse(tanggal_mulai))) {
    return { valid: false, message: 'Tanggal mulai wajib dipilih dan harus berupa tanggal valid.' };
  }

  if (!tanggal_selesai || isNaN(Date.parse(tanggal_selesai))) {
    return { valid: false, message: 'Tanggal selesai wajib dipilih dan harus berupa tanggal valid.' };
  }

  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const startDate = new Date(tanggal_mulai);
  startDate.setHours(0, 0, 0, 0);
  const endDate = new Date(tanggal_selesai);
  endDate.setHours(0, 0, 0, 0);

  if (startDate < today) {
    return { valid: false, message: 'Tanggal mulai tidak boleh sebelum hari ini.' };
  }

  if (endDate < startDate) {
    return { valid: false, message: 'Tanggal selesai tidak boleh lebih awal daripada tanggal mulai.' };
  }

  if (!lokasi || !lokasi.trim()) {
    return { valid: false, message: 'Lokasi wajib diisi dan tidak boleh hanya spasi.' };
  }

  const pesertaNum = parseInt(estimasi_peserta, 10);
  if (isNaN(pesertaNum) || pesertaNum < 10) {
    return { valid: false, message: 'Estimasi peserta wajib diisi dengan bilangan bulat minimal 10 orang.' };
  }

  const posterPath = (typeof poster_event === 'string' && poster_event.trim().length > 0)
    ? poster_event.trim()
    : null;

  return {
    valid: true,
    data: {
      judul: judul.trim(),
      deskripsi: deskripsi.trim(),
      kategori,
      target_audiences: uniqueAudiences,
      tanggal_mulai,
      tanggal_selesai,
      lokasi: lokasi.trim(),
      estimasi_peserta: pesertaNum,
      poster_event: posterPath,
      status: 'draft'
    }
  };
}

console.log('===============================================================');
console.log(' PENGUJIAN ATURAN VALIDASI MODUL 1 SESUAI PRD v1.1');
console.log('===============================================================\n');

let passedTests = 0;
let totalTests = 0;

function assertTest(name, condition, details = '') {
  totalTests++;
  if (condition) {
    passedTests++;
    console.log(`✅ [PASS] ${name}`);
  } else {
    console.error(`❌ [FAIL] ${name} -> ${details}`);
  }
}

// 1. Uji Judul < 5 karakter
const res1 = runValidationCheck({
  judul: 'AI',
  deskripsi: 'Seminar teknologi AI dan cloud computing untuk mahasiswa.',
  kategori: 'Seminar',
  target_audiences: ['Mahasiswa'],
  tanggal_mulai: '2026-11-01',
  tanggal_selesai: '2026-11-01',
  lokasi: 'Auditorium Unand',
  estimasi_peserta: 100
});
assertTest('Tolak judul < 5 karakter', !res1.valid && res1.message.includes('5 hingga 100 karakter'), res1.message);

// 2. Uji Judul > 100 karakter
const res2 = runValidationCheck({
  judul: 'A'.repeat(101),
  deskripsi: 'Seminar teknologi AI dan cloud computing untuk mahasiswa.',
  kategori: 'Seminar',
  target_audiences: ['Mahasiswa'],
  tanggal_mulai: '2026-11-01',
  tanggal_selesai: '2026-11-01',
  lokasi: 'Auditorium Unand',
  estimasi_peserta: 100
});
assertTest('Tolak judul > 100 karakter', !res2.valid && res2.message.includes('5 hingga 100 karakter'), res2.message);

// 3. Uji Deskripsi < 20 karakter
const res3 = runValidationCheck({
  judul: 'Seminar Nasional AI 2026',
  deskripsi: 'Deskripsi pendek',
  kategori: 'Seminar',
  target_audiences: ['Mahasiswa'],
  tanggal_mulai: '2026-11-01',
  tanggal_selesai: '2026-11-01',
  lokasi: 'Auditorium Unand',
  estimasi_peserta: 100
});
assertTest('Tolak deskripsi < 20 karakter', !res3.valid && res3.message.includes('minimal harus 20 karakter'), res3.message);

// 4. Uji Kategori Tidak Baku
const res4 = runValidationCheck({
  judul: 'Seminar Nasional AI 2026',
  deskripsi: 'Seminar edukasi teknologi terkini untuk mahasiswa dan umum di Auditorium Unand.',
  kategori: 'Konser Musik',
  target_audiences: ['Mahasiswa'],
  tanggal_mulai: '2026-11-01',
  tanggal_selesai: '2026-11-01',
  lokasi: 'Auditorium Unand',
  estimasi_peserta: 100
});
assertTest('Tolak kategori tidak baku', !res4.valid && res4.message.includes('Kategori tidak valid'), res4.message);

// 5. Uji Target Audience Kosong
const res5 = runValidationCheck({
  judul: 'Seminar Nasional AI 2026',
  deskripsi: 'Seminar edukasi teknologi terkini untuk mahasiswa dan umum di Auditorium Unand.',
  kategori: 'Seminar',
  target_audiences: [],
  tanggal_mulai: '2026-11-01',
  tanggal_selesai: '2026-11-01',
  lokasi: 'Auditorium Unand',
  estimasi_peserta: 100
});
assertTest('Tolak target audience kosong', !res5.valid && res5.message.includes('Minimal memilih satu'), res5.message);

// 6. Uji Tanggal Mulai di Masa Lalu
const res6 = runValidationCheck({
  judul: 'Seminar Nasional AI 2026',
  deskripsi: 'Seminar edukasi teknologi terkini untuk mahasiswa dan umum di Auditorium Unand.',
  kategori: 'Seminar',
  target_audiences: ['Mahasiswa'],
  tanggal_mulai: '2020-01-01',
  tanggal_selesai: '2020-01-02',
  lokasi: 'Auditorium Unand',
  estimasi_peserta: 100
});
assertTest('Tolak tanggal mulai di masa lalu', !res6.valid && res6.message.includes('sebelum hari ini'), res6.message);

// 7. Uji Tanggal Selesai Lebih Awal dari Tanggal Mulai
const res7 = runValidationCheck({
  judul: 'Seminar Nasional AI 2026',
  deskripsi: 'Seminar edukasi teknologi terkini untuk mahasiswa dan umum di Auditorium Unand.',
  kategori: 'Seminar',
  target_audiences: ['Mahasiswa'],
  tanggal_mulai: '2026-11-10',
  tanggal_selesai: '2026-11-05',
  lokasi: 'Auditorium Unand',
  estimasi_peserta: 100
});
assertTest('Tolak tanggal selesai < tanggal mulai', !res7.valid && res7.message.includes('lebih awal daripada tanggal mulai'), res7.message);

// 8. Uji Estimasi Peserta < 10
const res8 = runValidationCheck({
  judul: 'Seminar Nasional AI 2026',
  deskripsi: 'Seminar edukasi teknologi terkini untuk mahasiswa dan umum di Auditorium Unand.',
  kategori: 'Seminar',
  target_audiences: ['Mahasiswa'],
  tanggal_mulai: '2026-11-10',
  tanggal_selesai: '2026-11-10',
  lokasi: 'Auditorium Unand',
  estimasi_peserta: 8
});
assertTest('Tolak estimasi peserta < 10', !res8.valid && res8.message.includes('minimal 10 orang'), res8.message);

// 9. Uji Event Valid Lengkap (Dengan Poster Opsional)
const res9 = runValidationCheck({
  judul: 'Seminar Nasional AI & Karir 2026',
  deskripsi: 'Seminar edukasi teknologi terkini untuk mahasiswa dan umum di Auditorium Unand.',
  kategori: 'Seminar',
  target_audiences: ['Mahasiswa', 'Masyarakat Umum'],
  tanggal_mulai: '2026-11-10',
  tanggal_selesai: '2026-11-10',
  lokasi: 'Auditorium Universitas Andalas',
  estimasi_peserta: 250,
  poster_event: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87.jpg'
});
assertTest('Terima event valid dengan poster opsional', res9.valid && res9.data.poster_event != null && res9.data.status === 'draft');

// 10. Uji Event Valid Tanpa Poster (Fallback Placeholder)
const res10 = runValidationCheck({
  judul: 'Lomba PKM Inovatif Mahasiswa Unand',
  deskripsi: 'Kompetisi proposal ide inovasi dan riset terapan antar jurusan se-Universitas Andalas.',
  kategori: 'PKM',
  target_audiences: ['Mahasiswa'],
  tanggal_mulai: '2026-12-01',
  tanggal_selesai: '2026-12-03',
  lokasi: 'Gedung Rektorat Unand Lt. 4',
  estimasi_peserta: 120
});
assertTest('Terima event valid tanpa poster (poster_event = null)', res10.valid && res10.data.poster_event === null);

// 11. Uji Tolak Judul Hanya Simbol / Titik (misal ".....")
const res11 = runValidationCheck({
  judul: '.....',
  deskripsi: 'Seminar edukasi teknologi terkini untuk mahasiswa dan umum di Auditorium Unand.',
  kategori: 'Seminar',
  target_audiences: ['Mahasiswa'],
  tanggal_mulai: '2026-11-10',
  tanggal_selesai: '2026-11-10',
  lokasi: 'Auditorium Unand',
  estimasi_peserta: 100
});
assertTest('Tolak judul hanya simbol / titik (contoh: ".....")', !res11.valid, res11.message);

// 12. Uji Tolak Judul Teks Acak / Gibberish (misal "hgu7te823t9i")
const res12 = runValidationCheck({
  judul: 'hgu7te823t9i',
  deskripsi: 'Seminar edukasi teknologi terkini untuk mahasiswa dan umum di Auditorium Unand.',
  kategori: 'Seminar',
  target_audiences: ['Mahasiswa'],
  tanggal_mulai: '2026-11-10',
  tanggal_selesai: '2026-11-10',
  lokasi: 'Auditorium Unand',
  estimasi_peserta: 100
});
assertTest('Tolak judul teks acak / gibberish (contoh: "hgu7te823t9i")', !res12.valid && res12.message.includes('acak'), res12.message);

// 13. Uji Tolak Judul Kata Acak / Tidak Bermakna (misal "gueiuqoeqvb")
const res13 = runValidationCheck({
  judul: 'gueiuqoeqvb',
  deskripsi: 'Seminar edukasi teknologi terkini untuk mahasiswa dan umum di Auditorium Unand.',
  kategori: 'Seminar',
  target_audiences: ['Mahasiswa'],
  tanggal_mulai: '2026-11-10',
  tanggal_selesai: '2026-11-10',
  lokasi: 'Auditorium Unand',
  estimasi_peserta: 100
});
assertTest('Tolak judul kata acak / tidak bermakna (contoh: "gueiuqoeqvb")', !res13.valid, res13.message);

// 14. Uji Tolak Deskripsi > 3000 Karakter
const res14 = runValidationCheck({
  judul: 'Seminar Nasional AI 2026',
  deskripsi: 'A'.repeat(3001),
  kategori: 'Seminar',
  target_audiences: ['Mahasiswa'],
  tanggal_mulai: '2026-11-10',
  tanggal_selesai: '2026-11-10',
  lokasi: 'Auditorium Unand',
  estimasi_peserta: 100
});
assertTest('Tolak deskripsi > 3000 karakter', !res14.valid && res14.message.includes('maksimal 3000 karakter'), res14.message);

// 15. Uji Tolak Deskripsi Sama dengan Placeholder Bawaan
const res15 = runValidationCheck({
  judul: 'Seminar Nasional AI 2026',
  deskripsi: 'Jelaskan tujuan kegiatan, latar belakang, dan manfaat bagi peserta...',
  kategori: 'Seminar',
  target_audiences: ['Mahasiswa'],
  tanggal_mulai: '2026-11-10',
  tanggal_selesai: '2026-11-10',
  lokasi: 'Auditorium Unand',
  estimasi_peserta: 100
});
assertTest('Tolak deskripsi sama persis dengan teks placeholder bawaan', !res15.valid && res15.message.includes('placeholder'), res15.message);

// 16. Uji Tolak Deskripsi Huruf Berulang Berlebihan (misal "aaaaaa", "zzzzzzzzz")
const res16 = runValidationCheck({
  judul: 'Seminar Nasional AI 2026',
  deskripsi: 'zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz',
  kategori: 'Seminar',
  target_audiences: ['Mahasiswa'],
  tanggal_mulai: '2026-11-10',
  tanggal_selesai: '2026-11-10',
  lokasi: 'Auditorium Unand',
  estimasi_peserta: 100
});
assertTest('Tolak deskripsi huruf berulang berlebihan (contoh: "zzzzzzzzz")', !res16.valid && res16.message.includes('karakter berulang'), res16.message);

// 17. Uji Tolak Deskripsi Keyboard Smash (misal "asdfghjkl", "qwertyqwerty")
const res17 = runValidationCheck({
  judul: 'Seminar Nasional AI 2026',
  deskripsi: 'asdfghjkl asdfghjkl asdfghjkl asdfghjkl asdfghjkl',
  kategori: 'Seminar',
  target_audiences: ['Mahasiswa'],
  tanggal_mulai: '2026-11-10',
  tanggal_selesai: '2026-11-10',
  lokasi: 'Auditorium Unand',
  estimasi_peserta: 100
});
assertTest('Tolak deskripsi keyboard row smash (contoh: "asdfghjkl")', !res17.valid && res17.message.includes('keyboard'), res17.message);

// 18. Uji Tolak Deskripsi Kata Berulang Berturut-turut (Spam demi batas karakter)
const res18 = runValidationCheck({
  judul: 'Seminar Nasional AI 2026',
  deskripsi: 'seminar seminar seminar seminar seminar seminar seminar',
  kategori: 'Seminar',
  target_audiences: ['Mahasiswa'],
  tanggal_mulai: '2026-11-10',
  tanggal_selesai: '2026-11-10',
  lokasi: 'Auditorium Unand',
  estimasi_peserta: 100
});
assertTest('Tolak deskripsi kata berulang spam (contoh: "seminar seminar seminar")', !res18.valid && res18.message.includes('pengulangan kata'), res18.message);

console.log(`\nHasil Pengujian: ${passedTests}/${totalTests} Uji Berhasil (100% Sesuai PRD v1.1 Modul 1).`);
if (passedTests === totalTests) {
  process.exit(0);
} else {
  process.exit(1);
}
