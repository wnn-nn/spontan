const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');
require('dotenv').config();

async function initDatabase() {
  const host = process.env.DB_HOST || 'localhost';
  const user = process.env.DB_USER || 'root';
  const password = process.env.DB_PASSWORD || '';
  const port = process.env.DB_PORT ? parseInt(process.env.DB_PORT) : 3306;
  const dbName = process.env.DB_NAME || 'spontan_db';

  console.log(`[InitDB] Menghubungkan ke MySQL di ${host}:${port}...`);
  let connection;
  try {
    connection = await mysql.createConnection({ host, user, password, port });
    console.log('[InitDB] Berhasil terhubung ke server MySQL.');

    // 1. Buat Database jika belum ada
    await connection.query(`CREATE DATABASE IF NOT EXISTS \`${dbName}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;`);
    console.log(`[InitDB] Database \`${dbName}\` siap.`);

    await connection.query(`USE \`${dbName}\`;`);

    // 2. Buat Tabel users
    await connection.query(`
      CREATE TABLE IF NOT EXISTS users (
        id_user INT AUTO_INCREMENT PRIMARY KEY,
        nama VARCHAR(100) NOT NULL,
        email VARCHAR(100) NOT NULL UNIQUE,
        password_hash VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      ) ENGINE=InnoDB;
    `);
    console.log('[InitDB] Tabel `users` siap.');

    // 3. Buat Tabel events (dengan poster_event sesuai PRD v1.1 Modul 1)
    await connection.query(`
      CREATE TABLE IF NOT EXISTS events (
        id_event INT AUTO_INCREMENT PRIMARY KEY,
        id_pembuat INT NOT NULL,
        judul VARCHAR(150) NOT NULL,
        deskripsi TEXT NOT NULL,
        tanggal_mulai DATE NOT NULL,
        tanggal_selesai DATE NOT NULL,
        lokasi VARCHAR(150) NOT NULL,
        kategori VARCHAR(50) NOT NULL,
        estimasi_peserta INT NOT NULL,
        poster_event VARCHAR(255) NULL,
        status ENUM('draft', 'aktif', 'selesai') DEFAULT 'draft',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (id_pembuat) REFERENCES users(id_user) ON DELETE CASCADE
      ) ENGINE=InnoDB;
    `);

    // Pastikan kolom poster_event ada jika tabel sudah terbuat sebelumnya
    const [columns] = await connection.query(`
      SELECT COLUMN_NAME 
      FROM INFORMATION_SCHEMA.COLUMNS 
      WHERE TABLE_SCHEMA = ? AND TABLE_NAME = 'events' AND COLUMN_NAME = 'poster_event'
    `, [dbName]);

    if (columns.length === 0) {
      await connection.query(`ALTER TABLE events ADD COLUMN poster_event VARCHAR(255) NULL AFTER estimasi_peserta;`);
      console.log('[InitDB] Kolom `poster_event` ditambahkan ke tabel `events`.');
    }
    console.log('[InitDB] Tabel `events` siap.');

    // 4. Buat Tabel event_target_audiences
    await connection.query(`
      CREATE TABLE IF NOT EXISTS event_target_audiences (
        id INT AUTO_INCREMENT PRIMARY KEY,
        id_event INT NOT NULL,
        target_audience VARCHAR(50) NOT NULL,
        UNIQUE KEY unique_event_audience (id_event, target_audience),
        FOREIGN KEY (id_event) REFERENCES events(id_event) ON DELETE CASCADE
      ) ENGINE=InnoDB;
    `);
    console.log('[InitDB] Tabel `event_target_audiences` siap.');

    // 5. Seed Test User jika belum ada
    const [existing] = await connection.query('SELECT id_user FROM users WHERE email = ?', ['dhyva@student.unand.ac.id']);
    if (existing.length === 0) {
      const hash = await bcrypt.hash('password123', 10);
      await connection.query(
        'INSERT INTO users (nama, email, password_hash) VALUES (?, ?, ?)',
        ['Dhyva Aulia Hendri', 'dhyva@student.unand.ac.id', hash]
      );
      console.log('[InitDB] Seed user dibuat: dhyva@student.unand.ac.id (password: password123)');
    }

    console.log('✅ Inisialisasi Database SPONTAN Berhasil Selesai!');
  } catch (error) {
    console.error('❌ Gagal inisialisasi database:', error.message);
  } finally {
    if (connection) await connection.end();
  }
}

if (require.main === module) {
  initDatabase();
}

module.exports = initDatabase;
