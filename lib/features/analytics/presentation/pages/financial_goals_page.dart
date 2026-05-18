// ============================================================
// FEATURE: Analytics — Financial Goals Page
// lib/features/analytics/presentation/pages/financial_goals_page.dart
// ============================================================

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/core_app_bar.dart';

class FinancialGoalsPage extends StatelessWidget {
  const FinancialGoalsPage({super.key});

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
              'Financial Goals',
              style: AppTypography.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A202C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track your monthly targets and limits.',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF4A5568),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Omzet Target
            _GoalCard(
              title: 'Omzet Target',
              subtitle: 'November 2023',
              icon: Icons.trending_up_rounded,
              iconBgColor: const Color(0xFFE3F2FD),
              iconColor: const Color(0xFF0D47A1),
              currentAmount: 'Rp 42.500.000',
              targetAmount: 'Rp 50.000.000',
              progress: 0.85,
              progressColor: const Color(0xFF0D47A1),
              progressBgColor: const Color(0xFFEDF2F7),
              statusPill: 'On Track',
              statusIcon: Icons.check_circle_outline_rounded,
              statusColor: const Color(0xFF0D47A1),
              statusBgColor: const Color(0xFFE3F2FD),
              leftFooter: '85% Achieved',
              leftFooterColor: const Color(0xFF0D47A1),
              rightFooter: 'Rp 7.5M to go',
            ),
            const SizedBox(height: 16),

            // Savings
            _GoalCard(
              title: 'Savings',
              subtitle: 'Emergency Fund',
              icon: Icons.savings_outlined,
              iconBgColor: const Color(0xFFE3F2FD),
              iconColor: const Color(0xFF0D47A1),
              currentAmount: 'Rp 8.000.000',
              targetAmount: '10M',
              progress: 0.80,
              progressColor: const Color(0xFF0D47A1),
              progressBgColor: const Color(0xFFEDF2F7),
              rightFooter: '80% of target',
            ),
            const SizedBox(height: 16),

            // Expense Limit
            _GoalCard(
              title: 'Expense Limit',
              subtitle: 'Operational',
              icon: Icons.credit_card_rounded,
              iconBgColor: const Color(0xFFFED7D7),
              iconColor: const Color(0xFFC53030),
              currentAmount: 'Rp 16.500.000',
              currentAmountColor: const Color(0xFFC53030), // Red text for over limit
              targetAmount: '15M',
              progress: 1.0,
              progressColor: const Color(0xFFC53030),
              progressBgColor: const Color(0xFFFED7D7),
              statusPill: 'Over Limit',
              statusIcon: Icons.warning_amber_rounded,
              statusColor: const Color(0xFFC53030),
              statusBgColor: const Color(0xFFFED7D7),
              leftFooter: 'Rp 1.500.000 over expected limit',
              leftFooterColor: const Color(0xFFC53030),
              hasBorder: true,
              borderColor: const Color(0xFFFED7D7),
            ),
            const SizedBox(height: 100), // Bottom shell padding
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String currentAmount;
  final Color? currentAmountColor;
  final String targetAmount;
  final double progress;
  final Color progressColor;
  final Color progressBgColor;
  final String? statusPill;
  final IconData? statusIcon;
  final Color? statusColor;
  final Color? statusBgColor;
  final String? leftFooter;
  final Color? leftFooterColor;
  final String? rightFooter;
  final bool hasBorder;
  final Color? borderColor;

  const _GoalCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.currentAmount,
    this.currentAmountColor,
    required this.targetAmount,
    required this.progress,
    required this.progressColor,
    required this.progressBgColor,
    this.statusPill,
    this.statusIcon,
    this.statusColor,
    this.statusBgColor,
    this.leftFooter,
    this.leftFooterColor,
    this.rightFooter,
    this.hasBorder = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: hasBorder ? Border.all(color: borderColor ?? Colors.transparent) : null,
        boxShadow: [BoxShadow(color: AppColors.shadow.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF1A202C))),
                      const SizedBox(height: 4),
                      Text(subtitle, style: AppTypography.textTheme.bodyMedium?.copyWith(color: const Color(0xFF718096))),
                    ],
                  ),
                ],
              ),
              if (statusPill != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      if (statusIcon != null) ...[
                        Icon(statusIcon, color: statusColor, size: 14),
                        const SizedBox(width: 4),
                      ],
                      Text(statusPill!, style: AppTypography.textTheme.labelSmall?.copyWith(color: statusColor, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currentAmount,
                style: AppTypography.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: currentAmountColor ?? const Color(0xFF1A202C),
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  hasBorder ? '/ $targetAmount' : 'Rp $targetAmount', // Logic for formatting based on screenshot difference
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A202C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: progressBgColor,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (leftFooter != null)
                Text(leftFooter!, style: AppTypography.textTheme.labelSmall?.copyWith(color: leftFooterColor ?? const Color(0xFF718096)))
              else
                const SizedBox(),
              if (rightFooter != null)
                Text(rightFooter!, style: AppTypography.textTheme.labelSmall?.copyWith(color: const Color(0xFF718096)))
              else
                const SizedBox(),
            ],
          ),
        ],
      ),
    );
  }
}
