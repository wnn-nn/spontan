import 'package:flutter/material.dart';

/// Entitas Sponsor (PRD v1.1 §1.4).
///
/// Data profil perusahaan/brand calon sponsor yang ada di sistem (read-only bagi mahasiswa).
class SponsorModel {
  final String idSponsor;
  final String namaBrand;
  final String industri;
  final String deskripsi;
  final String? logo;
  final List<String> preferensiKategori;
  final List<String> preferensiTargetAudience;
  final List<String> preferensiJenisSponsorship;
  final String? kontakEmail;

  // Visual helper untuk UI (Figma matching)
  final String? customInitials;
  final Color? customAvatarBg;
  final Color? customAvatarColor;

  const SponsorModel({
    required this.idSponsor,
    required this.namaBrand,
    required this.industri,
    required this.deskripsi,
    this.logo,
    required this.preferensiKategori,
    required this.preferensiTargetAudience,
    required this.preferensiJenisSponsorship,
    this.kontakEmail,
    this.customInitials,
    this.customAvatarBg,
    this.customAvatarColor,
  });

  /// Inisial brand sponsor (misal "TI" untuk PT Telkom Indonesia, "BN" untuk Bank Nagari).
  String get initials {
    if (customInitials != null && customInitials!.isNotEmpty) {
      return customInitials!;
    }
    final words = namaBrand
        .replaceAll('PT ', '')
        .replaceAll('PT. ', '')
        .trim()
        .split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return namaBrand.substring(0, namaBrand.length >= 2 ? 2 : 1).toUpperCase();
  }

  Color get avatarBg => customAvatarBg ?? const Color(0xFFEFF6FF);
  Color get avatarColor => customAvatarColor ?? const Color(0xFF2563EB);

  factory SponsorModel.fromJson(Map<String, dynamic> json) {
    return SponsorModel(
      idSponsor: json['id_sponsor']?.toString() ?? '',
      namaBrand: json['nama_brand']?.toString() ?? '',
      industri: json['industri']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? '',
      logo: json['logo']?.toString(),
      preferensiKategori: (json['preferensi_kategori'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      preferensiTargetAudience:
          (json['preferensi_target_audience'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
      preferensiJenisSponsorship:
          (json['preferensi_jenis_sponsorship'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
      kontakEmail: json['kontak_email']?.toString(),
      customInitials: json['initials']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_sponsor': idSponsor,
      'nama_brand': namaBrand,
      'industri': industri,
      'deskripsi': deskripsi,
      'logo': logo,
      'preferensi_kategori': preferensiKategori,
      'preferensi_target_audience': preferensiTargetAudience,
      'preferensi_jenis_sponsorship': preferensiJenisSponsorship,
      'kontak_email': kontakEmail,
    };
  }
}

