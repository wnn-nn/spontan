import '../models/app_constants.dart';
import '../models/proposal_model.dart';

/// Repository in-memory untuk mengelola data [ProposalModel] (PRD v1.1 §1.6 & §2.9).
///
/// Seluruh data disimpan sementara menggunakan [List] di memori.
/// Mendukung pelacakan status, pembatalan proposal (FR-M3-03 & FR-M3-04),
/// dan query proposal aktif.
class ProposalRepository {
  /// Singleton instance agar satu List digunakan di seluruh aplikasi.
  static final ProposalRepository _instance = ProposalRepository._internal();
  static ProposalRepository get instance => _instance;

  factory ProposalRepository() => _instance;

  ProposalRepository._internal() {
    _initDefaultProposals();
  }

  /// Penyimpanan in-memory seluruh proposal.
  final List<ProposalModel> _items = [];

  void _initDefaultProposals() {
    _items.addAll([
      ProposalModel(
        id: 'PROP-001',
        eventId: '1',
        sponsorId: 'SPON-001',
        sponsorName: 'PT Telkom Indonesia',
        eventName: 'Seminar Teknologi Kampus',
        jenisKebutuhan: 'Dana & Media Partner',
        isiProposal:
            'Kami dari panitia Seminar Teknologi Kampus Universitas Andalas bermaksud mengajukan kerja sama sponsorship dalam bentuk dana operasional dan publikasi digital.',
        status: AppConstants.statusProposalAccepted,
        tanggalKirim: DateTime(2026, 10, 14, 10, 30),
        catatanSponsor: 'Disetujui. Dana sponsorship sebesar Rp 5.000.000 akan ditransfer.',
        statusDiperbaruiPada: DateTime(2026, 10, 16, 14, 00),
      ),
      ProposalModel(
        id: 'PROP-002',
        eventId: '1',
        sponsorId: 'SPON-002',
        sponsorName: 'Bank Nagari',
        eventName: 'Seminar Teknologi Kampus',
        jenisKebutuhan: 'Dana',
        isiProposal:
            'Pengajuan sponsorship paket Silver untuk mendukung kelancaran kegiatan seminar nasional kewirausahaan dan teknologi mahasiswa.',
        status: AppConstants.statusProposalAccepted,
        tanggalKirim: DateTime(2026, 10, 12, 9, 15),
        catatanSponsor: 'Disetujui paket Silver Sponsorship Rp 3.000.000.',
        statusDiperbaruiPada: DateTime(2026, 10, 15, 11, 20),
      ),
      ProposalModel(
        id: 'PROP-003',
        eventId: '2',
        sponsorId: 'SPON-003',
        sponsorName: 'Indofood Sukses Makmur',
        eventName: 'Festival Budaya Nusantara',
        jenisKebutuhan: 'Barang (Konsumsi 300 paket)',
        isiProposal:
            'Permohonan bantuan konsumsi snack box dan produk minuman kemasan untuk 300 peserta Festival Budaya Nusantara.',
        status: AppConstants.statusProposalPending,
        tanggalKirim: DateTime(2026, 10, 15, 14, 00),
        catatanSponsor: 'Sedang direview oleh divisi CSR & Humas PT Indofood.',
        statusDiperbaruiPada: DateTime(2026, 10, 15, 14, 00),
      ),
      ProposalModel(
        id: 'PROP-004',
        eventId: '2',
        sponsorId: 'SPON-005',
        sponsorName: 'Shopee Indonesia',
        eventName: 'Festival Budaya Nusantara',
        jenisKebutuhan: 'Media Partner',
        isiProposal:
            'Draft permohonan publikasi event pada kanal media sosial dan voucher diskon belanja bagi pemenang lomba.',
        status: AppConstants.statusProposalDraft,
        tanggalKirim: null,
        catatanSponsor: null,
      ),
      ProposalModel(
        id: 'PROP-005',
        eventId: '3',
        sponsorId: 'SPON-004',
        sponsorName: 'Gojek Padang',
        eventName: 'Lomba Mobile Apps Unand',
        jenisKebutuhan: 'Dana',
        isiProposal:
            'Pengajuan dana hadiah utama dan sertifikat kompetisi aplikasi mobile se-Sumatera Barat.',
        status: AppConstants.statusProposalRejected,
        tanggalKirim: DateTime(2026, 10, 10, 8, 30),
        catatanSponsor: 'Slot sponsorship kuartal IV sudah terpenuhi.',
        statusDiperbaruiPada: DateTime(2026, 10, 12, 16, 45),
      ),
      ProposalModel(
        id: 'PROP-006',
        eventId: '1',
        sponsorId: 'SPON-006',
        sponsorName: 'Paragon Technology & Innovation',
        eventName: 'Seminar Teknologi Kampus',
        jenisKebutuhan: 'Barang & Goodie Bag',
        isiProposal:
            'Pengajuan permohonan 100 paket seminar kit / produk perawatan untuk pemateri dan peserta.',
        status: AppConstants.statusProposalCancelled,
        tanggalKirim: DateTime(2026, 10, 11, 13, 00),
        alasanPembatalan: 'Telah mendapatkan sponsor barang alternatif dengan kuota lebih besar.',
        statusDiperbaruiPada: DateTime(2026, 10, 13, 10, 15),
      ),
    ]);
  }

  // ── Read ───────────────────────────────────────────────────────────────────

