// ============================================================
// FEATURE: Settings — Empty States Overview Page
// lib/features/settings/presentation/pages/empty_states_overview_page.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class EmptyStatesOverviewPage extends StatelessWidget {
  const EmptyStatesOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        titleSpacing: AppSpacing.pagePadding,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'CoreBusiness',
              style: AppTypography.textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, color: Theme.of(context).colorScheme.primary),
            onPressed: () => context.push(AppRoutes.alerts),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
            Text(
              'Empty States Overview',
              style: AppTypography.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Consistent collection of empty states for various contexts across the application.',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Transactions Empty State
            _EmptyStateCard(
              icon: Icons.receipt_long_rounded,
              title: 'Belum ada transaksi',
              description: 'Riwayat transaksi Anda akan muncul di sini. Mulai aktivitas baru untuk melihatnya.',
              buttonText: 'Buat Transaksi Baru',
              isButtonSolid: true,
              onPressed: () => context.push(AppRoutes.addTransaction),
            ),
            const SizedBox(height: 16),

            // Analytics Empty State
            _EmptyStateCard(
              icon: Icons.bar_chart_rounded,
              title: 'Data Analisis Kosong',
              description: 'Kumpulkan data lebih banyak untuk melihat tren dan analisis performa Anda.',
              buttonText: null, // No button
            ),
            const SizedBox(height: 16),

            // Schedule Empty State
            _EmptyStateCard(
              icon: Icons.calendar_month_rounded,
              title: 'Jadwal Kosong',
              description: 'Tidak ada jadwal aktif saat ini. Rencanakan sesi Anda berikutnya.',
              buttonText: 'Tambah Jadwal',
              isButtonSolid: true,
              onPressed: () => context.push(AppRoutes.addSchedule),
            ),
            const SizedBox(height: 16),

            // Business Empty State
            _EmptyStateCard(
              icon: Icons.storefront_rounded,
              title: 'Belum ada Bisnis',
              description: 'Daftarkan bisnis atau cabang baru untuk mulai mengelolanya dari sini.',
              buttonText: 'Daftar Bisnis',
              isButtonSolid: false,
              onPressed: () => context.push(AppRoutes.businessPortfolio),
            ),
            const SizedBox(height: 100), // Bottom shell padding
          ],
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? buttonText;
  final bool isButtonSolid;
  final VoidCallback? onPressed;

  const _EmptyStateCard({
    required this.icon,
    required this.title,
    required this.description,
    this.buttonText,
    this.isButtonSolid = true,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.shadow.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9), // Light greyish blue
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.outline, size: 32),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: AppTypography.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          if (buttonText != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: isButtonSolid ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(
                buttonText!,
                style: AppTypography.textTheme.labelMedium?.copyWith(
                  color: isButtonSolid ? Colors.white : Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}