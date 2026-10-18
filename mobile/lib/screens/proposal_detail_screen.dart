import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../models/app_constants.dart';
import '../models/proposal_model.dart';
import '../repositories/proposal_repository.dart';

/// Layar Detail Pelacakan Proposal dan Pembatalan Proposal (PRD v1.1 §1.6, §2.9, §3.2, FR-M3-03, FR-M3-04).
class ProposalDetailScreen extends StatefulWidget {
  final ProposalModel proposal;

  const ProposalDetailScreen({
    super.key,
    required this.proposal,
  });

  @override
  State<ProposalDetailScreen> createState() => _ProposalDetailScreenState();
}

class _ProposalDetailScreenState extends State<ProposalDetailScreen> {
  late ProposalModel _proposal;
  bool _isDataChanged = false;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _proposal = widget.proposal;
  }

  Color _getStatusBgColor(String status) {
    switch (status) {
      case AppConstants.statusProposalAccepted:
        return const Color(0xFFD1FAE5);
      case AppConstants.statusProposalPending:
        return const Color(0xFFFEF3C7);
      case AppConstants.statusProposalRejected:
        return const Color(0xFFFEE2E2);
      case AppConstants.statusProposalCancelled:
        return const Color(0xFFF1F5F9);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case AppConstants.statusProposalAccepted:
        return const Color(0xFF059669);
      case AppConstants.statusProposalPending:
        return const Color(0xFFD97706);
      case AppConstants.statusProposalRejected:
        return const Color(0xFFDC2626);
      case AppConstants.statusProposalCancelled:
        return const Color(0xFF64748B);
      default:
        return const Color(0xFF64748B);
    }
  }

  /// Menampilkan dialog form pembatalan proposal dengan inputan alasan pembatalan (FR-M3-03 & FR-M3-04).
  Future<void> _showCancelDialog() async {
    final formKey = GlobalKey<FormState>();
    final reasonController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.cancel_rounded, color: Color(0xFFDC2626), size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Batalkan Proposal',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Apakah Anda yakin ingin membatalkan pengajuan proposal ini? Status akan diperbarui menjadi "Cancelled" dan tidak dapat diubah kembali.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'ALASAN PEMBATALAN (WAJIB)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: reasonController,
                      maxLines: 3,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText: 'Tuliskan alasan pembatalan (misal: Sudah memperoleh sponsor lain)...',
                        hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                        filled: true,
                        fillColor: AppColors.surfaceMuted,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                      ),
                      validator: (value) {
                        final val = value?.trim() ?? '';
                        if (val.isEmpty) {
                          return 'Alasan pembatalan wajib diisi.';
                        }
                        if (val.length < 5) {
                          return 'Alasan pembatalan minimal 5 karakter.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, null),
                  child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    if (formKey.currentState?.validate() == true) {
                      Navigator.pop(ctx, reasonController.text.trim());
                    }
                  },
                  child: const Text('Konfirmasi Pembatalan'),
                ),
              ],
            );
          },
        );
      },
    );

    reasonController.dispose();

    if (result != null && result.isNotEmpty && mounted) {
      setState(() => _isCancelling = true);

      try {
        final updatedProposal = await ProposalRepository.instance.cancelProposal(
          _proposal.id,
          result,
        );

        if (mounted) {
          setState(() {
            _proposal = updatedProposal;
            _isDataChanged = true;
            _isCancelling = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Proposal ${_proposal.id} berhasil dibatalkan (Status: Cancelled).',
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF475569),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isCancelling = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal membatalkan proposal: $e'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _handlePop() {
    Navigator.pop(context, _isDataChanged);
  }

  @override
  Widget build(BuildContext context) {
    final status = _proposal.status;
    final isPending = status == AppConstants.statusProposalPending;
    final isCancelled = status == AppConstants.statusProposalCancelled;
    final isAccepted = status == AppConstants.statusProposalAccepted;
    final isRejected = status == AppConstants.statusProposalRejected;

    final formattedDate = _proposal.tanggalKirim != null
        ? '${_proposal.tanggalKirim!.day} Okt ${_proposal.tanggalKirim!.year}'
        : '-';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handlePop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textPrimary),
            onPressed: _handlePop,
          ),
          title: const Text(
            'Detail Pengajuan Proposal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. STATUS CARD UTAMA
              _buildStatusHeaderCard(status),
              const SizedBox(height: 16),

              // 2. TIMELINE PROGRES PENGAJUAN
              _buildTimelineSection(status),
              const SizedBox(height: 16),

              // 3. INFORMASI DETAIL PROPOSAL
              _buildProposalDetailCard(formattedDate),
              const SizedBox(height: 16),

              // 4. FEEDBACK / CATATAN SPONSOR DARI API (PRD §2.9)
              if (_proposal.catatanSponsor != null && _proposal.catatanSponsor!.isNotEmpty) ...[
                _buildSponsorFeedbackCard(isAccepted, isRejected),
                const SizedBox(height: 16),
              ],

              // 5. ALASAN PEMBATALAN OLEH MAHASISWA (Jika Cancelled, FR-M3-03)
              if (isCancelled && _proposal.alasanPembatalan != null) ...[
                _buildCancellationReasonCard(),
                const SizedBox(height: 16),
              ],

              // 6. DOKUMEN PROPOSAL PDF
              _buildDocumentAttachmentTile(),
              const SizedBox(height: 24),

              // 7. TOMBOL BATALKAN PROPOSAL (HANYA MUNCUL SAAT PENDING, FR-M3-03 & FR-M3-04)
              if (isPending) ...[
                _buildCancelButton(),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusHeaderCard(String status) {
    final bgColor = _getStatusBgColor(status);
    final textColor = _getStatusTextColor(status);

    IconData statusIcon;
    String statusTitle;
    String statusSubtitle;

    switch (status) {
      case AppConstants.statusProposalAccepted:
        statusIcon = Icons.check_circle_rounded;
        statusTitle = 'Proposal Diterima';
        statusSubtitle = 'Selamat! Pihak sponsor telah menyetujui pengajuan kerja sama Anda.';
        break;
      case AppConstants.statusProposalPending:
        statusIcon = Icons.hourglass_top_rounded;
        statusTitle = 'Sedang Ditinjau';
        statusSubtitle = 'Proposal sedang dalam proses evaluasi oleh tim sponsorship mitra.';
        break;
      case AppConstants.statusProposalRejected:
        statusIcon = Icons.cancel_rounded;
        statusTitle = 'Proposal Ditolak';
        statusSubtitle = 'Mohon maaf, sponsor belum dapat mendukung kegiatan kali ini.';
        break;
      case AppConstants.statusProposalCancelled:
        statusIcon = Icons.remove_circle_outline_rounded;
        statusTitle = 'Proposal Dibatalkan';
        statusSubtitle = 'Pengajuan sponsorship telah dibatalkan oleh pihak pengirim (mahasiswa).';
        break;
      default:
        statusIcon = Icons.edit_note_rounded;
        statusTitle = 'Draft Proposal';
        statusSubtitle = 'Proposal belum dikirimkan kepada calon sponsor.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: textColor, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      statusTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  statusSubtitle,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection(String status) {
    final bool step1Done = true; // Selalu dibuat
    final bool step2Active = status != AppConstants.statusProposalDraft; // Sudah dikirim
    final bool step3Done = status == AppConstants.statusProposalAccepted ||
        status == AppConstants.statusProposalRejected ||
        status == AppConstants.statusProposalCancelled;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PROGRES PENGAJUAN',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),
          _buildTimelineItem(
            isCompleted: step1Done,
            isCurrent: status == AppConstants.statusProposalDraft,
            title: 'Proposal Disusun',
            subtitle: 'Dokumen dan surat pengantar siap diajukan.',
            isLast: false,
          ),
          _buildTimelineItem(
            isCompleted: step2Active,
            isCurrent: status == AppConstants.statusProposalPending,
            title: 'Terkirim ke Sponsor (Pending)',
            subtitle: 'Menunggu peninjauan dan respons dari pihak mitra.',
            isLast: false,
          ),
          _buildTimelineItem(
            isCompleted: step3Done,
            isCurrent: step3Done,
            title: status == AppConstants.statusProposalCancelled
                ? 'Pengajuan Dibatalkan (Cancelled)'
                : (status == AppConstants.statusProposalAccepted
                    ? 'Disetujui Mitra Sponsor'
                    : (status == AppConstants.statusProposalRejected
                        ? 'Pengajuan Ditolak'
                        : 'Hasil Keputusan')),
            subtitle: status == AppConstants.statusProposalCancelled
                ? 'Dibatalkan oleh mahasiswa dengan alasan tertentu.'
                : 'Pemberitahuan resmi hasil pertimbangan sponsor.',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required bool isCompleted,
    required bool isCurrent,
    required String title,
    required String subtitle,
    required bool isLast,
  }) {
    Color nodeColor;
    if (isCompleted) {
      nodeColor = AppColors.primary;
    } else {
      nodeColor = const Color(0xFFCBD5E1);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isCompleted ? nodeColor : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: nodeColor, width: 2),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 38,
                color: isCompleted ? AppColors.primary : const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                    color: isCurrent ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProposalDetailCard(String formattedDate) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RINCIAN PENGAJUAN',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('ID Proposal', _proposal.id),
          const Divider(height: 16, color: AppColors.borderLight),
          _buildInfoRow('Calon Sponsor', _proposal.sponsorName ?? 'PT Telkom Indonesia'),
          const Divider(height: 16, color: AppColors.borderLight),
          _buildInfoRow('Nama Event', _proposal.eventName ?? 'Seminar Teknologi Kampus'),
          const Divider(height: 16, color: AppColors.borderLight),
          _buildInfoRow('Bentuk Sponsorship', _proposal.jenisKebutuhan ?? 'Dana & Media Partner'),
          const Divider(height: 16, color: AppColors.borderLight),
          _buildInfoRow('Tanggal Pengiriman', formattedDate),
          const SizedBox(height: 16),
          const Text(
            'SURAT PENGANTAR / PESAN',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _proposal.isiProposal,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF334155),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSponsorFeedbackCard(bool isAccepted, bool isRejected) {
    final Color bgColor = isAccepted ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2);
    final Color borderColor = isAccepted ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA);
    final Color titleColor = isAccepted ? const Color(0xFF16A34A) : const Color(0xFFDC2626);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.mark_chat_read_rounded, color: titleColor, size: 18),
              const SizedBox(width: 8),
              Text(
                'Catatan dari Mitra Sponsor (via API)',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _proposal.catatanSponsor ?? '',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF1E293B),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancellationReasonCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Color(0xFF475569), size: 18),
              SizedBox(width: 8),
              Text(
                'Alasan Pembatalan oleh Mahasiswa',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _proposal.alasanPembatalan ?? 'Tidak ada keterangan.',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF475569),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentAttachmentTile() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF2563EB), size: 24),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Proposal_Kegiatan_Kampus.pdf',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Dokumen PDF • 2.4 MB',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              side: const BorderSide(color: AppColors.primary),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pratinjau dokumen proposal PDF.'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: const Text('Buka', style: TextStyle(fontSize: 12, color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFEE2E2),
          foregroundColor: const Color(0xFFDC2626),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFFECACA), width: 1.2),
          ),
        ),
        onPressed: _isCancelling ? null : _showCancelDialog,
        icon: _isCancelling
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFDC2626)),
              )
            : const Icon(Icons.cancel_outlined, size: 20),
        label: Text(
          _isCancelling ? 'Memproses Pembatalan...' : 'Batalkan Pengajuan Proposal',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

