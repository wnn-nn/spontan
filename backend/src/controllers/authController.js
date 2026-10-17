const pool = require('../config/database');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
require('dotenv').config();

const JWT_SECRET = process.env.JWT_SECRET || 'spontan_super_secret_jwt_key_unand_2026';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '7d';

// Register Pengguna Baru
async function register(req, res) {
  try {
    const { nama, email, password } = req.body;

    if (!nama || !nama.trim()) {
      return res.status(400).json({ success: false, message: 'Nama lengkap wajib diisi.' });
    }
    if (!email || !email.trim()) {
      return res.status(400).json({ success: false, message: 'Email wajib diisi.' });
    }
    if (!password || password.length < 6) {
      return res.status(400).json({ success: false, message: 'Password minimal 6 karakter.' });
    }

    const cleanEmail = email.trim().toLowerCase();

    // Cek duplikasi email
    const [existing] = await pool.query('SELECT id_user FROM users WHERE email = ?', [cleanEmail]);
    if (existing.length > 0) {
      return res.status(409).json({ success: false, message: 'Email sudah terdaftar. Silakan gunakan email lain atau login.' });
    }

    // Hash password
    const passwordHash = await bcrypt.hash(password, 10);

    // Simpan ke database
    const [result] = await pool.query(
      'INSERT INTO users (nama, email, password_hash) VALUES (?, ?, ?)',
      [nama.trim(), cleanEmail, passwordHash]
    );

    const userId = result.insertId;
    const token = jwt.sign({ id_user: userId, nama: nama.trim(), email: cleanEmail }, JWT_SECRET, {
      expiresIn: JWT_EXPIRES_IN
    });

    return res.status(201).json({
      success: true,
      message: 'Registrasi berhasil.',
      token,
      user: {
        id_user: userId,
        nama: nama.trim(),
        email: cleanEmail
      }
    });
  } catch (error) {
    console.error('Error register:', error);
    return res.status(500).json({ success: false, message: 'Terjadi kesalahan pada server saat registrasi.' });
  }
}

// Login Pengguna
async function login(req, res) {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ success: false, message: 'Email dan password wajib diisi.' });
    }

    const cleanEmail = email.trim().toLowerCase();

    const [rows] = await pool.query(
      'SELECT id_user, nama, email, password_hash FROM users WHERE email = ?',
      [cleanEmail]
    );

    if (rows.length === 0) {
      return res.status(401).json({ success: false, message: 'Email atau password salah.' });
    }

    const user = rows[0];
    const isPasswordMatch = await bcrypt.compare(password, user.password_hash);
    if (!isPasswordMatch) {
      return res.status(401).json({ success: false, message: 'Email atau password salah.' });
    }

    const token = jwt.sign(
      { id_user: user.id_user, nama: user.nama, email: user.email },
      JWT_SECRET,
      { expiresIn: JWT_EXPIRES_IN }
    );

    return res.status(200).json({
      success: true,
      message: 'Login berhasil.',
      token,
      user: {
        id_user: user.id_user,
        nama: user.nama,
        email: user.email
      }
    });
  } catch (error) {
    console.error('Error login:', error);
    return res.status(500).json({ success: false, message: 'Terjadi kesalahan pada server saat login.' });
  }
}

// Get Profile Saat Ini
async function getMe(req, res) {
  try {
    const [rows] = await pool.query(
      'SELECT id_user, nama, email, created_at FROM users WHERE id_user = ?',
      [req.user.id_user]
    );

    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Pengguna tidak ditemukan.' });
    }

    return res.status(200).json({
      success: true,
      user: rows[0]
    });
  } catch (error) {
    console.error('Error getMe:', error);
    return res.status(500).json({ success: false, message: 'Terjadi kesalahan pada server.' });
  }
}

module.exports = {
  register,
  login,
  getMe
};
