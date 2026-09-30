import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../models/event_note_model.dart';
import '../screens/event_detail_screen.dart';
import '../screens/event_note_form_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/not_found_screen.dart';
import '../screens/onboarding_screen.dart';

/// Konstanta route dan pembuat route bernama aplikasi.
class AppRoutes {
  AppRoutes._();

  static const String onboarding = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String detail = '/detail';
  static const String noteForm = '/note-form';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case onboarding:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const OnboardingScreen(),
        );
      case login:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );
      case home:
        final arguments = settings.arguments;
        if (arguments is String && arguments.trim().isNotEmpty) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => HomeScreen(userName: arguments),
          );
        }
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => NotFoundScreen(
            routeName: settings.name,
            message: 'Nama pengguna tidak tersedia.',
          ),
        );
      case detail:
        final arguments = settings.arguments;
        if (arguments is EventModel) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => EventDetailScreen(event: arguments),
          );
        }
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => NotFoundScreen(
            routeName: settings.name,
            message: 'Data event tidak valid.',
          ),
        );
      case noteForm:
        final arguments = settings.arguments;
        if (arguments is EventModel) {
          return MaterialPageRoute<EventNote>(
            settings: settings,
            builder: (_) => EventNoteFormScreen(event: arguments),
          );
        }
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => NotFoundScreen(
            routeName: settings.name,
            message: 'Data event untuk form catatan tidak valid.',
          ),
        );
      default:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => NotFoundScreen(routeName: settings.name),
        );
    }
  }
}

