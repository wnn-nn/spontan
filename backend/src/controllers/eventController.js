const pool = require('../config/database');
const { CATEGORIES, TARGET_AUDIENCES } = require('../constants/referenceData');
const { validateEventTitle } = require('../utils/titleValidator');
const { validateEventDescription } = require('../utils/descriptionValidator');

// 1. GET /api/events - Ambil daftar event milik pengguna yang login
async function getMyEvents(req, res) {
  try {
    const userId = req.user.id_user;

    const [events] = await pool.query(
      `SELECT e.id_event, e.id_pembuat, e.judul, e.deskripsi, 
              DATE_FORMAT(e.tanggal_mulai, '%Y-%m-%d') AS tanggal_mulai, 
              DATE_FORMAT(e.tanggal_selesai, '%Y-%m-%d') AS tanggal_selesai, 
              e.lokasi, e.kategori, e.estimasi_peserta, e.poster_event, e.status, e.created_at
       FROM events e
       WHERE e.id_pembuat = ?
       ORDER BY e.created_at DESC`,
      [userId]
    );

    if (events.length === 0) {
      return res.status(200).json({
        success: true,
        data: []
      });
    }

    // Ambil target audiences untuk seluruh event ini
    const eventIds = events.map(e => e.id_event);
    const [audiences] = await pool.query(
      `SELECT id_event, target_audience 
       FROM event_target_audiences 
       WHERE id_event IN (?)`,
      [eventIds]
    );

    // Petakan audiences ke masing-masing event
    const audienceMap = {};
    for (const item of audiences) {
      if (!audienceMap[item.id_event]) {
        audienceMap[item.id_event] = [];
      }
      audienceMap[item.id_event].push(item.target_audience);
    }

    const result = events.map(event => ({
      ...event,
      target_audiences: audienceMap[event.id_event] || []
    }));

    return res.status(200).json({
      success: true,
      data: result
    });
  } catch (error) {
    console.error('Error getMyEvents:', error);
    return res.status(500).json({
      success: false,
      message: 'Gagal mengambil daftar event dari database.'
    });
  }
}

