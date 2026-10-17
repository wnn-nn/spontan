import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/services/api_service.dart';
import '../core/services/auth_storage.dart';
import '../models/event_model.dart';
import '../models/user_model.dart';
import 'create_event_screen.dart';
import 'event_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int tabIndex)? onNavigateToTab;

  const HomeScreen({super.key, this.onNavigateToTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? _currentUser;
  List<EventModel> _myEvents = [];
  bool _isLoading = false;
  String _selectedSponsorFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final user = await AuthStorage.getUser();
    List<EventModel> events = [];
    try {
      events = await ApiService.getMyEvents();
    } catch (_) {
      // Offline fallback
    }

    if (mounted) {
      setState(() {
        _currentUser = user;
        _myEvents = events;
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToCreateEvent() async {
    final created = await Navigator.push<EventModel>(
      context,
      MaterialPageRoute(builder: (context) => const CreateEventScreen()),
    );
    if (created != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Event "${created.judul}" berhasil dibuat!'),
          backgroundColor: AppColors.success,
        ),
      );
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = _currentUser?.nama.isNotEmpty == true
        ? _currentUser!.nama.split(' ').first
        : 'Dhyva';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: const Color(0xFF2563EB),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: LinearProgressIndicator(
                      backgroundColor: Color(0xFFF1F5F9),
                      color: Color(0xFF2563EB),
                      minHeight: 2,
                    ),
                  ),

                // 1. TOP BAR (Logo Squircle di kiri, Avatar Biru di kanan)
                _buildTopBar(),
                const SizedBox(height: 22),

                // 2. GREETING (Halo, Dhyva / Kelola sponsorship eventmu hari ini.)
                _buildGreeting(userName),
                const SizedBox(height: 20),

                // 3. PROPOSAL AKTIF CARD (Kotak Putih, "3 Proposal Aktif", 4 Kolom Status)
                _buildProposalAktifCard(),
                const SizedBox(height: 26),

                // 4. EVENT SAYA (Header + "Lihat semua" + Kartu Horizontal)
                _buildEventSayaSection(),
                const SizedBox(height: 26),

                // 5. REKOMENDASI SPONSOR (Filter Pills + List Sponsor A, B, C)
                _buildRekomendasiSponsorSection(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 1. Top Bar
  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo Squircle
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.all(7),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.bolt_rounded,
                color: Color(0xFF2563EB),
                size: 26,
              ),
            ),
          ),
        ),

        // Avatar Bulat Biru di kanan
        InkWell(
          onTap: () => widget.onNavigateToTab?.call(4),
          borderRadius: BorderRadius.circular(22),
          child: Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  // 2. Greeting
  Widget _buildGreeting(String userName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Halo, $userName',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Kelola sponsorship eventmu hari ini.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // 3. Proposal Aktif Card
  Widget _buildProposalAktifCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Baris Atas: [3] Proposal Aktif
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: const Text(
                  '3',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2563EB),
                    height: 1.0,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Text(
                'Proposal Aktif',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 18),

          // Baris Bawah: 1 Draft, 1 Pending, 2 Accepted, 1 Rejected
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricColumn('1', 'Draft', const Color(0xFF0F172A), const Color(0xFF64748B)),
              _buildMetricColumn('1', 'Pending', const Color(0xFFD97706), const Color(0xFFD97706)),
              _buildMetricColumn('2', 'Accepted', const Color(0xFF16A34A), const Color(0xFF16A34A)),
              _buildMetricColumn('1', 'Rejected', const Color(0xFFDC2626), const Color(0xFFDC2626)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(String count, String label, Color countColor, Color labelColor) {
    return InkWell(
      onTap: () => widget.onNavigateToTab?.call(2),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: countColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: labelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4. Event Saya
  Widget _buildEventSayaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Event Saya',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            InkWell(
              onTap: () => widget.onNavigateToTab?.call(1),
              child: const Text(
                'Lihat semua',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2563EB),
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xFF2563EB),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Horizontal Event Cards
        SizedBox(
          height: 165,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              // Card 1: Seminar Teknologi Kampus
              _buildEventCard(
                title: 'Seminar Teknologi Kampus',
                dateRange: '12 - 14 Nov 2026',
                status: 'Aktif',
                proposalCount: '2 proposal',
                icon: Icons.desktop_windows_outlined,
              ),
              const SizedBox(width: 12),

              // Card 2: Festival Budaya Nusantara
              _buildEventCard(
                title: 'Festival Budaya Nusantara',
                dateRange: '28 - 30 Nov 2026',
                status: 'Aktif',
                proposalCount: '5 proposal',
                icon: Icons.music_note_rounded,
              ),
              const SizedBox(width: 12),

              // Kartu dinamis dari backend jika ada
              ..._myEvents
                  .where((e) =>
                      e.judul != 'Seminar Teknologi Kampus' &&
                      e.judul != 'Festival Budaya Nusantara')
                  .map((e) => Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: _buildEventCard(
                          title: e.judul,
                          dateRange: e.tanggalMulai == e.tanggalSelesai
                              ? e.tanggalMulai
                              : '${e.tanggalMulai} - ${e.tanggalSelesai}',
                          status: e.status == 'aktif' ? 'Aktif' : 'Draft',
                          proposalCount: '${e.estimasiPeserta} Peserta',
                          icon: Icons.event_available_rounded,
                          event: e,
                        ),
                      )),

              // Tombol Tambah Event
              InkWell(
                onTap: _navigateToCreateEvent,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFFEFF6FF),
                        child: Icon(Icons.add, color: Color(0xFF2563EB), size: 20),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Buat Event',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
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
    );
  }

  Widget _buildEventCard({
    required String title,
    required String dateRange,
    required String status,
    required String proposalCount,
    required IconData icon,
    EventModel? event,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailScreen(
              event: event,
              initialJudul: title,
              initialTanggal: dateRange.contains(' - ')
                  ? dateRange.split(' - ').first
                  : dateRange,
              initialLokasi: title.toLowerCase().contains('budaya')
                  ? 'Lapangan Utama'
                  : 'Aula Fakultas',
              initialKategori: title.toLowerCase().contains('budaya')
                  ? 'Seni & Budaya'
                  : 'Seminar',
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 215,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Ikon Squircle
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: const Color(0xFF2563EB), size: 20),
            ),
            const SizedBox(height: 10),

            // Judul Event
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),

            // Tanggal
            Text(
              dateRange,
              style: const TextStyle(
                fontSize: 11.5,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 10),

            // Baris Bawah: [● Aktif]  2 proposal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F4EA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF137333),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        status,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF137333),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  proposalCount,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 5. Rekomendasi Sponsor
  Widget _buildRekomendasiSponsorSection() {
    final filters = ['Semua', 'Dana', 'Barang', 'Media Partner'];

    final sponsors = [
      {
        'nama': 'Sponsor A',
        'initials': 'SA',
        'industri': 'Industri Teknologi',
        'score': '100%',
        'percent': 1.0,
        'label': 'Tinggi',
        'kriteria': '3 dari 3 kriteria terpenuhi',
        'avatarBg': const Color(0xFFEFF6FF),
        'avatarColor': const Color(0xFF2563EB),
        'category': 'Dana',
      },
      {
        'nama': 'Sponsor B',
        'initials': 'SB',
        'industri': 'Fintech & Perbankan',
        'score': '85%',
        'percent': 0.85,
        'label': 'Tinggi',
        'kriteria': '2 dari 3 kriteria terpenuhi',
        'avatarBg': const Color(0xFFFFF1EB),
        'avatarColor': const Color(0xFFF97316),
        'category': 'Dana',
      },
      {
        'nama': 'Sponsor C',
        'initials': 'SC',
        'industri': 'Konsumsi & FnB',
        'score': '70%',
        'percent': 0.70,
        'label': 'Sedang',
        'kriteria': '1 dari 3 kriteria terpenuhi',
        'avatarBg': const Color(0xFFE6F9F0),
        'avatarColor': const Color(0xFF10B981),
        'category': 'Barang',
      },
    ];

    final filtered = _selectedSponsorFilter == 'Semua'
        ? sponsors
        : sponsors.where((s) => s['category'] == _selectedSponsorFilter).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rekomendasi Sponsor',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),

        // Filter Pills: Semua (Biru), Dana, Barang, Media Partner (Putih ber-border)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: filters.map((f) {
              final isSelected = _selectedSponsorFilter == f;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedSponsorFilter = f;
                    });
                  },
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Text(
                      f,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFF334155),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 14),

        // List Kartu Sponsor (SA, SB, SC)
        Column(
          children: (filtered.isEmpty ? sponsors : filtered).map((sp) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Circle Avatar Initials (SA / SB / SC)
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: sp['avatarBg'] as Color,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      sp['initials'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: sp['avatarColor'] as Color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Info Sponsor (Nama, Industri, Kriteria)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sp['nama'] as String,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          sp['industri'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sp['kriteria'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Kolom Kanan: Persentase (100%), Garis Progress, Label (Tinggi)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        sp['score'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Mini Progress Bar
                      Container(
                        width: 58,
                        height: 3.5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: sp['percent'] as double,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        sp['label'] as String,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
