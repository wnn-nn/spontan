import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiConstants {
  static const String _keyBaseUrl = 'spontan_custom_base_url';

  // IP Wi-Fi Komputer saat ini (dapat disesuaikan jika IP berubah)
  static const String defaultLocalIp = '10.44.51.182';

  // Base URL aktif yang digunakan seluruh request API
  static String _activeBaseUrl = 'http://127.0.0.1:5000/api';

  static String get baseUrl => _activeBaseUrl;

  // Daftar opsi URL backend yang bisa dipilih
  static List<Map<String, String>> get candidatePresets {
    return [
      {
        'label': 'HP via USB (adb reverse) / Desktop',
        'url': 'http://127.0.0.1:5000/api',
        'hint': 'Jalankan "adb reverse tcp:5000 tcp:5000"',
      },
      {
        'label': 'HP via Wi-Fi (Satu Jaringan)',
        'url': 'http://$defaultLocalIp:5000/api',
        'hint': 'Laptop & HP harus di Wi-Fi yang sama',
      },
      {
        'label': 'Android Emulator (AVD)',
        'url': 'http://10.0.2.2:5000/api',
        'hint': 'Khusus Android Studio Emulator',
      },
    ];
  }

  // Inisialisasi awal saat aplikasi dibuka
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_keyBaseUrl);
    if (saved != null && saved.isNotEmpty) {
      _activeBaseUrl = saved;
      return;
    }

    // Default untuk Web / Desktop Windows
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      _activeBaseUrl = 'http://127.0.0.1:5000/api';
      return;
    }

    // Untuk Android, cari preset yang merespons /health tercepat
    for (final preset in candidatePresets) {
      final url = preset['url']!;
      final isAlive = await checkHealth(url, timeoutMs: 700);
      if (isAlive) {
        _activeBaseUrl = url;
        return;
      }
    }

    // Jika belum ada yang merespons, default ke 127.0.0.1 (USB)
    _activeBaseUrl = 'http://127.0.0.1:5000/api';
  }

  // Fungsi tes endpoint /api/health
  static Future<bool> checkHealth(String candidateBaseUrl, {int timeoutMs = 2000}) async {
    try {
      final cleanUrl = candidateBaseUrl.trim().replaceAll(RegExp(r'/+$'), '');
      final uri = Uri.parse('$cleanUrl/health');
      final res = await http.get(uri).timeout(Duration(milliseconds: timeoutMs));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // Mengubah dan menyimpan base URL aktif
  static Future<void> setBaseUrl(String newUrl) async {
    _activeBaseUrl = newUrl.trim().replaceAll(RegExp(r'/+$'), '');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBaseUrl, _activeBaseUrl);
  }

  // Reset ke deteksi otomatis
  static Future<void> resetToDefault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyBaseUrl);
    await init();
  }

  // Endpoints API
  static String get register => '$baseUrl/auth/register';
  static String get login => '$baseUrl/auth/login';
  static String get me => '$baseUrl/auth/me';
  static String get referenceData => '$baseUrl/reference-data';
  static String get events => '$baseUrl/events';
}
