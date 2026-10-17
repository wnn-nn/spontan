import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'title': 'Proposal Diterima!',
        'message': 'PT Telkom Indonesia telah menyetujui proposal untuk event "Seminar Teknologi Kampus".',
        'time': '10 menit yang lalu',
        'type': 'accepted',
        'isUnread': true,
      },
      {
        'title': 'Proposal Diterima!',
        'message': 'Bank Nagari menyetujui permohonan sponsor Dana kategori Silver.',
        'time': '2 jam yang lalu',
        'type': 'accepted',
        'isUnread': true,
      },
      {
        'title': 'Pengingat Deadline H-7',
        'message': 'Event "Seminar Teknologi Kampus" akan berlangsung dalam 7 hari. Segera konfirmasi kebutuhan logistik.',
        'time': '1 hari yang lalu',
        'type': 'reminder',
        'isUnread': false,
      },
      {
        'title': 'Rekomendasi Sponsor Baru',
        'message': 'Ditemukan 3 sponsor dengan kecocokan tinggi (>75%) untuk event "Festival Budaya Nusantara".',
        'time': '2 hari yang lalu',
        'type': 'matching',
        'isUnread': false,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final notif = notifications[index];
          final isUnread = notif['isUnread'] as bool;
          final type = notif['type'] as String;

          IconData icon;
          Color iconColor;
          Color iconBg;

          if (type == 'accepted') {
            icon = Icons.check_circle_rounded;
            iconColor = const Color(0xFF059669);
            iconBg = const Color(0xFFD1FAE5);
          } else if (type == 'reminder') {
            icon = Icons.access_time_filled_rounded;
            iconColor = const Color(0xFFD97706);
            iconBg = const Color(0xFFFEF3C7);
          } else {
            icon = Icons.auto_awesome_rounded;
            iconColor = AppColors.primary;
            iconBg = AppColors.primaryLight;
          }

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isUnread ? AppColors.surface : AppColors.surface.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isUnread ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isUnread ? 0.03 : 0.01),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            notif['title'] as String,
                            style: TextStyle(
                              fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            notif['time'] as String,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notif['message'] as String,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
