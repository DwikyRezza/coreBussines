// ============================================================
// FEATURE: Notifications — Recent Alerts Page
// lib/features/notifications/presentation/pages/recent_alerts_page.dart
// ============================================================

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class RecentAlertsPage extends StatelessWidget {
  const RecentAlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        titleSpacing: AppSpacing.pagePadding,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=11'),
              backgroundColor: AppColors.surfaceContainer,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'CoreBusiness',
              style: AppTypography.textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.primary),
            onPressed: () {},
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding, vertical: AppSpacing.md),
        children: [
          Text(
            'Recent Alerts',
            style: AppTypography.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A202C),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Today Group
          Text(
            'Today',
            style: AppTypography.textTheme.titleMedium?.copyWith(color: const Color(0xFF4A5568)),
          ),
          const SizedBox(height: AppSpacing.md),
          _AlertCard(
            title: 'Low Stock Alert',
            time: '10:42 AM',
            description: 'Whey Protein Isolate (Vanilla) is running low. Only 4 units remaining in inventory.',
            icon: Icons.warning_amber_rounded,
            iconColor: const Color(0xFFC53030), // Red
            iconBgColor: const Color(0xFFFED7D7),
          ),
          const SizedBox(height: 12),
          _AlertCard(
            title: 'Export Complete',
            time: '09:15 AM',
            description: 'Q3 Financial Report has been successfully exported and is ready to download.',
            icon: Icons.check_circle_outline_rounded,
            iconColor: const Color(0xFF0D47A1), // Blue
            iconBgColor: const Color(0xFFE3F2FD),
          ),
          const SizedBox(height: 12),
          _AlertCard(
            title: 'Staff Meeting',
            time: '08:00 AM',
            description: 'Upcoming weekly alignment meeting in 30 minutes. Please review the agenda.',
            icon: Icons.notifications_none_rounded,
            iconColor: const Color(0xFF4A5568), // Grey
            iconBgColor: const Color(0xFFEDF2F7),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Yesterday Group
          Text(
            'Yesterday',
            style: AppTypography.textTheme.titleMedium?.copyWith(color: const Color(0xFF4A5568)),
          ),
          const SizedBox(height: AppSpacing.md),
          _AlertCard(
            title: 'Performance Insight',
            time: 'Yesterday',
            description: 'Member retention rate has improved by 4.2% this month compared to the previous period.',
            icon: Icons.lightbulb_outline_rounded,
            iconColor: const Color(0xFF9C4221), // Deep Orange/Brown
            iconBgColor: const Color(0xFFFEEBC8), // Light Orange
          ),
          const SizedBox(height: 12),
          _AlertCard(
            title: 'Equipment Maintenance',
            time: 'Yesterday',
            description: 'Scheduled maintenance for Treadmill Section A has been completed.',
            icon: Icons.notifications_none_rounded,
            iconColor: const Color(0xFF4A5568),
            iconBgColor: const Color(0xFFEDF2F7),
          ),
          const SizedBox(height: 100), // Bottom padding
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final String title;
  final String time;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  const _AlertCard({
    required this.title,
    required this.time,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF1A202C))),
                    Text(time, style: AppTypography.textTheme.labelSmall?.copyWith(color: const Color(0xFF718096))),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF4A5568),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
