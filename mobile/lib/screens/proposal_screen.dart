import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../models/app_constants.dart';
import '../models/proposal_model.dart';
import '../repositories/proposal_repository.dart';
import 'event_detail_screen.dart';
import 'proposal_detail_screen.dart';

/// Layar Pelacakan Status Proposal (PRD v1.1 §1.6, §2.9, FR-M3-02, FR-M3-03, FR-M3-04).
class ProposalScreen extends StatefulWidget {
  final VoidCallback? onOpenProfile;

  const ProposalScreen({super.key, this.onOpenProfile});

  @override
  State<ProposalScreen> createState() => _ProposalScreenState();
}

class _ProposalScreenState extends State<ProposalScreen> {
  final ProposalRepository _proposalRepo = ProposalRepository.instance;

  List<ProposalModel> _proposals = [];
  bool _isLoading = true;
  String _selectedStatus = 'Semua';

  // Urutan tab sesuai tampilan Figma: Semua, Draft, Pending, Accepted, Rejected, Cancelled
  final List<String> _tabLabels = [
    'Semua',
    AppConstants.statusProposalDraft,
    AppConstants.statusProposalPending,
    AppConstants.statusProposalAccepted,
    AppConstants.statusProposalRejected,
    AppConstants.statusProposalCancelled,
  ];

  @override
  void initState() {
    super.initState();
    _loadProposals();
  }

