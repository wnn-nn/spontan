/// Entitas SponsorTersimpan (PRD v1.1 §1.7, FR-M3-01).
///
/// Bookmark sponsor sasaran yang disimpan mahasiswa per event untuk difollow-up.
class SponsorTersimpanModel {
  final String id;
  final String idUser;
  final String idEvent;
  final String idSponsor;
  final DateTime createdAt;

  const SponsorTersimpanModel({
    required this.id,
    required this.idUser,
    required this.idEvent,
    required this.idSponsor,
    required this.createdAt,
  });

  factory SponsorTersimpanModel.fromJson(Map<String, dynamic> json) {
    return SponsorTersimpanModel(
      id: json['id']?.toString() ?? '',
      idUser: json['id_user']?.toString() ?? '',
      idEvent: json['id_event']?.toString() ?? '',
      idSponsor: json['id_sponsor']?.toString() ?? '',
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
      'created_at': createdAt.toIso8601String(),
    };
  }
}

