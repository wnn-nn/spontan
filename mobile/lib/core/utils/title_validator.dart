class TitleValidator {
  /// Validasi Kualitas Judul Event (Cerdas & Mencegah Teks Acak/Gibberish)
  /// - Menolak jika hanya simbol/titik: ".....", "!@#$%", "---"
  /// - Menolak karakter berulang tanpa jeda: ".....", "aaaaaa"
  /// - Menolak pengulangan suku kata/pola: "abcabcabc"
  /// - Menolak keyboard row smashing: "qwertyuiop", "asdfghjkl", "zxcvbnm"
  /// - Menolak 4+ vokal berurutan (misal: "ueiu" pada "gueiuqoeqvb")
  /// - Menolak 5+ konsonan berurutan: "brtpmkq", "dfghjkl"
  /// - Menolak huruf Q tidak diikuti U: "qo", "qv" pada "gueiuqoeqvb"
  /// - Menolak pasangan konsonan mustahil: "qv", "zx", "xz", "qz"
  /// - Menolak kombinasi acak huruf-angka: "hgu7te823t9i"
  /// - Menolak rasio vokal abnormal pada kata panjang
  static String? validate(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'Judul event wajib diisi dan tidak boleh hanya berisi spasi';
    }

    final trimmed = val.trim();

    // 1. Batas Panjang (PRD v1.1 §3.1 B.1: 5 - 100 karakter)
    if (trimmed.length < 5) {
      return 'Judul event minimal harus 5 karakter';
    }
    if (trimmed.length > 100) {
      return 'Judul event maksimal 100 karakter';
    }

    // 2. Cegah Judul Hanya Berisi Simbol / Tanda Baca (misal ".....", "!@#$%", "----")
    final letterCount = trimmed.replaceAll(RegExp(r'[^a-zA-Z]'), '').length;
    if (letterCount < 3) {
      return 'Judul event harus berupa nama kegiatan yang jelas (minimal 3 huruf alfabet)';
    }

    // 3. Cegah Karakter Berulang Tanpa Makna (misal ".....", "aaaaaa", "------")
    if (RegExp(r'(.)\1{3,}').hasMatch(trimmed)) {
      return 'Judul event tidak boleh berisi karakter berulang tanpa makna';
    }

    // 4. Cegah Pengulangan Suku Kata / N-Gram Berulang (misal "abcabcabc")
    final noSpaces = trimmed.replaceAll(RegExp(r'\s+'), '');
    if (RegExp(r'(.{2,4})\1{2,}').hasMatch(noSpaces)) {
      return 'Judul event mengandung pengulangan pola acak yang tidak bermakna';
    }

    // 5. Cegah Keyboard Row Smashing (misal "qwerty", "asdfgh", "zxcvbn")
    final keyboardSmash = RegExp(
      r'qwerty|wertyu|ertyui|rtyuio|tyuiop|poiuy|oiuyt|iuytr|uytre|ytrew|trewq|asdfg|sdfgh|dfghj|fghjk|ghjkl|lkjhg|kjhgf|jhgfd|hgfds|gfdsa|zxcvb|xcvbn|cvbnm|mnbvc|nbvcx|bvcxz',
      caseSensitive: false,
    );
    if (keyboardSmash.hasMatch(trimmed)) {
      return 'Judul event terindikasi ketikan deretan tombol keyboard acak';
    }

    // 6. Analisis per Kata
    final words = trimmed.split(RegExp(r'[\s\/\-_.,;:()]+')).where((w) => w.isNotEmpty);
    for (final word in words) {
      final cleanWord = word.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
      if (cleanWord.isEmpty) continue;

      // A. Transisi angka-huruf acak dalam 1 kata (misal "hgu7te823t9i")
      if (cleanWord.length >= 6 &&
          RegExp(r'[a-zA-Z]').hasMatch(cleanWord) &&
          RegExp(r'[0-9]').hasMatch(cleanWord)) {
        final transitions = RegExp(r'([a-zA-Z][0-9])|([0-9][a-zA-Z])')
            .allMatches(cleanWord)
            .length;
        if (transitions >= 3) {
          return 'Judul event mengandung kata kombinasi acak ("$word"). Masukkan nama kegiatan yang wajar';
        }
      }

      final alphaOnly = cleanWord.replaceAll(RegExp(r'[^a-zA-Z]'), '');
      if (alphaOnly.length >= 4) {
        // B. 4+ vokal berurutan (misal: "ueiu" pada "gueiuqoeqvb", "aeiou")
        if (RegExp(r'[aeiouAEIOU]{4,}').hasMatch(alphaOnly)) {
          return 'Judul event mengandung deretan vokal acak ("$word"). Gunakan kata yang bermakna';
        }

        // C. 5+ konsonan berurutan (misal: "brtpmkq", "dfghjkl")
        if (RegExp(r'[^aeiouAEIOU\d]{5,}').hasMatch(alphaOnly)) {
          return 'Judul event mengandung deretan konsonan acak ("$word"). Gunakan kata yang bermakna';
        }

        // D. Huruf Q tidak diikuti U (seperti "qo", "qv" pada "gueiuqoeqvb")
        if (RegExp(r'q(?![uU])', caseSensitive: false).hasMatch(alphaOnly)) {
          return 'Judul event mengandung struktur huruf janggal ("$word"). Harap gunakan kata yang benar';
        }

        // E. Pasangan konsonan mustahil (qv, zx, xz, qz, dsb)
        if (RegExp(r'qv|vq|zx|xz|qx|xq|qz|zq|vj|jv|bx|dx|fx|gx|jx|kx|mx|px|wx',
                caseSensitive: false)
            .hasMatch(alphaOnly)) {
          return 'Judul event mengandung kombinasi huruf tidak wajar ("$word")';
        }

        // F. Minimal ada vokal jika kata >= 4 huruf
        if (!RegExp(r'[aeiouAEIOU]').hasMatch(alphaOnly)) {
          return 'Judul event tidak valid. Masukkan nama kegiatan yang bermakna';
        }

        // G. Rasio vokal jika kata panjang (>= 7 huruf)
        if (alphaOnly.length >= 7) {
          final vowels = RegExp(r'[aeiouAEIOU]').allMatches(alphaOnly).length;
          final ratio = vowels / alphaOnly.length;
          if (ratio < 0.20 || ratio > 0.75) {
            return 'Judul event mengandung kata dengan susunan huruf tidak wajar ("$word")';
          }
        }
      }
    }

    return null;
  }
}
