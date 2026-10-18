import 'sponsor_model.dart';

/// Entitas MatchingScore (PRD v1.1 §1.5).
///
/// Hasil komputasi kecocokan antara sebuah event dengan calon sponsor.
class MatchingScoreModel {
  final String idMatching;
  final String idEvent;
  final String idSponsor;
  final int score; // 0 - 100 (P1 + P2 + P3)
  final int skorKategori; // 0 atau 40
  final int skorAudience; // 0 atau 30
  final int skorKebutuhan; // 0 sampai 30
  final String label; // 'Tinggi' (75-100), 'Sedang' (50-74), 'Rendah' (40-49)
  final String alasanMatching;
  final List<String> catatanKurang;
  final DateTime generatedAt;

  /// Data sponsor terkait (opsional/populated untuk kemudahan rendering UI).
  final SponsorModel? sponsor;

  const MatchingScoreModel({
    required this.idMatching,
    required this.idEvent,
    required this.idSponsor,
    required this.score,
    required this.skorKategori,
    required this.skorAudience,
    required this.skorKebutuhan,
    required this.label,
    required this.alasanMatching,
    required this.catatanKurang,
    required this.generatedAt,
    this.sponsor,
  });

  /// Persentase skor dalam rentang 0.0 sampai 1.0 (untuk progress bar di Figma).
  double get scoreFraction => (score / 100.0).clamp(0.0, 1.0);

  /// Jumlah kriteria terpenuhi (0, 1, 2, atau 3).
  int get kriteriaTerpenuhiCount {
    int count = 0;
    if (skorKategori > 0) count++;
    if (skorAudience > 0) count++;
    if (skorKebutuhan > 0) count++;
    return count;
  }

  factory MatchingScoreModel.fromJson(Map<String, dynamic> json) {
    return MatchingScoreModel(
      idMatching: json['id_matching']?.toString() ?? '',
      idEvent: json['id_event']?.toString() ?? '',
      idSponsor: json['id_sponsor']?.toString() ?? '',
      score: json['score'] is int
          ? json['score']
          : int.tryParse(json['score']?.toString() ?? '0') ?? 0,
      skorKategori: json['skor_kategori'] is int
          ? json['skor_kategori']
          : int.tryParse(json['skor_kategori']?.toString() ?? '0') ?? 0,
      skorAudience: json['skor_audience'] is int
          ? json['skor_audience']
          : int.tryParse(json['skor_audience']?.toString() ?? '0') ?? 0,
      skorKebutuhan: json['skor_kebutuhan'] is int
          ? json['skor_kebutuhan']
          : int.tryParse(json['skor_kebutuhan']?.toString() ?? '0') ?? 0,
      label: json['label']?.toString() ?? 'Rendah',
      alasanMatching: json['alasan_matching']?.toString() ?? '',
      catatanKurang: (json['catatan_kurang'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      generatedAt: json['generated_at'] != null
          ? DateTime.tryParse(json['generated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      sponsor: json['sponsor'] != null && json['sponsor'] is Map<String, dynamic>
          ? SponsorModel.fromJson(json['sponsor'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_matching': idMatching,
      'id_event': idEvent,
      'id_sponsor': idSponsor,
      'score': score,
      'skor_kategori': skorKategori,
      'skor_audience': skorAudience,
      'skor_kebutuhan': skorKebutuhan,
      'label': label,
      'alasan_matching': alasanMatching,
      'catatan_kurang': catatanKurang,
      'generated_at': generatedAt.toIso8601String(),
      if (sponsor != null) 'sponsor': sponsor!.toJson(),
    };
  }
}

