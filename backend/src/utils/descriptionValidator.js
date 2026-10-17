/**
 * Validasi Kualitas Deskripsi Event (Cerdas & Mencegah Teks Asal-asalan/Spam)
 * Aturan:
 * 1. Minimal 20 karakter, maksimal 3000 karakter (PRD v1.1 Modul 1).
 * 2. Bandingkan dengan Placeholder bawaan: Tidak boleh sama persis dengan teks panduan instruksi.
 * 3. Deteksi Huruf Berulang Berlebihan: Blokir jika mengandung huruf berulang (misal "aaaaaa", "zzzzzzzzz").
 * 4. Deteksi Huruf Mati Berurutan yang Tidak Wajar: Blokir deretan konsonan beruntun 6+ huruf (misal "asdfghjkl", "bcdfghjkl").
 * 5. Deteksi Keyboard Row Smashing: Blokir ketikan deretan tombol keyboard (misal "qwertyqwerty", "asdfghjkl", "zxcvbnm").
 * 6. Deteksi Kata Berulang (Spam): Blokir jika satu kata diulang berturut-turut atau mendominasi isi demi mengejar batas karakter.
 * 7. Minimal 10 huruf alfabet dan memiliki huruf vokal.
 */

const KNOWN_PLACEHOLDERS = [
  'jelaskan tujuan kegiatan, latar belakang, dan manfaat bagi peserta',
  'jelaskan tujuan kegiatan, latar belakang, dan manfaat bagi peserta...',
  'rincian penjelasan kegiatan, tujuan, dan latar belakang',
  'rincian penjelasan kegiatan, tujuan, dan latar belakang.',
  'rincian penjelasan kegiatan',
  'rincian penjelasan kegiatan...',
  'rincian detail kegiatan',
  'deskripsi kegiatan'
];

function normalizeText(text) {
  return text
    .toLowerCase()
    .trim()
    .replace(/[.,;:!…\s]+$/, '')
    .replace(/\s+/g, ' ');
}

function validateEventDescription(deskripsi) {
  if (!deskripsi || !deskripsi.trim()) {
    return 'Deskripsi event wajib diisi dan tidak boleh hanya berisi spasi.';
  }

  const trimmed = deskripsi.trim();

  // 1. Batas Panjang Karakter (20 - 3000 Karakter)
  if (trimmed.length < 20) {
    return 'Deskripsi event minimal harus 20 karakter.';
  }
  if (trimmed.length > 3000) {
    return 'Deskripsi event maksimal 3000 karakter.';
  }

  // 2. Bandingkan dengan Placeholder / Instruksi Bawaan
  const normalized = normalizeText(trimmed);
  for (const placeholder of KNOWN_PLACEHOLDERS) {
    if (normalized === normalizeText(placeholder)) {
      return 'Deskripsi event tidak boleh menggunakan teks petunjuk bawaan (placeholder). Harap tuliskan deskripsi asli kegiatan Anda.';
    }
  }

  // 3. Deteksi Huruf/Karakter Berulang Berlebihan (misal: "aaaaaa", "zzzzzzzzz", ".........")
  if (/(.)\1{5,}/i.test(trimmed)) {
    return 'Deskripsi event mengandung karakter berulang yang tidak wajar.';
  }

  // 4. Deteksi Keyboard Row Smashing (misal: "asdfghjkl", "qwertyqwerty", "zxcvbnm")
  const keyboardSmashRegex = /qwertyqwerty|asdfghjkl|zxcvbnm|qwertyuiop|poiuytrewq|lkjhgfdsa|mnbvcxz/i;
  if (keyboardSmashRegex.test(trimmed)) {
    return 'Deskripsi event terindikasi ketikan acak tombol keyboard (spam).';
  }

  // 5. Deteksi Deretan Huruf Mati Berurutan yang Tidak Wajar (6+ konsonan beruntun)
  if (/[^aeiouAEIOU\d\s\W]{6,}/.test(trimmed)) {
    return 'Deskripsi event mengandung susunan huruf mati berurutan yang tidak wajar.';
  }

  // 6. Deteksi Kata Berulang Berturut-turut (misal: "seminar seminar seminar seminar")
  const repeatedConsecutive = /\b([a-zA-Z0-9]+)\b(?:\s+\1\b){2,}/i;
  if (repeatedConsecutive.test(trimmed)) {
    return 'Deskripsi event terindikasi pengulangan kata yang sama berturut-turut.';
  }

  // 7. Deteksi Dominasi Kata Tunggal (misal satu kata diulang demi mengejar minimal karakter)
  const words = trimmed
    .split(/[\s,.;:!?]+/)
    .map(w => w.toLowerCase())
    .filter(w => w.length >= 2);

  if (words.length >= 4) {
    const freq = {};
    let maxCount = 0;
    let mostFrequentWord = '';

    for (const w of words) {
      freq[w] = (freq[w] || 0) + 1;
      if (freq[w] > maxCount) {
        maxCount = freq[w];
        mostFrequentWord = w;
      }
    }

    if (maxCount >= 3 && (maxCount / words.length) >= 0.5) {
      return `Deskripsi event terindikasi pengulangan kata '${mostFrequentWord}' secara berlebihan. Harap jelaskan kegiatan secara wajar.`;
    }
  }

  // 8. Kualitas Alfabet: Minimal 10 huruf & memiliki vokal
  const letterCount = (trimmed.match(/[a-zA-Z]/g) || []).length;
  if (letterCount < 10) {
    return 'Deskripsi event harus berupa kalimat yang jelas (minimal 10 huruf alfabet).';
  }
  if (!/[aeiouAEIOU]/.test(trimmed)) {
    return 'Deskripsi event tidak valid. Masukkan penjelasan kegiatan yang bermakna.';
  }

  return null;
}

module.exports = {
  validateEventDescription,
  KNOWN_PLACEHOLDERS
};
