/// Entitas SponsorTersimpan (PRD v1.1 §1.7, FR-M3-01).
///
/// Bookmark sponsor sasaran yang disimpan mahasiswa per event untuk difollow-up.
class SponsorTersimpanModel {
  final String id;
  final String idUser;
  final String idEvent;
  final String idSponsor;
  final String catatan;
  final DateTime createdAt;

  const SponsorTersimpanModel({
    required this.id,
    required this.idUser,
    required this.idEvent,
    required this.idSponsor,
    this.catatan = '',
    required this.createdAt,
  });

  factory SponsorTersimpanModel.fromJson(Map<String, dynamic> json) {
    return SponsorTersimpanModel(
      id: json['id']?.toString() ?? '',
      idUser: json['id_user']?.toString() ?? '',
      idEvent: json['id_event']?.toString() ?? '',
      idSponsor: json['id_sponsor']?.toString() ?? '',
      catatan: json['catatan']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_user': idUser,
      'id_event': idEvent,
      'id_sponsor': idSponsor,
      'catatan': catatan,
      'created_at': createdAt.toIso8601String(),
    };
  }

  SponsorTersimpanModel copyWith({
    String? id,
    String? idUser,
    String? idEvent,
    String? idSponsor,
    String? catatan,
    DateTime? createdAt,
  }) {
    return SponsorTersimpanModel(
      id: id ?? this.id,
      idUser: idUser ?? this.idUser,
      idEvent: idEvent ?? this.idEvent,
      idSponsor: idSponsor ?? this.idSponsor,
      catatan: catatan ?? this.catatan,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
