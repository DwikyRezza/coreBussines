// ============================================================
// FEATURE: Wallets — Wallets Page
// lib/features/wallets/presentation/pages/wallets_page.dart
// ============================================================

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class WalletsPage extends StatelessWidget {
  const WalletsPage({super.key});

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
          children: [
            const SizedBox(height: AppSpacing.xl),
            
            // Total Net Worth Header
            Text(
              'TOTAL NET WORTH',
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: const Color(0xFF4A5568),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '\$',
                    style: AppTypography.textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF718096),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '124,500.00',
                  style: AppTypography.textTheme.displayMedium?.copyWith(
                    color: const Color(0xFF1A202C),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    backgroundColor: const Color(0xFF0D47A1), // Blue
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text('Add Funds', style: AppTypography.textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    backgroundColor: const Color(0xFFE3F2FD), // Light Blue
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.swap_horiz_rounded, color: Color(0xFF0D47A1), size: 18),
                      const SizedBox(width: 8),
                      Text('Transfer', style: AppTypography.textTheme.labelLarge?.copyWith(color: const Color(0xFF0D47A1), fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),

            // Your Wallets Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Wallets',
                  style: AppTypography.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A202C),
                  ),
                ),
                Text(
                  'Manage',
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF2962FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Wallet Cards
            _WalletCard(
              icon: Icons.account_balance_rounded,
              iconColor: const Color(0xFF2962FF),
              iconBg: const Color(0xFFE3F2FD),
              title: 'Bank Accounts',
              amount: '\$118,250.00',
              subtitle: '2 Connected Accounts',
              dotColor: const Color(0xFF2962FF),
            ),
            const SizedBox(height: 16),
            _WalletCard(
              icon: Icons.account_balance_wallet_rounded,
              iconColor: const Color(0xFF1A202C),
              iconBg: const Color(0xFFEDF2F7),
              title: 'E-Wallets',
              amount: '\$5,400.00',
              subtitle: '3 Active Wallets',
              dotColor: const Color(0xFFC53030), // Red
            ),
            const SizedBox(height: 16),
            _WalletCard(
              icon: Icons.payments_rounded,
              iconColor: const Color(0xFF1A202C),
              iconBg: const Color(0xFFEDF2F7),
              title: 'Cash',
              amount: '\$850.00',
              subtitle: 'Physical Currency',
              dotColor: const Color(0xFF718096), // Grey
            ),
            const SizedBox(height: 100), // Bottom padding
          ],
        ),
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String amount;
  final String subtitle;
  final Color dotColor;

  const _WalletCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.dotColor,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(title, style: AppTypography.textTheme.titleMedium?.copyWith(color: const Color(0xFF4A5568))),
                ],
              ),
              const Icon(Icons.more_horiz_rounded, color: Color(0xFF718096)),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            amount,
            style: AppTypography.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A202C),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(subtitle, style: AppTypography.textTheme.bodyMedium?.copyWith(color: const Color(0xFF718096))),
            ],
          ),
        ],
      ),
    );
  }
}
