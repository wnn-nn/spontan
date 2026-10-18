/// Konstanta nama rute untuk seluruh halaman aplikasi SPONTAN.
///
/// Modul 1 — halaman-halaman milik Anggun:
/// [login], [register], [main], [eventList], [eventDetail],
/// [createEvent], [editEvent].
///
/// Modul 2 — halaman kebutuhan sponsorship:
/// [kebutuhan], [kebutuhanTambah].
///
/// Catatan: Navigasi antar-screen saat ini menggunakan [Navigator.push]
/// dengan [MaterialPageRoute]. Konstanta di class ini digunakan bersama
/// [RouteGenerator.onGenerateRoute] agar jalur navigasi terdokumentasi
/// dan dapat dipanggil dengan nama tanpa duplikasi string literal.
class AppRoutes {
  AppRoutes._();

  // ── Modul 1 (Anggun) ───────────────────────────────────────────────────────

  /// Halaman login.
  static const String login = '/login';

  /// Halaman registrasi akun.
  static const String register = '/register';

  /// Halaman utama setelah login (MainNavigationScreen).
  static const String main = '/';

  /// Halaman daftar event.
  static const String eventList = '/events';

  /// Halaman detail event. Argumen: [EventDetailArgs] atau [EventModel].
  static const String eventDetail = '/events/detail';

  /// Halaman buat event baru.
  static const String createEvent = '/events/create';

  /// Halaman edit event. Argumen: [EventModel].
  static const String editEvent = '/events/edit';

  // ── Modul 2 — Kebutuhan Sponsorship ───────────────────────────────────────

  /// Halaman daftar kebutuhan sponsorship untuk satu event.
  ///
  /// Argumen navigasi yang diharapkan: objek [EventModel].
  /// Gunakan [Navigator.pushNamed] dengan argumen:
  /// ```dart
  /// Navigator.pushNamed(context, AppRoutes.kebutuhan, arguments: event);
  /// ```
  static const String kebutuhan = '/kebutuhan';

  /// Halaman form tambah kebutuhan sponsorship.
  ///
  /// Argumen navigasi yang diharapkan: objek [EventModel].
  /// Gunakan [Navigator.pushNamed] dengan argumen:
  /// ```dart
  /// Navigator.pushNamed(context, AppRoutes.kebutuhanTambah, arguments: event);
  /// ```
  static const String kebutuhanTambah = '/kebutuhan/tambah';

  // ── Modul 3 — Matching, Rekomendasi & Tracking ─────────────────────────────

  /// Halaman detail profil sponsor & analisis kecocokan.
  /// Argumen: [SponsorModel] atau [Map<String, dynamic>] dengan key:
  /// 'sponsor', 'score', 'event'.
  static const String sponsorDetail = '/sponsors/detail';

  /// Halaman detail tracking proposal & pembatalan.
  /// Argumen: [ProposalModel].
  static const String proposalDetail = '/proposals/detail';

  /// Halaman daftar sponsor sasaran tersimpan (bookmark).
  static const String savedSponsors = '/sponsors/saved';
}

