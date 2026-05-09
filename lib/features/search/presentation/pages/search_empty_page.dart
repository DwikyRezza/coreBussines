// ============================================================
// FEATURE: Search — Search Empty Page
// lib/features/search/presentation/pages/search_empty_page.dart
// ============================================================

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class SearchEmptyPage extends StatelessWidget {
  const SearchEmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        titleSpacing: AppSpacing.pagePadding,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFE2E8F0),
              child: const Icon(Icons.person_outline_rounded, color: Color(0xFF4A5568), size: 18),
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
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          
          // Search Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2962FF)), // Active search border
              ),
              child: TextField(
                controller: TextEditingController(text: 'Pembayaran Netflix'),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0D47A1)),
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, color: Color(0xFF4A5568), size: 16),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Active Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
            child: Row(
              children: [
                _ActiveFilterChip(label: 'Bulan Ini'),
                const SizedBox(width: 8),
                _ActiveFilterChip(label: 'Pengeluaran'),
              ],
            ),
          ),
          
          // Empty State Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFE2E8F0),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(Icons.search_rounded, size: 56, color: Color(0xFF63B3ED)),
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(color: Color(0xFF63B3ED), shape: BoxShape.circle),
                              child: const Icon(Icons.close_rounded, size: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Tidak ada transaksi ditemukan',
                    style: AppTypography.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A202C),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Kami tidak dapat menemukan transaksi\nyang cocok dengan kata kunci\n"Pembayaran Netflix".',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF4A5568),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // Clear Filter Button
                  TextButton.icon(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFE2E8F0),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.filter_list_off_rounded, color: Color(0xFF0D47A1)),
                    label: Text(
                      'Hapus Filter',
                      style: AppTypography.textTheme.labelLarge?.copyWith(
                        color: const Color(0xFF0D47A1),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveFilterChip extends StatelessWidget {
  final String label;

  const _ActiveFilterChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFB3D4FF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTypography.textTheme.labelSmall?.copyWith(color: const Color(0xFF0D47A1))),
          const SizedBox(width: 4),
          const Icon(Icons.close_rounded, size: 14, color: Color(0xFF0D47A1)),
        ],
      ),
    );
  }
}
