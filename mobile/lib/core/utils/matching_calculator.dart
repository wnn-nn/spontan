import '../../models/event_model.dart';
import '../../models/kebutuhan_model.dart';
import '../../models/matching_score_model.dart';
import '../../models/sponsor_model.dart';

/// Algoritma Rule-based Matching Sponsorship (PRD v1.1 §2.8 & Modul 3 Step 5.2).
///
/// Menghitung Matching Score (0–100) secara deterministik:
/// Score = P1 (Kategori: 40) + P2 (Audience: 30) + P3 (Kebutuhan: 30)
class MatchingCalculator {
  MatchingCalculator._();

  /// Menghitung kecocokan antara sebuah [event] dengan satu [sponsor].
  static MatchingScoreModel calculate({
    required EventModel event,
    required SponsorModel sponsor,
    required List<KebutuhanModel> kebutuhanList,
  }) {
    // ── P1: Kategori Event (Maks. 40 poin) ───────────────────────────────────
    final eventKategoriLower = event.kategori.trim().toLowerCase();
    final isKategoriMatch = sponsor.preferensiKategori
        .any((k) => k.trim().toLowerCase() == eventKategoriLower);
    final int p1Score = isKategoriMatch ? 40 : 0;

    // ── P2: Target Audience (Maks. 30 poin) ──────────────────────────────────
    final sponsorAudiencesLower = sponsor.preferensiTargetAudience
        .map((a) => a.trim().toLowerCase())
        .toSet();

    bool isAudienceMatch = false;
    String matchedAudienceText = '';

    if (event.targetAudiences.isNotEmpty) {
      for (final audience in event.targetAudiences) {
        if (sponsorAudiencesLower.contains(audience.trim().toLowerCase())) {
          isAudienceMatch = true;
          matchedAudienceText = audience;
          break;
        }
      }
    }
    final int p2Score = isAudienceMatch ? 30 : 0;

    // ── P3: Jenis Kebutuhan Sponsorship (Maks. 30 poin) ─────────────────────
    final sponsorJenisLower = sponsor.preferensiJenisSponsorship
        .map((j) => j.trim().toLowerCase())
        .toSet();

    // Himpunan jenis kebutuhan unik event (Dana, Barang, Media Partner, dsb.)
    final eventJenisSet = kebutuhanList
        .map((k) => k.jenis.trim())
        .where((j) => j.isNotEmpty)
        .toSet();

    int p3Score = 0;
    int matchedJenisCount = 0;
    final List<String> matchedJenisList = [];

    if (eventJenisSet.isNotEmpty) {
      for (final jenis in eventJenisSet) {
        if (sponsorJenisLower.contains(jenis.toLowerCase())) {
          matchedJenisCount++;
          matchedJenisList.add(jenis);
        }
      }
      p3Score = ((30 * matchedJenisCount) / eventJenisSet.length).round();
    }

    // ── Total Score & Label (PRD §2.8.4 & §2.8.5) ───────────────────────────
    final int totalScore = (p1Score + p2Score + p3Score).clamp(0, 100);

    String label;
    if (totalScore >= 75) {
      label = 'Tinggi';
    } else if (totalScore >= 50) {
      label = 'Sedang';
    } else {
      label = 'Rendah';
    }

    // ── Pembentukan Alasan Matching & Catatan Kurang (PRD §2.8.6) ───────────
    final List<String> matches = [];
    final List<String> missing = [];

    if (p1Score > 0) {
      matches.add('Kategori ${event.kategori} sesuai preferensi sponsor');
    } else {
      missing.add('Kategori "${event.kategori}" belum termasuk preferensi sponsor');
    }

    if (p2Score > 0) {
      final audText = matchedAudienceText.isNotEmpty
          ? matchedAudienceText
          : (event.targetAudiences.isNotEmpty ? event.targetAudiences.first : 'Target audiens');
      matches.add('Target audience $audText sesuai');
    } else {
      missing.add('Target audience event belum sesuai preferensi sponsor');
    }

    if (eventJenisSet.isEmpty) {
      missing.add('Event belum memiliki kebutuhan sponsorship');
    } else if (p3Score > 0) {
      if (matchedJenisCount == eventJenisSet.length) {
        matches.add('Mendukung ${matchedJenisList.join(" & ")}');
      } else {
        matches.add('Mendukung $matchedJenisCount dari ${eventJenisSet.length} jenis kebutuhan');
      }
      if (matchedJenisCount < eventJenisSet.length) {
        final missingKinds = eventJenisSet
            .where((j) => !sponsorJenisLower.contains(j.toLowerCase()))
            .toList();
        missing.add('Belum mendukung kebutuhan: ${missingKinds.join(", ")}');
      }
    } else {
      missing.add('Bentuk sponsorship yang dibutuhkan event belum didukung sponsor');
    }

    final int criteriaCount = matches.length;
    final String alasanMatching = criteriaCount > 0
        ? '$criteriaCount dari 3 kriteria terpenuhi: ${matches.join(", ")}.'
        : 'Belum ada kriteria utama yang terpenuhi.';

    return MatchingScoreModel(
      idMatching: 'MATCH-${event.idEvent}-${sponsor.idSponsor}',
      idEvent: event.idEvent.toString(),
      idSponsor: sponsor.idSponsor,
      score: totalScore,
      skorKategori: p1Score,
      skorAudience: p2Score,
      skorKebutuhan: p3Score,
      label: label,
      alasanMatching: alasanMatching,
      catatanKurang: missing,
      generatedAt: DateTime.now(),
      sponsor: sponsor,
    );
  }

  /// Menghitung skor matching untuk seluruh sponsor, menyaring hanya skor >= 40 (ambang tampil),
  /// dan mengurutkannya dari skor tertinggi ke terendah lalu nama brand A-Z (PRD §2.8.5).
  static List<MatchingScoreModel> calculateRecommendations({
    required EventModel event,
    required List<SponsorModel> allSponsors,
    required List<KebutuhanModel> kebutuhanList,
  }) {
    final List<MatchingScoreModel> results = [];

    for (final sponsor in allSponsors) {
      final scoreModel = calculate(
        event: event,
        sponsor: sponsor,
        kebutuhanList: kebutuhanList,
      );

      // Ambang Tampil: Hanya skor >= 40 yang ditampilkan (PRD §2.8.5)
      if (scoreModel.score >= 40) {
        results.add(scoreModel);
      }
    }

    // Urutan: Skor tertinggi ke terendah, lalu nama brand A-Z jika skor sama
    results.sort((a, b) {
      final scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) return scoreCompare;
      final nameA = a.sponsor?.namaBrand ?? '';
      final nameB = b.sponsor?.namaBrand ?? '';
      return nameA.toLowerCase().compareTo(nameB.toLowerCase());
    });

    return results;
  }
}

