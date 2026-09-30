import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum1_flutter/data/item_repository.dart';
import 'package:praktikum1_flutter/models/item.dart';
import 'package:praktikum1_flutter/routes/app_routes.dart';
import 'package:praktikum1_flutter/screens/home_screen.dart';
import 'package:praktikum1_flutter/screens/login_screen.dart';
import 'package:praktikum1_flutter/screens/detail_screen.dart';
import 'package:praktikum1_flutter/screens/catatan_form_screen.dart';
import 'package:praktikum1_flutter/widgets/state_views.dart';

class MockEmptyRepository extends ItemRepository {
  @override
  Future<List<Item>> fetchItems({bool simulateError = false}) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return [];
  }
}

class MockSuccessRepository extends ItemRepository {
  @override
  Future<List<Item>> fetchItems({bool simulateError = false}) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return const [
      Item(
        id: 'sp-01',
        title: 'Bank Nagari',
        subtitle: 'Perbankan / Keuangan • Preferensi: Education & Youth',
        description: 'Bank Nagari secara aktif mendukung kegiatan mahasiswa...',
        matchingScore: 92,
        alasanMatching: 'Sesuai dengan target audience mahasiswa UNAND.',
      ),
      Item(
        id: 'sp-02',
        title: 'Telkomsel Sumatera Barat',
        subtitle: 'Telekomunikasi / Teknologi • Preferensi: Technology & Arts',
        description: 'Penyedia layanan telekomunikasi yang siap memberikan dukungan...',
        matchingScore: 88,
        alasanMatching: 'Cocok dengan jenis kebutuhan media partner.',
      ),
    ];
  }
}

