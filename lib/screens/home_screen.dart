import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/event_card.dart';
import '../widgets/sponsor_card.dart';
import '../widgets/top_bar.dart';
import '../models/event_model.dart';
import '../models/sponsor_model.dart';
import '../data/event_repository.dart';
import '../widgets/state_views.dart';
import '../routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  // State loading, error, dan data Home diambil dari repository.
  final EventRepository _eventRepository = EventRepository();
  List<EventModel> _events = const [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents({bool simulateError = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final events = await _eventRepository.fetchEvents(
        simulateError: simulateError,
      );
      if (!mounted) return;
      setState(() => _events = events);
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

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

      // â”€â”€â”€ Top Bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
      appBar: TopBar(greeting: 'Halo, ${widget.userName} 👋'),

      body: _buildCurrentPage(),

      // â”€â”€â”€ FAB â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 3,
        child: const Icon(Icons.add_rounded, size: 28),
      ),

      // â”€â”€â”€ Bottom Navigation Bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

  Widget _buildCurrentPage() {
    switch (_navIndex) {
      case 1:
        return _buildFeaturePage(
          title: 'Event',
          icon: Icons.event_rounded,
          message: 'Kelola semua event kamu di sini.',
        );
      case 2:
        return _buildFeaturePage(
          title: 'Proposal',
          icon: Icons.description_rounded,
          message: 'Pantau proposal sponsorship kamu.',
        );
      case 3:
        return _buildFeaturePage(
          title: 'Notifikasi',
          icon: Icons.notifications_rounded,
          message: 'Belum ada notifikasi baru.',
        );
      case 4:
        return _buildFeaturePage(
          title: 'Profil',
          icon: Icons.person_rounded,
          message: 'Kelola informasi profil kamu.',
        );
      case 0:
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    if (_isLoading) {
      return const LoadingView();
    }
    if (_errorMessage != null) {
      return ErrorView(
        message: _errorMessage!,
        onRetry: _loadEvents,
      );
    }
    if (_events.isEmpty) {
      return const EmptyView(message: 'Belum ada event.');
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Event Saya', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 12),
          SizedBox(
            height: 148,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _events.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) => GestureDetector(
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.detail,
                  arguments: _events[index],
                ),
                child: EventCard(event: _events[index]),
              ),
            ),
          ),
          const SizedBox(height: 28),
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
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _sponsors.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) => SponsorCard(sponsor: _sponsors[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturePage({
    required String title,
    required IconData icon,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(title, style: AppTextStyles.sectionTitle),
            const SizedBox(height: 8),
            Text(message, style: AppTextStyles.caption, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}







