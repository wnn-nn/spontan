import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _handleLogin() {
    // TODO: validasi & auth logic lewat Provider
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 48),

              // ─── Logo & Brand ─────────────────────────────────────────
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text('SPONTAN', style: AppTextStyles.brand),

              const SizedBox(height: 40),

              // ─── Judul ────────────────────────────────────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Masuk ke akunmu', style: AppTextStyles.title),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Selamat datang kembali!',
                  style: AppTextStyles.bodySecondary,
                ),
              ),

              const SizedBox(height: 24),

              // ─── Email Field ──────────────────────────────────────────
              AuthTextField(
                controller: _emailCtrl,
                hintText: 'Alamat Email',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 12),

              // ─── Password Field ───────────────────────────────────────
              AuthTextField(
                controller: _passCtrl,
                hintText: 'Password',
                isPassword: true,
                prefixIcon: Icons.lock_outline,
              ),

              const SizedBox(height: 8),

              // ─── Lupa Password ────────────────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 36),
                  ),
                  child: Text('Lupa password?', style: AppTextStyles.caption),
                ),
              ),

              const SizedBox(height: 16),

              // ─── Tombol Masuk ─────────────────────────────────────────
              PrimaryButton(
                label: 'Masuk',
                onPressed: _handleLogin,
              ),

              const SizedBox(height: 20),

              // ─── Link Daftar ──────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Belum punya akun? ',
                    style: AppTextStyles.caption,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Daftar',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
