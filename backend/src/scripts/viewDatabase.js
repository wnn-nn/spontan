const pool = require('../config/database');

async function viewDatabase() {
  console.log('\n===============================================================');
  console.log('       🔍 LOG MONITOR DATABASE MYSQL (LARAGON) - SPONTAN       ');
  console.log('===============================================================\n');

  try {
    // 1. Cek Koneksi
    const [dbInfo] = await pool.query('SELECT DATABASE() AS db, VERSION() AS version');
    console.log(`📌 Terhubung ke Database : ${dbInfo[0].db || 'spontan_db'}`);
    console.log(`📌 Versi MySQL           : ${dbInfo[0].version}`);
    console.log(`📌 Host & Port           : ${process.env.DB_HOST || 'localhost'}:${process.env.DB_PORT || 3306}`);
    console.log('---------------------------------------------------------------\n');

    // 2. Daftar Tabel
    const [tables] = await pool.query('SHOW TABLES');
    console.log(`📑 Total Tabel Ditemukan: ${tables.length}`);
    tables.forEach((t, i) => {
      const tableName = Object.values(t)[0];
      console.log(`   ${i + 1}. ${tableName}`);
    });
    console.log('');

    // 3. Tabel Users
    console.log('---------------------------------------------------------------');
    console.log('👤 TABEL: users');
    console.log('---------------------------------------------------------------');
    const [users] = await pool.query(
      'SELECT id_user, nama, email, created_at FROM users ORDER BY id_user ASC'
    );
    if (users.length === 0) {
      console.log('   (Belum ada data user tersimpan)\n');
    } else {
      console.table(users);
    }

    // 4. Tabel Events
    console.log('---------------------------------------------------------------');
    console.log('🎪 TABEL: events');
    console.log('---------------------------------------------------------------');
    const [events] = await pool.query(
      `SELECT id_event, id_pembuat, judul, kategori, estimasi_peserta, 
              DATE_FORMAT(tanggal_mulai, '%Y-%m-%d') AS tgl_mulai, 
              DATE_FORMAT(tanggal_selesai, '%Y-%m-%d') AS tgl_selesai, 
              lokasi, status, poster_event, created_at 
       FROM events 
       ORDER BY id_event ASC`
    );
    if (events.length === 0) {
      console.log('   (Belum ada data event tersimpan)\n');
    } else {
      console.table(events);
    }

    // 5. Tabel Event Target Audiences
    console.log('---------------------------------------------------------------');
    console.log('🎯 TABEL: event_target_audiences');
    console.log('---------------------------------------------------------------');
    const [audiences] = await pool.query(
      'SELECT id, id_event, target_audience FROM event_target_audiences ORDER BY id_event ASC'
    );
    if (audiences.length === 0) {
      console.log('   (Belum ada target audience tersimpan)\n');
    } else {
      console.table(audiences);
    }

    console.log('===============================================================');
    console.log(`✅ Log selesai pada: ${new Date().toLocaleString('id-ID')}`);
    console.log('===============================================================\n');
  } catch (error) {
    console.error('\n❌ GAGAL MENGHUBUNGI DATABASE LARAGON:');
    console.error(`Pesan Error: ${error.message}`);
    console.error('\n👉 Tips Periksa:');
    console.error('1. Pastikan aplikasi Laragon telah dibuka dan tombol "Start All" berwarna hijau.');
    console.error('2. Pastikan service MySQL di Laragon aktif di port 3306.');
    console.error('3. Pastikan database "spontan_db" telah dibuat di HeidiSQL/phpMyAdmin Laragon.\n');
  } finally {
    process.exit(0);
  }
}

viewDatabase();
