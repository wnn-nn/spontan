class DescriptionValidator {
  /// Daftar placeholder instruksi bawaan yang tidak boleh disalin mentah-mentah
  static const List<String> knownPlaceholders = [
    'jelaskan tujuan kegiatan, latar belakang, dan manfaat bagi peserta',
    'jelaskan tujuan kegiatan, latar belakang, dan manfaat bagi peserta...',
    'rincian penjelasan kegiatan, tujuan, dan latar belakang',
    'rincian penjelasan kegiatan, tujuan, dan latar belakang.',
    'rincian penjelasan kegiatan',
    'rincian penjelasan kegiatan...',
    'rincian detail kegiatan',
    'deskripsi kegiatan'
  ];

  static String _normalize(String text) {
    return text
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[.,;:!…\s]+$'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Validasi Cerdas Kualitas Deskripsi Event
  /// - Minimal 20 karakter & Maksimal 3000 karakter
  /// - Deteksi Penggunaan Teks Placeholder / Instruksi Bawaan
  /// - Deteksi Huruf Berulang Berlebihan (aaaaaa, zzzzzzzzz)
  /// - Deteksi Huruf Mati / Konsonan Berurutan Tidak Wajar (6+ konsonan)
  /// - Deteksi Keyboard Row Smashing (asdfghjkl, qwertyqwerty, zxcvbnm)
  /// - Deteksi Kata Berulang (Spam mengejar jumlah karakter)
  /// - Minimal 10 huruf alfabet & mengandung vokal
  static String? validate(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'Deskripsi event wajib diisi dan tidak boleh hanya berisi spasi';
    }

    final trimmed = val.trim();

    // 1. Batas Panjang Karakter (20 - 3000 Karakter)
    if (trimmed.length < 20) {
      return 'Deskripsi event minimal harus 20 karakter';
    }
    if (trimmed.length > 3000) {
      return 'Deskripsi event maksimal 3000 karakter';
    }

    // 2. Bandingkan dengan Placeholder / Instruksi Bawaan
    final normalized = _normalize(trimmed);
    for (final ph in knownPlaceholders) {
      if (normalized == _normalize(ph)) {
        return 'Deskripsi event tidak boleh menggunakan teks petunjuk bawaan (placeholder). Harap tuliskan deskripsi asli kegiatan Anda';
      }
    }

    // 3. Deteksi Huruf Berulang Berlebihan (misal "aaaaaa", "zzzzzzzzz", ".........")
    if (RegExp(r'(.)\1{5,}', caseSensitive: false).hasMatch(trimmed)) {
      return 'Deskripsi event mengandung karakter berulang yang tidak wajar';
    }

    // 4. Deteksi Keyboard Row Smashing (misal "asdfghjkl", "qwertyqwerty", "zxcvbnm")
    final keyboardSmash = RegExp(
      r'qwertyqwerty|asdfghjkl|zxcvbnm|qwertyuiop|poiuytrewq|lkjhgfdsa|mnbvcxz',
      caseSensitive: false,
    );
    if (keyboardSmash.hasMatch(trimmed)) {
      return 'Deskripsi event terindikasi ketikan acak tombol keyboard (spam)';
    }

    // 5. Deteksi Deretan Huruf Mati Berurutan yang Tidak Wajar (6+ konsonan beruntun)
    if (RegExp(r'[^aeiouAEIOU\d\s\W]{6,}').hasMatch(trimmed)) {
      return 'Deskripsi event mengandung susunan huruf mati berurutan yang tidak wajar';
    }

    // 6. Deteksi Kata Berulang Berturut-turut (misal "seminar seminar seminar")
    final repeatedConsecutive = RegExp(
      r'\b([a-zA-Z0-9]+)\b(?:\s+\1\b){2,}',
      caseSensitive: false,
    );
    if (repeatedConsecutive.hasMatch(trimmed)) {
      return 'Deskripsi event terindikasi pengulangan kata yang sama berturut-turut';
    }

    // 7. Deteksi Dominasi Kata Tunggal (misal mengulang kata yang sama demi mencapai minimal karakter)
    final words = trimmed
        .split(RegExp(r'[\s,.;:!?]+'))
        .map((w) => w.toLowerCase())
        .where((w) => w.length >= 2)
        .toList();

    if (words.length >= 4) {
      final freq = <String, int>{};
      int maxCount = 0;
      String mostFrequentWord = '';

      for (final w in words) {
        final count = (freq[w] ?? 0) + 1;
        freq[w] = count;
        if (count > maxCount) {
          maxCount = count;
          mostFrequentWord = w;
        }
      }

      if (maxCount >= 3 && (maxCount / words.length) >= 0.5) {
        return "Deskripsi event terindikasi pengulangan kata '$mostFrequentWord' secara berlebihan. Harap jelaskan kegiatan secara wajar";
      }
    }

    // 8. Kualitas Alfabet: Minimal 10 huruf & memiliki vokal
    final letterCount = trimmed.replaceAll(RegExp(r'[^a-zA-Z]'), '').length;
    if (letterCount < 10) {
      return 'Deskripsi event harus berupa kalimat yang jelas (minimal 10 huruf alfabet)';
    }
    if (!RegExp(r'[aeiouAEIOU]').hasMatch(trimmed)) {
      return 'Deskripsi event tidak valid. Masukkan penjelasan kegiatan yang bermakna';
    }

    return null;
  }
}
