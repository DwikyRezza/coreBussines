// ============================================================
// FEATURE: Analytics — Analytics Overview Page
// lib/features/analytics/presentation/pages/analytics_overview_page.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/core_app_bar.dart';
import '../../../../core/utils/responsive_helper.dart';

class AnalyticsOverviewPage extends StatelessWidget {
  const AnalyticsOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.pagePadding(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CoreAppBar(),
      body: ResponsiveHelper.constrainWidth(
        context: context,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              Text(
                'Analytics Overview',
                style: AppTypography.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Review your financial performance for this month.',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Net Profit Card (Blue)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary, // Deep blue
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Net Profit',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                        ),
                        const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 24),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '\$12,450.00',
                      style: AppTypography.textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.trending_up_rounded, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '+14.5% vs last month',
                            style: AppTypography.textTheme.labelSmall?.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Total Income & Expense Cards
              if (ResponsiveHelper.isTabletOrLarger(context))
                Row(
                  children: [
                    Expanded(
                      child: _SimpleStatCard(
                        title: 'Total Income',
                        amount: '\$18,200.00',
                        icon: Icons.arrow_downward_rounded,
                        iconColor: Theme.of(context).colorScheme.primary,
                        iconBg: Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _SimpleStatCard(
                        title: 'Total Expense',
                        amount: '\$5,750.00',
                        icon: Icons.arrow_upward_rounded,
                        iconColor: Theme.of(context).colorScheme.error,
                        iconBg: Theme.of(context).colorScheme.errorContainer,
                      ),
                    ),
                  ],
                )
              else ...[
                _SimpleStatCard(
                  title: 'Total Income',
                  amount: '\$18,200.00',
                  icon: Icons.arrow_downward_rounded,
                  iconColor: Theme.of(context).colorScheme.primary,
                  iconBg: Theme.of(context).colorScheme.primaryContainer,
                ),
                const SizedBox(height: AppSpacing.md),
                _SimpleStatCard(
                  title: 'Total Expense',
                  amount: '\$5,750.00',
                  icon: Icons.arrow_upward_rounded,
                  iconColor: Theme.of(context).colorScheme.error,
                  iconBg: Theme.of(context).colorScheme.errorContainer,
                ),
              ],
              const SizedBox(height: AppSpacing.xl),

            // Financial Trend Chart
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
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
                      Text(
                        'Financial\nTrend',
                        style: AppTypography.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text('Weekly', style: AppTypography.textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text('Monthly', style: AppTypography.textTheme.labelMedium?.copyWith(color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 5000,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(color: Theme.of(context).colorScheme.surfaceContainerHighest, strokeWidth: 1);
                          },
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 22,
                              getTitlesWidget: (value, meta) {
                                final style = TextStyle(color: Theme.of(context).colorScheme.outline, fontSize: 10);
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
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                final style = TextStyle(color: Theme.of(context).colorScheme.outline, fontSize: 10);
                                if (value == 0) return Text('0', style: style);
                                return Text('\$${(value/1000).toInt()}k', style: style);
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minX: 0,
                        maxX: 5,
                        minY: 0,
                        maxY: 20000,
                        lineBarsData: [
                          LineChartBarData(
                            spots: const [
                              FlSpot(0, 5000),
                              FlSpot(1, 6000),
                              FlSpot(2, 12000),
                              FlSpot(3, 9000),
                              FlSpot(4, 16000),
                              FlSpot(5, 19000),
                            ],
                            isCurved: true,
                            color: Theme.of(context).colorScheme.primary, // Bright Blue
                            barWidth: 4,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: Colors.white,
                                  strokeWidth: 3,
                                  strokeColor: Theme.of(context).colorScheme.primary,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            ),
                          ),
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
      ),
    );
  }
}

class _SimpleStatCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const _SimpleStatCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 8),
              Text(amount, style: AppTypography.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
        ],
      ),
    );
  }
}