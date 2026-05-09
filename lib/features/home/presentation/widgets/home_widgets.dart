// ============================================================
// FEATURE: Home — Reusable Widgets
// lib/features/home/presentation/widgets/home_widgets.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/home_entities.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/router/app_router.dart';

// ─────────────────────────────────────────────────────────────
// BALANCE CARD
// ─────────────────────────────────────────────────────────────
class BalanceCard extends StatelessWidget {
  final BalanceSummary summary;

  const BalanceCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final isPositive = summary.monthlyChange >= 0;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Saldo',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppFormatter.currency(summary.totalBalance),
            style: AppTypography.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 30,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${isPositive ? '+' : ''}${AppFormatter.currency(summary.monthlyChange)} bulan ini',
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
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

// ─────────────────────────────────────────────────────────────
// QUICK ACTIONS GRID
// ─────────────────────────────────────────────────────────────
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  static const List<_QuickActionItem> _actions = [
    _QuickActionItem(
      icon: Icons.add_circle_outline_rounded,
      label: 'Tambah\nPemasukan',
      id: 'add_income',
    ),
    _QuickActionItem(
      icon: Icons.remove_circle_outline_rounded,
      label: 'Tambah\nPengeluaran',
      id: 'add_expense',
    ),
    _QuickActionItem(
      icon: Icons.qr_code_scanner_rounded,
      label: 'Scan\nStruk',
      id: 'scan',
    ),
    _QuickActionItem(
      icon: Icons.calendar_month_rounded,
      label: 'Jadwal',
      id: 'schedule',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _actions
            .map((action) => _QuickActionButton(action: action))
            .toList(),
      ),
    );
  }
}

class _QuickActionItem {
  final IconData icon;
  final String label;
  final String id;
  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.id,
  });
}

class _QuickActionButton extends StatelessWidget {
  final _QuickActionItem action;

  const _QuickActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: InkWell(
            onTap: () {
              // TODO: Route to specific action
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(action.id)),
              );
            },
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(
                  color: AppColors.outlineVariant.withOpacity(0.5),
                ),
              ),
              child: Icon(
                action.icon,
                color: AppColors.primary,
                size: 26,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          action.label,
          textAlign: TextAlign.center,
          style: AppTypography.textTheme.labelSmall?.copyWith(
            color: AppColors.onSurfaceVariant,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// INSIGHT CARD (AI)
// ─────────────────────────────────────────────────────────────
class HomeInsightCard extends StatelessWidget {
  final InsightCard insight;

  const HomeInsightCard({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.bolt_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    color: AppColors.onBackground,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  insight.message,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
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

// ─────────────────────────────────────────────────────────────
// TRANSACTION TILE
// ─────────────────────────────────────────────────────────────
class TransactionTile extends StatelessWidget {
  final Transaction transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(
        '/transaction/${transaction.id}',
      ),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.pagePadding,
        ),
        child: Row(
          children: [
            // Category Icon
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: transaction.isIncome
                    ? AppColors.incomeLight
                    : AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(
                _categoryIcon(transaction.categoryIcon),
                color: transaction.isIncome
                    ? AppColors.income
                    : AppColors.onSurfaceVariant,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Title & Date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onBackground,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${AppFormatter.relativeDate(transaction.dateTime)}, ${AppFormatter.timeWib(transaction.dateTime).replaceAll(' WIB', '')}',
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Amount
            Text(
              AppFormatter.currency(
                transaction.amount * (transaction.isIncome ? 1 : -1),
                showSign: true,
              ),
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: transaction.isIncome ? AppColors.income : AppColors.expense,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(String icon) {
    switch (icon) {
      case 'food':
        return Icons.restaurant_rounded;
      case 'income':
        return Icons.account_balance_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'health':
        return Icons.fitness_center_rounded;
      case 'transport':
        return Icons.directions_car_rounded;
      case 'entertainment':
        return Icons.movie_rounded;
      default:
        return Icons.attach_money_rounded;
    }
  }
}

// ─────────────────────────────────────────────────────────────
// SECTION HEADER
// ─────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: AppColors.onBackground,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                actionLabel!,
                style: AppTypography.textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SKELETON LOADING WIDGET
// ─────────────────────────────────────────────────────────────
class SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
          ),
        );
      },
    );
  }
}
