// ============================================================
// FEATURE: Notifications — Empty State Page
// lib/features/notifications/presentation/pages/notifications_empty_page.dart
// ============================================================

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class NotificationsEmptyPage extends StatelessWidget {
  const NotificationsEmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        titleSpacing: AppSpacing.pagePadding,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFFED7D7), // Light red
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 16), // Mock avatar replacement
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
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 3D Glassmorphism Bell Mock
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0D47A1).withOpacity(0.05),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1614332287897-cdc485fa562d?w=400&q=80', // Mock abstract glassmorphism image
                    fit: BoxFit.cover,
                    color: Colors.white.withOpacity(0.2), // Lighten the image
                    colorBlendMode: BlendMode.lighten,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Belum ada notifikasi',
                style: AppTypography.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A202C),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Kami akan memberi tahu Anda jika ada\naktivitas penting di sini.',
                textAlign: TextAlign.center,
                style: AppTypography.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF4A5568),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  'Muat Ulang',
                  style: AppTypography.textTheme.labelLarge?.copyWith(
                    color: const Color(0xFF0D47A1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 100), // Bottom navigation padding
            ],
          ),
        ),
      ),
    );
  }
}
