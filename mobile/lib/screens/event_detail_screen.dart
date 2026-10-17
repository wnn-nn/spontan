import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../models/event_model.dart';
import '../models/kebutuhan_model.dart';
import 'add_kebutuhan_screen.dart';
import 'edit_event_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final EventModel? event;
  final String? initialJudul;
  final String? initialTanggal;
  final String? initialLokasi;
  final String? initialKategori;

  const EventDetailScreen({
    super.key,
    this.event,
    this.initialJudul,
    this.initialTanggal,
    this.initialLokasi,
    this.initialKategori,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  String _activeTab = 'Info';

  late List<KebutuhanModel> _kebutuhanList;

  @override
  void initState() {
    super.initState();
    _kebutuhanList = [
      KebutuhanModel(
        id: 'KB-001',
        jenisKebutuhan: 'Dana',
        deskripsi: 'Dana Operasional Pembicara',
        nilaiEstimasi: 5000000,
        satuanKeterangan: 'Rp 5.000.000',
        status: 'Terbuka',
      ),
      KebutuhanModel(
        id: 'KB-002',
        jenisKebutuhan: 'Barang',
        deskripsi: 'Konsumsi 500 Snack Box',
        nilaiEstimasi: 7500000,
        satuanKeterangan: '500 Paket',
        status: 'Terbuka',
      ),
      KebutuhanModel(
        id: 'KB-003',
        jenisKebutuhan: 'Media Partner',
        deskripsi: 'Publikasi Media Sosial',
        nilaiEstimasi: 0,
        satuanKeterangan: '10 Akun Kampus',
        status: 'Terpenuhi',
      ),
    ];
  }

  Future<void> _navigateToAddKebutuhan() async {
    final result = await Navigator.push<KebutuhanModel>(
      context,
      MaterialPageRoute(
        builder: (context) => AddKebutuhanScreen(
          eventId: widget.event?.idEvent.toString(),
          eventJudul: widget.event?.judul ?? widget.initialJudul,
        ),
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
                child: Text('Kebutuhan "${result.deskripsi}" berhasil ditambahkan!'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Parameter data fallback sesuai screenshot
    final judul = widget.event?.judul ??
        widget.initialJudul ??
        'Seminar Teknologi Kampus';
    
    // Konfigurasi preset data berdasarkan judul event
    String kategoriUpper = 'TEKNOLOGI & SAINS';
    String kategori = 'Seminar';
    String tanggal = '12 Nov 2026';
    String lokasi = 'Aula Fakultas';
    String peserta = '500 Peserta Terdaftar';
    String targetAudience = 'Mhs Nasional';
    String deskripsi =
        'Seminar tahunan yang menghadirkan pakar industri digital dan kecerdasan buatan untuk menginspirasi mahasiswa di era transformasi teknologi.';
    String tanggalMulaiText = '12 November 2026, 08:30 WIB';
    String tanggalSelesaiText = '12 November 2026, 16:00 WIB';
    String lokasiLengkapText =
        'Aula Utama Fakultas Teknik, Gedung A Lantai 3, Kampus Pusat';
    IconData eventIcon = Icons.terminal_rounded;

    if (judul.toLowerCase().contains('futsal')) {
      kategoriUpper = 'OLAHRAGA & KOMPETISI';
      kategori = 'Olahraga';
      tanggal = '05 Des 2026';
      lokasi = 'GOR Kampus';
      peserta = '320 Peserta Terdaftar';
      targetAudience = 'Mhs Universitas';
      deskripsi =
          'Turnamen futsal bergengsi antar fakultas se-universitas untuk memperebutkan Piala Bergilir Rektor dan total hadiah puluhan juta rupiah.';
      tanggalMulaiText = '05 Desember 2026, 08:00 WIB';
      tanggalSelesaiText = '07 Desember 2026, 18:00 WIB';
      lokasiLengkapText =
          'Gedung Olahraga (GOR) Kampus Utama, Lapangan Futsal A & B';
      eventIcon = Icons.sports_soccer_rounded;
    } else if (judul.toLowerCase().contains('budaya')) {
      kategoriUpper = 'SENI & KEBUDAYAAN';
      kategori = 'Seni & Budaya';
      tanggal = '28 Nov 2026';
      lokasi = 'Lapangan Utama';
      peserta = '1.500 Peserta Terdaftar';
      targetAudience = 'Umum & Mhs';
      deskripsi =
          'Perayaan keragaman budaya nusantara dengan pertunjukan seni tari tradisional, pameran busana daerah, dan kuliner khas dari berbagai provinsi di Indonesia.';
      tanggalMulaiText = '28 November 2026, 09:00 WIB';
      tanggalSelesaiText = '30 November 2026, 22:00 WIB';
      lokasiLengkapText =
          'Lapangan Utama Kampus Pusat, Panggung Terbuka & Area Bazaar';
      eventIcon = Icons.theater_comedy_rounded;
    } else if (judul.toLowerCase().contains('ui/ux') ||
        judul.toLowerCase().contains('design') ||
        judul.toLowerCase().contains('workshop')) {
      kategoriUpper = 'DESAIN & KREATIF';
      kategori = 'Workshop';
      tanggal = '18 Des 2026';
      lokasi = 'Lab Komputer 3';
      peserta = '120 Peserta Terdaftar';
      targetAudience = 'Mhs Desain & IT';
      deskripsi =
          'Pelatihan intensif perancangan produk digital interaktif menggunakan Figma dan generative AI untuk mahasiswa dan penggiat desain pemula.';
      tanggalMulaiText = '18 Desember 2026, 09:00 WIB';
      tanggalSelesaiText = '18 Desember 2026, 16:30 WIB';
      lokasiLengkapText =
          'Lab Komputer Gedung C Lantai 2, Kampus Pusat Universitas';
      eventIcon = Icons.draw_rounded;
    }

    // Jika objek EventModel backend tersedia, gunakan data riilnya
    if (widget.event != null) {
      if (widget.event!.kategori.isNotEmpty) {
        kategori = widget.event!.kategori;
        kategoriUpper = kategori.toUpperCase();
      }
      if (widget.event!.tanggalMulai.isNotEmpty) {
        tanggal = widget.event!.tanggalMulai;
        tanggalMulaiText = '${widget.event!.tanggalMulai}, 08:30 WIB';
      }
      if (widget.event!.tanggalSelesai.isNotEmpty) {
        tanggalSelesaiText = '${widget.event!.tanggalSelesai}, 16:00 WIB';
      }
      if (widget.event!.lokasi.isNotEmpty) {
        lokasi = widget.event!.lokasi;
        lokasiLengkapText = widget.event!.lokasi;
      }
      if (widget.event!.deskripsi.isNotEmpty) {
        deskripsi = widget.event!.deskripsi;
      }
      if (widget.event!.estimasiPeserta > 0) {
        peserta = '${widget.event!.estimasiPeserta} Peserta Terdaftar';
      }
      if (widget.event!.targetAudiences.isNotEmpty) {
        targetAudience = widget.event!.targetAudiences.first;
      }
    } else {
      if (widget.initialTanggal != null) tanggal = widget.initialTanggal!;
      if (widget.initialLokasi != null) lokasi = widget.initialLokasi!;
      if (widget.initialKategori != null) kategori = widget.initialKategori!;
    }

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
          'Detail Event',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: Color(0xFF0F172A),
              size: 20,
            ),
            tooltip: 'Edit Event',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditEventScreen(
                    event: widget.event,
                    initialJudul: judul,
                    initialDeskripsi: deskripsi,
                    initialTanggalMulai: tanggalMulaiText,
                    initialTanggalSelesai: tanggalSelesaiText,
                    initialLokasi: lokasiLengkapText,
                    initialKategori: kategori,
                    initialTarget: targetAudience,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TOP SUMMARY CARD (Identitas, 2x2 Grid + Kuota)
            _buildSummaryCard(
              judul: judul,
              kategoriUpper: kategoriUpper,
              kategori: kategori,
              tanggal: tanggal,
              lokasi: lokasi,
              target: targetAudience,
              peserta: peserta,
              eventIcon: eventIcon,
            ),
            const SizedBox(height: 18),

            // 2. SEGMENTED TABS: [Info]  [Kebutuhan]  [Sponsor]  [Proposal]
            _buildSegmentedTabs(),
            const SizedBox(height: 16),

            // 3. TAB CONTENT (Sesuai Tab yang Aktif)
            _buildActiveTabContent(
              deskripsi: deskripsi,
              tanggalMulaiText: tanggalMulaiText,
              tanggalSelesaiText: tanggalSelesaiText,
              lokasiLengkapText: lokasiLengkapText,
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  // 1. Top Summary Card
  Widget _buildSummaryCard({
    required String judul,
    required String kategoriUpper,
    required String kategori,
    required String tanggal,
    required String lokasi,
    required String target,
    required String peserta,
    required IconData eventIcon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Baris: Ikon Squircle + [TEKNOLOGI & SAINS / Judul Event]
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(eventIcon, color: const Color(0xFF2563EB), size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kategoriUpper,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2563EB),
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      judul,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 2x2 Info Grid
          Row(
            children: [
              // Box 1: Tanggal
              Expanded(
                child: _buildInfoGridBox(
                  icon: Icons.calendar_today_outlined,
                  iconColor: const Color(0xFF3B82F6),
                  label: 'Tanggal',
                  value: tanggal,
                ),
              ),
              const SizedBox(width: 10),
              // Box 2: Lokasi
              Expanded(
                child: _buildInfoGridBox(
                  icon: Icons.location_on_outlined,
                  iconColor: const Color(0xFFEA580C),
                  label: 'Lokasi',
                  value: lokasi,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Box 3: Kategori
              Expanded(
                child: _buildInfoGridBox(
                  icon: Icons.category_outlined,
                  iconColor: const Color(0xFF6366F1),
                  label: 'Kategori',
                  value: kategori,
                ),
              ),
              const SizedBox(width: 10),
              // Box 4: Target
              Expanded(
                child: _buildInfoGridBox(
                  icon: Icons.groups_outlined,
                  iconColor: const Color(0xFF3B82F6),
                  label: 'Target',
                  value: target,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Box Full-Width: Estimasi Kuota
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6FB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.assignment_ind_outlined,
                  size: 20,
                  color: Color(0xFFEA580C),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estimasi Kuota',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      peserta,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
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

  Widget _buildInfoGridBox({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. Segmented Tab Bar: [Info]  [Kebutuhan]  [Sponsor]  [Proposal]
  Widget _buildSegmentedTabs() {
    final tabs = ['Info', 'Kebutuhan', 'Sponsor', 'Proposal'];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: tabs.map((t) {
          final isSelected = _activeTab == t;
          return Expanded(
            child: InkWell(
              onTap: () {
                setState(() => _activeTab = t);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2F65F6) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  t,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF475569),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 3. Tab Content
  Widget _buildActiveTabContent({
    required String deskripsi,
    required String tanggalMulaiText,
    required String tanggalSelesaiText,
    required String lokasiLengkapText,
  }) {
    if (_activeTab == 'Info') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // DESKRIPSI
            _buildDetailSectionLabel('DESKRIPSI'),
            const SizedBox(height: 6),
            Text(
              deskripsi,
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF334155),
                height: 1.5,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 16),

            // TANGGAL MULAI
            _buildDetailSectionLabel('TANGGAL MULAI'),
            const SizedBox(height: 6),
            Text(
              tanggalMulaiText,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 16),

            // TANGGAL SELESAI
            _buildDetailSectionLabel('TANGGAL SELESAI'),
            const SizedBox(height: 6),
            Text(
              tanggalSelesaiText,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 16),

            // LOKASI
            _buildDetailSectionLabel('LOKASI'),
            const SizedBox(height: 6),
            Text(
              lokasiLengkapText,
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF334155),
                height: 1.4,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    }

    if (_activeTab == 'Kebutuhan') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Kebutuhan Sponsorship (Modul 2)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${_kebutuhanList.length} Item',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ..._kebutuhanList.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildNeedItem(
                  item.deskripsi,
                  item.jenisKebutuhan,
                  item.satuanKeterangan ?? 'Estimasi: Rp ${item.nilaiEstimasi.toInt()}',
                  item.status,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Tombol Buka Layar Tambah Kebutuhan Event
            InkWell(
              onTap: _navigateToAddKebutuhan,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFBFDBFE), width: 1.2),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline_rounded,
                      color: Color(0xFF2563EB),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Tambah Kebutuhan Event',
                      style: TextStyle(
                        color: Color(0xFF2563EB),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_activeTab == 'Sponsor') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rekomendasi Sponsor Teratas (Modul 3)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            SizedBox(height: 12),
            Text(
              'Berdasarkan kategori "Seminar" dan target "Mhs Nasional", terdapat 3 calon sponsor dengan tingkat kecocokan tinggi.',
              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.4),
            ),
          ],
        ),
      );
    }

    // Tab Proposal
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Proposal Terhubung (2)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(height: 10),
          Text(
            '• PT Telkom Indonesia (Status: Accepted)\n• Bank Nagari (Status: Accepted)',
            style: TextStyle(fontSize: 13, height: 1.6, color: Color(0xFF334155)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSectionLabel(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF64748B),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildNeedItem(String name, String type, String value, String status) {
    final isTerbuka = status == 'Terbuka';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 2),
              Text('$type • $value', style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isTerbuka ? const Color(0xFFEFF6FF) : const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: isTerbuka ? const Color(0xFF2563EB) : const Color(0xFF059669),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
