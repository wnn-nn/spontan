import 'package:flutter_test/flutter_test.dart';
import 'package:spontan/core/utils/description_validator.dart';
import 'package:spontan/core/utils/title_validator.dart';
import 'package:spontan/models/event_model.dart';

void main() {
  group('EventModel Unit Test (PRD v1.1 Modul 1)', () {
    test('EventModel serializes and deserializes correctly with poster_event', () {
      final json = {
        'id_event': 101,
        'id_pembuat': 1,
        'judul': 'Seminar Nasional AI & Cloud 2026',
        'deskripsi': 'Seminar edukasi teknologi terkini untuk mahasiswa dan umum di Auditorium Unand.',
        'tanggal_mulai': '2026-11-20',
        'tanggal_selesai': '2026-11-20',
        'lokasi': 'Auditorium Universitas Andalas',
        'kategori': 'Seminar',
        'estimasi_peserta': 350,
        'poster_event': 'https://images.unsplash.com/photo-1540575467063-178a50c2df87',
        'status': 'draft',
        'target_audiences': ['Mahasiswa', 'Masyarakat Umum'],
        'created_at': '2026-10-17T08:00:00.000Z',
      };

      final event = EventModel.fromJson(json);

      expect(event.idEvent, 101);
      expect(event.idPembuat, 1);
      expect(event.judul, 'Seminar Nasional AI & Cloud 2026');
      expect(event.deskripsi.length >= 20, isTrue);
      expect(event.kategori, 'Seminar');
      expect(event.estimasiPeserta, 350);
      expect(event.posterEvent, 'https://images.unsplash.com/photo-1540575467063-178a50c2df87');
      expect(event.status, 'draft');
      expect(event.targetAudiences, contains('Mahasiswa'));
      expect(event.targetAudiences, contains('Masyarakat Umum'));

      final mappedJson = event.toJson();
      expect(mappedJson['id_event'], 101);
      expect(mappedJson['poster_event'], 'https://images.unsplash.com/photo-1540575467063-178a50c2df87');
      expect(mappedJson['estimasi_peserta'], 350);
    });

    test('EventModel handles null poster_event gracefully', () {
      final json = {
        'id_event': 102,
        'id_pembuat': 1,
        'judul': 'Lomba Pemrograman Web Nasional',
        'deskripsi': 'Kompetisi coding mahasiswa seluruh Indonesia tingkat perguruan tinggi.',
        'tanggal_mulai': '2026-12-01',
        'tanggal_selesai': '2026-12-02',
        'lokasi': 'Gedung FTI Unand',
        'kategori': 'Kompetisi',
        'estimasi_peserta': 50,
        'status': 'draft',
        'target_audiences': ['Mahasiswa'],
      };

      final event = EventModel.fromJson(json);
      expect(event.posterEvent, isNull);
      expect(event.toJson()['poster_event'], isNull);
    });
  });

  group('PRD v1.1 Modul 1 Validation Rules Unit Test', () {
    test('Rule 1: Judul minimal 5 dan maksimal 100 karakter serta lolos TitleValidator', () {
      expect(TitleValidator.validate(''), isNotNull);
      expect(TitleValidator.validate('   '), isNotNull);
      expect(TitleValidator.validate('AI'), equals('Judul event minimal harus 5 karakter'));
      expect(TitleValidator.validate('Seminar AI Unand 2026'), isNull);
      expect(TitleValidator.validate('A' * 101), equals('Judul event maksimal 100 karakter'));

      // Deteksi simbol saja seperti titik 5 buah (.....)
      expect(TitleValidator.validate('.....'), equals('Judul event harus berupa nama kegiatan yang jelas (minimal 3 huruf alfabet)'));
      expect(TitleValidator.validate('----'), equals('Judul event minimal harus 5 karakter'));
      expect(TitleValidator.validate('------'), equals('Judul event harus berupa nama kegiatan yang jelas (minimal 3 huruf alfabet)'));
      expect(TitleValidator.validate('!@#\$%^&*()'), equals('Judul event harus berupa nama kegiatan yang jelas (minimal 3 huruf alfabet)'));

      // Deteksi karakter berulang (spam)
      expect(TitleValidator.validate('aaaaaaa'), equals('Judul event tidak boleh berisi karakter berulang tanpa makna'));

      // Deteksi ketikan acak tanpa huruf vokal
      expect(TitleValidator.validate('dfghjkl'), isNotNull);

      // Deteksi kombinasi huruf dan angka acak (gibberish seperti hgu7te823t9i)
      expect(TitleValidator.validate('hgu7te823t9i'), contains('Judul event mengandung kata kombinasi acak'));

      // Deteksi kata acak tanpa makna / deretan vokal tak wajar (seperti gueiuqoeqvb)
      expect(TitleValidator.validate('gueiuqoeqvb'), contains('Judul event mengandung deretan vokal acak'));

      // Deteksi keyboard row smash (qwertyuiop, asdfghjkl)
      expect(TitleValidator.validate('qwertyuiop'), contains('Judul event terindikasi ketikan deretan tombol keyboard acak'));
      expect(TitleValidator.validate('asdfghjkl'), contains('Judul event terindikasi ketikan deretan tombol keyboard acak'));

      // Deteksi pengulangan pola acak (abcabcabc)
      expect(TitleValidator.validate('abcabcabc'), contains('Judul event mengandung pengulangan pola acak'));

      // Deteksi deretan konsonan tak wajar (brtpmkq)
      expect(TitleValidator.validate('brtpmkq'), contains('Judul event mengandung deretan konsonan acak'));
      
      // Judul yang valid dan wajar
      expect(TitleValidator.validate('Workshop UI/UX Unand 2026'), isNull);
      expect(TitleValidator.validate('Festival Musik & Budaya 2026'), isNull);
      expect(TitleValidator.validate('Compfest 2026'), isNull);
      expect(TitleValidator.validate('SPONTAN Campus Roadshow'), isNull);
    });

    test('Rule 2: Deskripsi minimal 20, maksimal 3000, serta lolos DescriptionValidator (Anti-Spam & Placeholder)', () {
      expect(DescriptionValidator.validate(''), isNotNull);
      expect(DescriptionValidator.validate('   '), isNotNull);
      expect(DescriptionValidator.validate('Singkat'), equals('Deskripsi event minimal harus 20 karakter'));
      expect(DescriptionValidator.validate('A' * 3001), equals('Deskripsi event maksimal 3000 karakter'));

      // Deteksi teks placeholder bawaan
      expect(DescriptionValidator.validate('Jelaskan tujuan kegiatan, latar belakang, dan manfaat bagi peserta...'), contains('placeholder'));
      expect(DescriptionValidator.validate('rincian penjelasan kegiatan, tujuan, dan latar belakang'), contains('placeholder'));

      // Deteksi huruf berulang berlebihan (misal: aaaaaa, zzzzzzzzz)
      expect(DescriptionValidator.validate('zzzzzzzzzzzzzzzzzzzzzzzzzzzzzz'), contains('karakter berulang'));

      // Deteksi keyboard smash (misal: asdfghjkl, qwertyqwerty)
      expect(DescriptionValidator.validate('asdfghjkl asdfghjkl asdfghjkl'), contains('keyboard'));
      expect(DescriptionValidator.validate('qwertyqwerty qwertyqwerty'), contains('keyboard'));

      // Deteksi kata berulang berturut-turut (misal: seminar seminar seminar)
      expect(DescriptionValidator.validate('seminar seminar seminar seminar seminar seminar'), contains('pengulangan kata'));

      // Deskripsi valid dan bermakna
      expect(DescriptionValidator.validate('Seminar teknologi AI dan cloud computing untuk mahasiswa Universitas Andalas.'), isNull);
      expect(DescriptionValidator.validate('Kompetisi ide bisnis dan inovasi startup digital antar perguruan tinggi se-Indonesia.'), isNull);
    });

    test('Rule 3: Estimasi peserta integer >= 10', () {
      String? validatePeserta(String? val) {
        if (val == null || val.trim().isEmpty) {
          return 'Estimasi peserta wajib diisi';
        }
        final num = int.tryParse(val.trim());
        if (num == null || num < 10) {
          return 'Estimasi peserta minimal 10 orang';
        }
        return null;
      }

      expect(validatePeserta(''), isNotNull);
      expect(validatePeserta('0'), equals('Estimasi peserta minimal 10 orang'));
      expect(validatePeserta('9'), equals('Estimasi peserta minimal 10 orang'));
      expect(validatePeserta('-5'), equals('Estimasi peserta minimal 10 orang'));
      expect(validatePeserta('10'), isNull);
      expect(validatePeserta('250'), isNull);
    });

    test('Rule 4: Tanggal mulai tidak boleh sebelum hari ini dan tanggal selesai >= tanggal mulai', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final tomorrow = today.add(const Duration(days: 1));

      String? validateDates(DateTime? start, DateTime? end) {
        if (start == null) return 'Tanggal mulai wajib dipilih.';
        if (end == null) return 'Tanggal selesai wajib dipilih.';
        final startDay = DateTime(start.year, start.month, start.day);
        if (startDay.isBefore(today)) {
          return 'Tanggal mulai tidak boleh sebelum hari ini.';
        }
        if (end.isBefore(start)) {
          return 'Tanggal selesai tidak boleh lebih awal daripada tanggal mulai.';
        }
        return null;
      }

      expect(validateDates(yesterday, tomorrow), equals('Tanggal mulai tidak boleh sebelum hari ini.'));
      expect(validateDates(tomorrow, today), equals('Tanggal selesai tidak boleh lebih awal daripada tanggal mulai.'));
      expect(validateDates(today, today), isNull);
      expect(validateDates(today, tomorrow), isNull);
    });
  });
}
