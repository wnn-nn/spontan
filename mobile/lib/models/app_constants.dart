/// Konstanta aplikasi bersama untuk Modul 2 -- Kebutuhan Sponsorship dan Proposal.
///
/// Semua nilai baku jenis kebutuhan dan status proposal didefinisikan di sini.
class AppConstants {
  AppConstants._();

  // Jenis Kebutuhan
  static const String jenisKebutuhanDana = 'Dana';
  static const String jenisKebutuhanBarang = 'Barang';
  static const String jenisKebutuhanMediaPartner = 'Media Partner';
  static const String jenisKebutuhanLainnya = 'Lainnya';

  static const List<String> jenisKebutuhanOptions = [
    jenisKebutuhanDana,
    jenisKebutuhanBarang,
    jenisKebutuhanMediaPartner,
    jenisKebutuhanLainnya,
  ];

  // Status Kebutuhan
  static const String statusKebutuhanTerbuka = 'Terbuka';
  static const String statusKebutuhanTerpenuhi = 'Terpenuhi';

  // Status Proposal
  static const String statusProposalDraft = 'Draft';
  static const String statusProposalPending = 'Pending';
  static const String statusProposalAccepted = 'Accepted';
  static const String statusProposalRejected = 'Rejected';

  static const List<String> statusProposalOptions = [
    statusProposalDraft,
    statusProposalPending,
    statusProposalAccepted,
    statusProposalRejected,
  ];
}