// 2. POST /api/events - Buat Event Baru secara Atomik
async function createEvent(req, res) {
  const userId = req.user.id_user;
  const {
    judul,
    deskripsi,
    kategori,
    target_audiences,
    tanggal_mulai,
    tanggal_selesai,
    lokasi,
    estimasi_peserta,
    poster_event
  } = req.body;

  // --- VALIDASI BACKEND (Strict validation sesuai PRD v1.1 Modul 1) ---
  const titleValidationErr = validateEventTitle(judul);
  if (titleValidationErr) {
    return res.status(400).json({ success: false, message: titleValidationErr });
  }

  const descValidationErr = validateEventDescription(deskripsi);
  if (descValidationErr) {
    return res.status(400).json({ success: false, message: descValidationErr });
  }

  if (!kategori || !CATEGORIES.includes(kategori)) {
    return res.status(400).json({
      success: false,
      message: `Kategori tidak valid. Harus salah satu dari: ${CATEGORIES.join(', ')}.`
    });
  }

  if (!Array.isArray(target_audiences) || target_audiences.length === 0) {
    return res.status(400).json({
      success: false,
      message: 'Minimal memilih satu target audience.'
    });
  }

  // Cek keabsahan setiap target audience
  const uniqueAudiences = [...new Set(target_audiences)];
  for (const aud of uniqueAudiences) {
    if (!TARGET_AUDIENCES.includes(aud)) {
      return res.status(400).json({
        success: false,
        message: `Target audience '${aud}' tidak valid.`
      });
    }
  }

  if (!tanggal_mulai || isNaN(Date.parse(tanggal_mulai))) {
    return res.status(400).json({ success: false, message: 'Tanggal mulai wajib dipilih dan harus berupa tanggal valid.' });
  }

  if (!tanggal_selesai || isNaN(Date.parse(tanggal_selesai))) {
    return res.status(400).json({ success: false, message: 'Tanggal selesai wajib dipilih dan harus berupa tanggal valid.' });
  }

  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const startDate = new Date(tanggal_mulai);
  startDate.setHours(0, 0, 0, 0);
  const endDate = new Date(tanggal_selesai);
  endDate.setHours(0, 0, 0, 0);

  // Aturan PRD v1.1 §3.1 B.5: tanggal_mulai tidak boleh sebelum hari ini
  if (startDate < today) {
    return res.status(400).json({
      success: false,
      message: 'Tanggal mulai tidak boleh sebelum hari ini.'
    });
  }

  // Aturan PRD v1.1 §3.1 B.5: tanggal_selesai >= tanggal_mulai
  if (endDate < startDate) {
    return res.status(400).json({
      success: false,
      message: 'Tanggal selesai tidak boleh lebih awal daripada tanggal mulai.'
    });
  }

  if (!lokasi || !lokasi.trim()) {
    return res.status(400).json({ success: false, message: 'Lokasi wajib diisi dan tidak boleh hanya spasi.' });
  }

  // Aturan PRD v1.1 §3.1 B.4: estimasi_peserta >= 10
  const pesertaNum = parseInt(estimasi_peserta, 10);
  if (isNaN(pesertaNum) || pesertaNum < 10) {
    return res.status(400).json({
      success: false,
      message: 'Estimasi peserta wajib diisi dengan bilangan bulat minimal 10 orang.'
    });
  }

  // Validasi opsional poster_event (PRD v1.1 §3.1 B.6)
  const posterPath = (typeof poster_event === 'string' && poster_event.trim().length > 0)
    ? poster_event.trim()
    : null;

  // --- DATABASE TRANSACTION (Penyimpanan Atomik) ---
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    // 1. Insert Event (status awal otomatis 'draft')
    const [eventResult] = await connection.query(
      `INSERT INTO events (
        id_pembuat, judul, deskripsi, tanggal_mulai, tanggal_selesai, 
        lokasi, kategori, estimasi_peserta, poster_event, status
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'draft')`,
      [
        userId,
        judul.trim(),
        deskripsi.trim(),
        tanggal_mulai,
        tanggal_selesai,
        lokasi.trim(),
        kategori,
        pesertaNum,
        posterPath
      ]
    );

    const newEventId = eventResult.insertId;

    // 2. Insert Target Audiences secara bulk
    const audienceValues = uniqueAudiences.map(aud => [newEventId, aud]);
    await connection.query(
      `INSERT INTO event_target_audiences (id_event, target_audience) VALUES ?`,
      [audienceValues]
    );

    // Commit jika seluruh query berhasil
    await connection.commit();

    const createdEvent = {
      id_event: newEventId,
      id_pembuat: userId,
      judul: judul.trim(),
      deskripsi: deskripsi.trim(),
      tanggal_mulai,
      tanggal_selesai,
      lokasi: lokasi.trim(),
      kategori,
      estimasi_peserta: pesertaNum,
      poster_event: posterPath,
      status: 'draft',
      target_audiences: uniqueAudiences,
      created_at: new Date().toISOString()
    };

    return res.status(201).json({
      success: true,
      message: 'Event berhasil dibuat.',
      data: createdEvent
    });
  } catch (err) {
    // Rollback jika terjadi kegagalan agar tidak ada data tersimpan sebagian
    await connection.rollback();
    console.error('Transaction Error pada createEvent:', err);
    return res.status(500).json({
      success: false,
      message: 'Gagal menyimpan event ke database. Transaksi dibatalkan.'
    });
  } finally {
    connection.release();
  }
}

