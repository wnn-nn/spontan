import 'package:flutter_test/flutter_test.dart';
import 'package:spontan/core/utils/matching_calculator.dart';
import 'package:spontan/models/app_constants.dart';
import 'package:spontan/models/event_model.dart';
import 'package:spontan/models/kebutuhan_model.dart';
import 'package:spontan/models/proposal_model.dart';
import 'package:spontan/models/sponsor_model.dart';
import 'package:spontan/repositories/proposal_repository.dart';
import 'package:spontan/repositories/sponsor_repository.dart';

void main() {
  group('Modul 3: Matching Calculator Tests (PRD v1.1 §2.8 & FR-M3-02)', () {
    final sampleEvent = EventModel(
      idEvent: 1,
      idPembuat: 1,
      judul: 'Seminar Nasional Teknologi dan Karir 2026',
      deskripsi: 'Seminar teknologi nasional untuk membekali mahasiswa dan pelajar dengan skill masa depan.',
      tanggalMulai: '2026-11-20',
      tanggalSelesai: '2026-11-20',
      lokasi: 'Auditorium Universitas Andalas',
      kategori: 'Seminar',
      estimasiPeserta: 300,
      status: 'aktif',
      targetAudiences: const ['Mahasiswa', 'Pelajar (SMA/SMK)'],
    );

    final kebutuhanDana = KebutuhanModel(
      id: 'KEB-001',
      eventId: '1',
      jenis: AppConstants.jenisKebutuhanDana,
      deskripsi: 'Bantuan Dana Operasional',
      nilai: 5000000,
    );

    final kebutuhanBarang = KebutuhanModel(
      id: 'KEB-002',
      eventId: '1',
      jenis: AppConstants.jenisKebutuhanBarang,
      deskripsi: 'Snack Konsumsi Peserta',
      nilai: 3000000,
    );

    test('Hitung skor sempurna (100) bila P1, P2, dan P3 terpenuhi', () {
      const sponsorSempurna = SponsorModel(
        idSponsor: 'SPON-TEST-1',
        namaBrand: 'PT Maju Bersama',
        industri: 'Teknologi',
        deskripsi: 'Sponsor teknologi',
        preferensiKategori: ['Seminar'],
        preferensiTargetAudience: ['Mahasiswa'],
        preferensiJenisSponsorship: ['Dana', 'Barang'],
        kontakEmail: 'csr@maju.id',
      );

      final score = MatchingCalculator.calculate(
        event: sampleEvent,
        sponsor: sponsorSempurna,
        kebutuhanList: [kebutuhanDana, kebutuhanBarang],
      );

      expect(score.skorKategori, 40);
      expect(score.skorAudience, 30);
      expect(score.skorKebutuhan, 30);
      expect(score.score, 100);
      expect(score.label, 'Tinggi');
      expect(score.kriteriaTerpenuhiCount, 3);
    });

    test('Hitung skor parsial (70 = P1: 40 + P2: 30 + P3: 0)', () {
      const sponsorTanpaKebutuhanCocok = SponsorModel(
        idSponsor: 'SPON-TEST-2',
        namaBrand: 'Media Partner Express',
        industri: 'Media',
        deskripsi: 'Khusus media partner',
        preferensiKategori: ['Seminar'],
        preferensiTargetAudience: ['Mahasiswa'],
        preferensiJenisSponsorship: ['Media Partner'], // Tidak butuh Dana/Barang
        kontakEmail: 'redaksi@express.id',
      );

      final score = MatchingCalculator.calculate(
        event: sampleEvent,
        sponsor: sponsorTanpaKebutuhanCocok,
        kebutuhanList: [kebutuhanDana, kebutuhanBarang],
      );

      expect(score.skorKategori, 40);
      expect(score.skorAudience, 30);
      expect(score.skorKebutuhan, 0);
      expect(score.score, 70);
      expect(score.label, 'Sedang');
      expect(score.kriteriaTerpenuhiCount, 2);
    });

    test('Filter ambang batas: hanya sponsor dengan total skor >= 40 yang ditampilkan', () {
      const sponsorTidakCocokSamaSekali = SponsorModel(
        idSponsor: 'SPON-TEST-LOW',
        namaBrand: 'Sponsor Berbeda Jauh',
        industri: 'Konstruksi Berat',
        deskripsi: 'Hanya event lomba olahraga',
        preferensiKategori: ['Kompetisi'],
        preferensiTargetAudience: ['Masyarakat Umum'],
        preferensiJenisSponsorship: ['Jasa'],
        kontakEmail: 'info@low.id',
      );

      final recommendations = MatchingCalculator.calculateRecommendations(
        event: sampleEvent,
        allSponsors: [sponsorTidakCocokSamaSekali],
        kebutuhanList: [kebutuhanDana],
      );

      expect(recommendations.isEmpty, isTrue);
    });

    test('Sorting rekomendasi: skor tertinggi dahulu, jika skor sama urut abjad namaBrand', () {
      const sponsorA = SponsorModel(
        idSponsor: 'A',
        namaBrand: 'Brand Alpha',
        industri: 'IT',
        deskripsi: 'A',
        preferensiKategori: ['Seminar'],
        preferensiTargetAudience: ['Mahasiswa'],
        preferensiJenisSponsorship: ['Dana'],
        kontakEmail: 'a@a.id',
      );

      const sponsorB = SponsorModel(
        idSponsor: 'B',
        namaBrand: 'Brand Beta',
        industri: 'IT',
        deskripsi: 'B',
        preferensiKategori: ['Seminar'],
        preferensiTargetAudience: ['Mahasiswa'],
        preferensiJenisSponsorship: ['Dana'],
        kontakEmail: 'b@b.id',
      );

      final recommendations = MatchingCalculator.calculateRecommendations(
        event: sampleEvent,
        allSponsors: [sponsorB, sponsorA],
        kebutuhanList: [kebutuhanDana],
      );

      expect(recommendations.length, 2);
      expect(recommendations[0].sponsor?.namaBrand, 'Brand Alpha');
      expect(recommendations[1].sponsor?.namaBrand, 'Brand Beta');
    });
  });

  group('Modul 3: Sponsor Bookmark Tests (FR-M3-01)', () {
    final repo = SponsorRepository.instance;

    test('Toggle bookmark sponsor sasaran berfungsi dengan baik', () async {
      const eventId = 'TEST_EVT_100';
      const sponsorId = 'SPON-001';

      // Pastikan awalnya false
      final initialStatus = await repo.isSponsorSaved(eventId, sponsorId);
      expect(initialStatus, isFalse);

      // Bookmark pertama -> true
      final toggledOn = await repo.toggleSaveSponsor(eventId, sponsorId);
      expect(toggledOn, isTrue);
      expect(await repo.isSponsorSaved(eventId, sponsorId), isTrue);

      // Bookmark kedua -> false (un-bookmark)
      final toggledOff = await repo.toggleSaveSponsor(eventId, sponsorId);
      expect(toggledOff, isFalse);
      expect(await repo.isSponsorSaved(eventId, sponsorId), isFalse);
    });
  });

  group('Modul 3: Proposal Tracking & Pembatalan Tests (FR-M3-03 & FR-M3-04)', () {
    final repo = ProposalRepository.instance;

    test('Membatalkan proposal yang pending berhasil dan menyimpan alasan pembatalan', () async {
      final proposals = await repo.getAll();
      final pendingProposal = proposals.firstWhere(
        (p) => p.status == AppConstants.statusProposalPending,
      );

      const alasan = 'Perubahan jadwal kegiatan acara secara mendadak oleh pihak fakultas';
      final updated = await repo.cancelProposal(
        pendingProposal.id,
        alasan,
      );

      expect(updated.status, AppConstants.statusProposalCancelled);
      expect(updated.alasanPembatalan, alasan);
      expect(updated.statusDiperbaruiPada, isNotNull);

      // Verifikasi di repository juga berubah
      final retrieved = await repo.getById(pendingProposal.id);
      expect(retrieved?.status, AppConstants.statusProposalCancelled);
      expect(retrieved?.alasanPembatalan, alasan);
    });

    test('Membatalkan proposal dengan status selain pending harus melempar StateError', () async {
      final proposals = await repo.getAll();
      final acceptedProposal = proposals.firstWhere(
        (p) => p.status == AppConstants.statusProposalAccepted,
      );

      expect(
        () async => await repo.cancelProposal(
          acceptedProposal.id,
          'Mau batalkan proposal yang sudah di-accept',
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('Membatalkan proposal dengan alasan kosong atau kurang dari 5 karakter melempar ArgumentError', () async {
      final newProposal = ProposalModel(
        id: 'PROP-TEST-VALIDATION',
        eventId: '99',
        sponsorId: 'SPON-002',
        isiProposal: 'Pesan pengantar uji validasi pembatalan',
        status: AppConstants.statusProposalPending,
      );
      await repo.add(newProposal);

      expect(
        () async => await repo.cancelProposal(
          newProposal.id,
          '   ',
        ),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () async => await repo.cancelProposal(
          newProposal.id,
          'batal', // < 5 huruf yang bermakna jika whitespace di-trim
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
