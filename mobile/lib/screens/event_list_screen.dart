import 'package:flutter/material.dart';

import '../core/services/api_service.dart';
import '../core/services/auth_storage.dart';
import '../models/event_model.dart';
import '../models/user_model.dart';
import 'create_event_screen.dart';
import 'edit_event_screen.dart';
import 'event_detail_screen.dart';

class EventListScreen extends StatefulWidget {
  final VoidCallback? onOpenProfile;

  const EventListScreen({super.key, this.onOpenProfile});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventItemData {
  final String id;
  String judul;
  String tanggal;
  String lokasi;
  String status;
  String mitra;
  IconData icon;

  _EventItemData({
    required this.id,
    required this.judul,
    required this.tanggal,
    required this.lokasi,
    required this.status,
    required this.mitra,
    required this.icon,
  });
}

class _EventListScreenState extends State<EventListScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<EventModel> _backendEvents = [];
  bool _isLoadingEvents = false;
  UserModel? _currentUser;

  // Selected Status Tab: 'Semua', 'Aktif', 'Selesai'
  String _selectedStatus = 'Semua';

  // Preset default events matching the exact UI screenshot
  late List<_EventItemData> _items;

  @override
  void initState() {
    super.initState();
    _initDefaultItems();
    _loadUserAndEvents();
  }

  void _initDefaultItems() {
    _items = [
      _EventItemData(
        id: 'EVT-001',
        judul: 'Seminar Teknologi Kampus',
        tanggal: '12 Nov 2026',
        lokasi: 'Aula Fakultas',
        status: 'Aktif',
        mitra: '2 Mitra Terhubung',
        icon: Icons.terminal_rounded,
      ),
      _EventItemData(
        id: 'EVT-002',
        judul: 'Festival Budaya Nusantara',
        tanggal: '28 Nov 2026',
        lokasi: 'Lapangan Utama',
        status: 'Aktif',
        mitra: '3 Mitra Terhubung',
        icon: Icons.theater_comedy_rounded,
      ),
      _EventItemData(
        id: 'EVT-003',
        judul: 'Kompetisi Futsal Rektor Cup',
        tanggal: '05 Des 2026',
        lokasi: 'GOR Kampus',
        status: 'Aktif',
        mitra: '3 Mitra Terhubung',
        icon: Icons.sports_soccer_rounded,
      ),
      _EventItemData(
        id: 'EVT-004',
        judul: 'Workshop UI/UX & AI Design',
        tanggal: '18 Des 2026',
        lokasi: 'Lab Komputer 3',
        status: 'Aktif',
        mitra: '2 Mitra Terhubung',
        icon: Icons.draw_rounded,
      ),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserAndEvents() async {
    final user = await AuthStorage.getUser();
    if (mounted) {
      setState(() => _currentUser = user);
    }
    await _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() => _isLoadingEvents = true);
    try {
      final list = await ApiService.getMyEvents();
      if (!mounted) return;
      setState(() {
        _backendEvents = list;
        _isLoadingEvents = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingEvents = false);
    }
  }

  // Navigasi ke Form Pembuatan Event
  Future<void> _navigateToCreateEvent() async {
    final createdEvent = await Navigator.push<EventModel>(
      context,
      MaterialPageRoute(builder: (context) => const CreateEventScreen()),
    );

    if (createdEvent != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Event "${createdEvent.judul}" berhasil dibuat!'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      // Tambahkan ke daftar tampilan
      setState(() {
        _items.insert(
          0,
          _EventItemData(
            id: 'EVT-${DateTime.now().millisecondsSinceEpoch % 1000}',
            judul: createdEvent.judul,
            tanggal: createdEvent.tanggalMulai,
            lokasi: createdEvent.lokasi,
            status: createdEvent.status == 'aktif' ? 'Aktif' : 'Draft',
            mitra: '0 Mitra Terhubung',
            icon: Icons.event_available_rounded,
          ),
        );
      });

      _fetchEvents();
    }
  }

  // Navigasi ke Detail Event Screen
  void _navigateToDetail(_EventItemData item) {
    EventModel? matched;
    try {
      matched = _backendEvents.firstWhere((e) => e.judul == item.judul);
    } catch (_) {
      matched = null;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailScreen(
          event: matched,
          initialJudul: item.judul,
          initialTanggal: item.tanggal,
          initialLokasi: item.lokasi,
          initialKategori: item.judul.toLowerCase().contains('futsal')
              ? 'Olahraga'
              : item.judul.toLowerCase().contains('budaya')
                  ? 'Seni & Budaya'
                  : item.judul.toLowerCase().contains('workshop')
                      ? 'Workshop'
                      : 'Seminar',
        ),
      ),
    );
  }

  // Navigasi ke Halaman Edit Event (FR-M1-03)
  Future<void> _navigateToEditEvent(_EventItemData item) async {
    EventModel? matched;
    try {
      matched = _backendEvents.firstWhere((e) => e.judul == item.judul);
    } catch (_) {
      matched = null;
    }

    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEventScreen(
          event: matched,
          initialJudul: item.judul,
          initialTanggalMulai: '${item.tanggal}, 08:30 WIB',
          initialTanggalSelesai: '${item.tanggal}, 16:00 WIB',
          initialLokasi: item.lokasi,
          initialKategori: item.judul.toLowerCase().contains('futsal')
              ? 'Kompetisi'
              : item.judul.toLowerCase().contains('budaya')
                  ? 'Kegiatan Organisasi'
                  : 'Seminar & Workshop',
          initialTarget: 'Mahasiswa Nasional',
          initialEstimasiPeserta: 500,
        ),
      ),
    );

