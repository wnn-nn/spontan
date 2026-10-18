import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants/app_colors.dart';
import '../models/app_constants.dart';
import '../models/event_model.dart';
import '../models/kebutuhan_model.dart';
import '../repositories/kebutuhan_repository.dart';

/// Form untuk menambahkan satu kebutuhan sponsorship baru pada sebuah event.
///
/// Mengembalikan objek [KebutuhanModel] melalui [Navigator.pop] setelah
/// penyimpanan berhasil. Data event hanya dibaca untuk mengambil [EventModel.idEvent].
class FormKebutuhanScreen extends StatefulWidget {
  final EventModel event;

  const FormKebutuhanScreen({super.key, required this.event});

  @override
  State<FormKebutuhanScreen> createState() => _FormKebutuhanScreenState();
}

class _FormKebutuhanScreenState extends State<FormKebutuhanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _deskripsiController = TextEditingController();
  final _nilaiController = TextEditingController();

  final KebutuhanRepository _repository = KebutuhanRepository();

  String? _selectedJenis;
  bool _isSaving = false;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _deskripsiController.dispose();
    _nilaiController.dispose();
    super.dispose();
  }

  // ── Validasi ───────────────────────────────────────────────────────────────

  String? _validateJenis(String? value) {
    if (value == null || value.isEmpty) {
      return 'Jenis kebutuhan wajib dipilih.';
    }
    return null;
  }

  String? _validateDeskripsi(String? value) {
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) {
      return 'Deskripsi kebutuhan wajib diisi.';
    }
    if (trimmed.length < 5) {
      return 'Deskripsi minimal 5 karakter.';
    }
    return null;
  }

  String? _validateNilai(String? value) {
    final raw = (value ?? '').trim();

    if (raw.isEmpty) {
      return 'Nilai estimasi wajib diisi.';
    }

    // Tolak desimal
    if (raw.contains('.') || raw.contains(',')) {
      return 'Nilai harus berupa angka bulat tanpa desimal.';
    }

    // Tolak non-angka
    final parsed = int.tryParse(raw);
    if (parsed == null) {
      return 'Nilai harus berupa angka yang valid.';
    }

    // Tolak negatif dan nol
    if (parsed <= 0) {
      return 'Nilai estimasi harus lebih dari Rp 0.';
    }

    // Nilai minimum Rp 10.000
    if (parsed < 10000) {
      return 'Nilai estimasi minimal Rp 10.000.';
    }

    return null;
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _handleSimpan() async {
    // Paksa rebuild agar error dropdown jenis muncul
    setState(() {});

    final isValid = _formKey.currentState!.validate();
    final isJenisValid = _selectedJenis != null && _selectedJenis!.isNotEmpty;

    if (!isValid || !isJenisValid) return;

    // Backup validation: pastikan nilai benar-benar valid sebelum menyimpan
    final rawNilai = _nilaiController.text.trim();
    final parsedNilai = int.tryParse(rawNilai);
    if (parsedNilai == null || parsedNilai < 10000) return;

    // Cegah double-tap: blokir tombol selama penyimpanan
    setState(() => _isSaving = true);

    try {
      // Simulasi durasi ~1 detik sesuai spesifikasi
      await Future.delayed(const Duration(milliseconds: 1000));

      final nilai = double.parse(_nilaiController.text.trim());
      final satuanKeterangan = _buildSatuanKeterangan(_selectedJenis!, nilai);

      final kebutuhan = KebutuhanModel(
        id: 'KB-${DateTime.now().millisecondsSinceEpoch}',
        eventId: widget.event.idEvent.toString(),
        jenis: _selectedJenis!,
        deskripsi: _deskripsiController.text.trim(),
        nilai: nilai,
        satuanKeterangan: satuanKeterangan,
        status: AppConstants.statusKebutuhanTerbuka,
      );

      await _repository.add(kebutuhan);

      if (!mounted) return;

      // Kembalikan hasil ke layar pemanggil
      Navigator.pop(context, kebutuhan);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text('Gagal menyimpan: ${e.toString()}')),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  /// Membangun teks satuan/keterangan untuk ditampilkan di kartu kebutuhan.
  String _buildSatuanKeterangan(String jenis, double nilai) {
    if (jenis == AppConstants.jenisKebutuhanMediaPartner) {
      return 'Publikasi Media Partner';
    }
    return 'Rp ${_formatRupiah(nilai.toInt())}';
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
          onPressed: _isSaving ? null : () => Navigator.pop(context),
        ),
        title: const Text(
          'Tambah Kebutuhan',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Event
              _buildEventInfoBanner(),
              const SizedBox(height: 24),

              // 1. Jenis Kebutuhan
              _buildFieldLabel('Jenis Kebutuhan', isRequired: true),
              const SizedBox(height: 8),
              _buildJenisDropdown(),
              const SizedBox(height: 20),

              // 2. Deskripsi
              _buildFieldLabel('Deskripsi Kebutuhan', isRequired: true),
              const SizedBox(height: 8),
              _buildDeskripsiField(),
              const SizedBox(height: 20),

              // 3. Nilai Estimasi
              _buildFieldLabel('Nilai Estimasi (Rp)', isRequired: true),
              const SizedBox(height: 8),
              _buildNilaiField(),
              const SizedBox(height: 8),
              const Text(
                'Masukkan angka bulat tanpa titik atau koma. Minimal Rp 10.000.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 36),

              // Tombol Simpan
              _buildSimpanButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Komponen UI ────────────────────────────────────────────────────────────

  Widget _buildEventInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primarySurface),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_note_rounded, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kebutuhan untuk event:',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.event.judul,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJenisDropdown() {
    // Gunakan FormField agar validasi dropdown terintegrasi dengan Form
    return FormField<String>(
      validator: _validateJenis,
      initialValue: _selectedJenis,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: field.hasError ? AppColors.error : AppColors.border,
                  width: field.hasError ? 1.5 : 1.0,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedJenis,
                  hint: const Text(
                    'Pilih jenis kebutuhan',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                    size: 24,
                  ),
                  items: AppConstants.jenisKebutuhanOptions.map((opt) {
                    return DropdownMenuItem<String>(
                      value: opt,
                      child: Text(
                        opt,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: _isSaving
                      ? null
                      : (val) {
                          setState(() => _selectedJenis = val);
                          field.didChange(val);
                        },
                ),
              ),
            ),
            if (field.hasError) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  field.errorText!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildDeskripsiField() {
    return TextFormField(
      controller: _deskripsiController,
      enabled: !_isSaving,
      maxLines: 4,
      minLines: 3,
      maxLength: 250,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: _validateDeskripsi,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textPrimary,
        height: 1.45,
      ),
      decoration: InputDecoration(
        hintText: 'Jelaskan rincian kebutuhan yang diperlukan...',
        hintStyle: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 13.5,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildNilaiField() {
    return TextFormField(
      controller: _nilaiController,
      enabled: !_isSaving,
      keyboardType: TextInputType.number,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      validator: _validateNilai,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: 'Contoh: 500000',
        hintStyle: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        prefixText: 'Rp ',
        prefixStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildSimpanButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _handleSimpan,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primarySurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          elevation: _isSaving ? 0 : 2,
          shadowColor: AppColors.primary.withValues(alpha: 0.4),
        ),
        child: _isSaving
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Menyimpan...',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              )
            : const Text(
                'Simpan',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.1,
        ),
        children: isRequired
            ? const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ]
            : [],
      ),
    );
  }
}
