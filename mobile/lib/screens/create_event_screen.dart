import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../core/constants/app_colors.dart';
import '../core/services/api_service.dart';
import '../core/utils/description_validator.dart';
import '../core/utils/title_validator.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();

  // 1. Controllers Input Teks (Sesuai Spesifikasi PRD v1.1 Modul 1)
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _pesertaController = TextEditingController();
  final _posterController = TextEditingController();

  // 2. State Input Pilihan & Tanggal
  String? _selectedCategory;
  final Set<String> _selectedTargetAudiences = {};
  DateTime? _startDate;
  DateTime? _endDate;

  // 3. State Proses (Sesuai Spesifikasi Workflow Bagian H)
  bool _isLoadingReferenceData = true;
  String? _referenceDataError;
  bool _isSubmitting = false;
  String? _submitError;

  // Daftar Baku dari Backend
  List<String> _categories = [];
  List<String> _targetAudiencesList = [];

  // State Error Tambahan untuk Custom Picker (Audience & Tanggal)
  String? _audienceError;
  String? _dateError;

  @override
  void initState() {
    super.initState();
    _loadReferenceData();
  }

  // Wajib dibersihkan menggunakan dispose() saat layar tidak lagi digunakan (Bagian H)
  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _lokasiController.dispose();
    _pesertaController.dispose();
    _posterController.dispose();
    super.dispose();
  }

  // Memuat daftar baku dari endpoint GET /api/reference-data
  Future<void> _loadReferenceData() async {
    setState(() {
      _isLoadingReferenceData = true;
      _referenceDataError = null;
    });

    try {
      final refData = await ApiService.getReferenceData();
      if (!mounted) return;
      setState(() {
        _categories = refData.categories;
        _targetAudiencesList = refData.targetAudiences;
        _isLoadingReferenceData = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _referenceDataError = e.toString();
        _isLoadingReferenceData = false;
      });
    }
  }

  // DatePicker Tanggal Mulai (PRD v1.1 §3.1 B.5: tidak boleh sebelum hari ini)
  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate != null && _startDate!.isAfter(today) ? _startDate! : today,
      firstDate: today.subtract(const Duration(days: 1)),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        // Jika tanggal selesai sebelumnya lebih awal dari tanggal mulai yang baru, sesuaikan
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = picked;
        }
        _validateDates();
      });
    }
  }

  // DatePicker Tanggal Selesai
  Future<void> _pickEndDate() async {
    final initial = _endDate ?? _startDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: _startDate ?? DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
        _validateDates();
      });
    }
  }

  bool _validateDates() {
    if (_startDate == null) {
      setState(() => _dateError = 'Tanggal mulai wajib dipilih.');
      return false;
    }
    if (_endDate == null) {
      setState(() => _dateError = 'Tanggal selesai wajib dipilih.');
      return false;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDay = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
    if (startDay.isBefore(today)) {
      setState(() => _dateError = 'Tanggal mulai tidak boleh sebelum hari ini.');
      return false;
    }
    // Aturan: Tanggal selesai tidak boleh lebih awal daripada tanggal mulai. Tanggal yang sama diperbolehkan.
    if (_endDate!.isBefore(_startDate!)) {
      setState(
        () => _dateError =
            'Tanggal selesai tidak boleh lebih awal daripada tanggal mulai.',
      );
      return false;
    }
    setState(() => _dateError = null);
    return true;
  }

  bool _validateAudiences() {
    // Aturan: Minimal memilih satu; pilihan harus valid dan tidak boleh duplikat.
    if (_selectedTargetAudiences.isEmpty) {
      setState(() => _audienceError = 'Pilih minimal satu target audience.');
      return false;
    }
    setState(() => _audienceError = null);
    return true;
  }

  // Handler Submit "Buat Event"
  Future<void> _handleSubmit() async {
    // 1. Validasi Field menggunakan Form dan validator Flutter
    final isFormValid = _formKey.currentState!.validate();
    final isAudienceValid = _validateAudiences();
    final isDatesValid = _validateDates();

    if (!isFormValid || !isAudienceValid || !isDatesValid) {
      // Jika input tidak valid, aplikasi menampilkan pesan yang sesuai,
      // tetap berada pada form, dan mempertahankan input.
      return;
    }

    // 2. Set State Submitting
    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    final formatter = DateFormat('yyyy-MM-dd');
    final tglMulaiStr = formatter.format(_startDate!);
    final tglSelesaiStr = formatter.format(_endDate!);
    final estimasiNum = int.parse(_pesertaController.text.trim());

    try {
      // 3. Kirim request POST /api/events dengan access token & poster opsional
      final createdEvent = await ApiService.createEvent(
        judul: _judulController.text.trim(),
        deskripsi: _deskripsiController.text.trim(),
        kategori: _selectedCategory!,
        targetAudiences: _selectedTargetAudiences.toList(),
        tanggalMulai: tglMulaiStr,
        tanggalSelesai: tglSelesaiStr,
        lokasi: _lokasiController.text.trim(),
        estimasiPeserta: estimasiNum,
        posterEvent: _posterController.text.trim().isNotEmpty
            ? _posterController.text.trim()
            : null,
      );

      if (!mounted) return;

      // 4. Sukses: Kembalikan objek Event melalui hasil navigasi
      Navigator.pop(context, createdEvent);
    } catch (e) {
      if (!mounted) return;
      // Jika penyimpanan gagal, pengguna tetap berada di form dengan input dipertahankan
      // dan pesan error ditampilkan.
      setState(() {
        _isSubmitting = false;
        _submitError = e.toString();
      });
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
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Buat Event Baru',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Pemuatan data referensi baku
    if (_isLoadingReferenceData) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Memuat daftar kategori & target audience...',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
            ),
          ],
        ),
      );
    }

    // Gagal memuat data referensi
    if (_referenceDataError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              const Text(
                'Gagal Menghubungi Server',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _referenceDataError!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadReferenceData,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Form Utama Pembuatan Event
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner Error Penyimpanan (Jika submit gagal, input dipertahankan)
            if (_submitError != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Gagal Menyimpan Event',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _submitError!,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 13,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // KELOMPOK 1: INFORMASI EVENT
            _buildSectionCard(
              title: 'Informasi Event',
              subtitle: 'Identitas dan karakteristik dasar kegiatan',
              icon: Icons.info_outline_rounded,
              children: [
                // Field 1: Judul Event (PRD v1.1 §3.1 B.1: min 5, max 100 karakter)
                _buildLabel('1. Judul Event', isRequired: true),
                TextFormField(
                  controller: _judulController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: _inputDecoration(
                    hint: 'Contoh: Seminar Nasional AI & Masa Depan Karir',
                    prefixIcon: Icons.title_rounded,
                  ),
                  // Aturan PRD v1.1 §3.1 B.1 + Deteksi Teks Acak/Gibberish
                  validator: TitleValidator.validate,
                ),
                const SizedBox(height: 16),

                // Field 2: Deskripsi Event
                _buildLabel('2. Deskripsi Event', isRequired: true),
                TextFormField(
                  controller: _deskripsiController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  maxLines: 3,
                  decoration: _inputDecoration(
                    hint: 'Jelaskan tujuan kegiatan, latar belakang, dan manfaat bagi peserta...',
                    prefixIcon: Icons.description_outlined,
                  ),
                  // Aturan PRD v1.1 Modul 1: min 20, max 3000, cegah spam/gibberish & placeholder
                  validator: DescriptionValidator.validate,
                ),
                const SizedBox(height: 16),

                // Field 3: Kategori Event (Single Choice dari Daftar Baku)
                _buildLabel('3. Kategori Event', isRequired: true),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: _inputDecoration(
                    hint: 'Pilih salah satu kategori',
                    prefixIcon: Icons.category_outlined,
                  ),
                  items: _categories.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCategory = val;
                    });
                  },
                  // Aturan: Wajib memilih satu kategori dari daftar baku backend
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Kategori wajib dipilih dari daftar baku';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Field 4: Target Audience (Multi-Select dari Daftar Baku)
                _buildLabel('4. Target Audience', isRequired: true),
                const Text(
                  'Pilih sasaran peserta kegiatan (bisa lebih dari satu):',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _targetAudiencesList.map((aud) {
                    final isSelected = _selectedTargetAudiences.contains(aud);
                    return FilterChip(
                      label: Text(aud),
                      selected: isSelected,
                      selectedColor: AppColors.primaryLight,
                      checkmarkColor: AppColors.primary,
                      backgroundColor: AppColors.surfaceMuted,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.primaryDark
                            : AppColors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        fontSize: 12.5,
                      ),
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            _selectedTargetAudiences.add(aud);
                          } else {
                            _selectedTargetAudiences.remove(aud);
                          }
                          _validateAudiences();
                        });
                      },
                    );
                  }).toList(),
                ),
                if (_audienceError != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _audienceError!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),

            // KELOMPOK 2: PELAKSANAAN EVENT
            _buildSectionCard(
              title: 'Pelaksanaan Event',
              subtitle: 'Waktu, tempat, dan estimasi peserta',
              icon: Icons.calendar_month_rounded,
              children: [
                // Field 5 & 6: Tanggal Mulai dan Selesai
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('5. Tanggal Mulai', isRequired: true),
                          InkWell(
                            onTap: _pickStartDate,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      _dateError != null && _startDate == null
                                      ? AppColors.error
                                      : AppColors.border,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.date_range_rounded,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _startDate != null
                                          ? DateFormat('dd MMM yyyy')
                                                .format(_startDate!)
                                          : 'Pilih Tanggal',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: _startDate != null
                                            ? AppColors.textPrimary
                                            : AppColors.textMuted,
                                        fontWeight: _startDate != null
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('6. Tanggal Selesai', isRequired: true),
                          InkWell(
                            onTap: _pickEndDate,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _dateError != null && _endDate == null
                                      ? AppColors.error
                                      : AppColors.border,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.event_available_rounded,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _endDate != null
                                          ? DateFormat('dd MMM yyyy')
                                                .format(_endDate!)
                                          : 'Pilih Tanggal',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: _endDate != null
                                            ? AppColors.textPrimary
                                            : AppColors.textMuted,
                                        fontWeight: _endDate != null
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_dateError != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _dateError!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // Field 7: Lokasi
                _buildLabel('7. Lokasi', isRequired: true),
                TextFormField(
                  controller: _lokasiController,
                  decoration: _inputDecoration(
                    hint: 'Contoh: Gedung Auditorium Unand / Hybrid Zoom',
                    prefixIcon: Icons.location_on_rounded,
                  ),
                  // Aturan: Wajib diisi dan tidak boleh hanya berisi spasi
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Lokasi kegiatan wajib diisi dan tidak boleh hanya berisi spasi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Field 8: Estimasi Peserta (PRD v1.1 §3.1 B.4: integer positif >= 10)
                _buildLabel('8. Estimasi Peserta', isRequired: true),
                TextFormField(
                  controller: _pesertaController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _inputDecoration(
                    hint: 'Contoh: 250 (minimal 10 orang)',
                    prefixIcon: Icons.groups_rounded,
                    suffixText: 'Orang',
                  ),
                  // Aturan: Wajib diisi dengan bilangan bulat minimal 10 orang
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Estimasi peserta wajib diisi';
                    }
                    final num = int.tryParse(val.trim());
                    if (num == null || num < 10) {
                      return 'Estimasi peserta minimal 10 orang';
                    }
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // KELOMPOK 3: MEDIA & POSTER EVENT (OPSIONAL SESUAI PRD §3.1 B.6)
            _buildSectionCard(
              title: 'Poster Event (Opsional)',
              subtitle: 'Mendukung format .jpg, .jpeg, .png (Maks. 5 MB)',
              icon: Icons.image_outlined,
              children: [
                _buildLabel('9. Tautan Gambar Poster / Sample Poster', isRequired: false),
                TextFormField(
                  controller: _posterController,
                  decoration: _inputDecoration(
                    hint: 'https://example.com/poster.jpg atau pilih preset',
                    prefixIcon: Icons.link_rounded,
                  ),
                  onChanged: (val) {
                    setState(() {});
                  },
                  validator: (val) {
                    if (val != null && val.trim().isNotEmpty) {
                      final lower = val.trim().toLowerCase();
                      final isValidExt = lower.endsWith('.jpg') ||
                          lower.endsWith('.jpeg') ||
                          lower.endsWith('.png') ||
                          lower.startsWith('http://') ||
                          lower.startsWith('https://');
                      if (!isValidExt) {
                        return 'Format harus berupa URL gambar valid (.jpg, .jpeg, .png)';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                const Text(
                  'Atau pilih contoh poster siap pakai:',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.school, size: 16, color: AppColors.primary),
                      label: const Text('Poster Seminar AI'),
                      onPressed: () {
                        setState(() {
                          _posterController.text =
                              'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800&auto=format&fit=crop&q=80';
                        });
                      },
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.emoji_events, size: 16, color: AppColors.primary),
                      label: const Text('Poster Kompetisi'),
                      onPressed: () {
                        setState(() {
                          _posterController.text =
                              'https://images.unsplash.com/photo-1511578314322-379afb476865?w=800&auto=format&fit=crop&q=80';
                        });
                      },
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.lightbulb_outline, size: 16, color: AppColors.primary),
                      label: const Text('Poster Workshop PKM'),
                      onPressed: () {
                        setState(() {
                          _posterController.text =
                              'https://images.unsplash.com/photo-1523580494863-6f3031224c94?w=800&auto=format&fit=crop&q=80';
                        });
                      },
                    ),
                    if (_posterController.text.isNotEmpty)
                      ActionChip(
                        avatar: const Icon(Icons.clear, size: 16, color: AppColors.error),
                        label: const Text('Hapus Poster'),
                        onPressed: () {
                          setState(() {
                            _posterController.clear();
                          });
                        },
                      ),
                  ],
                ),
                if (_posterController.text.trim().isNotEmpty) ...[
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      color: AppColors.surfaceMuted,
                      child: Image.network(
                        _posterController.text.trim(),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          padding: const EdgeInsets.all(16),
                          alignment: Alignment.center,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image, color: AppColors.error, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Pratinjau gambar tidak dapat dimuat',
                                style: TextStyle(color: AppColors.error, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 28),

            // Tombol "Buat Event" (Submit Button)
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                  shadowColor: AppColors.primary.withValues(alpha: 0.4),
                ),
                child: _isSubmitting
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 14),
                          Text(
                            'Menyimpan Event ke Backend...',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_rounded, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Simpan & Buat Event',
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: AppColors.border),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (isRequired)
            const Text(
              ' *',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    String? suffixText,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
      prefixIcon: Icon(prefixIcon, size: 20, color: AppColors.primary),
      suffixText: suffixText,
      suffixStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        color: AppColors.textSecondary,
      ),
      filled: true,
      fillColor: AppColors.surfaceMuted,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color.fromARGB(255, 109, 111, 116), width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.6),
      ),
    );
  }
}