    if (updated != null && mounted) {
      String newJudul = item.judul;
      String newTanggal = item.tanggal;
      String newLokasi = item.lokasi;

      if (updated is EventModel) {
        newJudul = updated.judul;
        newTanggal = updated.tanggalMulai;
        newLokasi = updated.lokasi;
      } else if (updated is Map) {
        newJudul = updated['judul'] ?? item.judul;
        final rawTgl = updated['tanggal_mulai']?.toString() ?? '';
        newTanggal = rawTgl.contains(',') ? rawTgl.split(',').first : (rawTgl.isNotEmpty ? rawTgl : item.tanggal);
        newLokasi = updated['lokasi'] ?? item.lokasi;
      }

      setState(() {
        item.judul = newJudul;
        item.tanggal = newTanggal;
        item.lokasi = newLokasi;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Event "$newJudul" berhasil diperbarui!'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      _fetchEvents();
    }
  }

  // Filter gabungan (search keyword & status filter)
  List<_EventItemData> get _filteredItems {
    final query = _searchController.text.trim().toLowerCase();
    return _items.where((item) {
      final matchesQuery = query.isEmpty ||
          item.judul.toLowerCase().contains(query) ||
          item.lokasi.toLowerCase().contains(query);

      final matchesStatus = _selectedStatus == 'Semua' ||
          item.status.toLowerCase() == _selectedStatus.toLowerCase();

      return matchesQuery && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final countSemua = _items.length;
    final countAktif = _items.where((i) => i.status == 'Aktif').length;
    final countSelesai = _items.where((i) => i.status == 'Selesai').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchEvents,
                color: const Color(0xFF2563EB),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. TOP BAR (Logo + "Daftar Event" + Avatar Biru)
                      _buildTopBar(),
                      const SizedBox(height: 18),

                      // 2. SEARCH BAR (Cari agenda atau nama kegiatan...)
                      _buildSearchBar(),
                      const SizedBox(height: 16),

                      // 3. STATUS FILTER PILLS: [Semua (4)]  [Aktif (4)]  [Selesai (0)]
                      _buildStatusFilterRow(countSemua, countAktif, countSelesai),
                      const SizedBox(height: 18),

                      // 4. DAFTAR KARTU EVENT
                      _buildEventCardsList(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            // 5. TOMBOL BESAR BIRU DI BAWAH: "Buat Event"
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _navigateToCreateEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: const Color(0xFF2563EB).withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text(
                    'Buat Event',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 1. Top Bar
  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // Logo Squircle
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.bolt_rounded,
                    color: Color(0xFF2563EB),
                    size: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Daftar Event',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),

        // Avatar Bulat Biru
        InkWell(
          onTap: widget.onOpenProfile,
          borderRadius: BorderRadius.circular(22),
          child: Tooltip(
            message: _currentUser?.nama.isNotEmpty == true
                ? _currentUser!.nama
                : 'Profil',
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
        ),
      ],
    );
  }

  // 2. Search Bar
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Cari agenda atau nama kegiatan...',
                hintStyle: TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: Color(0xFF64748B),
              size: 19,
            ),
          ),
        ],
      ),
    );
  }

  // 3. Status Filter Row: [Semua (4)]  [Aktif (4)]  [Selesai (0)]
  Widget _buildStatusFilterRow(int countSemua, int countAktif, int countSelesai) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          _buildSegmentButton('Semua', 'Semua ($countSemua)'),
          _buildSegmentButton('Aktif', 'Aktif ($countAktif)'),
          _buildSegmentButton('Selesai', 'Selesai ($countSelesai)'),
        ],
      ),
    );
  }

  Widget _buildSegmentButton(String key, String title) {
    final isSelected = _selectedStatus == key;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedStatus = key;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }

  // 4. Daftar Kartu Event
  Widget _buildEventCardsList() {
    if (_isLoadingEvents && _items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: CircularProgressIndicator(color: Color(0xFF2563EB)),
        ),
      );
    }
    final list = _filteredItems;

    if (list.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Column(
          children: [
            Icon(Icons.event_busy_rounded, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text(
              'Tidak ada event ditemukan',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: list.map((item) => _buildEventCardItem(item)).toList(),
    );
  }

  Widget _buildEventCardItem(_EventItemData item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
        children: [
          // Baris Atas: Ikon + Judul & Tanggal + Tombol Panah
          InkWell(
            onTap: () => _navigateToDetail(item),
            borderRadius: BorderRadius.circular(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Squircle Ikon Kiri
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(item.icon, color: const Color(0xFF2563EB), size: 24),
                ),
                const SizedBox(width: 14),

                // Judul & Tanggal/Lokasi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.judul,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 13,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              '${item.tanggal} • ${item.lokasi}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Tombol Panah Kanan Bulat
                InkWell(
                  onTap: () => _navigateToDetail(item),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Color(0xFF2563EB),
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Baris Bawah: [● Aktif]  2 Mitra Terhubung  Edit Event
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Pill Status: ● Aktif
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
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
                          item.status,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF137333),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Mitra Terhubung
                  Text(
                    item.mitra,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // Tautan Edit Event (Warna Coklat / Amber)
              InkWell(
                onTap: () => _navigateToEditEvent(item),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  child: Text(
                    'Edit Event',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB45309),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
