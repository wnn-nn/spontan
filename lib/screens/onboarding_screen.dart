import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/primary_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.onboardingBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            // Batasi lebar maksimal sesuai ukuran layar mobile Figma (428px)
            constraints: const BoxConstraints(maxWidth: 428),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),

                  // ─── Main Hero Graphic Container (~40% Visual Weight) ───
                  SizedBox(
                    height: 290,
                    width: double.infinity,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Ambient Energy Radiance: Crimson
                        Positioned(
                          left: 10,
                          top: 10,
                          child: Container(
                            width: 256,
                            height: 256,
                            decoration: const BoxDecoration(
                              color: AppColors.radianceCrimson,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),

                        // Ambient Energy Radiance: Soft Slate
                        Positioned(
                          right: 10,
                          bottom: 10,
                          child: Container(
                            width: 192,
                            height: 192,
                            decoration: const BoxDecoration(
                              color: AppColors.radianceBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),

                        // Main Illustration Card
                        Container(
                          width: 320,
                          height: 240,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(13),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(20),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.bolt_rounded,
                                  size: 44,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'SPONTAN',
                                style: AppTextStyles.brand,
                              ),
                            ],
                          ),
                        ),

                        // Tactile Micro-Badge: Verified Campus Deal
                        Positioned(
                          right: 0,
                          bottom: 10,
                          child: Transform.rotate(
                            angle: 2 * (math.pi / 180), // 2deg
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(25),
                                    blurRadius: 6,
                                    offset: const Offset(0, 4),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withAlpha(25),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withAlpha(26),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.verified_rounded,
                                        size: 14,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'VERIFIED',
                                        style: AppTextStyles.onboardingBadgeTag,
                                      ),
                                      Text(
                                        'Campus Deal',
                                        style: AppTextStyles.onboardingBadgeTitle,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ─── Onboarding Visual Steps Indicator ─────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 28,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.indicatorInactive,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.indicatorInactive,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ─── Core Messaging ────────────────────────────────────
                  Text(
                    'Cari Sponsor\nJadi Lebih Mudah',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.onboardingHeading,
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: Text(
                      'Temukan sponsor yang tepat untuk eventmu dalam beberapa langkah mudah.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.onboardingDescription,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // ─── Bottom Interactive Zone ───────────────────────────
                  PrimaryButton(
                    label: 'Mulai',
                    height: 60,
                    borderRadius: 16,
                    hasGlowShadow: true,
                    textStyle: AppTextStyles.onboardingButton,
                    trailingIcon: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                  ),

                  const SizedBox(height: 16),

                  // ─── Secondary Navigation Link ─────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sudah punya akun? ',
                        style: AppTextStyles.onboardingLinkText,
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/login'),
                        child: Text(
                          'Masuk',
                          style: AppTextStyles.onboardingLinkAction,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