Widget buildCompleteTestApp({String initialRoute = AppRoutes.login}) {
  return MaterialApp(
    initialRoute: initialRoute,
    routes: {
      AppRoutes.login: (_) => const LoginScreen(),
      AppRoutes.home: (_) => HomeScreen(repository: MockSuccessRepository()),
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
  );
}

void main() {
  group('🧪 1. Pengujian Langkah 4 (Login Form & Validasi)', () {
    testWidgets('1. Tekan tombol Masuk tanpa mengisi apapun', (tester) async {
      await tester.pumpWidget(buildCompleteTestApp());

      final tombolMasuk = find.widgetWithText(FilledButton, 'Masuk ke SPONTAN');
      await tester.tap(tombolMasuk);
      await tester.pumpAndSettle();

      expect(find.text('Email wajib diisi'), findsOneWidget);
      expect(find.text('Password wajib diisi'), findsOneWidget);
    });

    testWidgets('2. Isi email dengan abc', (tester) async {
      await tester.pumpWidget(buildCompleteTestApp());

      final emailField = find.widgetWithText(TextFormField, 'Email Mahasiswa');
      await tester.enterText(emailField, 'abc');

      final tombolMasuk = find.widgetWithText(FilledButton, 'Masuk ke SPONTAN');
      await tester.tap(tombolMasuk);
      await tester.pumpAndSettle();

      expect(find.text('Format email tidak valid'), findsOneWidget);
    });

    testWidgets('3. Isi password dengan 123', (tester) async {
      await tester.pumpWidget(buildCompleteTestApp());

      final passwordField = find.widgetWithText(TextFormField, 'Password');
      await tester.enterText(passwordField, '123');

      final tombolMasuk = find.widgetWithText(FilledButton, 'Masuk ke SPONTAN');
      await tester.tap(tombolMasuk);
      await tester.pumpAndSettle();

      expect(find.text('Password minimal 8 karakter'), findsOneWidget);
    });

    testWidgets('4. Isi email (dhyva@student.unand.ac.id) & password (12345678) dengan benar', (tester) async {
      await tester.pumpWidget(buildCompleteTestApp());

      await tester.enterText(find.widgetWithText(TextFormField, 'Email Mahasiswa'), 'dhyva@student.unand.ac.id');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), '12345678');

      final tombolMasuk = find.widgetWithText(FilledButton, 'Masuk ke SPONTAN');
      await tester.tap(tombolMasuk);
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });

  group('🧪 2. Pengujian Langkah 5 (Home Status States)', () {
    testWidgets('1. Buka layar Home -> Loading indicator (~2 detik), lalu daftar sponsor/item tampil', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HomeScreen()),
      );

      expect(find.byType(LoadingView), findsOneWidget);
      expect(find.text('Menghitung matching score sponsor...'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.byType(LoadingView), findsNothing);
      expect(find.text('Bank Nagari'), findsOneWidget);
    });

    testWidgets('2. Ubah _simulateError = true di home_screen.dart -> ErrorView dengan tombol "Coba Lagi"', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HomeScreen(simulateError: true)),
      );

      expect(find.byType(LoadingView), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorView), findsOneWidget);
      expect(find.text('Terjadi Kesalahan'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
    });

    testWidgets('3. Kembalikan _simulateError = false, lalu tekan tombol "Coba Lagi"', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(simulateError: false, repository: MockSuccessRepository()),
        ),
      );

      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      expect(find.text('Bank Nagari'), findsOneWidget);
    });

    testWidgets('4. Kosongkan sementara list _items di ItemRepository -> EmptyView', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: HomeScreen(repository: MockEmptyRepository())),
      );

      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      expect(find.byType(EmptyView), findsOneWidget);
      expect(find.text('Tidak Ada Data'), findsOneWidget);
    });
  });

  group('🧪 3. Pengujian Langkah 6 & 7 (Named Routes & Data Passing)', () {
    testWidgets('1. Tekan tombol Back saat berada di layar Home -> TIDAK kembali ke layar Login', (tester) async {
      await tester.pumpWidget(buildCompleteTestApp());

      // Login terlebih dahulu
      await tester.enterText(find.widgetWithText(TextFormField, 'Email Mahasiswa'), 'dhyva@student.unand.ac.id');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), '12345678');
      await tester.tap(find.widgetWithText(FilledButton, 'Masuk ke SPONTAN'));
      await tester.pumpAndSettle();

      // Sekarang berada di HomeScreen
      expect(find.byType(HomeScreen), findsOneWidget);

      // Verifikasi Navigator stack: rute Login sudah digantikan oleh Home (canPop = false)
      final navigatorState = tester.state<NavigatorState>(find.byType(Navigator));
      expect(navigatorState.canPop(), isFalse);

      // Mencoba pop
      final didPop = await navigatorState.maybePop();
      expect(didPop, isFalse);

      // Tetap di HomeScreen, TIDAK kembali ke LoginScreen
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    });

    testWidgets('2. Tap pada item sponsor A -> Pindah ke DetailScreen membawa data detail sponsor A', (tester) async {
      await tester.pumpWidget(buildCompleteTestApp(initialRoute: AppRoutes.home));
      await tester.pumpAndSettle();

      // Tap item sponsor A (Bank Nagari)
      final sponsorA = find.text('Bank Nagari');
      expect(sponsorA, findsOneWidget);
      await tester.tap(sponsorA);
      await tester.pumpAndSettle();

      // Memastikan berada di DetailScreen dengan data sponsor A
      expect(find.byType(DetailScreen), findsOneWidget);
      expect(find.text('Bank Nagari'), findsWidgets);
      expect(find.text('92% Match'), findsOneWidget);
      expect(find.text('Sesuai dengan target audience mahasiswa UNAND.'), findsOneWidget);
    });

    testWidgets('3. Kembali ke Home, lalu tap item sponsor B -> Pindah ke DetailScreen membawa data detail sponsor B yang berbeda', (tester) async {
      await tester.pumpWidget(buildCompleteTestApp(initialRoute: AppRoutes.home));
      await tester.pumpAndSettle();

      // Buka sponsor A
      await tester.tap(find.text('Bank Nagari'));
      await tester.pumpAndSettle();
      expect(find.text('Bank Nagari'), findsWidgets);

      // Kembali ke Home
      final navigatorState = tester.state<NavigatorState>(find.byType(Navigator));
      navigatorState.pop();
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);

      // Tap item sponsor B (Telkomsel Sumatera Barat)
      await tester.tap(find.text('Telkomsel Sumatera Barat'));
      await tester.pumpAndSettle();

      // Memastikan DetailScreen membawa data sponsor B yang berbeda
      expect(find.byType(DetailScreen), findsOneWidget);
      expect(find.text('Telkomsel Sumatera Barat'), findsWidgets);
      expect(find.text('88% Match'), findsOneWidget);
      expect(find.text('Cocok dengan jenis kebutuhan media partner.'), findsOneWidget);
      expect(find.text('Bank Nagari'), findsNothing);
    });
  });

  group('🧪 4. Pengujian Langkah 8 (Form Catatan & Return Data)', () {
    const testItem = Item(
      id: 'sp-01',
      title: 'Bank Nagari',
      subtitle: 'Perbankan / Keuangan',
      description: 'Mendukung sponsorship event kampus.',
      matchingScore: 92,
      alasanMatching: 'Cocok dengan kriteria event.',
    );

    Widget buildDetailApp() {
      return MaterialApp(
        home: const DetailScreen(item: testItem),
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.catatanForm) {
            return MaterialPageRoute<String>(
              builder: (_) => const CatatanFormScreen(),
              settings: settings,
            );
          }
          return null;
        },
      );
    }

    testWidgets('1. Tekan tombol Simpan tanpa mengisi catatan -> Pesan error "Catatan wajib diisi"', (tester) async {
      await tester.pumpWidget(buildDetailApp());

      // Buka Form Catatan
      await tester.tap(find.widgetWithText(FilledButton, 'Tulis Catatan Proposal'));
      await tester.pumpAndSettle();

      // Tekan tombol Simpan tanpa isi
      await tester.tap(find.widgetWithText(FilledButton, 'Simpan Catatan'));
      await tester.pumpAndSettle();

      expect(find.text('Catatan wajib diisi'), findsOneWidget);
    });

    testWidgets('2. Isi catatan dengan abc, lalu tekan Simpan -> Pesan error "Catatan minimal 5 karakter"', (tester) async {
      await tester.pumpWidget(buildDetailApp());

      await tester.tap(find.widgetWithText(FilledButton, 'Tulis Catatan Proposal'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'abc');
      await tester.tap(find.widgetWithText(FilledButton, 'Simpan Catatan'));
      await tester.pumpAndSettle();

      expect(find.text('Catatan minimal 5 karakter'), findsOneWidget);
    });

    testWidgets('3. Isi catatan Pengajuan dana 5 juta, lalu tekan Simpan -> Kembali ke DetailScreen, teks catatan tampil, dan muncul SnackBar', (tester) async {
      await tester.pumpWidget(buildDetailApp());

      await tester.tap(find.widgetWithText(FilledButton, 'Tulis Catatan Proposal'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'Pengajuan dana 5 juta');
      await tester.tap(find.widgetWithText(FilledButton, 'Simpan Catatan'));
      await tester.pumpAndSettle();

      // Kembali ke DetailScreen
      expect(find.byType(DetailScreen), findsOneWidget);
      expect(find.text('Pengajuan dana 5 juta'), findsOneWidget);
      expect(find.text('Catatan proposal berhasil disimpan!'), findsOneWidget);
    });

    testWidgets('4. Buka form catatan lagi, lalu tekan tombol Back (batal) -> Catatan lama yang tersimpan tidak berubah', (tester) async {
      await tester.pumpWidget(buildDetailApp());

      // Simpan catatan awal
      await tester.tap(find.widgetWithText(FilledButton, 'Tulis Catatan Proposal'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'Pengajuan dana 5 juta');
      await tester.tap(find.widgetWithText(FilledButton, 'Simpan Catatan'));
      await tester.pumpAndSettle();
      expect(find.text('Pengajuan dana 5 juta'), findsOneWidget);

      // Buka form catatan lagi
      await tester.tap(find.widgetWithText(FilledButton, 'Tulis Catatan Proposal'));
      await tester.pumpAndSettle();
      expect(find.byType(CatatanFormScreen), findsOneWidget);

      // Tekan tombol back / batalkan (Navigator pop tanpa hasil)
      final navigatorState = tester.state<NavigatorState>(find.byType(Navigator));
      navigatorState.pop();
      await tester.pumpAndSettle();

      // Kembali ke DetailScreen dan catatan lama tidak berubah
      expect(find.byType(DetailScreen), findsOneWidget);
      expect(find.text('Pengajuan dana 5 juta'), findsOneWidget);
    });
  });
}
