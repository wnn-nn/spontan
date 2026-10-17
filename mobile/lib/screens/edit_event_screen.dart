import 'package:flutter/material.dart';

import '../core/services/api_service.dart';
import '../core/utils/description_validator.dart';
import '../core/utils/title_validator.dart';
import '../models/event_model.dart';

class EditEventScreen extends StatefulWidget {
  final EventModel? event;
  final String? initialJudul;
  final String? initialDeskripsi;
  final String? initialTanggalMulai;
  final String? initialTanggalSelesai;
  final String? initialLokasi;
  final String? initialKategori;
  final String? initialTarget;
  final int? initialEstimasiPeserta;

  const EditEventScreen({
    super.key,
    this.event,
    this.initialJudul,
    this.initialDeskripsi,
    this.initialTanggalMulai,
    this.initialTanggalSelesai,
    this.initialLokasi,
    this.initialKategori,
    this.initialTarget,
    this.initialEstimasiPeserta,
  });

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _judulController;
  late TextEditingController _deskripsiController;
  late TextEditingController _lokasiController;
  late TextEditingController _pesertaController;

  late String _tanggalMulaiText;
  late String _tanggalSelesaiText;
  late DateTime _startDate;
  late DateTime _endDate;

  String? _selectedKategori;
  String? _selectedTarget;

  bool _isSubmitting = false;

  final List<String> _kategoriOptions = [
    'Seminar & Workshop',
    'Seminar',
    'Kompetisi',
    'PKM',
    'Kegiatan Organisasi',
    'Lainnya',
  ];

  final List<String> _targetOptions = [
    'Mahasiswa Nasional',
    'Mahasiswa',
    'Pelajar (SMA/SMK)',
    'Masyarakat Umum',
    'Komunitas/Profesional',
  ];

  @override
  void initState() {
    super.initState();

    final ev = widget.event;
    final defaultJudul = ev?.judul ?? widget.initialJudul ?? 'Seminar Teknologi Kampus 2026';
    final defaultDeskripsi = ev?.deskripsi.isNotEmpty == true
        ? ev!.deskripsi
        : widget.initialDeskripsi ??
            'Seminar tahunan yang menghadirkan pakar industri digital dan kecerdasan buatan';
    final defaultLokasi = ev?.lokasi.isNotEmpty == true
        ? ev!.lokasi
        : widget.initialLokasi ?? 'Aula Utama Fakultas Teknik, Gedung A Lantai 3';
    final defaultPeserta = ev?.estimasiPeserta != null && ev!.estimasiPeserta > 0
        ? ev.estimasiPeserta
        : widget.initialEstimasiPeserta ?? 500;

    _judulController = TextEditingController(text: defaultJudul);
    _deskripsiController = TextEditingController(text: defaultDeskripsi);
    _lokasiController = TextEditingController(text: defaultLokasi);
    _pesertaController = TextEditingController(text: defaultPeserta.toString());

    _tanggalMulaiText = widget.initialTanggalMulai ?? '12 November 2026, 08:30 WIB';
    _tanggalSelesaiText = widget.initialTanggalSelesai ?? '12 November 2026, 16:00 WIB';

    _startDate = DateTime(2026, 11, 12, 8, 30);
    _endDate = DateTime(2026, 11, 12, 16, 0);

    // Kategori
    final initialKat = ev?.kategori ?? widget.initialKategori ?? 'Seminar & Workshop';
    _selectedKategori = _kategoriOptions.contains(initialKat)
        ? initialKat
        : 'Seminar & Workshop';

    // Target Audience
    final initialAud = ev?.targetAudiences.isNotEmpty == true
        ? ev!.targetAudiences.first
        : widget.initialTarget ?? 'Mahasiswa Nasional';
    _selectedTarget = _targetOptions.contains(initialAud)
        ? initialAud
        : 'Mahasiswa Nasional';
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _lokasiController.dispose();
    _pesertaController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime(bool isStart) async {
    final initial = isStart ? _startDate : _endDate;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2025),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null || !mounted) return;

    final combined = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    final formatted = _formatDateTimeDisplay(combined);

