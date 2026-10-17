const express = require('express');
const cors = require('cors');
require('dotenv').config();

const authRoutes = require('./routes/authRoutes');
const referenceRoutes = require('./routes/referenceRoutes');
const eventRoutes = require('./routes/eventRoutes');

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware Global
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Logging sederhana untuk development
app.use((req, res, next) => {
  console.log(`[${new Date().toLocaleTimeString()}] ${req.method} ${req.originalUrl}`);
  next();
});

// Root endpoint
app.get('/', (req, res) => {
  res.status(200).json({
    status: 'ok',
    message: '🚀 SPONTAN Backend REST API siap digunakan!',
    endpoints: {
      health: '/api/health',
      auth: '/api/auth',
      events: '/api/events',
      referenceData: '/api/reference-data'
    }
  });
});

const pool = require('./config/database');

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.status(200).json({
    status: 'ok',
    message: 'Backend SPONTAN berjalan dengan baik.',
    time: new Date().toISOString()
  });
});

// Debug / Viewer Database MySQL Laragon
app.get('/api/debug/db', async (req, res) => {
  try {
    const [users] = await pool.query('SELECT id_user, nama, email, created_at FROM users');
    const [events] = await pool.query('SELECT * FROM events ORDER BY id_event DESC');
    const [audiences] = await pool.query('SELECT * FROM event_target_audiences');

    res.status(200).json({
      success: true,
      database: process.env.DB_NAME || 'spontan_db',
      host: `${process.env.DB_HOST || 'localhost'}:${process.env.DB_PORT || 3306}`,
      timestamp: new Date().toISOString(),
      counts: {
        users: users.length,
        events: events.length,
        audiences: audiences.length
      },
      data: {
        users,
        events,
        event_target_audiences: audiences
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal membaca database Laragon: ' + error.message
    });
  }
});

// Routing API
app.use('/api/auth', authRoutes);
app.use('/api/reference-data', referenceRoutes);
app.use('/api/events', eventRoutes);

// 404 Route Handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: `Endpoint ${req.originalUrl} tidak ditemukan di server SPONTAN.`
  });
});

// Global Error Handler
app.use((err, req, res, next) => {
  console.error('Unhandled Server Error:', err);
  res.status(500).json({
    success: false,
    message: 'Terjadi kesalahan internal pada server.',
    error: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

app.listen(PORT, () => {
  console.log(`===============================================`);
  console.log(`🚀 SPONTAN Backend API running on port ${PORT}`);
  console.log(`📡 URL: http://localhost:${PORT}`);
  console.log(`===============================================`);
});

module.exports = app;
