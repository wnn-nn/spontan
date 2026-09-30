import 'package:flutter/material.dart';
import '../models/item.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/primary_button.dart';

class DetailScreen extends StatefulWidget {
  // (1) Data yang DITERIMA dari Home melalui Route arguments (Langkah 7)
  final Item item;

  const DetailScreen({super.key, required this.item});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // (2) Menyimpan catatan yang dikirim balik dari CatatanFormScreen (Langkah 8)
  String? _catatan;

  // (3) Buka form catatan, TUNGGU hasilnya, lalu tampilkan (Ketentuan teknis no. 4 & 8)
  Future<void> _bukaFormCatatan() async {
    final hasil = await Navigator.pushNamed<String>(
      context,
      AppRoutes.catatanForm,
    );

    // Ketentuan teknis no. 4: periksa !mounted setelah await (hasil null = pengguna batal/back)
    if (!mounted || hasil == null) return;

    setState(() => _catatan = hasil);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Catatan berhasil disimpan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Di dalam State, data widget dibaca dengan "widget.item"
    final item = widget.item;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(item.title, style: AppTextStyles.title),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Judul Event
          Text(item.title, style: AppTextStyles.headline),
          const SizedBox(height: 8),

          // Subtitle / Info Tambahan
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.softGray,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              item.subtitle,
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 20),

          // Deskripsi Lengkap
          Text(
            'Deskripsi',
            style: AppTextStyles.title.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            item.description,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          const Divider(color: AppColors.border),
          const SizedBox(height: 16),

          // ─── Bagian Catatan / Review Event ────────────────────────────
          Text(
            'Catatan / Review Event',
            style: AppTextStyles.title.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'Catatan atau review yang kamu tulis di form akan ditampilkan di bawah ini:',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _catatan == null ? AppColors.softGray : AppColors.primary.withAlpha(12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _catatan == null ? AppColors.border : AppColors.primary.withAlpha(60),
                width: _catatan == null ? 1 : 1.5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _catatan == null ? Icons.edit_note_outlined : Icons.check_circle_rounded,
                  color: _catatan == null ? AppColors.textMuted : AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _catatan == null ? 'Belum ada catatan.' : 'Catatan: $_catatan',
                        style: AppTextStyles.body.copyWith(
                          color: _catatan == null ? AppColors.textMuted : AppColors.textPrimary,
                          fontWeight: _catatan == null ? FontWeight.normal : FontWeight.w600,
                        ),
                      ),
                      if (_catatan == null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Tekan tombol "Tulis Catatan" di bawah untuk mengisi review.',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Tombol Tulis Catatan
          PrimaryButton(
            label: 'Tulis Catatan',
            trailingIcon: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 22),
            onPressed: _bukaFormCatatan,
          ),
        ],
      ),
    );
  }
}
