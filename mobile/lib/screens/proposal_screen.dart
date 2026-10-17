import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class ProposalScreen extends StatefulWidget {
  const ProposalScreen({super.key});

  @override
  State<ProposalScreen> createState() => _ProposalScreenState();
}

class _ProposalScreenState extends State<ProposalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _proposals = [
    {
      'id': 'PROP-001',
      'sponsor': 'PT Telkom Indonesia',
      'event': 'Seminar Teknologi Kampus',
      'status': 'Accepted',
      'tanggal': '14 Okt 2026',
      'jenis': 'Dana & Media Partner',
      'catatan': 'Disetujui. Dana sponsorship sebesar Rp 5.000.000 akan ditransfer.',
    },
    {
      'id': 'PROP-002',
      'sponsor': 'Bank Nagari',
      'event': 'Seminar Teknologi Kampus',
      'status': 'Accepted',
      'tanggal': '12 Okt 2026',
      'jenis': 'Dana',
      'catatan': 'Disetujui paket Silver Sponsorship.',
    },
    {
      'id': 'PROP-003',
      'sponsor': 'Indofood Sukses Makmur',
      'event': 'Festival Budaya Nusantara',
      'status': 'Pending',
      'tanggal': '15 Okt 2026',
      'jenis': 'Barang (Konsumsi 300 paket)',
      'catatan': 'Sedang direview oleh divisi CSR & Humas.',
    },
    {
      'id': 'PROP-004',
      'sponsor': 'Shopee Indonesia',
      'event': 'Festival Budaya Nusantara',
      'status': 'Draft',
      'tanggal': '16 Okt 2026',
      'jenis': 'Media Partner',
      'catatan': 'Belum dikirim ke pihak sponsor.',
    },
    {
      'id': 'PROP-005',
      'sponsor': 'Gojek Padang',
      'event': 'Lomba Mobile Apps Unand',
      'status': 'Rejected',
      'tanggal': '10 Okt 2026',
      'jenis': 'Dana',
      'catatan': 'Slot sponsorship kuartal IV sudah terpenuhi.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filterByStatus(String status) {
    if (status == 'Semua') return _proposals;
    return _proposals.where((p) => p['status'] == status).toList();
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
          'Tracking Proposal',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Semua (5)'),
            Tab(text: 'Draft (1)'),
            Tab(text: 'Pending (1)'),
            Tab(text: 'Accepted (2)'),
            Tab(text: 'Rejected (1)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProposalList(_filterByStatus('Semua')),
          _buildProposalList(_filterByStatus('Draft')),
          _buildProposalList(_filterByStatus('Pending')),
          _buildProposalList(_filterByStatus('Accepted')),
          _buildProposalList(_filterByStatus('Rejected')),
        ],
      ),
    );
  }

  Widget _buildProposalList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada proposal pada status ini.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final status = item['status'] as String;

        Color badgeColor;
        Color badgeTextColor;
        switch (status) {
          case 'Accepted':
            badgeColor = const Color(0xFFD1FAE5);
            badgeTextColor = const Color(0xFF059669);
            break;
          case 'Pending':
            badgeColor = const Color(0xFFFEF3C7);
            badgeTextColor = const Color(0xFFD97706);
            break;
          case 'Rejected':
            badgeColor = const Color(0xFFFEE2E2);
            badgeTextColor = const Color(0xFFDC2626);
            break;
          default:
            badgeColor = const Color(0xFFF1F5F9);
            badgeTextColor = const Color(0xFF64748B);
        }

        return Container(
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
                    item['id'],
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
                item['sponsor'],
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
                  Text(
                    item['event'],
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const Divider(height: 20, color: AppColors.border),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bentuk: ${item['jenis']}',
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                  ),
                  Text(
                    item['tanggal'],
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
              if (item['catatan'] != null && (item['catatan'] as String).isNotEmpty) ...[
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
                          item['catatan'],
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
