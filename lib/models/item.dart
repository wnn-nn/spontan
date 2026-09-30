/// Model data rekomendasi sponsor untuk SPONTAN
class Item {
  final String id;
  final String title; // Nama Brand Sponsor
  final String subtitle; // Industri & Kategori Preferensi
  final String description; // Deskripsi Profil Sponsor
  final int matchingScore; // Skor Kecocokan (%)
  final String alasanMatching; // Alasan Matching

  const Item({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    this.matchingScore = 85,
    this.alasanMatching = 'Cocok dengan kategori event & target audience mahasiswa UNAND',
  });
}