// 3. PUT /api/events/:id - Update Event (FR-M1-03)
async function updateEvent(req, res) {
  const userId = req.user.id_user;
  const eventId = req.params.id;
  const {
    judul,
    deskripsi,
    kategori,
    target_audiences,
    tanggal_mulai,
    tanggal_selesai,
    lokasi,
    estimasi_peserta,
    status
  } = req.body;

  try {
    const [existingEvents] = await pool.query(
      'SELECT * FROM events WHERE id_event = ? AND id_pembuat = ?',
      [eventId, userId]
    );

    if (existingEvents.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Event tidak ditemukan atau bukan milik Anda.'
      });
    }

    // Aturan Bisnis FR-M1-03: Event tidak dapat diedit jika ada proposal accepted
    try {
      const [acceptedProps] = await pool.query(
        "SELECT id_proposal FROM proposals WHERE id_event = ? AND status = 'accepted' LIMIT 1",
        [eventId]
      );
      if (acceptedProps && acceptedProps.length > 0) {
        return res.status(403).json({
          success: false,
          message: 'Event tidak dapat diedit karena sudah memiliki proposal yang diterima (accepted).'
        });
      }
    } catch (_) {
      // Abaikan jika tabel proposals belum ada
    }

    // Validasi field-field
    if (judul !== undefined) {
      const err = validateEventTitle(judul);
      if (err) {
        return res.status(400).json({ success: false, message: err });
      }
    }

    if (deskripsi !== undefined) {
      const descErr = validateEventDescription(deskripsi);
      if (descErr) {
        return res.status(400).json({
          success: false,
          message: descErr
        });
      }
    }

    if (kategori !== undefined && !CATEGORIES.includes(kategori)) {
      return res.status(400).json({
        success: false,
        message: `Kategori tidak valid. Harus salah satu dari: ${CATEGORIES.join(', ')}.`
      });
    }

    let finalAudience = null;
    if (target_audiences !== undefined) {
      if (!Array.isArray(target_audiences) || target_audiences.length === 0) {
        return res.status(400).json({
          success: false,
          message: 'Minimal memilih satu target audience.'
        });
      }
      finalAudience = [...new Set(target_audiences)];
    }

    const connection = await pool.getConnection();
    try {
      await connection.beginTransaction();

      const current = existingEvents[0];
      const updatedJudul = judul !== undefined ? judul.trim() : current.judul;
      const updatedDeskripsi = deskripsi !== undefined ? deskripsi.trim() : current.deskripsi;
      const updatedKategori = kategori !== undefined ? kategori : current.kategori;
      const updatedTglMulai = tanggal_mulai !== undefined ? tanggal_mulai : current.tanggal_mulai;
      const updatedTglSelesai = tanggal_selesai !== undefined ? tanggal_selesai : current.tanggal_selesai;
      const updatedLokasi = lokasi !== undefined ? lokasi.trim() : current.lokasi;
      const updatedPeserta = estimasi_peserta !== undefined ? parseInt(estimasi_peserta) : current.estimasi_peserta;
      const updatedStatus = status !== undefined ? status : current.status;

      await connection.query(
        `UPDATE events 
         SET judul = ?, deskripsi = ?, kategori = ?, tanggal_mulai = ?, tanggal_selesai = ?, lokasi = ?, estimasi_peserta = ?, status = ?
         WHERE id_event = ? AND id_pembuat = ?`,
        [updatedJudul, updatedDeskripsi, updatedKategori, updatedTglMulai, updatedTglSelesai, updatedLokasi, updatedPeserta, updatedStatus, eventId, userId]
      );

      if (finalAudience) {
        await connection.query('DELETE FROM event_target_audiences WHERE id_event = ?', [eventId]);
        const audienceValues = finalAudience.map(aud => [eventId, aud]);
        await connection.query(
          'INSERT INTO event_target_audiences (id_event, target_audience) VALUES ?',
          [audienceValues]
        );
      }

      await connection.commit();

      return res.status(200).json({
        success: true,
        message: 'Event berhasil diperbarui.',
        data: {
          id_event: parseInt(eventId),
          judul: updatedJudul,
          deskripsi: updatedDeskripsi,
          kategori: updatedKategori,
          tanggal_mulai: updatedTglMulai,
          tanggal_selesai: updatedTglSelesai,
          lokasi: updatedLokasi,
          estimasi_peserta: updatedPeserta,
          status: updatedStatus,
          target_audiences: finalAudience || []
        }
      });
    } catch (err) {
      await connection.rollback();
      console.error('Error updateEvent transaction:', err);
      return res.status(500).json({
        success: false,
        message: 'Gagal memperbarui event di database.'
      });
    } finally {
      connection.release();
    }
  } catch (error) {
    console.error('Error updateEvent:', error);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan internal server saat update event.'
    });
  }
}

module.exports = {
  getMyEvents,
  createEvent,
  updateEvent
};
