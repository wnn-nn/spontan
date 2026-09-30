import '../models/item.dart';

/// Repository penyedia data dummy calon sponsor untuk matching event mahasiswa
class ItemRepository {
  static const List<Item> _items = [
    Item(
      id: 'sp-01',
      title: 'Bank Nagari',
      subtitle: 'Perbankan / Keuangan • Preferensi: Education & Youth',
      description: 'Bank Nagari secara aktif mendukung kegiatan mahasiswa Universitas Andalas melalui bantuan dana sponsorship dan penyediaan fasilitas payment gateway event.',
      matchingScore: 92,
      alasanMatching: 'Sesuai dengan target audience mahasiswa UNAND dan skala event kampus.',
    ),
    Item(
      id: 'sp-02',
      title: 'Telkomsel Sumatera Barat',
      subtitle: 'Telekomunikasi / Teknologi • Preferensi: Technology & Arts',
      description: 'Penyedia layanan telekomunikasi yang siap memberikan dukungan sponsorship berupa produk, booth event, voucher internet, dan media partner.',
      matchingScore: 88,
      alasanMatching: 'Cocok dengan jenis kebutuhan media partner dan fasilitas event.',
    ),
    Item(
      id: 'sp-03',
      title: 'Kahf / Paragon',
      subtitle: 'Personal Care / FMCG • Preferensi: Sport & Seminar',
      description: 'Brand personal care yang sering menjadi mitra utama event kampus dalam bentuk produk/goodie bag, produk trial, dan dukungan dana segar.',
      matchingScore: 81,
      alasanMatching: 'Sangat sesuai untuk target peserta seminar dan perlombaan mahasiswa.',
    ),
  ];

  /// Mengambil daftar sponsor ter-matching
  Future<List<Item>> fetchItems({bool simulateError = false}) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulasi waktu server
    if (simulateError) {
      throw Exception('Gagal memuat rekomendasi sponsor. Periksa koneksi internet.');
    }
    return _items;
  }
}