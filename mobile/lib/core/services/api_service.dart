import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../../models/user_model.dart';
import '../../models/reference_data_model.dart';
import '../../models/event_model.dart';
import 'auth_storage.dart';

class ApiService {
  static const Duration _timeout = Duration(seconds: 8);

  // Helper Headers dengan Bearer Token
  static Future<Map<String, String>> _getHeaders({bool withAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (withAuth) {
      final token = await AuthStorage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // 1. Auth: Register
  static Future<Map<String, dynamic>> register({
    required String nama,
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse(ApiConstants.register);
      final headers = await _getHeaders(withAuth: false);
      final body = jsonEncode({
        'nama': nama,
        'email': email,
        'password': password,
      });

      final response = await http.post(url, headers: headers, body: body).timeout(_timeout);
      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        final token = data['token'] as String;
        final user = UserModel.fromJson(data['user']);
        await AuthStorage.saveToken(token);
        await AuthStorage.saveUser(user);
        return {'success': true, 'user': user, 'token': token};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mendaftar akun.',
        };
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server backend (${ApiConstants.baseUrl}). Pastikan backend aktif.'
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Koneksi ke backend timeout (${ApiConstants.baseUrl}). Pastikan IP server benar.'
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // 2. Auth: Login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse(ApiConstants.login);
      final headers = await _getHeaders(withAuth: false);
      final body = jsonEncode({
        'email': email,
        'password': password,
      });

      final response = await http.post(url, headers: headers, body: body).timeout(_timeout);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final token = data['token'] as String;
        final user = UserModel.fromJson(data['user']);
        await AuthStorage.saveToken(token);
        await AuthStorage.saveUser(user);
        return {'success': true, 'user': user, 'token': token};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Email atau password salah.',
        };
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server backend (${ApiConstants.baseUrl}). Pastikan backend aktif.'
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Koneksi ke backend timeout (${ApiConstants.baseUrl}). Pastikan IP server benar.'
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // 3. Reference Data: GET /api/reference-data
  static Future<ReferenceDataModel> getReferenceData() async {
    try {
      final url = Uri.parse(ApiConstants.referenceData);
      final headers = await _getHeaders(withAuth: false);

      final response = await http.get(url, headers: headers).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return ReferenceDataModel.fromJson(data['data']);
        }
      }
      throw Exception('Format data referensi dari server tidak valid.');
    } on SocketException {
      throw Exception('Gagal terhubung ke server backend (${ApiConstants.baseUrl}).');
    } on TimeoutException {
      throw Exception('Koneksi timeout ke server backend (${ApiConstants.baseUrl}).');
    } catch (e) {
      throw Exception('Gagal memuat data referensi: $e');
    }
  }

  // 4. Events: GET /api/events (My Events)
  static Future<List<EventModel>> getMyEvents() async {
    try {
      final url = Uri.parse(ApiConstants.events);
      final headers = await _getHeaders(withAuth: true);

      final response = await http.get(url, headers: headers).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          return (data['data'] as List)
              .map((e) => EventModel.fromJson(e))
              .toList();
        }
      } else if (response.statusCode == 401) {
        throw Exception('Sesi login telah berakhir. Silakan login kembali.');
      }
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Gagal mengambil daftar event.');
    } on SocketException {
      throw Exception('Koneksi terputus: Server backend tidak dapat dihubungi (${ApiConstants.baseUrl}).');
    } on TimeoutException {
      throw Exception('Koneksi timeout ke server backend (${ApiConstants.baseUrl}).');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // 5. Events: POST /api/events (Create Event)
  static Future<EventModel> createEvent({
    required String judul,
    required String deskripsi,
    required String kategori,
    required List<String> targetAudiences,
    required String tanggalMulai,
    required String tanggalSelesai,
    required String lokasi,
    required int estimasiPeserta,
    String? posterEvent,
  }) async {
    try {
      final url = Uri.parse(ApiConstants.events);
      final headers = await _getHeaders(withAuth: true);
      final payload = <String, dynamic>{
        'judul': judul,
        'deskripsi': deskripsi,
        'kategori': kategori,
        'target_audiences': targetAudiences,
        'tanggal_mulai': tanggalMulai,
        'tanggal_selesai': tanggalSelesai,
        'lokasi': lokasi,
        'estimasi_peserta': estimasiPeserta,
      };

      if (posterEvent != null && posterEvent.trim().isNotEmpty) {
        payload['poster_event'] = posterEvent.trim();
      }

      final body = jsonEncode(payload);

      final response = await http.post(url, headers: headers, body: body).timeout(_timeout);
      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return EventModel.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Gagal menyimpan event ke backend.');
      }
    } on SocketException {
      throw Exception('Gagal mengirim data: Server backend tidak dapat dijangkau (${ApiConstants.baseUrl}).');
    } on TimeoutException {
      throw Exception('Koneksi timeout ke server backend (${ApiConstants.baseUrl}).');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // 6. Events: PUT /api/events/:id (Update Event - FR-M1-03)
  static Future<EventModel> updateEvent({
    required int idEvent,
    String? judul,
    String? deskripsi,
    String? kategori,
    List<String>? targetAudiences,
    String? tanggalMulai,
    String? tanggalSelesai,
    String? lokasi,
    int? estimasiPeserta,
    String? status,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.events}/$idEvent');
      final headers = await _getHeaders(withAuth: true);
      final payload = <String, dynamic>{};
      if (judul != null) payload['judul'] = judul;
      if (deskripsi != null) payload['deskripsi'] = deskripsi;
      if (kategori != null) payload['kategori'] = kategori;
      if (targetAudiences != null) payload['target_audiences'] = targetAudiences;
      if (tanggalMulai != null) payload['tanggal_mulai'] = tanggalMulai;
      if (tanggalSelesai != null) payload['tanggal_selesai'] = tanggalSelesai;
      if (lokasi != null) payload['lokasi'] = lokasi;
      if (estimasiPeserta != null) payload['estimasi_peserta'] = estimasiPeserta;
      if (status != null) payload['status'] = status;

      final body = jsonEncode(payload);
      final response = await http.put(url, headers: headers, body: body).timeout(_timeout);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return EventModel.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Gagal memperbarui event.');
      }
    } on SocketException {
      throw Exception('Gagal mengirim data: Server backend tidak dapat dijangkau (${ApiConstants.baseUrl}).');
    } on TimeoutException {
      throw Exception('Koneksi timeout ke server backend (${ApiConstants.baseUrl}).');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
