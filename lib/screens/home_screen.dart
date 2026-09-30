import 'package:flutter/material.dart';
import '../data/item_repository.dart';
import '../models/item.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/state_views.dart';

// (1) Status tampilan UI
enum ViewStatus { loading, success, error }

class HomeScreen extends StatefulWidget {
  final bool simulateError;
  final ItemRepository? repository;

  const HomeScreen({
    super.key,
    this.simulateError = false,
    this.repository,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // (2) Variabel State
  late final _repository = widget.repository ?? ItemRepository();
  ViewStatus _status = ViewStatus.loading;
  List<Item> _items = [];
  String _errorMessage = '';
  late final bool _simulateError = widget.simulateError; // Ubah ke true untuk uji error state

  // (3) Ambil data saat screen dimuat
  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  // (4) Mengambil data & penanganan error
  Future<void> _loadItems() async {
    if (_status != ViewStatus.loading) {
      setState(() => _status = ViewStatus.loading);
    }

    try {
      final items = await _repository.fetchItems(simulateError: _simulateError);

      if (!mounted) return;

      setState(() {
        _items = items;
        _status = ViewStatus.success;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _status = ViewStatus.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softGray,
      appBar: AppBar(
        title: const Text('Rekomendasi Sponsor (Matching)'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.sectionTitle.copyWith(
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
      // (5) Tampilan berdasarkan status
      body: _buildContent(),
    );
  }

  // (6) Memilih status tampilan
  Widget _buildContent() {
    return switch (_status) {
      ViewStatus.loading => const LoadingView(
          message: 'Menghitung matching score sponsor...',
        ),
      ViewStatus.error => ErrorView(
          message: _errorMessage,
          onRetry: _loadItems,
        ),
      ViewStatus.success => _buildList(),
    };
  }

  // (6) Render daftar sponsor hasil matching
  Widget _buildList() {
    if (_items.isEmpty) {
      return const EmptyView(
        message: 'Belum ada sponsor yang cocok dengan kriteria event.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return Card(
          elevation: 0,
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  item.title.isNotEmpty ? item.title[0] : 'S',
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            title: Text(
              item.title,
              style: AppTextStyles.title.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                item.subtitle,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${item.matchingScore}% Match',
                style: AppTextStyles.badge.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            // (7) Kirim item terpilih ke DetailScreen
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.detail,
                arguments: item,
              );
            },
          ),
        );
      },
    );
  }
}
