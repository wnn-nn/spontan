import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Top bar untuk HomeScreen.
/// Implements PreferredSizeWidget agar bisa dipakai sebagai appBar.
class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String greeting;
  final String? avatarUrl;

  const TopBar({
    super.key,
    required this.greeting,
    this.avatarUrl,
  });

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // ─── Greeting ─────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(greeting, style: AppTextStyles.sectionTitle),
                  Text(
                    'Temukan sponsor terbaik hari ini',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),

            // ─── Avatar ───────────────────────────────────────────────
            GestureDetector(
              onTap: () {},
              child: CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary.withAlpha(20),
                backgroundImage:
                    avatarUrl != null && avatarUrl!.isNotEmpty ? NetworkImage(avatarUrl!) : null,
                child: avatarUrl == null || avatarUrl!.isEmpty
                    ? const Icon(Icons.person_rounded, color: AppColors.primary, size: 24)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
