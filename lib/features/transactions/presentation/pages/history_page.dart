// ============================================================
// FEATURE: Transactions — History Page
// lib/features/transactions/presentation/pages/history_page.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/app_router.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
        backgroundColor: AppColors.background,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.md),
                  // Search & Filter
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          child: Row(
                            children: [
                              const Icon(Icons.search_rounded, color: AppColors.onSurfaceVariant, size: 20),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Cari transaksi...',
                                    hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {},
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  const Icon(Icons.filter_list_rounded, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Filter',
                                    style: AppTypography.textTheme.labelLarge?.copyWith(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          title: 'Total Pemasukan',
                          amount: 'Rp 4.250.000',
                          color: AppColors.primary,
                          isIncome: true,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _SummaryCard(
                          title: 'Total Pengeluaran',
                          amount: 'Rp 1.820.000',
                          color: AppColors.expense,
                          isIncome: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
          
          // TODAY Group
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DateHeader(label: 'TODAY', date: '24 May 2024'),
                  const SizedBox(height: AppSpacing.sm),
                  _TransactionItem(
                    icon: Icons.payments_rounded,
                    iconColor: AppColors.primary,
                    iconBg: AppColors.primaryContainer,
                    title: 'Freelance Project',
                    category: 'Work & Professional',
                    amount: '+ Rp 2.500.000',
                    time: '09:41',
                    isIncome: true,
                    onTap: () => context.push(AppRoutes.editTransaction.replaceAll(':id', '1')),
                  ),
                  _TransactionItem(
                    icon: Icons.restaurant_rounded,
                    iconColor: AppColors.expense,
                    iconBg: const Color(0xFFFDECEA),
                    title: 'Gacoan Fried Noodles',
                    category: 'Food & Dining',
                    amount: '- Rp 45.000',
                    time: '12:45',
                    isIncome: false,
                    isSwiped: true, // Show swipe action mock
                    onTap: () => context.push(AppRoutes.editTransaction.replaceAll(':id', '2')),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
          
          // YESTERDAY Group
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DateHeader(label: 'YESTERDAY', date: '23 May 2024'),
                  const SizedBox(height: AppSpacing.sm),
                  _TransactionItem(
                    icon: Icons.fitness_center_rounded,
                    iconColor: AppColors.onSurfaceVariant,
                    iconBg: AppColors.surfaceContainer,
                    title: 'Gym Membership',
                    category: 'Health & Fitness',
                    amount: '- Rp 350.000',
                    time: '18:15',
                    isIncome: false,
                    onTap: () {},
                  ),
                  _TransactionItem(
                    icon: Icons.bolt_rounded,
                    iconColor: AppColors.onSurfaceVariant,
                    iconBg: AppColors.surfaceContainer,
                    title: 'PLN Electricity',
                    category: 'Utilities',
                    amount: '- Rp 1.200.000',
                    time: '10:00',
                    isIncome: false,
                    onTap: () {},
                  ),
                  _TransactionItem(
                    icon: Icons.savings_rounded,
                    iconColor: AppColors.primary,
                    iconBg: AppColors.primaryContainer,
                    title: 'Cashback Promo',
                    category: 'Rewards',
                    amount: '+ Rp 25.000',
                    time: '08:20',
                    isIncome: true,
                    onTap: () {},
                  ),
                  const SizedBox(height: 100), // Bottom padding for FAB
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final Color color;
  final bool isIncome;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Left Border Indicator
          Positioned(
            left: -16,
            top: -16,
            bottom: -16,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                amount,
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  final String label;
  final String date;

  const _DateHeader({required this.label, required this.date});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.textTheme.labelMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        Text(
          date,
          style: AppTypography.textTheme.labelMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String category;
  final String amount;
  final String time;
  final bool isIncome;
  final bool isSwiped;
  final VoidCallback onTap;

  const _TransactionItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.category,
    required this.amount,
    required this.time,
    required this.isIncome,
    this.isSwiped = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  category,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: AppTypography.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isIncome ? AppColors.primary : AppColors.expense,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: AppTypography.textTheme.labelMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (isSwiped) {
      return Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.expense,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: const Icon(Icons.archive_outlined, color: Colors.white),
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(64, 0),
            child: GestureDetector(
              onTap: onTap,
              child: content,
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: content,
    );
  }
}
