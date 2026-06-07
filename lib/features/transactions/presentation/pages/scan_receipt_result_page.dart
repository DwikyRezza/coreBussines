// ============================================================
// FEATURE: Transactions — Scan Receipt Result Page
// lib/features/transactions/presentation/pages/scan_receipt_result_page.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class ScanReceiptResultPage extends StatelessWidget {
  const ScanReceiptResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context)
          .scaffoldBackgroundColor, // Very light gray/blue matching screenshot
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close_rounded,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Detail Transaksi',
          style: AppTypography.textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.lg),

            // Receipt Image Mock
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                image: const DecorationImage(
                  image: NetworkImage(
                      'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=400&q=80'), // Mock receipt image
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline_rounded,
                    color: Theme.of(context).colorScheme.primary, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Data berhasil diekstrak',
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Form Fields
            _EditableField(
              label: 'Total Tagihan',
              value: 'Rp 55.000',
              valueStyle: AppTypography.textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            _EditableField(
              label: 'Merchant',
              value: 'Starbucks',
              icon: Icons.storefront_rounded,
              iconBg: Theme.of(context).colorScheme.outlineVariant,
              iconColor: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.sm),

            Row(
              children: [
                Expanded(
                  child: _EditableField(
                    label: 'Kategori',
                    value: 'Makanan & Minuman',
                    icon: Icons.restaurant_rounded,
                    iconBg: Theme.of(context).colorScheme.outlineVariant,
                    iconColor: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _EditableField(
                    label: 'Tanggal',
                    value: '24 Mei 2024',
                    icon: Icons.calendar_today_rounded,
                    iconBg: Theme.of(context).colorScheme.outlineVariant,
                    iconColor: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 100), // Space for button
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            backgroundColor: Theme.of(context).colorScheme.primary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Konfirmasi & Simpan',
                  style: AppTypography.textTheme.labelLarge?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              const Icon(Icons.check_rounded, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _EditableField extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBg;

  const _EditableField({
    required this.label,
    required this.value,
    this.valueStyle,
    this.icon,
    this.iconColor,
    this.iconBg,
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
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: valueStyle ??
                      AppTypography.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ],
            ),
          ),
          Icon(Icons.edit_outlined,
              color: Theme.of(context).colorScheme.outline, size: 20),
        ],
      ),
    );
  }
}
