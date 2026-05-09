// ============================================================
// FEATURE: Analytics — Page
// lib/features/analytics/presentation/pages/analytics_page.dart
// ============================================================

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

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
              'CoreFit',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Ringkasan Bulan\nIni',
                    style: AppTypography.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Oktober\n2023',
                        style: AppTypography.textTheme.labelMedium?.copyWith(
                          color: AppColors.primary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary, size: 20),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Summary Cards
            _SummaryCard(
              title: 'Omzet Bulan Ini',
              amount: 'Rp 42.500.000',
              trend: '12%',
              isPositiveTrend: true,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            _SummaryCard(
              title: 'Total Pengeluaran',
              amount: 'Rp 18.230.000',
              trend: '5%',
              isPositiveTrend: false,
              color: const Color(0xFF993300), // Darker red matching screenshot
            ),
            const SizedBox(height: AppSpacing.xl),

            // Kategori Pengeluaran Terbesar
            Text(
              'Kategori Pengeluaran Terbesar',
              style: AppTypography.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  // Donut Chart
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 0,
                            centerSpaceRadius: 40,
                            sections: [
                              PieChartSectionData(
                                color: const Color(0xFF0D47A1), // Deep blue
                                value: 65,
                                radius: 20,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                color: const Color(0xFF993300), // Deep red
                                value: 25,
                                radius: 20,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                color: const Color(0xFF757575), // Grey
                                value: 10,
                                radius: 20,
                                showTitle: false,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Total', style: AppTypography.textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant)),
                            Text('100%', style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Legend
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LegendItem(color: const Color(0xFF0D47A1), label: 'Operasional', value: '65%'),
                        const SizedBox(height: 12),
                        _LegendItem(color: const Color(0xFF993300), label: 'Pemasaran', value: '25%'),
                        const SizedBox(height: 12),
                        _LegendItem(color: const Color(0xFF757575), label: 'Lainnya', value: '10%'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // AI Insight
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Color(0xFF1A237E), size: 24), // Darker blue
                const SizedBox(width: 8),
                Text(
                  'AI Insight',
                  style: AppTypography.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryContainer),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF37474F), // Dark slate gray
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(text: 'Berdasarkan data bulan Oktober, pengeluaran operasional Anda meningkat '),
                        TextSpan(text: '8%', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
                        const TextSpan(text: ' dibandingkan bulan lalu. Hal ini dipicu oleh biaya logistik yang tidak terduga di minggu kedua.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    text: TextSpan(
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF37474F),
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(text: 'Rekomendasi: ', style: TextStyle(fontWeight: FontWeight.w800)),
                        const TextSpan(text: 'Cobalah untuk menegosiasikan kontrak vendor pengiriman untuk mendapatkan diskon kuantitas di bulan depan guna menjaga margin keuntungan tetap di atas 50%.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Download Button
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: const Color(0xFF0D47A1), // Deep blue
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.picture_as_pdf_outlined, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Text('Unduh Laporan PDF', style: AppTypography.textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 100), // Bottom padding for FAB and Nav
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final String trend;
  final bool isPositiveTrend;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.trend,
    required this.isPositiveTrend,
    required this.color,
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
            left: -24,
            top: -24,
            bottom: -24,
            child: Container(
              width: 6,
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
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount,
                    style: AppTypography.textTheme.headlineMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      Icon(
                        isPositiveTrend ? Icons.trending_up_rounded : Icons.trending_up_rounded, // Assuming trend arrows
                        color: isPositiveTrend ? const Color(0xFF4CAF50) : AppColors.expense,
                        size: 16,
                      ),
                      Text(
                        trend,
                        style: AppTypography.textTheme.labelMedium?.copyWith(
                          color: isPositiveTrend ? const Color(0xFF4CAF50) : AppColors.expense,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _LegendItem({required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.onBackground),
          ),
        ),
        Text(
          value,
          style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }
}
