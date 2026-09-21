import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/sponsor_model.dart';

/// Card sponsor vertikal — menampilkan logo, nama, match score, alasan,
/// dan tombol "Ajukan".
class SponsorCard extends StatelessWidget {
  final SponsorModel sponsor;

  const SponsorCard({super.key, required this.sponsor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ─── Logo / Avatar ──────────────────────────────────────────
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                sponsor.initial,
                style: AppTextStyles.title.copyWith(
                  color: AppColors.primary,
                  fontSize: 20,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // ─── Info Sponsor ───────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sponsor.name, style: AppTextStyles.title),
                const SizedBox(height: 3),
                Text(
                  sponsor.reason,
                  style: AppTextStyles.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ─── Match Score + Tombol ───────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Match score badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${sponsor.matchScore}% Match',
                  style: AppTextStyles.badge.copyWith(color: AppColors.primary),
                ),
              ),

              const SizedBox(height: 10),

              // Tombol Ajukan
              SizedBox(
                height: 32,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    elevation: 0,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Ajukan',
                    style: AppTextStyles.badge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
