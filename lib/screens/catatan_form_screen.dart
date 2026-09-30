import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/validators.dart';

class CatatanFormScreen extends StatefulWidget {
  const CatatanFormScreen({super.key});

  @override
  State<CatatanFormScreen> createState() => _CatatanFormScreenState();
}

class _CatatanFormScreenState extends State<CatatanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _catatanController = TextEditingController();

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  void _simpan() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    // Pop dan kirim balik teks catatan ke DetailScreen
    Navigator.pop(context, _catatanController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softGray,
      appBar: AppBar(
        title: const Text('Catatan Pengajuan Proposal'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tuliskan Kebutuhan & Catatan Khusus',
                style: AppTextStyles.title.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Catatan ini akan dilampirkan bersama pengajuan proposal sponsor.',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _catatanController,
                maxLines: 5,
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  labelText: 'Kebutuhan & Catatan Khusus Proposal',
                  labelStyle: AppTextStyles.caption,
                  hintText:
                      'Tuliskan item yang diajukan (misal: Sponsorship Dana Rp 5jt, Media Partner, Goodie Bag)...',
                  hintStyle: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surface,
                  alignLabelWithHint: true,
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
                validator: (value) =>
                    Validators.minLength(value, 5, fieldName: 'Catatan'),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _simpan,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: AppTextStyles.button.copyWith(fontSize: 15),
                ),
                child: const Text('Simpan Catatan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
