class KebutuhanModel {
  final String id;
  final String jenisKebutuhan; // 'Dana', 'Barang', 'Media Partner', 'Lainnya'
  final String deskripsi;
  final double nilaiEstimasi;
  final String? satuanKeterangan;
  final String status; // 'Terbuka', 'Terpenuhi'

  KebutuhanModel({
    required this.id,
    required this.jenisKebutuhan,
    required this.deskripsi,
    required this.nilaiEstimasi,
    this.satuanKeterangan,
    this.status = 'Terbuka',
  });

  factory KebutuhanModel.fromJson(Map<String, dynamic> json) {
    return KebutuhanModel(
      id: json['id_kebutuhan']?.toString() ?? '',
      jenisKebutuhan: json['jenis_kebutuhan'] ?? 'Dana',
      deskripsi: json['deskripsi'] ?? '',
      nilaiEstimasi: (json['nilai_estimasi'] is num)
          ? (json['nilai_estimasi'] as num).toDouble()
          : double.tryParse(json['nilai_estimasi']?.toString() ?? '0') ?? 0.0,
      satuanKeterangan: json['satuan_keterangan'],
      status: json['status'] ?? 'Terbuka',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_kebutuhan': id,
      'jenis_kebutuhan': jenisKebutuhan,
      'deskripsi': deskripsi,
      'nilai_estimasi': nilaiEstimasi,
      'satuan_keterangan': satuanKeterangan,
      'status': status,
    };
  }
}
