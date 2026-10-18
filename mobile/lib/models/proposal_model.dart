import 'app_constants.dart';

class ProposalModel {
  final String id;
  final String eventId;
  final String sponsorId;
  final String isiProposal;
  final String? fileDokumen; // Referensi file dokumen; boleh kosong pada Progress 1
  final String status; // Nilai baku dari AppConstants.statusProposal*
  final DateTime? tanggalKirim; // Null sebelum proposal dikirim
  final String? catatanSponsor; // Null jika sponsor belum memberikan catatan

  ProposalModel({
    required this.id,
    required this.eventId,
    required this.sponsorId,
    required this.isiProposal,
    this.fileDokumen,
    this.status = AppConstants.statusProposalDraft,
    this.tanggalKirim,
    this.catatanSponsor,
  });

  factory ProposalModel.fromJson(Map<String, dynamic> json) {
    return ProposalModel(
      id: json['id_proposal']?.toString() ?? '',
      eventId: json['event_id']?.toString() ?? '',
      sponsorId: json['sponsor_id']?.toString() ?? '',
      isiProposal: json['isi_proposal'] ?? '',
      fileDokumen: json['file_dokumen']?.toString(),
      status: json['status'] ?? AppConstants.statusProposalDraft,
      tanggalKirim: json['tanggal_kirim'] != null
          ? DateTime.tryParse(json['tanggal_kirim'].toString())
          : null,
      catatanSponsor: json['catatan_sponsor']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_proposal': id,
      'event_id': eventId,
      'sponsor_id': sponsorId,
      'isi_proposal': isiProposal,
      'file_dokumen': fileDokumen,
      'status': status,
      'tanggal_kirim': tanggalKirim?.toIso8601String(),
      'catatan_sponsor': catatanSponsor,
    };
  }
}
