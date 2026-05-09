// ============================================================
// FEATURE: Inventory — Inventory Overview Page
// lib/features/inventory/presentation/pages/inventory_overview_page.dart
// ============================================================

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class InventoryOverviewPage extends StatelessWidget {
  const InventoryOverviewPage({super.key});

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
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
            Text(
              'Inventory Overview',
              style: AppTypography.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A202C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your stock levels and monitor recent changes.',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF4A5568),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Overview Header Cards
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: AppColors.shadow.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.inventory_2_outlined, color: Color(0xFF4A5568), size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text('Total Active SKUs', style: AppTypography.textTheme.titleSmall?.copyWith(color: const Color(0xFF4A5568)))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text('1,248', style: AppTypography.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF1A202C))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFED7D7), // Light Red
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: AppColors.shadow.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Color(0xFFC53030), size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text('Low Stock Alerts', style: AppTypography.textTheme.titleSmall?.copyWith(color: const Color(0xFFC53030)))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text('12', style: AppTypography.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFFC53030))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Current Stock Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Current Stock', style: AppTypography.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF1A202C))),
                Row(
                  children: [
                    const Icon(Icons.filter_list_rounded, color: Color(0xFF2962FF), size: 18),
                    const SizedBox(width: 4),
                    Text('Filter', style: AppTypography.textTheme.labelMedium?.copyWith(color: const Color(0xFF2962FF), fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Stock Items
            _StockItemCard(
              title: 'Pro Dumbbell Set - 25kg',
              sku: 'EQ-DB-25-PRO',
              icon: Icons.fitness_center_rounded,
              statusText: '-15 units in last 48h',
              statusColor: const Color(0xFFC53030),
              statusIcon: Icons.trending_down_rounded,
              unitsLeft: '04',
              pillText: 'Low Stock',
              pillColor: const Color(0xFFC53030),
              pillBg: const Color(0xFFFED7D7),
              pillIcon: Icons.error_outline_rounded,
              isCritical: true,
            ),
            const SizedBox(height: 16),
            _StockItemCard(
              title: 'Yoga Mat - Premium Grip',
              sku: 'AC-YM-GR-01',
              icon: Icons.accessibility_new_rounded,
              statusText: 'Restocked 2 weeks ago',
              statusColor: const Color(0xFF718096),
              statusIcon: Icons.refresh_rounded,
              unitsLeft: '142',
              pillText: 'In Stock',
              pillColor: const Color(0xFF4A5568),
              pillBg: const Color(0xFFEDF2F7),
            ),
            const SizedBox(height: 16),
            _StockItemCard(
              title: 'Hydration Flask 1L',
              sku: 'AC-FL-1L-BK',
              icon: Icons.local_drink_rounded,
              statusText: 'Steady decline this month',
              statusColor: const Color(0xFF9C4221), // Orange
              statusIcon: Icons.trending_down_rounded,
              unitsLeft: '28',
              pillText: 'Reorder Soon',
              pillColor: Colors.white,
              pillBg: const Color(0xFFDD6B20),
              pillIcon: Icons.warning_amber_rounded,
            ),
            const SizedBox(height: 24),

            // Bottom Button
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                side: const BorderSide(color: Color(0xFFCBD5E0)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('View All Inventory', style: AppTypography.textTheme.labelLarge?.copyWith(color: const Color(0xFF0D47A1), fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 100), // Bottom padding
          ],
        ),
      ),
    );
  }
}

class _StockItemCard extends StatelessWidget {
  final String title;
  final String sku;
  final IconData icon;
  final String statusText;
  final Color statusColor;
  final IconData statusIcon;
  final String unitsLeft;
  final String pillText;
  final Color pillColor;
  final Color pillBg;
  final IconData? pillIcon;
  final bool isCritical;

  const _StockItemCard({
    required this.title,
    required this.sku,
    required this.icon,
    required this.statusText,
    required this.statusColor,
    required this.statusIcon,
    required this.unitsLeft,
    required this.pillText,
    required this.pillColor,
    required this.pillBg,
    this.pillIcon,
    this.isCritical = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isCritical ? const Color(0xFFC53030) : Colors.transparent, width: isCritical ? 1 : 0),
        boxShadow: [
          if (!isCritical)
            BoxShadow(color: AppColors.shadow.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isCritical)
              Container(
                width: 4,
                decoration: const BoxDecoration(
                  color: Color(0xFFC53030),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDF2F7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: const Color(0xFF4A5568), size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF1A202C))),
                              const SizedBox(height: 4),
                              Text('SKU: $sku', style: AppTypography.textTheme.bodySmall?.copyWith(color: const Color(0xFF718096))),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(statusIcon, color: statusColor, size: 14),
                                  const SizedBox(width: 4),
                                  Text(statusText, style: AppTypography.textTheme.labelSmall?.copyWith(color: statusColor)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(unitsLeft, style: AppTypography.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF1A202C))),
                            Text('Units Left', style: AppTypography.textTheme.labelSmall?.copyWith(color: const Color(0xFF718096))),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: pillBg,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              if (pillIcon != null) ...[
                                Icon(pillIcon, color: pillColor, size: 14),
                                const SizedBox(width: 4),
                              ],
                              Text(pillText, style: AppTypography.textTheme.labelSmall?.copyWith(color: pillColor, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
