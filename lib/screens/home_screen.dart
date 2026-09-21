import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/event_card.dart';
import '../widgets/sponsor_card.dart';
import '../widgets/top_bar.dart';
import '../models/event_model.dart';
import '../models/sponsor_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  // ─── Dummy Data ─────────────────────────────────────────────────────────
  final List<EventModel> _events = const [
    EventModel(title: 'Concert Jazz Night', date: '25 Okt 2026', status: 'Open'),
    EventModel(title: 'Seminar Digital 2026', date: '10 Nov 2026', status: 'Draft'),
    EventModel(title: 'Festival Kopi Nusantara', date: '02 Des 2026', status: 'Closed'),
  ];

  final List<SponsorModel> _sponsors = const [
    SponsorModel(
      name: 'Indofood',
      initial: 'I',
      matchScore: 92,
      reason: 'Audience cocok & engagement tinggi',
    ),
    SponsorModel(
      name: 'Telkomsel',
      initial: 'T',
      matchScore: 86,
      reason: 'Kategori event sangat relevan',
    ),
    SponsorModel(
      name: 'Bank BRI',
      initial: 'B',
      matchScore: 79,
      reason: 'Target demografi sesuai segmen',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softGray,

      // ─── Top Bar ───────────────────────────────────────────────────────
      appBar: TopBar(greeting: 'Halo, Dip 👋'),

      // ─── Body Scrollable ───────────────────────────────────────────────
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section: Event Saya ─────────────────────────────────────
            Text('Event Saya', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 12),
            SizedBox(
              height: 148,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _events.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) => EventCard(event: _events[index]),
              ),
            ),

            const SizedBox(height: 28),

            // ── Section: Rekomendasi Sponsor ────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Rekomendasi Sponsor', style: AppTextStyles.sectionTitle),
                Text(
                  'Lihat semua',
                  style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.separated(
              // Tidak boleh scroll karena sudah di dalam SingleChildScrollView
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _sponsors.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) => SponsorCard(sponsor: _sponsors[index]),
            ),
          ],
        ),
      ),

      // ─── FAB ───────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 3,
        child: const Icon(Icons.add_rounded, size: 28),
      ),

      // ─── Bottom Navigation Bar ─────────────────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: AppColors.surface,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined),
            activeIcon: Icon(Icons.event_rounded),
            label: 'Event',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            activeIcon: Icon(Icons.description_rounded),
            label: 'Proposal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications_rounded),
            label: 'Notifikasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
