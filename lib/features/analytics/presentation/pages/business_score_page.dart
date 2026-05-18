// ============================================================
// FEATURE: Analytics — Business Score Page
// lib/features/analytics/presentation/pages/business_score_page.dart
// ============================================================

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/core_app_bar.dart';

class BusinessScorePage extends StatelessWidget {
  const BusinessScorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CoreAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: AppSpacing.md),
            Text(
              'Skor Bisnis Anda',
              style: AppTypography.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A202C),
              ),
            ),
            const SizedBox(height: 32),

            // Circular Score Widget
            SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer dashed circle mock
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE3F2FD), width: 8), // Inner track
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: CircularProgressIndicator(
                      value: 0.82,
                      strokeWidth: 8,
                      color: const Color(0xFF0D47A1), // Outer progress
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '82',
                        style: AppTypography.textTheme.displayMedium?.copyWith(
                          color: const Color(0xFF0D47A1),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '/ 100',
                        style: AppTypography.textTheme.labelMedium?.copyWith(
                          color: const Color(0xFF4A5568),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.trending_up_rounded, color: Color(0xFF1A202C), size: 16),
                const SizedBox(width: 8),
                Text('Sehat & Bertumbuh', style: AppTypography.textTheme.labelMedium?.copyWith(color: const Color(0xFF1A202C))),
              ],
            ),
            const SizedBox(height: 32),

            // AI Evaluation Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.psychology_outlined, color: Color(0xFF0D47A1), size: 24),
                      const SizedBox(width: 8),
                      Text('Evaluasi AI', style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF1A202C))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Kesehatan bisnis Anda dalam kondisi prima. Likuiditas terjaga dengan baik, memungkinkan ekspansi operasional. Disarankan untuk mulai mengalokasikan 15% dari surplus bulan ini ke instrumen investasi jangka pendek untuk memaksimalkan idle cash.',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(color: const Color(0xFF4A5568), height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Metrics Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _MetricCard(
                  icon: Icons.water_drop_outlined,
                  iconColor: const Color(0xFF0D47A1),
                  iconBg: const Color(0xFFE3F2FD),
                  score: '90/100',
                  title: 'Likuiditas',
                  value: 'Sangat Baik',
                ),
                _MetricCard(
                  icon: Icons.savings_outlined,
                  iconColor: const Color(0xFF0D47A1),
                  iconBg: const Color(0xFFE3F2FD),
                  score: '75/100',
                  title: 'Tabungan',
                  value: 'Cukup',
                ),
                _MetricCard(
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: const Color(0xFF0D47A1),
                  iconBg: const Color(0xFFE3F2FD),
                  score: '85/100',
                  title: 'Rasio Hutang',
                  value: 'Aman',
                ),
                _MetricCard(
                  icon: Icons.trending_up_rounded,
                  iconColor: const Color(0xFF0D47A1),
                  iconBg: const Color(0xFFE3F2FD),
                  score: '80/100',
                  title: 'Pertumbuhan',
                  value: 'Stabil',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Key Performance Indicators
            Text(
              'Indikator Kinerja Utama',
              style: AppTypography.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _KpiRow(
                    title: 'Pendapatan Bersih (Bulan ini)',
                    amount: 'Rp 45.000.000',
                    trend: '12%',
                    isPositiveTrend: true,
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  _KpiRow(
                    title: 'Biaya Operasional',
                    amount: 'Rp 18.500.000',
                    trend: '3%',
                    isPositiveTrend: false,
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  _KpiRow(
                    title: 'Arus Kas Masuk',
                    amount: 'Rp 60.200.000',
                    trend: '8%',
                    isPositiveTrend: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100), // Bottom shell padding
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String score;
  final String title;
  final String value;

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.score,
    required this.title,
    required this.value,
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
            color: AppColors.shadow.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(score, style: AppTypography.textTheme.labelSmall?.copyWith(color: const Color(0xFF0D47A1), fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const Spacer(),
          Text(title, style: AppTypography.textTheme.labelMedium?.copyWith(color: const Color(0xFF4A5568))),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF1A202C))),
        ],
      ),
    );
  }
}

class _KpiRow extends StatelessWidget {
  final String title;
  final String amount;
  final String trend;
  final bool isPositiveTrend;

  const _KpiRow({
    required this.title,
    required this.amount,
    required this.trend,
    required this.isPositiveTrend,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.textTheme.labelMedium?.copyWith(color: const Color(0xFF1A202C), fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(amount, style: AppTypography.textTheme.bodySmall?.copyWith(color: const Color(0xFF4A5568))),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isPositiveTrend ? const Color(0xFFF0FFF4) : const Color(0xFFFFF5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  isPositiveTrend ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                  color: isPositiveTrend ? const Color(0xFF38A169) : const Color(0xFFE53E3E),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  trend,
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: isPositiveTrend ? const Color(0xFF38A169) : const Color(0xFFE53E3E),
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
