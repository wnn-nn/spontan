import 'package:flutter/material.dart';

import '../models/kebutuhan_model.dart';

class AddKebutuhanScreen extends StatefulWidget {
  final String? eventId;
  final String? eventJudul;

  const AddKebutuhanScreen({
    super.key,
    this.eventId,
    this.eventJudul,
  });

  @override
  State<AddKebutuhanScreen> createState() => _AddKebutuhanScreenState();
}

class _AddKebutuhanScreenState extends State<AddKebutuhanScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _estimasiController = TextEditingController(text: 'Rp 500.000');

  String? _selectedJenis;
  final List<String> _jenisOptions = [
    'Dana',
    'Barang',
    'Media Partner',
    'Lainnya',
  ];

  @override
  void dispose() {
    _deskripsiController.dispose();
    _estimasiController.dispose();
    super.dispose();
  }

  void _submit() {
    // 1. Validasi Jenis Kebutuhan
    if (_selectedJenis == null || _selectedJenis!.isEmpty) {
      _showErrorSnackBar('Pilih jenis kebutuhan terlebih dahulu.');
      return;
    }

    // 2. Validasi Deskripsi Kebutuhan (PRD v1.1 Modul 2: min 5, maks 250 karakter)
    final deskripsi = _deskripsiController.text.trim();
    if (deskripsi.length < 5) {
      _showErrorSnackBar('Deskripsi kebutuhan minimal 5 karakter.');
      return;
    }
    if (deskripsi.length > 250) {
      _showErrorSnackBar('Deskripsi kebutuhan maksimal 250 karakter.');
      return;
    }

    // 3. Validasi & Parsing Estimasi Kebutuhan
    final rawEstimasi = _estimasiController.text
        .replaceAll('Rp', '')
        .replaceAll('.', '')
        .replaceAll(',', '')
        .replaceAll(' ', '')
        .trim();
    final double nilaiEstimasi = double.tryParse(rawEstimasi) ?? 0.0;

    if (_selectedJenis == 'Dana' && nilaiEstimasi <= 0) {
      _showErrorSnackBar('Estimasi kebutuhan untuk jenis Dana wajib bernilai nominal positif.');
      return;
    }

    // Tentukan satuan keterangan tampilan
    String formattedSatuan = 'Rp ${_formatRupiah(nilaiEstimasi.toInt())}';
    if (_selectedJenis == 'Barang') {
      formattedSatuan = deskripsi.contains('Paket') || deskripsi.contains('Box')
          ? deskripsi
          : 'Rp ${_formatRupiah(nilaiEstimasi.toInt())} (Ekuivalen)';
    } else if (_selectedJenis == 'Media Partner') {
      formattedSatuan = 'Publikasi Media Partner';
    }

    final newKebutuhan = KebutuhanModel(
      id: 'KB-${DateTime.now().millisecondsSinceEpoch % 1000}',
      jenisKebutuhan: _selectedJenis!,
      deskripsi: deskripsi,
      nilaiEstimasi: nilaiEstimasi,
      satuanKeterangan: formattedSatuan,
      status: 'Terbuka',
    );

    Navigator.pop(context, newKebutuhan);
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
          'Tambah Kebutuhan Event',
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Jenis Kebutuhan *
              _buildFieldLabel('Jenis Kebutuhan', isRequired: true),
              const SizedBox(height: 8),
              Container(
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedJenis,
                    hint: const Text(
                      'Pilih kategori kebutuhan',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF64748B),
                      size: 24,
                    ),
                    items: _jenisOptions.map((opt) {
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
                      setState(() {
                        _selectedJenis = val;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 2. Deskripsi Kebutuhan *
              _buildFieldLabel('Deskripsi Kebutuhan', isRequired: true),
              const SizedBox(height: 8),
              Container(
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: TextField(
                  controller: _deskripsiController,
                  maxLines: 5,
                  minLines: 4,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF0F172A),
                    height: 1.45,
                  ),
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Jelaskan rincian kebutuhan yang diperlukan...',
                    hintStyle: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 3. Estimasi Kebutuhan*
              _buildFieldLabel('Estimasi Kebutuhan', isRequired: true),
              const SizedBox(height: 8),
              Container(
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: TextField(
                  controller: _estimasiController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Rp 500.000',
                    hintStyle: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Estimasi total anggaran atau ekuivalen nilai barang/jasa yang diajukan.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 36),

              // 4. Tombol: Tambah Kebutuhan
              InkWell(
                onTap: _submit,
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
                  child: const Text(
                    'Tambah Kebutuhan',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
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
          fontSize: 13.5,
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
}
