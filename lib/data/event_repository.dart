import '../models/event_model.dart';
import '../models/event_note_model.dart';

/// Sumber data sementara untuk event SPONTAN.
/// Data mengikuti event yang saat ini ditampilkan di Home.
class EventRepository {
  // Catatan tersimpan selama proses aplikasi berjalan.
  static final Map<String, EventNote> _notesByEvent = {};

  static String _eventKey(EventModel event) => '${event.title}|${event.date}';

  static EventNote? noteFor(EventModel event) => _notesByEvent[_eventKey(event)];

  static void saveNote(EventModel event, EventNote note) {
    _notesByEvent[_eventKey(event)] = note;
  }
  static const List<EventModel> _events = [
    EventModel(title: 'Concert Jazz Night', date: '25 Okt 2026', status: 'Open'),
    EventModel(title: 'Seminar Digital 2026', date: '10 Nov 2026', status: 'Draft'),
    EventModel(title: 'Festival Kopi Nusantara', date: '02 Des 2026', status: 'Closed'),
  ];

  /// Mengambil daftar event dummy.
  /// [simulateError] bisa dipakai nanti untuk menguji tampilan error.
  Future<List<EventModel>> fetchEvents({bool simulateError = false}) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (simulateError) {
      throw Exception('Gagal memuat data. Periksa koneksi internet.');
    }
    return _events;
  }
}


