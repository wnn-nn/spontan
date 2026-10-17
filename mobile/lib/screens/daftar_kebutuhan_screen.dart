import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../models/event_model.dart';
import '../models/kebutuhan_model.dart';
import '../repositories/kebutuhan_repository.dart';
import 'form_kebutuhan_screen.dart';

/// Layar daftar kebutuhan sponsorship untuk satu event tertentu.
///
/// Menerima [event] sebagai argumen navigasi dan menggunakan
/// [KebutuhanRepository] untuk mengambil daftar kebutuhan berdasarkan
/// [EventModel.idEvent]. Data event hanya dibaca, tidak diubah.
class DaftarKebutuhanScreen extends StatefulWidget {
  final EventModel event;

  const DaftarKebutuhanScreen({super.key, required this.event});

  @override
  State<DaftarKebutuhanScreen> createState() => _DaftarKebutuhanScreenState();
}

class _DaftarKebutuhanScreenState extends State<DaftarKebutuhanScreen> {
  final KebutuhanRepository _repository = KebutuhanRepository();

  List<KebutuhanModel> _kebutuhanList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKebutuhan();
  }

  // ── Data ────────────────────────────────────────────────────────────────────

  Future<void> _loadKebutuhan() async {
    setState(() => _isLoading = true);
    try {
      final list = await _repository.getByEvent(widget.event.idEvent.toString());
      if (!mounted) return;
      setState(() {
        _kebutuhanList = list;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  // ── Navigasi ────────────────────────────────────────────────────────────────

  Future<void> _navigateToForm() async {
    final result = await Navigator.push<KebutuhanModel>(
      context,
      MaterialPageRoute(
        builder: (context) => FormKebutuhanScreen(event: widget.event),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _kebutuhanList.insert(0, result);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Kebutuhan "${result.deskripsi}" berhasil ditambahkan!',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Kebutuhan Sponsorship',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.event.judul,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToForm,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text(
          'Tambah Kebutuhan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Memuat daftar kebutuhan...',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
            ),
          ],
        ),
      );
    }

    if (_kebutuhanList.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadKebutuhan,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: _kebutuhanList.length,
        itemBuilder: (context, index) {
          return _buildKebutuhanCard(_kebutuhanList[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Belum Ada Kebutuhan',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tambahkan kebutuhan sponsorship untuk event ini agar sponsor dapat melihat apa yang dibutuhkan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                onPressed: _navigateToForm,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text(
                  'Tambah Kebutuhan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKebutuhanCard(KebutuhanModel item) {
    final isTerpenuhi = item.status == 'Terpenuhi';

    final Color jenisColor;
    final Color jenisBgColor;
    final IconData jenisIcon;

    switch (item.jenis) {
      case 'Dana':
        jenisColor = AppColors.primary;
        jenisBgColor = AppColors.primaryLight;
        jenisIcon = Icons.account_balance_wallet_outlined;
        break;
      case 'Barang':
        jenisColor = const Color(0xFF7C3AED);
        jenisBgColor = const Color(0xFFEDE9FE);
        jenisIcon = Icons.inventory_2_outlined;
        break;
      case 'Media Partner':
        jenisColor = const Color(0xFFD97706);
        jenisBgColor = const Color(0xFFFEF3C7);
        jenisIcon = Icons.campaign_outlined;
        break;
      default:
        jenisColor = AppColors.textSecondary;
        jenisBgColor = AppColors.surfaceMuted;
        jenisIcon = Icons.label_outline;
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
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ikon jenis
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: jenisBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(jenisIcon, size: 20, color: jenisColor),
          ),
          const SizedBox(width: 12),
          // Konten
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.deskripsi,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Badge status
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isTerpenuhi
                            ? AppColors.successLight
                            : AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.status,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: isTerpenuhi ? AppColors.success : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Badge jenis
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: jenisBgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.jenis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: jenisColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Nilai estimasi
                Row(
                  children: [
                    const Icon(
                      Icons.monetization_on_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.satuanKeterangan ??
                          'Rp ${_formatRupiah(item.nilai.toInt())}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatRupiah(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return buffer.toString().split('').reversed.join('');
  }
}
