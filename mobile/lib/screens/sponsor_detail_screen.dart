import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../models/event_model.dart';
import '../models/matching_score_model.dart';
import '../models/sponsor_model.dart';
import '../repositories/sponsor_repository.dart';

/// Layar Detail Profil Sponsor dan Breakdown Skor Matching (PRD v1.1 §1.4, §1.5, §2.8, FR-M3-01, FR-M3-02).
class SponsorDetailScreen extends StatefulWidget {
  final SponsorModel sponsor;
  final MatchingScoreModel? score;
  final EventModel? event;

  const SponsorDetailScreen({
    super.key,
    required this.sponsor,
    this.score,
    this.event,
  });

  @override
  State<SponsorDetailScreen> createState() => _SponsorDetailScreenState();
}

class _SponsorDetailScreenState extends State<SponsorDetailScreen> {
  final SponsorRepository _sponsorRepo = SponsorRepository.instance;
  bool _isSaved = false;
  bool _isLoadingBookmark = false;

  @override
  void initState() {
    super.initState();
    _checkSavedStatus();
  }

  Future<void> _checkSavedStatus() async {
    final eventId = widget.event?.idEvent.toString() ?? widget.score?.idEvent ?? '0';
    final saved = await _sponsorRepo.isSponsorSaved(eventId, widget.sponsor.idSponsor);
    if (mounted) {
      setState(() => _isSaved = saved);
    }
  }

