import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ─── Brand ─────────────────────────────────────────────────────────────
  static const TextStyle brand = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: 2.0,
  );

  // ─── Heading ───────────────────────────────────────────────────────────
  static const TextStyle headline = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // ─── Onboarding Specific Typography (from Figma/CSS) ───────────────────
  static const TextStyle onboardingHeading = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textHeading,
    height: 1.285, // 36px / 28px
    letterSpacing: -0.7,
  );

  static const TextStyle onboardingDescription = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.64, // 23px / 14px
  );

  static const TextStyle onboardingButton = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: -0.2,
    height: 1.4, // 28px / 20px
  );

  static const TextStyle onboardingBadgeTag = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
    height: 1.4,
  );

  static const TextStyle onboardingBadgeTitle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: AppColors.textHeading,
    letterSpacing: 0.24,
    height: 1.33,
  );

  static const TextStyle onboardingLinkText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.43, // 20px / 14px
  );

  static const TextStyle onboardingLinkAction = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    letterSpacing: 0.14,
    height: 1.43,
  );

  // ─── Section Title (Home sections) ─────────────────────────────────────
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // ─── Title (card title, screen title) ──────────────────────────────────
  static const TextStyle title = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // ─── Body ──────────────────────────────────────────────────────────────
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  // ─── Body Secondary (subtitle / hint) ──────────────────────────────────
  static const TextStyle bodySecondary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.6,
  );

  // ─── Caption ───────────────────────────────────────────────────────────
  static const TextStyle caption = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // ─── Button ────────────────────────────────────────────────────────────
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.3,
  );

  // ─── Badge ─────────────────────────────────────────────────────────────
  static const TextStyle badge = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );
}