  Future<void> _loadProposals() async {
    setState(() => _isLoading = true);
    final list = await _proposalRepo.getAll();
    if (mounted) {
      setState(() {
        _proposals = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    final list = await _proposalRepo.refreshProposalStatuses();
    if (mounted) {
      setState(() => _proposals = list);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.sync_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Status proposal berhasil disinkronkan dengan API.'),
            ],
          ),
          backgroundColor: const Color(0xFF2563EB),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  List<ProposalModel> _filterByStatus(String status) {
    if (status == 'Semua') return _proposals;
    return _proposals
        .where((p) => p.status.toLowerCase() == status.toLowerCase())
        .toList();
  }

  int _getCountByStatus(String status) {
    if (status == 'Semua') return _proposals.length;
    return _proposals
        .where((p) => p.status.toLowerCase() == status.toLowerCase())
        .length;
  }

  Future<void> _navigateToDetail(ProposalModel proposal) async {
    final isDataChanged = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ProposalDetailScreen(proposal: proposal),
      ),
    );

    if (isDataChanged == true && mounted) {
      _loadProposals();
    }
  }

  void _handleAjukanProposal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Ajukan Proposal Sponsorship',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pilih event untuk melihat rekomendasi sponsor yang cocok lalu ajukan proposal.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              tileColor: const Color(0xFFF8FAFC),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.event_note, color: Color(0xFF2563EB), size: 22),
              ),
              title: const Text(
                'Seminar Teknologi Kampus',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              subtitle: const Text('2 Mitra Terhubung • 12 Nov 2026'),
              trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF2563EB)),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EventDetailScreen(
                      initialJudul: 'Seminar Teknologi Kampus',
                      initialTanggal: '12 Nov 2026',
                      initialLokasi: 'Aula Fakultas',
                      initialKategori: 'Seminar',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              tileColor: const Color(0xFFF8FAFC),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.music_note_rounded, color: Color(0xFF2563EB), size: 22),
              ),
              title: const Text(
                'Festival Budaya Nusantara',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              subtitle: const Text('3 Mitra Terhubung • 28 Nov 2026'),
              trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF2563EB)),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EventDetailScreen(
                      initialJudul: 'Festival Budaya Nusantara',
                      initialTanggal: '28 Nov 2026',
                      initialLokasi: 'Lapangan Utama',
                      initialKategori: 'Seni & Budaya',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '12 Nov 2026';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final month = months[(dt.month - 1).clamp(0, 11)];
    return '$day $month ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                color: const Color(0xFF2563EB),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. TOP BAR (Logo Squircle Spontan di kiri, Avatar Profil di kanan)
                      _buildTopBar(),
                      const SizedBox(height: 18),

                      // 2. STATUS FILTER PILLS: [Semua (6)]  [Draft]  [Pending] ...
                      _buildStatusFilterPills(),
                      const SizedBox(height: 18),

                      // 3. DAFTAR KARTU PROPOSAL
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                          ),
                        )
                      else
                        _buildProposalCardsList(),
                    ],
                  ),
                ),
              ),
            ),

            // 4. TOMBOL BESAR BIRU DI BAWAH: "Ajukan Proposal" (Identik dengan tombol "Buat Event")
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _handleAjukanProposal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: const Color(0xFF2563EB).withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text(
                    'Ajukan Proposal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 1. Top Bar (Identik dengan Top Bar di event_list_screen & home_screen)
  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // Logo Squircle Spontan
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.bolt_rounded,
                    color: Color(0xFF2563EB),
                    size: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Daftar Proposal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),

        // Avatar Bulat Biru di kanan
        InkWell(
          onTap: widget.onOpenProfile,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  // 2. Status Filter Pills (Capsule pill biru saat aktif, teks bersih saat tidak aktif)
  Widget _buildStatusFilterPills() {
    final countSemua = _getCountByStatus('Semua');

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _tabLabels.map((status) {
          final isSelected = _selectedStatus == status;
          final label = status == 'Semua' ? 'Semua ($countSemua)' : status;

          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedStatus = status;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF475569),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 3. Daftar Kartu Proposal
  Widget _buildProposalCardsList() {
    final items = _filterByStatus(_selectedStatus);

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.description_outlined,
                  size: 40,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Tidak ada proposal pada status ini.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: items.map((item) {
        final status = item.status;

        // Visual Icon, Background, and Badges according to status and Figma
        IconData leadingIcon;
        Color leadingBgColor;
        Color leadingIconColor;
        Color badgeBgColor;
        Color badgeTextColor;
        Color badgeDotColor;

        switch (status) {
          case AppConstants.statusProposalAccepted:
            leadingIcon = Icons.check_circle_outline_rounded;
            leadingBgColor = const Color(0xFFD1FAE5);
            leadingIconColor = const Color(0xFF059669);
            badgeBgColor = const Color(0xFFD1FAE5);
            badgeTextColor = const Color(0xFF059669);
            badgeDotColor = const Color(0xFF059669);
            break;
          case AppConstants.statusProposalPending:
            leadingIcon = Icons.emoji_events_outlined;
            leadingBgColor = const Color(0xFFFEF3C7);
            leadingIconColor = const Color(0xFFD97706);
            badgeBgColor = const Color(0xFFFEF3C7);
            badgeTextColor = const Color(0xFFB45309);
            badgeDotColor = const Color(0xFFD97706);
            break;
          case AppConstants.statusProposalRejected:
            leadingIcon = Icons.cancel_outlined;
            leadingBgColor = const Color(0xFFFEE2E2);
            leadingIconColor = const Color(0xFFDC2626);
            badgeBgColor = const Color(0xFFFEE2E2);
            badgeTextColor = const Color(0xFFDC2626);
            badgeDotColor = const Color(0xFFDC2626);
            break;
          case AppConstants.statusProposalDraft:
            leadingIcon = Icons.description_outlined;
            leadingBgColor = const Color(0xFFF1F5F9);
            leadingIconColor = const Color(0xFF64748B);
            badgeBgColor = const Color(0xFFF1F5F9);
            badgeTextColor = const Color(0xFF64748B);
            badgeDotColor = const Color(0xFF64748B);
            break;
          case AppConstants.statusProposalCancelled:
          default:
            leadingIcon = Icons.block_flipped;
            leadingBgColor = const Color(0xFFF1F5F9);
            leadingIconColor = const Color(0xFF64748B);
            badgeBgColor = const Color(0xFFF1F5F9);
            badgeTextColor = const Color(0xFF64748B);
            badgeDotColor = const Color(0xFF64748B);
            break;
        }

        final tanggalText = _formatDate(item.tanggalKirim);

        return InkWell(
          onTap: () => _navigateToDetail(item),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
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
                // Squircle Icon di kiri
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: leadingBgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    leadingIcon,
                    color: leadingIconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),

                // Kolom Tengah: Sponsor Name, Event Name, Tanggal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.sponsorName ?? 'Sponsor Mitra',
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.eventName ?? 'Seminar Teknologi Kampus',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 13,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            tanggalText,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Badge Status di kanan atas: • Status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: badgeDotColor,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: badgeTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
