import 'package:flutter/material.dart';

class AppColors {
  // Warna Utama (Brand, Tombol, AppBar)
  static const Color primary = Color(0xFF2563EB); // Tombol utama, appbar, ikon aktif
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFFEFF6FF); // Background chip kategori aktif
  static const Color primarySurface = Color(0xFFDBEAFE);

  // Aksen
  static const Color accent = Color(0xFF3B82F6);
  static const Color accentIndigo = Color(0xFF4F46E5);
  static const Color accentOrange = Color(0xFFF97316);

  // Background & Kartu
  static const Color background = Color(0xFFF8FAFC); // Latar belakang layar
  static const Color surface = Colors.white; // Background kartu event & form
  static const Color surfaceMuted = Color(0xFFF1F5F9); // Background kolom input teks
  static const Color border = Color(0xFFE2E8F0); // Garis tepi input & kartu
  static const Color borderLight = Color(0xFFF1F5F9);

  // Warna Teks
  static const Color textPrimary = Color(0xFF0F172A); // Judul & teks tebal
  static const Color textSecondary = Color(0xFF64748B); // Keterangan & deskripsi
  static const Color textMuted = Color(0xFF94A3B8); // Teks hint / placeholder

  // Status & Notifikasi
  static const Color success = Color(0xFF10B981); // SnackBar sukses
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color error = Color(0xFFEF4444); // Pesan error validasi
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);

  // Badge Status Event
  static const Color draftBadge = Color(0xFF64748B);
  static const Color draftBadgeBg = Color(0xFFE2E8F0);
  static const Color activeBadge = Color(0xFF2563EB);
  static const Color activeBadgeBg = Color(0xFFDBEAFE);
}
