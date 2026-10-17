/**
 * Validasi Kualitas Judul Event (Cerdas & Mencegah Teks Acak/Gibberish)
 * Mencegah:
 * - Hanya simbol/tanda baca: ".....", "!@#$%", "---"
 * - Karakter berulang tanpa jeda: ".....", "aaaaaa"
 * - Pengulangan suku kata acak: "abcabcabc"
 * - Keyboard smash sequence: "qwertyuiop", "asdfghjkl", "zxcvbnm"
 * - Vokal beruntun tidak wajar (>= 4 vokal): "gueiuqoeqvb" (mengandung ueiu)
 * - 5+ konsonan berurutan: "brtpmkq", "dfghjkl"
 * - Huruf Q tidak diikuti U: "qo", "qv" pada "gueiuqoeqvb"
 * - Kombinasi konsonan mustahil / acak: "qv", "zx", "xz", "qz"
 * - Kombinasi acak huruf-angka dalam satu kata: "hgu7te823t9i"
 * - Rasio vokal abnormal pada kata panjang
 */
function validateEventTitle(judul) {
  if (!judul || !judul.trim()) {
    return 'Judul event wajib diisi dan tidak boleh hanya berisi spasi.';
  }

  const trimmed = judul.trim();

  // 1. Batasan Panjang Karakter (PRD v1.1 §3.1 B.1: 5 - 100 karakter)
  if (trimmed.length < 5 || trimmed.length > 100) {
    return 'Judul event harus terdiri dari 5 hingga 100 karakter.';
  }

  // 2. Cegah Judul Hanya Berisi Simbol / Tanda Baca (misal ".....", "!@#$%", "----")
  const letterCount = (trimmed.match(/[a-zA-Z]/g) || []).length;
  if (letterCount < 3) {
    return 'Judul event harus berupa nama kegiatan yang jelas (minimal mengandung 3 huruf alfabet).';
  }

  // 3. Cegah Karakter Berulang Tanpa Makna (misal ".....", "aaaaaa", "------")
  if (/(.)\1{3,}/.test(trimmed)) {
    return 'Judul event tidak boleh berisi karakter berulang tanpa makna.';
  }

  // 4. Cegah Pengulangan Suku Kata / N-Gram Berulang (misal "abcabcabc")
  if (/(.{2,4})\1{2,}/.test(trimmed.replace(/\s+/g, ''))) {
    return 'Judul event mengandung pengulangan kata/pola acak yang tidak bermakna.';
  }

  // 5. Cegah Keyboard Row Smashing (misal "qwerty", "asdfgh", "zxcvbn")
  const keyboardSmash = /qwerty|wertyu|ertyui|rtyuio|tyuiop|poiuy|oiuyt|iuytr|uytre|ytrew|trewq|asdfg|sdfgh|dfghj|fghjk|ghjkl|lkjhg|kjhgf|jhgfd|hgfds|gfdsa|zxcvb|xcvbn|cvbnm|mnbvc|nbvcx|bvcxz/i;
  if (keyboardSmash.test(trimmed)) {
    return 'Judul event terindikasi ketikan deretan tombol keyboard acak.';
  }

  // 6. Analisis per Kata
  const words = trimmed.split(/[\s\/\-_.,;:()]+/).filter(Boolean);
  for (const word of words) {
    const cleanWord = word.replace(/[^a-zA-Z0-9]/g, '');
    if (!cleanWord) continue;

    // A. Transisi angka-huruf acak dalam 1 kata (misal "hgu7te823t9i")
    if (cleanWord.length >= 6 && /[a-zA-Z]/.test(cleanWord) && /[0-9]/.test(cleanWord)) {
      const transitions = (cleanWord.match(/([a-zA-Z][0-9])|([0-9][a-zA-Z])/g) || []).length;
      if (transitions >= 3) {
        return `Judul event mengandung kata kombinasi acak ("${word}"). Masukkan nama kegiatan yang wajar.`;
      }
    }

    const alphaOnly = cleanWord.replace(/[^a-zA-Z]/g, '');
    if (alphaOnly.length >= 4) {
      // B. 4+ vokal berurutan (misal: "ueiu" pada "gueiuqoeqvb", "aeiou")
      if (/[aeiouAEIOU]{4,}/.test(alphaOnly)) {
        return `Judul event mengandung deretan vokal acak ("${word}"). Gunakan nama kegiatan yang bermakna.`;
      }

      // C. 5+ konsonan berurutan (misal: "brtpmkq", "dfghjkl")
      if (/[^aeiouAEIOU\d]{5,}/.test(alphaOnly)) {
        return `Judul event mengandung deretan konsonan acak ("${word}"). Gunakan nama kegiatan yang bermakna.`;
      }

      // D. Huruf Q tidak diikuti U (seperti "qo", "qv" pada "gueiuqoeqvb")
      if (/q(?![uU])/i.test(alphaOnly)) {
        return `Judul event mengandung struktur huruf janggal ("${word}"). Harap gunakan kata yang benar.`;
      }

      // E. Pasangan konsonan mustahil dalam bahasa Indonesia/Inggris (qv, zx, xz, qz, dsb)
      if (/qv|vq|zx|xz|qx|xq|qz|zq|vj|jv|bx|dx|fx|gx|jx|kx|mx|px|wx/i.test(alphaOnly)) {
        return `Judul event mengandung kombinasi huruf tidak wajar ("${word}").`;
      }

      // F. Minimal ada vokal jika kata >= 4 huruf
      if (!/[aeiouAEIOU]/.test(alphaOnly)) {
        return 'Judul event tidak valid. Masukkan kata atau kalimat judul kegiatan yang bermakna.';
      }

      // G. Rasio vokal jika kata panjang (>= 7 huruf)
      if (alphaOnly.length >= 7) {
        const vowels = (alphaOnly.match(/[aeiouAEIOU]/g) || []).length;
        const ratio = vowels / alphaOnly.length;
        if (ratio < 0.20 || ratio > 0.75) {
          return `Judul event mengandung kata dengan susunan huruf tidak wajar ("${word}").`;
        }
      }
    }
  }

  return null;
}

module.exports = {
  validateEventTitle
};
