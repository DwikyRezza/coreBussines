// ============================================================
// FEATURE: Catalog — Catalog Page
// lib/features/catalog/presentation/pages/catalog_page.dart
// ============================================================

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

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
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
              child: Text(
                'Catalog',
                style: AppTypography.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A202C),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
              child: Text(
                'Manage your products, services, and memberships.',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF4A5568),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Top Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
              child: Row(
                children: [
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      side: const BorderSide(color: Color(0xFFCBD5E0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.filter_list_rounded, color: Color(0xFF0D47A1), size: 18),
                        const SizedBox(width: 8),
                        Text('Filter', style: AppTypography.textTheme.labelMedium?.copyWith(color: const Color(0xFF0D47A1), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      backgroundColor: const Color(0xFF0D47A1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.add, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text('New Item', style: AppTypography.textTheme.labelMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Summary Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: AppColors.shadow.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TOTAL ACTIVE', style: AppTypography.textTheme.labelSmall?.copyWith(color: const Color(0xFF4A5568), letterSpacing: 1.2)),
                    const SizedBox(height: 8),
                    Text('142', style: AppTypography.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF1A202C))),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.trending_up_rounded, color: Color(0xFF2962FF), size: 16),
                        const SizedBox(width: 4),
                        Text('+12 this month', style: AppTypography.textTheme.labelSmall?.copyWith(color: const Color(0xFF2962FF))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Image Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1579722820308-d74e571900a9?w=800&q=80'), // Mock gym supplements
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('TOP CATEGORY', style: AppTypography.textTheme.labelSmall?.copyWith(color: Colors.white70, letterSpacing: 1.2)),
                      const SizedBox(height: 4),
                      Text('Supplements', style: AppTypography.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('45 items in catalog', style: AppTypography.textTheme.bodySmall?.copyWith(color: Colors.white70)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Alert Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFED7D7)), // Light red border
                  boxShadow: [BoxShadow(color: AppColors.shadow.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('NEEDS ATTENTION', style: AppTypography.textTheme.labelSmall?.copyWith(color: const Color(0xFFC53030), letterSpacing: 1.2)),
                    const SizedBox(height: 8),
                    Text('4', style: AppTypography.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF1A202C))),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Color(0xFFC53030), size: 16),
                        const SizedBox(width: 4),
                        Text('Low stock alerts', style: AppTypography.textTheme.labelSmall?.copyWith(color: const Color(0xFFC53030))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Horizontal Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
              child: Row(
                children: [
                  _FilterChip(label: 'All Items', isSelected: true),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Membership', isSelected: false),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Food & Beverage', isSelected: false),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Membership Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
              child: Text('Membership', style: AppTypography.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
              child: _CatalogItemCard(
                title: 'Membership Pro',
                subtitle: 'Full access + 2 PT Sessions',
                icon: Icons.card_membership_rounded,
                price: '\$89.99',
                statusPill: 'Active',
                isImage: false,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
              child: _CatalogItemCard(
                title: 'Basic Tier',
                subtitle: 'Standard gym floor access',
                icon: Icons.badge_outlined,
                price: '\$29.99',
                statusPill: 'Active',
                isImage: false,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Food & Beverage Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
              child: Text('Food & Beverage', style: AppTypography.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
              child: _CatalogItemCard(
                title: 'Whey Protein Isolate',
                subtitle: 'Vanilla / 2lbs',
                imageUrl: 'https://images.unsplash.com/photo-1593095948071-474c5cc2989d?w=150&q=80',
                price: '\$45.00',
                stockInfo: 'Stock: 3',
                statusPill: 'Low Stock',
                isLowStock: true,
                isImage: true,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
              child: _CatalogItemCard(
                title: 'Pre-Workout Energy',
                subtitle: 'Fruit Punch / Can',
                icon: Icons.local_drink_rounded,
                price: '\$3.50',
                stockInfo: 'Stock: 124',
                statusPill: 'In Stock',
                isImage: false,
              ),
            ),
            const SizedBox(height: 100), // Bottom navigation padding
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _FilterChip({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE3F2FD) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0)),
      ),
      child: Text(
        label,
        style: AppTypography.textTheme.labelMedium?.copyWith(
          color: isSelected ? const Color(0xFF0D47A1) : const Color(0xFF4A5568),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }
}

class _CatalogItemCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final String statusPill;
  final IconData? icon;
  final String? imageUrl;
  final String? stockInfo;
  final bool isLowStock;
  final bool isImage;

  const _CatalogItemCard({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.statusPill,
    this.icon,
    this.imageUrl,
    this.stockInfo,
    this.isLowStock = false,
    required this.isImage,
  });

  @override
  Widget build(BuildContext context) {
    Color pillColor;
    Color pillBg;
    
    if (statusPill == 'Active' || statusPill == 'In Stock') {
      pillColor = const Color(0xFF0D47A1);
      pillBg = const Color(0xFFE3F2FD);
    } else if (isLowStock) {
      pillColor = const Color(0xFFC53030);
      pillBg = const Color(0xFFFED7D7);
    } else {
      pillColor = const Color(0xFF4A5568);
      pillBg = const Color(0xFFEDF2F7);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.shadow.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isImage && imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(imageUrl!, width: 48, height: 48, fit: BoxFit.cover),
                )
              else
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF2F7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: const Color(0xFF4A5568)),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF1A202C))),
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppTypography.textTheme.bodyMedium?.copyWith(color: const Color(0xFF4A5568))),
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
                  Text(price, style: AppTypography.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF1A202C))),
                  const SizedBox(height: 2),
                  Text(stockInfo ?? 'per month', style: AppTypography.textTheme.labelSmall?.copyWith(color: const Color(0xFF718096))),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: pillBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(statusPill, style: AppTypography.textTheme.labelSmall?.copyWith(color: pillColor, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.more_vert_rounded, color: Color(0xFF718096)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
