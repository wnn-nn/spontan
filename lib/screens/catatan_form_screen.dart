import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/validators.dart';
import '../widgets/primary_button.dart';

class CatatanFormScreen extends StatefulWidget {
  const CatatanFormScreen({super.key});

  @override
  State<CatatanFormScreen> createState() => _CatatanFormScreenState();
}

class _CatatanFormScreenState extends State<CatatanFormScreen> {
  // Key untuk Form dan controller catatan
  final _formKey = GlobalKey<FormState>();
  final _catatanController = TextEditingController();

  // Membuang controller saat layar ditutup (Ketentuan teknis no. 2)
  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  // Mengirim hasil kembali ke layar sebelumnya (Ketentuan teknis no. 8)
  void _simpan() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    // Tutup layar ini sambil MEMBAWA teks catatan ke layar sebelumnya
    Navigator.pop(context, _catatanController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    // Ketentuan teknis no. 9: Gunakan PopScope dan onPopInvokedWithResult
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // Layar diizinkan ditutup kembali ke DetailScreen
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Tulis Catatan', style: AppTextStyles.title),
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: AppColors.border, height: 1),
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
                  'Catatan & Review Event',
                  style: AppTextStyles.title,
                ),
                const SizedBox(height: 6),
                Text(
                  'Tuliskan ulasan, catatan internal, atau review untuk item event ini (minimal 5 karakter).',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 16),
                // Input teks catatan dengan validator minLength(5)
                TextFormField(
                  controller: _catatanController,
                  maxLines: 4,
                  style: AppTextStyles.body,
                  decoration: InputDecoration(
                    labelText: 'Catatan',
                    hintText: 'Tuliskan catatan atau review di sini (minimal 5 karakter)...',
                    hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.softGray,
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
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red, width: 1),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red, width: 1.5),
                    ),
                  ),
                  validator: (value) =>
                      Validators.minLength(value, 5, fieldName: 'Catatan'),
                ),
                const SizedBox(height: 24),
                // Tombol Simpan
                PrimaryButton(
                  label: 'Simpan',
                  trailingIcon: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
                  onPressed: _simpan,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