    setState(() {
      if (isStart) {
        _startDate = combined;
        _tanggalMulaiText = formatted;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(hours: 4));
          _tanggalSelesaiText = _formatDateTimeDisplay(_endDate);
        }
      } else {
        _endDate = combined;
        _tanggalSelesaiText = formatted;
      }
    });
  }

  String _formatDateTimeDisplay(DateTime dt) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final month = months[dt.month - 1];
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$min WIB';
  }

  Future<void> _submit() async {
    final judul = _judulController.text.trim();
    final deskripsi = _deskripsiController.text.trim();
    final lokasi = _lokasiController.text.trim();
    final pesertaStr = _pesertaController.text.trim();

    // 1. Validasi Judul (PRD v1.1 Modul 1 + Deteksi Teks Acak/Gibberish)
    final titleErr = TitleValidator.validate(judul);
    if (titleErr != null) {
      _showErrorSnackBar(titleErr);
      return;
    }

    // 2. Validasi Deskripsi (PRD v1.1 Modul 1: min 20, max 3000, spam/gibberish & placeholder)
    final descErr = DescriptionValidator.validate(deskripsi);
    if (descErr != null) {
      _showErrorSnackBar(descErr);
      return;
    }

    // 3. Validasi Lokasi
    if (lokasi.isEmpty) {
      _showErrorSnackBar('Lokasi event wajib diisi.');
      return;
    }

    // 4. Validasi Estimasi Peserta (PRD v1.1 Modul 1: integer >= 10)
    final pesertaNum = int.tryParse(pesertaStr) ?? 0;
    if (pesertaNum < 10) {
      _showErrorSnackBar('Estimasi peserta minimal 10 orang.');
      return;
    }

    // 5. Validasi Tanggal
    if (_endDate.isBefore(_startDate)) {
      _showErrorSnackBar('Tanggal selesai tidak boleh lebih awal dari tanggal mulai.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Jika terhubung ke event backend yang nyata
      if (widget.event != null && widget.event!.idEvent > 0) {
        final backendKategori = _selectedKategori == 'Seminar & Workshop' ? 'Seminar' : _selectedKategori!;
        final backendAudience = _selectedTarget == 'Mahasiswa Nasional' ? 'Mahasiswa' : _selectedTarget!;

        final updated = await ApiService.updateEvent(
          idEvent: widget.event!.idEvent,
          judul: judul,
          deskripsi: deskripsi,
          kategori: backendKategori,
          targetAudiences: [backendAudience],
          tanggalMulai: '${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}',
          tanggalSelesai: '${_endDate.year}-${_endDate.month.toString().padLeft(2, '0')}-${_endDate.day.toString().padLeft(2, '0')}',
          lokasi: lokasi,
          estimasiPeserta: pesertaNum,
        );

        if (!mounted) return;
        Navigator.pop(context, updated);
        return;
      }

      // Fallback mode / offline mock
      final resultData = {
        'judul': judul,
        'deskripsi': deskripsi,
        'tanggal_mulai': _tanggalMulaiText,
        'tanggal_selesai': _tanggalSelesaiText,
        'lokasi': lokasi,
        'kategori': _selectedKategori ?? 'Seminar & Workshop',
        'target': _selectedTarget ?? 'Mahasiswa Nasional',
        'estimasi_peserta': pesertaNum,
      };

      if (!mounted) return;
      Navigator.pop(context, resultData);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showErrorSnackBar(e.toString());
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF0F172A),
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Event',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Judul Event *
              _buildFieldLabel('Judul Event', isRequired: true),
              const SizedBox(height: 8),
              _buildInputContainer(
                child: TextField(
                  controller: _judulController,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Nama kegiatan...',
                    hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // 2. Deskripsi Event *
              _buildFieldLabel('Deskripsi Event', isRequired: true),
              const SizedBox(height: 8),
              _buildInputContainer(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: TextField(
                  controller: _deskripsiController,
                  maxLines: 4,
                  minLines: 3,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF0F172A),
                    height: 1.45,
                  ),
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Rincian penjelasan kegiatan...',
                    hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // 3. Tanggal Mulai *
              _buildFieldLabel('Tanggal Mulai', isRequired: true),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _pickDateTime(true),
                borderRadius: BorderRadius.circular(16),
                child: _buildInputContainer(
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, color: Color(0xFF64748B), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _tanggalMulaiText,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // 4. Tanggal Selesai *
              _buildFieldLabel('Tanggal Selesai', isRequired: true),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _pickDateTime(false),
                borderRadius: BorderRadius.circular(16),
                child: _buildInputContainer(
                  child: Row(
                    children: [
                      const Icon(Icons.event_outlined, color: Color(0xFF64748B), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _tanggalSelesaiText,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // 5. Lokasi Event *
              _buildFieldLabel('Lokasi Event', isRequired: true),
              const SizedBox(height: 8),
              _buildInputContainer(
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: Color(0xFF64748B), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _lokasiController,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                        decoration: const InputDecoration.collapsed(
                          hintText: 'Tempat penyelenggaraan...',
                          hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 6. Kategori Event *
              _buildFieldLabel('Kategori Event', isRequired: true),
              const SizedBox(height: 8),
              _buildInputContainer(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                child: Row(
                  children: [
                    const Icon(Icons.category_outlined, color: Color(0xFF64748B), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedKategori,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B), size: 22),
                          items: _kategoriOptions.map((opt) {
                            return DropdownMenuItem<String>(
                              value: opt,
                              child: Text(
                                opt,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedKategori = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 7. Target Audience *
              _buildFieldLabel('Target Audience', isRequired: true),
              const SizedBox(height: 8),
              _buildInputContainer(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                child: Row(
                  children: [
                    const Icon(Icons.badge_outlined, color: Color(0xFF64748B), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedTarget,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B), size: 22),
                          items: _targetOptions.map((opt) {
                            return DropdownMenuItem<String>(
                              value: opt,
                              child: Text(
                                opt,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedTarget = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 8. Estimasi Peserta *
              _buildFieldLabel('Estimasi Peserta', isRequired: true),
              const SizedBox(height: 8),
              _buildInputContainer(
                child: Row(
                  children: [
                    const Icon(Icons.groups_outlined, color: Color(0xFF64748B), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _pesertaController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                        decoration: const InputDecoration.collapsed(
                          hintText: '500',
                          hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                        ),
                      ),
                    ),
                    const Text(
                      'orang',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 9. Tombol: Simpan Perubahan
              InkWell(
                onTap: _isSubmitting ? null : _submit,
                borderRadius: BorderRadius.circular(26),
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2F65F6),
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          'Simpan Perubahan',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 28),
            ],
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
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0F172A),
          letterSpacing: -0.1,
        ),
        children: isRequired
            ? const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ]
            : [],
      ),
    );
  }

  Widget _buildInputContainer({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}