  Future<void> _handleToggleBookmark() async {
    if (_isLoadingBookmark) return;
    setState(() => _isLoadingBookmark = true);

    final eventId = widget.event?.idEvent.toString() ?? widget.score?.idEvent ?? '0';
    final isNowSaved = await _sponsorRepo.toggleSaveSponsor(eventId, widget.sponsor.idSponsor);

    if (mounted) {
      setState(() {
        _isSaved = isNowSaved;
        _isLoadingBookmark = false;
      });

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isNowSaved ? Icons.bookmark_added_rounded : Icons.bookmark_remove_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isNowSaved
                      ? 'Sponsor "${widget.sponsor.namaBrand}" berhasil disimpan ke daftar sasaran!'
                      : 'Sponsor "${widget.sponsor.namaBrand}" dihapus dari sasaran.',
                ),
              ),
            ],
          ),
          backgroundColor: isNowSaved ? AppColors.success : AppColors.textSecondary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleAjukanProposal() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.send_rounded, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Ajukan Proposal',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Anda akan mengajukan proposal kerja sama sponsorship kepada ${widget.sponsor.namaBrand}.',
              style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Event: ${widget.event?.judul ?? "Event Mahasiswa Unand"}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kategori: ${widget.event?.kategori ?? "Seminar"}',
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Silakan gunakan form upload proposal untuk mengirimkan dokumen ke ${widget.sponsor.namaBrand}.',
                  ),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sponsor = widget.sponsor;
    final score = widget.score;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Profil Sponsor',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: _isSaved ? 'Hapus dari sasaran' : 'Simpan sebagai sasaran',
            icon: Icon(
              _isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
              color: _isSaved ? const Color(0xFFF59E0B) : AppColors.textSecondary,
              size: 26,
            ),
            onPressed: _handleToggleBookmark,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HERO HEADER SPONSOR CARD
            _buildSponsorHeaderCard(sponsor),
            const SizedBox(height: 16),

            // 2. BREAKDOWN MATCHING SCORE CARD (Jika ada data score)
            if (score != null) ...[
              _buildMatchingScoreSection(score),
              const SizedBox(height: 16),
            ],

            // 3. PREFERENSI & KRITERIA SPONSOR
            _buildPreferensiSection(sponsor),
            const SizedBox(height: 16),

            // 4. KONTAK & INFORMASI CSR
            _buildContactSection(sponsor),
            const SizedBox(height: 24),

            // 5. TOMBOL AKSI UTAMA
            _buildActionButtons(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSponsorHeaderCard(SponsorModel sponsor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: sponsor.avatarBg,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  sponsor.initials,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: sponsor.avatarColor,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sponsor.namaBrand,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sponsor.industri,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 14),
          const Text(
            'TENTANG PERUSAHAAN',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            sponsor.deskripsi,
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFF334155),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchingScoreSection(MatchingScoreModel score) {
    Color badgeColor;
    Color badgeTextColor;
    if (score.score >= 75) {
      badgeColor = const Color(0xFFD1FAE5);
      badgeTextColor = const Color(0xFF059669);
    } else if (score.score >= 50) {
      badgeColor = const Color(0xFFFEF3C7);
      badgeTextColor = const Color(0xFFD97706);
    } else {
      badgeColor = const Color(0xFFFEE2E2);
      badgeTextColor = const Color(0xFFDC2626);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Analisis Kecocokan Event',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${score.label} (${score.score}%)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: badgeTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            score.alasanMatching,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),

          // Mini progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score.scoreFraction,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(
                score.score >= 75
                    ? const Color(0xFF10B981)
                    : (score.score >= 50 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444)),
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 14),

          // 3 Parameter Breakdown (PRD §2.8.2: P1=40, P2=30, P3=30)
          const Text(
            'RINCIAN PARAMETER MATCHING',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          _buildScoreParameterRow(
            'P1. Kategori Event',
            'Bobot maks. 40 poin',
            score.skorKategori,
            40,
          ),
          const SizedBox(height: 8),
          _buildScoreParameterRow(
            'P2. Target Audience',
            'Bobot maks. 30 poin',
            score.skorAudience,
            30,
          ),
          const SizedBox(height: 8),
          _buildScoreParameterRow(
            'P3. Jenis Kebutuhan',
            'Bobot maks. 30 poin',
            score.skorKebutuhan,
            30,
          ),

          // Catatan Kurang jika ada
          if (score.catatanKurang.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: Color(0xFFDC2626), size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Kriteria Belum Sesuai:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ...score.catatanKurang.map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 3),
                      child: Text(
                        '• $c',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF991B1B),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreParameterRow(String title, String subtitle, int score, int maxScore) {
    final isFull = score == maxScore;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isFull ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$score / $maxScore',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: isFull ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreferensiSection(SponsorModel sponsor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preferensi Sponsor',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),

          // Kategori
          _buildChipGroup('Kategori Event Didukung', sponsor.preferensiKategori, const Color(0xFFEFF6FF), AppColors.primary),
          const SizedBox(height: 12),

          // Target Audience
          _buildChipGroup('Target Audiens Disasar', sponsor.preferensiTargetAudience, const Color(0xFFF0FDF4), const Color(0xFF16A34A)),
          const SizedBox(height: 12),

          // Bentuk Sponsorship
          _buildChipGroup('Bentuk Dukungan Tersedia', sponsor.preferensiJenisSponsorship, const Color(0xFFFFF7ED), const Color(0xFFEA580C)),
        ],
      ),
    );
  }

  Widget _buildChipGroup(String label, List<String> items, Color chipBg, Color chipText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: items.map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: chipBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: chipText,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildContactSection(SponsorModel sponsor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.email_outlined, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kontak Humas / Kemitraan',
                  style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  sponsor.kontakEmail ?? 'humas@perusahaan.co.id',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Bookmark Button
        Expanded(
          flex: 2,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: _isSaved ? const Color(0xFFF59E0B) : AppColors.border),
              backgroundColor: _isSaved ? const Color(0xFFFFFBEB) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _handleToggleBookmark,
            icon: Icon(
              _isSaved ? Icons.bookmark_added_rounded : Icons.bookmark_add_outlined,
              color: _isSaved ? const Color(0xFFD97706) : AppColors.textSecondary,
              size: 20,
            ),
            label: Text(
              _isSaved ? 'Tersimpan' : 'Simpan',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: _isSaved ? const Color(0xFFD97706) : AppColors.textSecondary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Ajukan Proposal Button
        Expanded(
          flex: 3,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _handleAjukanProposal,
            icon: const Icon(Icons.send_rounded, size: 18),
            label: const Text(
              'Ajukan Proposal',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

