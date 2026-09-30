import 'package:flutter/material.dart';
import '../models/item.dart';
import '../routes/app_routes.dart';
import '../screens/catatan_form_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class DetailScreen extends StatefulWidget {
  // (1) Menerima objek Item/Sponsor dari HomeScreen
  final Item item;

  const DetailScreen({super.key, required this.item});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // (2) Menyimpan catatan pengajuan proposal
  String? _catatan;

  // (3) Buka form catatan, tunggu hasil balik (data passing)
  Future<void> _bukaFormCatatan() async {
    final hasil = await Navigator.push<String>(
      context,
      MaterialPageRoute<String>(
        builder: (_) => const CatatanFormScreen(),
        settings: const RouteSettings(name: AppRoutes.catatanForm),
      ),
    );

    if (!mounted || hasil == null) return; // Pengguna membatalkan

    setState(() => _catatan = hasil);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Catatan proposal berhasil disimpan!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      backgroundColor: AppColors.softGray,
      appBar: AppBar(
        title: Text(item.title),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.title.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.border,
            height: 1,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: AppTextStyles.headline.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Chip(
                avatar: const Icon(
                  Icons.stars,
                  size: 18,
                  color: AppColors.primary,
                ),
                backgroundColor: AppColors.primary.withAlpha(20),
                side: BorderSide.none,
                label: Text(
                  '${item.matchingScore}% Match',
                  style: AppTextStyles.badge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            item.subtitle,
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 20),
          Text(
            'Profil Sponsor:',
            style: AppTextStyles.title.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            item.description,
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 20),
          Text(
            'Alasan Matching:',
            style: AppTextStyles.title.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            item.alasanMatching,
            style: AppTextStyles.bodySecondary.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
          const Divider(height: 36, color: AppColors.border),
          Text(
            'Draft Catatan Pengajuan Proposal:',
            style: AppTextStyles.title.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              _catatan == null
                  ? 'Belum ada catatan pengajuan proposal.'
                  : _catatan!,
              style: AppTextStyles.body.copyWith(
                fontStyle:
                    _catatan == null ? FontStyle.italic : FontStyle.normal,
                color: _catatan == null
                    ? AppColors.textMuted
                    : AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _bukaFormCatatan,
            icon: const Icon(Icons.edit_note, size: 20),
            label: const Text('Tulis Catatan Proposal'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: AppTextStyles.button.copyWith(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