  /// Mengambil seluruh proposal yang tersimpan di repository.
  Future<List<ProposalModel>> getAll() async {
    return List.unmodifiable(_items);
  }

  /// Mengambil proposal berdasarkan [id].
  Future<ProposalModel?> getById(String id) async {
    try {
      return _items.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Mengambil semua proposal yang terkait dengan [eventId] tertentu.
  Future<List<ProposalModel>> getByEvent(String eventId) async {
    return _items.where((p) => p.eventId == eventId).toList();
  }

  /// Mengambil proposal yang disaring berdasarkan [status] (atau semua jika 'Semua').
  Future<List<ProposalModel>> getByStatus(String status) async {
    if (status == 'Semua') return List.unmodifiable(_items);
    return _items.where((p) => p.status.toLowerCase() == status.toLowerCase()).toList();
  }

  // ── Create ─────────────────────────────────────────────────────────────────

  /// Menambahkan [proposal] baru ke repository.
  Future<void> add(ProposalModel proposal) async {
    _items.add(proposal);
  }

  // ── Update ─────────────────────────────────────────────────────────────────

  /// Memperbarui proposal yang sudah ada berdasarkan [proposal.id].
  Future<void> update(ProposalModel proposal) async {
    final index = _items.indexWhere((p) => p.id == proposal.id);
    if (index == -1) {
      throw ArgumentError('Proposal dengan id "${proposal.id}" tidak ditemukan.');
    }
    _items[index] = proposal;
  }

  // ── Delete ─────────────────────────────────────────────────────────────────

  /// Menghapus proposal berdasarkan [id] (khusus draft, FR-M2-04).
  Future<void> delete(String id) async {
    _items.removeWhere((p) => p.id == id);
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  /// Mengirimkan proposal dengan [id]: mengubah status dari Draft ke Pending.
  Future<void> submit(String id) async {
    final index = _items.indexWhere((p) => p.id == id);
    if (index == -1) {
      throw ArgumentError('Proposal dengan id "$id" tidak ditemukan.');
    }

    final proposal = _items[index];
    if (proposal.status != AppConstants.statusProposalDraft) {
      throw ArgumentError(
        'Proposal tidak dapat dikirim karena statusnya bukan '
        '"${AppConstants.statusProposalDraft}". Status saat ini: "${proposal.status}".',
      );
    }

    _items[index] = proposal.copyWith(
      status: AppConstants.statusProposalPending,
      tanggalKirim: DateTime.now(),
      statusDiperbaruiPada: DateTime.now(),
    );
  }

  // ── Pembatalan Proposal (FR-M3-03 & FR-M3-04) ──────────────────────────────

  /// Membatalkan proposal yang masih berstatus [AppConstants.statusProposalPending]
  /// dan memperbarui statusnya menjadi [AppConstants.statusProposalCancelled] dengan
  /// menyertakan [alasanPembatalan] oleh mahasiswa (PRD v1.1 §3.2 Aturan 5).
  Future<ProposalModel> cancelProposal(String id, String alasanPembatalan) async {
    final trimmedAlasan = alasanPembatalan.trim();
    if (trimmedAlasan.length < 5) {
      throw ArgumentError('Alasan pembatalan minimal 5 karakter.');
    }

    final index = _items.indexWhere((p) => p.id == id);
    if (index == -1) {
      throw ArgumentError('Proposal dengan id "$id" tidak ditemukan.');
    }

    final proposal = _items[index];
    if (proposal.status != AppConstants.statusProposalPending) {
      throw StateError(
        'Hanya proposal dengan status "${AppConstants.statusProposalPending}" yang dapat dibatalkan. '
        'Status saat ini: "${proposal.status}".',
      );
    }

    final updated = proposal.copyWith(
      status: AppConstants.statusProposalCancelled,
      alasanPembatalan: trimmedAlasan,
      statusDiperbaruiPada: DateTime.now(),
    );

    _items[index] = updated;
    return updated;
  }

  // ── Query Helpers ──────────────────────────────────────────────────────────

  /// Memeriksa apakah [eventId] memiliki setidaknya satu proposal aktif
  /// (berstatus Pending atau Accepted, PRD §3.2 Aturan 1 & 2).
  Future<bool> hasActiveProposal(String eventId) async {
    return _items.any(
      (p) =>
          p.eventId == eventId &&
          (p.status == AppConstants.statusProposalPending ||
              p.status == AppConstants.statusProposalAccepted),
    );
  }

  // ── Simulasi API Sync / Refresh (PRD §2.9) ──────────────────────────────────

  /// Mengambil data status terbaru dari API/Mock API saat pull-to-refresh.
  Future<List<ProposalModel>> refreshProposalStatuses() async {
    // Simulasi delay network NFR-01 (< 3 detik)
    await Future.delayed(const Duration(milliseconds: 600));
    return List.unmodifiable(_items);
  }

  // ── Internal Testing Only ──────────────────────────────────────────────────

  /// Mensimulasikan respons sponsor (Accepted / Rejected) untuk keperluan pengujian.
  Future<void> simulateStatus(String id, String newStatus, {String? catatan}) async {
    final index = _items.indexWhere((p) => p.id == id);
    if (index == -1) {
      throw ArgumentError('Proposal dengan id "$id" tidak ditemukan.');
    }

    final proposal = _items[index];
    _items[index] = proposal.copyWith(
      status: newStatus,
      catatanSponsor: catatan ?? proposal.catatanSponsor,
      statusDiperbaruiPada: DateTime.now(),
    );
  }
}
