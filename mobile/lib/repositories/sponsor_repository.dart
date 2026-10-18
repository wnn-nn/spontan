import 'package:flutter/material.dart';

import '../models/sponsor_model.dart';
import '../models/sponsor_tersimpan_model.dart';

/// Repository in-memory untuk master data [SponsorModel] dan bookmark [SponsorTersimpanModel] (PRD v1.1 §1.4 & §1.7, FR-M3-01).
class SponsorRepository {
  static final SponsorRepository _instance = SponsorRepository._internal();
  static SponsorRepository get instance => _instance;

  factory SponsorRepository() => _instance;

  SponsorRepository._internal() {
    _initDefaultSponsors();
  }

  final List<SponsorModel> _sponsors = [];
  final List<SponsorTersimpanModel> _savedSponsors = [];

  void _initDefaultSponsors() {
    _sponsors.addAll([
      const SponsorModel(
        idSponsor: 'SPON-001',
        namaBrand: 'PT Telkom Indonesia',
        industri: 'Teknologi & Telekomunikasi',
        deskripsi:
            'Perusahaan BUMN telekomunikasi terkemuka di Indonesia yang aktif mendukung inovasi digital, literasi IT, dan kegiatan kemahasiswaan nasional.',
        preferensiKategori: ['Seminar', 'Kompetisi', 'PKM'],
        preferensiTargetAudience: ['Mahasiswa', 'Pelajar (SMA/SMK)'],
        preferensiJenisSponsorship: ['Dana', 'Media Partner'],
        kontakEmail: 'csr@telkom.co.id',
        customInitials: 'TI',
        customAvatarBg: Color(0xFFEFF6FF),
        customAvatarColor: Color(0xFF2563EB),
      ),
      const SponsorModel(
        idSponsor: 'SPON-002',
        namaBrand: 'Bank Nagari',
        industri: 'Perbankan & Keuangan Daerah',
        deskripsi:
            'Bank Pembangunan Daerah Sumatera Barat yang berkomitmen memajukan pendidikan, kepemudaan, dan kewirausahaan mahasiswa Universitas Andalas.',
        preferensiKategori: ['Seminar', 'Kegiatan Organisasi', 'Lainnya'],
        preferensiTargetAudience: ['Mahasiswa', 'Masyarakat Umum'],
        preferensiJenisSponsorship: ['Dana'],
        kontakEmail: 'sponsorship@banknagari.co.id',
        customInitials: 'BN',
        customAvatarBg: Color(0xFFFFF1EB),
        customAvatarColor: Color(0xFFF97316),
      ),
      const SponsorModel(
        idSponsor: 'SPON-003',
        namaBrand: 'Indofood Sukses Makmur',
        industri: 'Fast-Moving Consumer Goods (FMCG)',
        deskripsi:
            'Produsen makanan dan minuman terbesar yang rutin memberikan dukungan konsumsi, goodie bag, dan produk sponsorship untuk event kampus berskala besar.',
        preferensiKategori: ['Seminar', 'Kompetisi', 'Kegiatan Organisasi', 'Lainnya'],
        preferensiTargetAudience: ['Mahasiswa', 'Pelajar (SMA/SMK)', 'Masyarakat Umum'],
        preferensiJenisSponsorship: ['Barang', 'Dana'],
        kontakEmail: 'community@indofood.co.id',
        customInitials: 'IF',
        customAvatarBg: Color(0xFFE6F9F0),
        customAvatarColor: Color(0xFF10B981),
      ),
      const SponsorModel(
        idSponsor: 'SPON-004',
        namaBrand: 'Gojek Indonesia',
        industri: 'Teknologi & Transportasi On-Demand',
        deskripsi:
            'Platform on-demand terdepan yang mendukung mobilitas, voucher diskon perjalanan peserta, serta dana sponsorship untuk kegiatan teknologi dan kepemudaan.',
        preferensiKategori: ['Kompetisi', 'Seminar', 'Lainnya'],
        preferensiTargetAudience: ['Mahasiswa', 'Komunitas/Profesional'],
        preferensiJenisSponsorship: ['Dana', 'Media Partner'],
        kontakEmail: 'padang@go-jek.com',
        customInitials: 'GJ',
        customAvatarBg: Color(0xFFE0F2FE),
        customAvatarColor: Color(0xFF0284C7),
      ),
      const SponsorModel(
        idSponsor: 'SPON-005',
        namaBrand: 'Shopee Indonesia',
        industri: 'E-Commerce & Digital Services',
        deskripsi:
            'Platform belanja daring terpopuler yang fokus pada pemberdayaan generasi muda, sponsorship kompetisi kreatif, dan kemitraan media partner kampus.',
        preferensiKategori: ['Kompetisi', 'Seminar'],
        preferensiTargetAudience: ['Mahasiswa', 'Pelajar (SMA/SMK)'],
        preferensiJenisSponsorship: ['Media Partner', 'Dana'],
        kontakEmail: 'campus.relations@shopee.co.id',
        customInitials: 'SH',
        customAvatarBg: Color(0xFFFEF2F2),
        customAvatarColor: Color(0xFFEF4444),
      ),
      const SponsorModel(
        idSponsor: 'SPON-006',
        namaBrand: 'Paragon Technology & Innovation',
        industri: 'Beauty & FMCG (Wardah, Emina, Kahf)',
        deskripsi:
            'Perusahaan kosmetik nasional yang memiliki program Paragon Goes to Campus, mendukung seminar kepemimpinan, grooming, dan festival mahasiswa.',
        preferensiKategori: ['Seminar', 'Kegiatan Organisasi'],
        preferensiTargetAudience: ['Mahasiswa', 'Komunitas/Profesional'],
        preferensiJenisSponsorship: ['Barang', 'Dana'],
        kontakEmail: 'csr@paragon-tni.com',
        customInitials: 'PT',
        customAvatarBg: Color(0xFFFDF4FF),
        customAvatarColor: Color(0xFFA855F7),
      ),
      const SponsorModel(
        idSponsor: 'SPON-007',
        namaBrand: 'Ruangguru',
        industri: 'Pendidikan & Teknologi (EdTech)',
        deskripsi:
            'Perusahaan teknologi pendidikan terbesar di Indonesia yang mendukung seminar akademik, beasiswa, dan pendampingan olimpiade/kompetisi pelajar-mahasiswa.',
        preferensiKategori: ['Seminar', 'Kompetisi', 'PKM'],
        preferensiTargetAudience: ['Pelajar (SMA/SMK)', 'Mahasiswa'],
        preferensiJenisSponsorship: ['Media Partner', 'Barang'],
        kontakEmail: 'partnership@ruangguru.com',
        customInitials: 'RG',
        customAvatarBg: Color(0xFFEFF6FF),
        customAvatarColor: Color(0xFF3B82F6),
      ),
      const SponsorModel(
        idSponsor: 'SPON-008',
        namaBrand: 'PT Semen Padang',
        industri: 'Manufaktur & Material Konstruksi',
        deskripsi:
            'Pabrik semen tertua di Asia Tenggara yang aktif memberikan kontribusi CSR berkelanjutan untuk kegiatan akademik, PKM, dan riset mahasiswa Universitas Andalas.',
        preferensiKategori: ['Seminar', 'PKM', 'Kegiatan Organisasi'],
        preferensiTargetAudience: ['Mahasiswa', 'Masyarakat Umum'],
        preferensiJenisSponsorship: ['Dana'],
        kontakEmail: 'humas@semenpadang.co.id',
        customInitials: 'SP',
        customAvatarBg: Color(0xFFF1F5F9),
        customAvatarColor: Color(0xFF475569),
      ),
    ]);

    // Initial default saved sponsors (Bookmark)
    _savedSponsors.addAll([
      SponsorTersimpanModel(
        id: 'BM-001',
        idUser: '1',
        idEvent: '1',
        idSponsor: 'SPON-001',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      SponsorTersimpanModel(
        id: 'BM-002',
        idUser: '1',
        idEvent: '1',
        idSponsor: 'SPON-002',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      SponsorTersimpanModel(
        id: 'BM-003',
        idUser: '1',
        idEvent: '2',
        idSponsor: 'SPON-003',
        createdAt: DateTime.now(),
      ),
    ]);
  }

  // ── Read Master Data ───────────────────────────────────────────────────────

  /// Mengambil seluruh data sponsor yang tersedia di sistem.
  Future<List<SponsorModel>> getAll() async {
    return List.unmodifiable(_sponsors);
  }

  /// Mencari sponsor berdasarkan [idSponsor].
  Future<SponsorModel?> getById(String idSponsor) async {
    return getSponsorById(idSponsor);
  }

  /// Mencari sponsor berdasarkan [idSponsor] secara langsung (sinkron).
  SponsorModel? getSponsorById(String idSponsor) {
    try {
      return _sponsors.firstWhere((s) => s.idSponsor == idSponsor);
    } catch (_) {
      return null;
    }
  }

  // ── Bookmark / Sponsor Sasaran (FR-M3-01) ──────────────────────────────────

  /// Memeriksa apakah sponsor tertentu sudah disimpan di event tersebut.
  Future<bool> isSponsorSaved(String eventId, String sponsorId) async {
    return _savedSponsors.any((b) => b.idEvent == eventId && b.idSponsor == sponsorId);
  }

  /// Menyimpan atau menghapus sponsor dari "Daftar Sponsor Sasaran" (Bookmark).
  ///
  /// Mengembalikan `true` jika status berubah menjadi disimpan (saved),
  /// atau `false` jika status berubah menjadi dihapus (un-saved).
  Future<bool> toggleSaveSponsor(String eventId, String sponsorId) async {
    final index = _savedSponsors.indexWhere(
      (b) => b.idEvent == eventId && b.idSponsor == sponsorId,
    );

    if (index >= 0) {
      _savedSponsors.removeAt(index);
      return false;
    } else {
      _savedSponsors.add(
        SponsorTersimpanModel(
          id: 'BM-${DateTime.now().millisecondsSinceEpoch}',
          idUser: '1',
          idEvent: eventId,
          idSponsor: sponsorId,
          createdAt: DateTime.now(),
        ),
      );
      return true;
    }
  }

  /// Mengambil daftar sponsor yang disimpan untuk [eventId] tertentu.
  Future<List<SponsorModel>> getSavedSponsorsByEvent(String eventId) async {
    final sponsorIds = _savedSponsors
        .where((b) => b.idEvent == eventId)
        .map((b) => b.idSponsor)
        .toSet();
    return _sponsors.where((s) => sponsorIds.contains(s.idSponsor)).toList();
  }

  /// Mengambil seluruh sponsor sasaran yang tersimpan beserta info bookmark.
  Future<List<Map<String, dynamic>>> getAllSavedSponsors() async {
    final List<Map<String, dynamic>> results = [];
    for (final bookmark in _savedSponsors) {
      final sponsor = await getById(bookmark.idSponsor);
      if (sponsor != null) {
        results.add({
          'bookmark': bookmark,
          'sponsor': sponsor,
        });
      }
    }
    return results;
  }
}
