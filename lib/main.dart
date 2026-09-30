import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme/app_colors.dart';
import 'routes/app_routes.dart';
import 'models/app_state.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/catatan_form_screen.dart';
import 'models/item.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AppState())],
      child: MaterialApp(
        title: 'SPONTAN',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Poppins',
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ).copyWith(primary: AppColors.primary, surface: AppColors.surface),
        ),
        initialRoute: AppRoutes.onboarding,
        routes: {
          AppRoutes.onboarding: (_) => const OnboardingScreen(),
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.home: (_) => const HomeScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.detail) {
            final item = settings.arguments as Item;
            return MaterialPageRoute<void>(
              builder: (_) => DetailScreen(item: item),
              settings: settings,
            );
          }
          if (settings.name == AppRoutes.catatanForm) {
            return MaterialPageRoute<String>(
              builder: (_) => const CatatanFormScreen(),
              settings: settings,
            );
          }
          return null;
        },
      ),
    );
  }
}
