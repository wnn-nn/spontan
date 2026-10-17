class EventModel {
  final int idEvent;
  final int idPembuat;
  final String judul;
  final String deskripsi;
  final String tanggalMulai;
  final String tanggalSelesai;
  final String lokasi;
  final String kategori;
  final int estimasiPeserta;
  final String status;
  final List<String> targetAudiences;
  final String? posterEvent;
  final String? createdAt;

  EventModel({
    required this.idEvent,
    required this.idPembuat,
    required this.judul,
    required this.deskripsi,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.lokasi,
    required this.kategori,
    required this.estimasiPeserta,
    required this.status,
    required this.targetAudiences,
    this.posterEvent,
    this.createdAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      idEvent: json['id_event'] is int
          ? json['id_event']
          : int.tryParse(json['id_event'].toString()) ?? 0,
      idPembuat: json['id_pembuat'] is int
          ? json['id_pembuat']
          : int.tryParse(json['id_pembuat'].toString()) ?? 0,
      judul: json['judul'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      tanggalMulai: json['tanggal_mulai'] ?? '',
      tanggalSelesai: json['tanggal_selesai'] ?? '',
      lokasi: json['lokasi'] ?? '',
      kategori: json['kategori'] ?? '',
      estimasiPeserta: json['estimasi_peserta'] is int
          ? json['estimasi_peserta']
          : int.tryParse(json['estimasi_peserta'].toString()) ?? 0,
      status: json['status'] ?? 'draft',
      targetAudiences: (json['target_audiences'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      posterEvent: json['poster_event']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_event': idEvent,
      'id_pembuat': idPembuat,
      'judul': judul,
      'deskripsi': deskripsi,
      'tanggal_mulai': tanggalMulai,
      'tanggal_selesai': tanggalSelesai,
      'lokasi': lokasi,
      'kategori': kategori,
      'estimasi_peserta': estimasiPeserta,
      'poster_event': posterEvent,
      'status': status,
      'target_audiences': targetAudiences,
      'created_at': createdAt,
    };
  }
}
