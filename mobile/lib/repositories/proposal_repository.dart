import '../models/app_constants.dart';
import '../models/proposal_model.dart';

/// Repository in-memory untuk mengelola data [ProposalModel].
///
/// Seluruh data disimpan sementara menggunakan [List] di memori.
/// Semua fungsi mengembalikan [Future] agar konsisten dengan pola
/// asynchronous project dan mudah digantikan implementasi backend di kemudian hari.
///
/// Catatan Progress 1:
/// - Status [AppConstants.statusProposalAccepted] dan [AppConstants.statusProposalRejected]
///   pada produksi harus berasal dari API/mock API, bukan diubah langsung oleh pengguna.
/// - [simulateStatus] disediakan khusus untuk kebutuhan pengujian internal dan
///   TIDAK boleh dipanggil dari tombol atau fitur yang dapat diakses pengguna.
class ProposalRepository {
  /// Singleton instance agar satu List digunakan di seluruh aplikasi.
  static final ProposalRepository _instance = ProposalRepository._internal();

  factory ProposalRepository() => _instance;

  ProposalRepository._internal();

  /// Penyimpanan in-memory seluruh proposal.
  final List<ProposalModel> _items = [];

  // ── Read ───────────────────────────────────────────────────────────────────

  /// Mengambil seluruh proposal yang tersimpan di repository.
  Future<List<ProposalModel>> getAll() async {
    return List.unmodifiable(_items);
  }

  /// Mengambil semua proposal yang terkait dengan [eventId] tertentu.
  ///
  /// Mengembalikan list kosong jika belum ada proposal untuk event tersebut.
  Future<List<ProposalModel>> getByEvent(String eventId) async {
    return _items.where((p) => p.eventId == eventId).toList();
  }

  // ── Create ─────────────────────────────────────────────────────────────────

  /// Menambahkan [proposal] baru ke repository.
  ///
  /// Proposal baru wajib berstatus [AppConstants.statusProposalDraft].
  /// Melempar [ArgumentError] jika status awal bukan draft.
  Future<void> add(ProposalModel proposal) async {
    if (proposal.status != AppConstants.statusProposalDraft) {
      throw ArgumentError(
        'Proposal baru harus berstatus "${AppConstants.statusProposalDraft}". '
        'Status yang diterima: "${proposal.status}".',
      );
    }
    _items.add(proposal);
  }

  // ── Update ─────────────────────────────────────────────────────────────────

  /// Memperbarui proposal yang sudah ada berdasarkan [proposal.id].
  ///
  /// Melempar [ArgumentError] jika proposal dengan ID tersebut tidak ditemukan.
  Future<void> update(ProposalModel proposal) async {
    final index = _items.indexWhere((p) => p.id == proposal.id);
    if (index == -1) {
      throw ArgumentError('Proposal dengan id "${proposal.id}" tidak ditemukan.');
    }
    _items[index] = proposal;
  }

  // ── Delete ─────────────────────────────────────────────────────────────────

  /// Menghapus proposal berdasarkan [id].
  ///
  /// Tidak melakukan apa-apa jika ID tidak ditemukan (idempotent).
  Future<void> delete(String id) async {
    _items.removeWhere((p) => p.id == id);
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  /// Mengirimkan proposal dengan [id]: mengubah status dari
  /// [AppConstants.statusProposalDraft] menjadi [AppConstants.statusProposalPending]
  /// dan mencatat [ProposalModel.tanggalKirim] dengan waktu saat ini.
  ///
  /// Melempar [ArgumentError] jika:
  /// - Proposal dengan [id] tidak ditemukan.
  /// - Status proposal bukan [AppConstants.statusProposalDraft]
  ///   (proposal sudah pernah dikirim atau dalam status lain).
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

    _items[index] = ProposalModel(
      id: proposal.id,
      eventId: proposal.eventId,
      sponsorId: proposal.sponsorId,
      isiProposal: proposal.isiProposal,
      fileDokumen: proposal.fileDokumen,
      status: AppConstants.statusProposalPending,
      tanggalKirim: DateTime.now(),
      catatanSponsor: proposal.catatanSponsor,
    );
  }

  // ── Query Helpers ──────────────────────────────────────────────────────────

  /// Memeriksa apakah [eventId] memiliki setidaknya satu proposal aktif
  /// (berstatus selain [AppConstants.statusProposalRejected]).
  ///
  /// Dapat dipanggil oleh Modul 1. Pada Progress 1 selalu mengembalikan [false].
  Future<bool> hasActiveProposal(String eventId) async {
    // Progress 1: belum ada integrasi data nyata; nilai awal false.
    return false;
  }

  // ── Internal Testing Only ──────────────────────────────────────────────────

  /// Mensimulasikan perubahan status proposal untuk keperluan pengujian internal.
  ///
  /// ⚠️ HANYA untuk pengujian. Fungsi ini TIDAK boleh dipanggil dari tombol
  /// atau fitur UI yang dapat diakses pengguna. Pada produksi, status
  /// [AppConstants.statusProposalAccepted] dan [AppConstants.statusProposalRejected]
  /// berasal dari respons API.
  ///
  /// Melempar [ArgumentError] jika proposal dengan [id] tidak ditemukan.
  Future<void> simulateStatus(String id, String newStatus) async {
    final index = _items.indexWhere((p) => p.id == id);
    if (index == -1) {
      throw ArgumentError('Proposal dengan id "$id" tidak ditemukan.');
    }

    final proposal = _items[index];
    _items[index] = ProposalModel(
      id: proposal.id,
      eventId: proposal.eventId,
      sponsorId: proposal.sponsorId,
      isiProposal: proposal.isiProposal,
      fileDokumen: proposal.fileDokumen,
      status: newStatus,
      tanggalKirim: proposal.tanggalKirim,
      catatanSponsor: proposal.catatanSponsor,
    );
  }
}
