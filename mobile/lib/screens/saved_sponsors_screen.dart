import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../models/sponsor_model.dart';
import '../repositories/sponsor_repository.dart';
import 'sponsor_detail_screen.dart';

/// Layar Daftar Sponsor Sasaran / Bookmark (PRD v1.1 §1.7, FR-M3-01).
class SavedSponsorsScreen extends StatefulWidget {
  const SavedSponsorsScreen({super.key});

  @override
  State<SavedSponsorsScreen> createState() => _SavedSponsorsScreenState();
}

class _SavedSponsorsScreenState extends State<SavedSponsorsScreen> {
  final SponsorRepository _sponsorRepo = SponsorRepository.instance;
  List<Map<String, dynamic>> _savedList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedSponsors();
  }

  Future<void> _loadSavedSponsors() async {
    setState(() => _isLoading = true);
    final items = await _sponsorRepo.getAllSavedSponsors();
    if (mounted) {
      setState(() {
        _savedList = items;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRemoveBookmark(SponsorModel sponsor, String eventId) async {
    await _sponsorRepo.toggleSaveSponsor(eventId, sponsor.idSponsor);
    _loadSavedSponsors();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sponsor "${sponsor.namaBrand}" dihapus dari sasaran.'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Daftar Sponsor Sasaran',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _savedList.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadSavedSponsors,
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _savedList.length,
                    itemBuilder: (context, index) {
                      final item = _savedList[index];
                      final sponsor = item['sponsor'] as SponsorModel;
                      final bookmark = item['bookmark'];
                      final eventId = bookmark.idEvent as String;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(18),
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
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: sponsor.avatarBg,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    sponsor.initials,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 17,
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
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        sponsor.industri,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Hapus bookmark',
                                  icon: const Icon(
                                    Icons.bookmark_remove_rounded,
                                    color: Color(0xFFF59E0B),
                                    size: 22,
                                  ),
                                  onPressed: () => _handleRemoveBookmark(sponsor, eventId),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              sponsor.deskripsi,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF475569),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Divider(height: 1, color: AppColors.borderLight),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Wrap(
                                  spacing: 4,
                                  children: sponsor.preferensiJenisSponsorship.take(2).map((j) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryLight,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        j,
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    side: const BorderSide(color: AppColors.primary),
                                  ),
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SponsorDetailScreen(sponsor: sponsor),
                                      ),
                                    );
                                    _loadSavedSponsors();
                                  },
                                  icon: const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
                                  label: const Text(
                                    'Detail Profil',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bookmark_border_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Belum Ada Sponsor Sasaran',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Simpan profil sponsor dari daftar rekomendasi matching untuk ditindaklanjuti dan diajukan proposal.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

