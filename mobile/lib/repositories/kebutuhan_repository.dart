import '../models/kebutuhan_model.dart';

/// Repository in-memory untuk mengelola data [KebutuhanModel].
///
/// Seluruh data disimpan sementara menggunakan [List] di memori.
/// Kebutuhan dari satu event tidak akan tercampur dengan event lain
/// karena setiap operasi membaca/menulis berdasarkan [eventId].
///
/// Semua fungsi mengembalikan [Future] agar konsisten dengan pola
/// asynchronous project dan mudah digantikan implementasi backend di kemudian hari.
class KebutuhanRepository {
  /// Singleton instance agar satu List digunakan di seluruh aplikasi.
  static final KebutuhanRepository _instance = KebutuhanRepository._internal();

  factory KebutuhanRepository() => _instance;

  KebutuhanRepository._internal();

  /// Penyimpanan in-memory seluruh kebutuhan.
  final List<KebutuhanModel> _items = [];

  // ── Read ───────────────────────────────────────────────────────────────────

  /// Mengambil semua kebutuhan yang terkait dengan [eventId] tertentu.
  ///
  /// Mengembalikan list kosong jika belum ada kebutuhan untuk event tersebut.
  Future<List<KebutuhanModel>> getByEvent(String eventId) async {
    return _items.where((k) => k.eventId == eventId).toList();
  }

  // ── Create ─────────────────────────────────────────────────────────────────

  /// Menambahkan [kebutuhan] baru ke repository.
  ///
  /// Kebutuhan yang ditambahkan akan tersimpan di memori hingga sesi berakhir.
  Future<void> add(KebutuhanModel kebutuhan) async {
    _items.add(kebutuhan);
  }

  // ── Update ─────────────────────────────────────────────────────────────────

  /// Memperbarui kebutuhan yang sudah ada berdasarkan [kebutuhan.id].
  ///
  /// Melempar [ArgumentError] jika kebutuhan dengan ID tersebut tidak ditemukan.
  Future<void> update(KebutuhanModel kebutuhan) async {
    final index = _items.indexWhere((k) => k.id == kebutuhan.id);
    if (index == -1) {
      throw ArgumentError('Kebutuhan dengan id "${kebutuhan.id}" tidak ditemukan.');
    }
    _items[index] = kebutuhan;
  }

  // ── Delete ─────────────────────────────────────────────────────────────────

  /// Menghapus kebutuhan berdasarkan [id].
  ///
  /// Tidak melakukan apa-apa jika ID tidak ditemukan (idempotent).
  Future<void> delete(String id) async {
    _items.removeWhere((k) => k.id == id);
  }
}
