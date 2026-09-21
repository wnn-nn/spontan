import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/event_model.dart';

/// Warna dan label untuk setiap status event.
Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'open':
      return const Color(0xFF16A34A); // hijau
    case 'draft':
      return const Color(0xFFCA8A04); // kuning
    case 'closed':
      return AppColors.textSecondary; // abu
    default:
      return AppColors.textSecondary;
  }
}

Color _statusBg(String status) {
  switch (status.toLowerCase()) {
    case 'open':
      return const Color(0xFFDCFCE7);
    case 'draft':
      return const Color(0xFFFEF9C3);
    case 'closed':
      return AppColors.border;
    default:
      return AppColors.border;
  }
}

/// Card event horizontal — menampilkan judul, tanggal, dan status badge.
class EventCard extends StatelessWidget {
  final EventModel event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Status Badge ───────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusBg(event.status),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              event.status,
              style: AppTextStyles.badge.copyWith(
                color: _statusColor(event.status),
              ),
            ),
          ),

          const Spacer(),

          // ─── Judul Event ─────────────────────────────────────────────
          Text(
            event.title,
            style: AppTextStyles.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 6),

          // ─── Tanggal ─────────────────────────────────────────────────
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 12,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(event.date, style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }
}
