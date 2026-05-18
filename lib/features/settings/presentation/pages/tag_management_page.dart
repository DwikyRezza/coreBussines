// ============================================================
// FEATURE: Settings — Tag Management Page
// lib/features/settings/presentation/pages/tag_management_page.dart
// ============================================================

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/core_app_bar.dart';

class TagManagementPage extends StatelessWidget {
  const TagManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CoreAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
            Text(
              'Tag Management',
              style: AppTypography.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A202C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Organize and categorize your system entities.',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF4A5568),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Create New Tag Button (Dashed)
            InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD).withOpacity(0.5), // Very light blue
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF63B3ED), // Light blue border
                    style: BorderStyle.solid, // Note: Flutter doesn't have native dashed border without custom painter, using solid for mockup or we can use dotted_border package if available. Falling back to solid with light color simulating the intent.
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF0D47A1)),
                    const SizedBox(width: 8),
                    Text(
                      'Create New Tag',
                      style: AppTypography.textTheme.labelLarge?.copyWith(
                        color: const Color(0xFF0D47A1),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Tag List
            _TagCard(
              title: 'Urgent',
              count: '42 associated items',
              icon: Icons.priority_high_rounded,
              iconColor: const Color(0xFFC53030),
              iconBgColor: const Color(0xFFFED7D7),
            ),
            const SizedBox(height: 16),
            _TagCard(
              title: 'Marketing',
              count: '156 associated items',
              icon: Icons.campaign_rounded,
              iconColor: const Color(0xFF2962FF),
              iconBgColor: const Color(0xFFE3F2FD),
            ),
            const SizedBox(height: 16),
            _TagCard(
              title: 'Operasional',
              count: '89 associated items',
              icon: Icons.settings_rounded,
              iconColor: const Color(0xFF4A5568),
              iconBgColor: const Color(0xFFEDF2F7),
            ),
            const SizedBox(height: 100), // Bottom shell padding
          ],
        ),
      ),
    );
  }
}

class _TagCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  const _TagCard({
    required this.title,
    required this.count,
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
          BoxShadow(color: AppColors.shadow.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
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
                Text(title, style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF1A202C))),
                const SizedBox(height: 4),
                Text(count, style: AppTypography.textTheme.bodyMedium?.copyWith(color: const Color(0xFF4A5568))),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF718096)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFC53030)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
