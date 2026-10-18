import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../models/app_constants.dart';
import '../models/proposal_model.dart';
import '../repositories/proposal_repository.dart';
import 'proposal_detail_screen.dart';

/// Layar Pelacakan Status Proposal (PRD v1.1 §1.6, §2.9, FR-M3-02, FR-M3-03, FR-M3-04).
class ProposalScreen extends StatefulWidget {
  const ProposalScreen({super.key});

  @override
  State<ProposalScreen> createState() => _ProposalScreenState();
}

class _ProposalScreenState extends State<ProposalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ProposalRepository _proposalRepo = ProposalRepository.instance;

  List<ProposalModel> _proposals = [];
  bool _isLoading = true;

  final List<String> _tabLabels = [
    'Semua',
    AppConstants.statusProposalPending,
    AppConstants.statusProposalAccepted,
    AppConstants.statusProposalRejected,
    AppConstants.statusProposalCancelled,
    AppConstants.statusProposalDraft,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabLabels.length, vsync: this);
    _loadProposals();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          backgroundColor: AppColors.primary,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Daftar Proposal',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Sinkronisasi Status API',
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: _handleRefresh,
          ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: _tabLabels.map((status) {
            final count = _getCountByStatus(status);
            return Tab(text: '$status ($count)');
          }).toList(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _handleRefresh,
              color: AppColors.primary,
              child: TabBarView(
                controller: _tabController,
                children: _tabLabels.map((status) {
                  return _buildProposalList(_filterByStatus(status));
                }).toList(),
              ),
            ),
    );
  }

  Widget _buildProposalList(List<ProposalModel> items) {
    if (items.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24),
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
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final status = item.status;

        Color badgeColor;
        Color badgeTextColor;
        switch (status) {
          case AppConstants.statusProposalAccepted:
            badgeColor = const Color(0xFFD1FAE5);
            badgeTextColor = const Color(0xFF059669);
            break;
          case AppConstants.statusProposalPending:
            badgeColor = const Color(0xFFFEF3C7);
            badgeTextColor = const Color(0xFFD97706);
            break;
          case AppConstants.statusProposalRejected:
            badgeColor = const Color(0xFFFEE2E2);
            badgeTextColor = const Color(0xFFDC2626);
            break;
          case AppConstants.statusProposalCancelled:
            badgeColor = const Color(0xFFF1F5F9);
            badgeTextColor = const Color(0xFF64748B);
            break;
          default:
            badgeColor = const Color(0xFFF1F5F9);
            badgeTextColor = const Color(0xFF64748B);
        }

        final tanggalText = item.tanggalKirim != null
            ? '${item.tanggalKirim!.day} Okt ${item.tanggalKirim!.year}'
            : 'Draft';

        return InkWell(
          onTap: () => _navigateToDetail(item),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.id,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: badgeTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.sponsorName ?? 'Sponsor Mitra',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.event_note, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.eventName ?? 'Event Mahasiswa',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20, color: AppColors.border),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bentuk: ${item.jenisKebutuhan ?? "Dana"}',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                    ),
                    Text(
                      tanggalText,
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                if (item.catatanSponsor != null && item.catatanSponsor!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.catatanSponsor!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (item.status == AppConstants.statusProposalCancelled &&
                    item.alasanPembatalan != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.cancel_outlined, size: 14, color: Color(0xFFDC2626)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Alasan: ${item.alasanPembatalan!}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF991B1B)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
