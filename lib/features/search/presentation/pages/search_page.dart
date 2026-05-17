// ============================================================
// FEATURE: Search — Search Page
// lib/features/search/presentation/pages/search_page.dart
// ============================================================

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

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
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
            
            // Search Input
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2962FF)), // Active blue border
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2962FF).withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search CoreBusiness...',
                  hintStyle: AppTypography.textTheme.bodyLarge?.copyWith(color: const Color(0xFFA0AEC0)),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0D47A1)),
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.mic_none_rounded, color: Color(0xFF4A5568), size: 20),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(label: 'Transactions', icon: Icons.receipt_long_rounded, isSelected: true),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Schedules', icon: Icons.calendar_month_rounded, isSelected: false),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Businesses', icon: Icons.storefront_rounded, isSelected: false),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Recent Searches Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Searches',
                  style: AppTypography.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A202C),
                  ),
                ),
                Text(
                  'Clear',
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF2962FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Recent Searches Chips
            Wrap(
              spacing: 8,
              runSpacing: 12,
              children: [
                _RecentSearchChip(label: 'Yoga mats'),
                _RecentSearchChip(label: 'Downtown Studio'),
                _RecentSearchChip(label: 'Membership renewal'),
              ],
            ),
            const SizedBox(height: 32),

            // Suggested Businesses
            Text(
              'Suggested Businesses',
              style: AppTypography.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A202C),
              ),
            ),
            const SizedBox(height: 16),

            // Large Business Card
            Container(
              padding: const EdgeInsets.all(12),
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=150&h=150&fit=crop', // Gym image
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Apex Performance Center',
                                style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF1A202C)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star_outline_rounded, color: Color(0xFFC53030), size: 14),
                                const SizedBox(width: 2),
                                Text('4.9', style: AppTypography.textTheme.labelSmall?.copyWith(color: const Color(0xFFC53030), fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Premium training facility', style: AppTypography.textTheme.bodyMedium?.copyWith(color: const Color(0xFF4A5568))),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _Tag(label: 'Gym'),
                            const SizedBox(width: 8),
                            _Tag(label: '1.2km'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Grid Business Cards
            Row(
              children: [
                Expanded(
                  child: _SmallBusinessCard(
                    title: 'Zenith Yoga',
                    subtitle: 'Studio',
                    icon: Icons.self_improvement_rounded,
                    iconBg: const Color(0xFF2962FF),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SmallBusinessCard(
                    title: 'City Aquatics',
                    subtitle: 'Facility',
                    icon: Icons.pool_rounded,
                    iconBg: const Color(0xFFDD6B20), // Orange
                  ),
                ),
              ],
            ),
            const SizedBox(height: 100), // Bottom padding
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;

  const _FilterChip({required this.label, required this.icon, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF2962FF) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : const Color(0xFF4A5568)),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: isSelected ? Colors.white : const Color(0xFF4A5568),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentSearchChip extends StatelessWidget {
  final String label;

  const _RecentSearchChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Light grey background
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.history_rounded, size: 16, color: Color(0xFF718096)),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF4A5568),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;

  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTypography.textTheme.labelSmall?.copyWith(color: const Color(0xFF4A5568)),
      ),
    );
  }
}

class _SmallBusinessCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;

  const _SmallBusinessCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
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
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 16),
          Text(title, style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF1A202C))),
          const SizedBox(height: 4),
          Text(subtitle, style: AppTypography.textTheme.bodyMedium?.copyWith(color: const Color(0xFF4A5568))),
        ],
      ),
    );
  }
}
