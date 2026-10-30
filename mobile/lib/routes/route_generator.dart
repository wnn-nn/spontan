import 'package:flutter/material.dart';

import '../models/event_model.dart';
import '../models/matching_score_model.dart';
import '../models/proposal_model.dart';
import '../models/sponsor_model.dart';
import '../screens/create_event_screen.dart';
import '../screens/daftar_kebutuhan_screen.dart';
import '../screens/edit_event_screen.dart';
import '../screens/event_detail_screen.dart';
import '../screens/event_list_screen.dart';
import '../screens/form_kebutuhan_screen.dart';
import '../screens/login_screen.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/proposal_detail_screen.dart';
import '../screens/register_screen.dart';
import '../screens/saved_sponsors_screen.dart';
import '../screens/sponsor_detail_screen.dart';
import 'app_routes.dart';

/// Generator rute terpusat untuk aplikasi SPONTAN.
///
/// Digunakan sebagai nilai [MaterialApp.onGenerateRoute].
/// Mempertahankan semua rute Modul 1 (Anggun) dan menambahkan
/// rute Modul 2 ([AppRoutes.kebutuhan] dan [AppRoutes.kebutuhanTambah]).
///
/// Rute Modul 1 yang sudah ada tidak diubah; screen Modul 1 tetap
/// dapat digunakan melalui [Navigator.push] dengan [MaterialPageRoute]
/// seperti sebelumnya maupun melalui [Navigator.pushNamed].
class RouteGenerator {
  RouteGenerator._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ── Modul 1 (Anggun) ────────────────────────────────────────────────────

      case AppRoutes.main:
        return MaterialPageRoute(
          builder: (_) => const MainNavigationScreen(),
          settings: settings,
        );

      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case AppRoutes.register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
          settings: settings,
        );

      case AppRoutes.eventList:
        return MaterialPageRoute(
          builder: (_) => const EventListScreen(),
          settings: settings,
        );

      case AppRoutes.eventDetail:
        final event = settings.arguments as EventModel?;
        return MaterialPageRoute(
          builder: (_) => EventDetailScreen(event: event),
          settings: settings,
        );

      case AppRoutes.createEvent:
        return MaterialPageRoute(
          builder: (_) => const CreateEventScreen(),
          settings: settings,
        );

      case AppRoutes.editEvent:
        final event = settings.arguments as EventModel?;
        return MaterialPageRoute(
          builder: (_) => EditEventScreen(event: event),
          settings: settings,
        );

      // ── Modul 2 — Kebutuhan Sponsorship ─────────────────────────────────────

      case AppRoutes.kebutuhan:
        // Argumen wajib: objek EventModel.
        final event = settings.arguments as EventModel;
        return MaterialPageRoute(
          builder: (_) => DaftarKebutuhanScreen(event: event),
          settings: settings,
        );

      case AppRoutes.kebutuhanTambah:
        // Argumen wajib: objek EventModel.
        final event = settings.arguments as EventModel;
        return MaterialPageRoute(
          builder: (_) => FormKebutuhanScreen(event: event),
          settings: settings,
        );

      // ── Modul 3 — Matching, Rekomendasi & Tracking ───────────────────────────

      case AppRoutes.sponsorDetail:
        if (settings.arguments is SponsorModel) {
          final sponsor = settings.arguments as SponsorModel;
          return MaterialPageRoute(
            builder: (_) => SponsorDetailScreen(sponsor: sponsor),
            settings: settings,
          );
        } else if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => SponsorDetailScreen(
              sponsor: args['sponsor'] as SponsorModel,
              score: args['score'] as MatchingScoreModel?,
              event: args['event'] as EventModel?,
            ),
            settings: settings,
          );
        }
        return MaterialPageRoute(
          builder: (_) => _RouteNotFoundScreen(routeName: settings.name),
          settings: settings,
        );

      case AppRoutes.proposalDetail:
        final proposal = settings.arguments as ProposalModel;
        return MaterialPageRoute(
          builder: (_) => ProposalDetailScreen(proposal: proposal),
          settings: settings,
        );

      case AppRoutes.savedSponsors:
        return MaterialPageRoute(
          builder: (_) => const SavedSponsorsScreen(),
          settings: settings,
        );

      // ── Fallback ─────────────────────────────────────────────────────────────

      default:
        return MaterialPageRoute(
          builder: (_) => _RouteNotFoundScreen(routeName: settings.name),
          settings: settings,
        );
    }
  }
}

/// Halaman fallback yang ditampilkan ketika rute tidak dikenali.
///
/// Hanya muncul jika ada nama rute yang salah ketik; tidak terekspos ke pengguna
/// dalam kondisi normal.
class _RouteNotFoundScreen extends StatelessWidget {
  final String? routeName;

  const _RouteNotFoundScreen({this.routeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Halaman Tidak Ditemukan')),
      body: Center(
        child: Text(
          'Rute "${routeName ?? 'unknown'}" tidak terdaftar.',
          style: const TextStyle(fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
