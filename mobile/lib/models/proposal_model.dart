import 'app_constants.dart';

/// Entitas Proposal (PRD v1.1 §1.6).
///
/// Data pengajuan sponsorship yang dikirim mahasiswa ke sponsor tertentu.
class ProposalModel {
  final String id;
  final String eventId;
  final String sponsorId;
  final String isiProposal;
  final String? fileDokumen; // Format PDF
  final String status; // Draft, Pending, Accepted, Rejected, Cancelled
  final DateTime? tanggalKirim;
  final String? catatanSponsor; // Dari respons API sponsor
  final String? alasanPembatalan; // Diinput oleh mahasiswa saat batalkan pending (FR-M3-03)
  final DateTime? statusDiperbaruiPada;

  // Display helpers untuk UI Tracking & Detail
  final String? sponsorName;
  final String? eventName;
  final String? jenisKebutuhan;

  ProposalModel({
    required this.id,
    required this.eventId,
    required this.sponsorId,
    required this.isiProposal,
    this.fileDokumen,
    this.status = AppConstants.statusProposalDraft,
    this.tanggalKirim,
    this.catatanSponsor,
    this.alasanPembatalan,
    this.statusDiperbaruiPada,
    this.sponsorName,
    this.eventName,
    this.jenisKebutuhan,
  });

  ProposalModel copyWith({
    String? id,
    String? eventId,
    String? sponsorId,
    String? isiProposal,
    String? fileDokumen,
    String? status,
    DateTime? tanggalKirim,
    String? catatanSponsor,
    String? alasanPembatalan,
    DateTime? statusDiperbaruiPada,
    String? sponsorName,
    String? eventName,
    String? jenisKebutuhan,
  }) {
    return ProposalModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      sponsorId: sponsorId ?? this.sponsorId,
      isiProposal: isiProposal ?? this.isiProposal,
      fileDokumen: fileDokumen ?? this.fileDokumen,
      status: status ?? this.status,
      tanggalKirim: tanggalKirim ?? this.tanggalKirim,
      catatanSponsor: catatanSponsor ?? this.catatanSponsor,
      alasanPembatalan: alasanPembatalan ?? this.alasanPembatalan,
      statusDiperbaruiPada: statusDiperbaruiPada ?? this.statusDiperbaruiPada,
      sponsorName: sponsorName ?? this.sponsorName,
      eventName: eventName ?? this.eventName,
      jenisKebutuhan: jenisKebutuhan ?? this.jenisKebutuhan,
    );
  }

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
      alasanPembatalan: json['alasan_pembatalan']?.toString(),
      statusDiperbaruiPada: json['status_diperbarui_pada'] != null
          ? DateTime.tryParse(json['status_diperbarui_pada'].toString())
          : null,
      sponsorName: json['sponsor_name']?.toString(),
      eventName: json['event_name']?.toString(),
      jenisKebutuhan: json['jenis_kebutuhan']?.toString(),
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
      'alasan_pembatalan': alasanPembatalan,
      'status_diperbarui_pada': statusDiperbaruiPada?.toIso8601String(),
      'sponsor_name': sponsorName,
      'event_name': eventName,
      'jenis_kebutuhan': jenisKebutuhan,
    };
  }
}
