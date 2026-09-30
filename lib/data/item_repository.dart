import '../models/item.dart';

/// Sumber data sementara (dummy). Nanti bisa diganti dengan API/database.
class ItemRepository {
  // Data dummy yang relevan dengan project SPONTAN
  static const List<Item> _items = [
    Item(
      id: '1',
      title: 'Concert Jazz Night',
      subtitle: '25 Okt 2026 • Status: Open',
      description:
          'Konser musik jazz tahunan dengan musisi nasional dan internasional. Dihadiri lebih dari 3.000 penonton muda dan profesional.',
    ),
    Item(
      id: '2',
      title: 'Seminar Digital 2026',
      subtitle: '10 Nov 2026 • Status: Draft',
      description:
          'Seminar transformasi digital dan inovasi teknologi terkini untuk mahasiswa, akademisi, dan praktisi startup.',
    ),
    Item(
      id: '3',
      title: 'Festival Kopi Nusantara',
      subtitle: '02 Des 2026 • Status: Closed',
      description:
          'Pameran dan expo para pegiat UMKM kopi dari seluruh pelosok nusantara dengan workshop barista dan kompetisi roasting.',
    ),
  ];

  /// Mengambil daftar item.
  /// simulateError: true -> sengaja dibuat gagal untuk menguji error state.
  Future<List<Item>> fetchItems({bool simulateError = false}) async {
    await Future.delayed(const Duration(seconds: 2)); // simulasi waktu tunggu server
    if (simulateError) {
      throw Exception('Gagal memuat data. Periksa koneksi internet.');
    }
    return _items;
  }
}