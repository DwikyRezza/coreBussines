// ============================================================
// FEATURE: Analytics — Financial Overview Page
// lib/features/analytics/presentation/pages/financial_overview_page.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/core_app_bar.dart';

class FinancialOverviewPage extends StatelessWidget {
  const FinancialOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CoreAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
            Text(
              'Overview',
              style: AppTypography.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Top Summary Cards
            _OverviewCard(
              title: 'Total Spend (This Month)',
              amount: '\$4,250.00',
              trend: '+12.5% vs last month',
              isPositiveTrend: false,
            ),
            const SizedBox(height: AppSpacing.md),
            _OverviewCard(
              title: 'Total Savings',
              amount: '\$12,800.50',
              trend: '+5.2% vs last month',
              isPositiveTrend: true,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Category Breakdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Category Breakdown',
                  style: AppTypography.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(
                  'View All',
                  style: AppTypography.textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _CategoryRow(
                    icon: Icons.shopping_cart_outlined,
                    iconColor: Theme.of(context).colorScheme.primary,
                    iconBg: const Color(0xFFE3F2FD),
                    title: 'Groceries',
                    percentage: '25% of total',
                    amount: '\$1,062.50',
                    barColor: Theme.of(context).colorScheme.primary,
                    progress: 0.25,
                  ),
                  Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
                  _CategoryRow(
                    icon: Icons.home_outlined,
                    iconColor: const Color(0xFFC53030),
                    iconBg: const Color(0xFFFED7D7),
                    title: 'Housing',
                    percentage: '40% of total',
                    amount: '\$1,700.00',
                    barColor: const Color(0xFFC53030),
                    progress: 0.40,
                  ),
                  Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
                  _CategoryRow(
                    icon: Icons.directions_car_outlined,
                    iconColor: Theme.of(context).colorScheme.onSurfaceVariant,
                    iconBg: Theme.of(context).colorScheme.surfaceContainerHighest,
                    title: 'Transport',
                    percentage: '15% of total',
                    amount: '\$637.50',
                    barColor: Theme.of(context).colorScheme.onSurfaceVariant,
                    progress: 0.15,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Spending Trend Bar Chart
            Text(
              'Spending Trend',
              style: AppTypography.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Last 6 Months', style: AppTypography.textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      Row(
                        children: [
                          Container(width: 10, height: 10, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text('This Year', style: AppTypography.textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 100,
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final style = TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10);
                                String text;
                                switch (value.toInt()) {
                                  case 0: text = 'Jan'; break;
                                  case 1: text = 'Feb'; break;
                                  case 2: text = 'Mar'; break;
                                  case 3: text = 'Apr'; break;
                                  case 4: text = 'May'; break;
                                  case 5: text = 'Jun'; break;
                                  default: text = ''; break;
                                }
                                return SideTitleWidget(axisSide: meta.axisSide, child: Text(text, style: style));
                              },
                              reservedSize: 28,
                            ),
                          ),
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                         barGroups: [
                          _buildBarGroup(context, 0, 30, 40),
                          _buildBarGroup(context, 1, 30, 60),
                          _buildBarGroup(context, 2, 25, 28),
                          _buildBarGroup(context, 3, 40, 70),
                          _buildBarGroup(context, 4, 30, 40),
                          _buildBarGroup(context, 5, 75, 85),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100), // Bottom padding
          ],
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(BuildContext context, int x, double y1, double y2) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y2,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2), // Light background bar
          width: 20,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
          rodStackItems: [
            BarChartRodStackItem(0, y1, Theme.of(context).colorScheme.primary), // Solid foreground bar
          ],
        ),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String title;
  final String amount;
  final String trend;
  final bool isPositiveTrend;

  const _OverviewCard({
    required this.title,
    required this.amount,
    required this.trend,
    required this.isPositiveTrend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          Text(amount, style: AppTypography.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isPositiveTrend ? Icons.trending_up_rounded : Icons.trending_up_rounded,
                color: isPositiveTrend ? Theme.of(context).colorScheme.primary : const Color(0xFFC53030),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                trend,
                style: AppTypography.textTheme.labelMedium?.copyWith(
                  color: isPositiveTrend ? Theme.of(context).colorScheme.primary : const Color(0xFFC53030),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String percentage;
  final String amount;
  final Color barColor;
  final double progress;

  const _CategoryRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.percentage,
    required this.amount,
    required this.barColor,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(percentage, style: AppTypography.textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: AppTypography.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              SizedBox(
                width: 80,
                child: Stack(
                  children: [
                    Container(height: 6, decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(3))),
                    FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(height: 6, decoration: BoxDecoration(color: barColor, borderRadius: BorderRadius.circular(3))),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}