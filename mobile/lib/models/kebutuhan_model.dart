import 'app_constants.dart';

class KebutuhanModel {
  final String id;
  final String eventId;
  final String jenis; // Nilai baku dari AppConstants.jenisKebutuhanOptions
  final String deskripsi;
  final double nilai; // Estimasi nilai dalam Rupiah
  final String? satuanKeterangan;
  final String status; // Nilai baku dari AppConstants.statusKebutuhan*

  KebutuhanModel({
    required this.id,
    required this.eventId,
    required this.jenis,
    required this.deskripsi,
    required this.nilai,
    this.satuanKeterangan,
    this.status = AppConstants.statusKebutuhanTerbuka,
  });

  factory KebutuhanModel.fromJson(Map<String, dynamic> json) {
    return KebutuhanModel(
      id: json['id_kebutuhan']?.toString() ?? '',
      eventId: json['event_id']?.toString() ?? '',
      jenis: json['jenis_kebutuhan'] ?? AppConstants.jenisKebutuhanDana,
      deskripsi: json['deskripsi'] ?? '',
      nilai: (json['nilai_estimasi'] is num)
          ? (json['nilai_estimasi'] as num).toDouble()
          : double.tryParse(json['nilai_estimasi']?.toString() ?? '0') ?? 0.0,
      satuanKeterangan: json['satuan_keterangan'],
      status: json['status'] ?? AppConstants.statusKebutuhanTerbuka,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_kebutuhan': id,
      'event_id': eventId,
      'jenis_kebutuhan': jenis,
      'deskripsi': deskripsi,
      'nilai_estimasi': nilai,
      'satuan_keterangan': satuanKeterangan,
      'status': status,
    };
  }
}
