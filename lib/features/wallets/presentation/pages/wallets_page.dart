// ============================================================
// FEATURE: Wallets — Wallets Page
// lib/features/wallets/presentation/pages/wallets_page.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/core_app_bar.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/di/service_locator.dart';

class WalletsPage extends StatefulWidget {
  const WalletsPage({super.key});

  @override
  State<WalletsPage> createState() => _WalletsPageState();
}

class _WalletsPageState extends State<WalletsPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _localStorage = sl<LocalStorageService>();
  final _fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  bool _isLoading = true;
  double _totalNetWorth = 0;
  List<Map<String, dynamic>> _wallets = [];

  @override
  void initState() {
    super.initState();
    _loadWallets();
  }

  Future<void> _loadWallets() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw StateError('User belum login.');
      }

      String? businessId = _localStorage.activeBusinessId;
      if (businessId == null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        businessId =
            userDoc.data()?['active_business_id'] as String? ?? 'business_${user.uid}';
        await _localStorage.setActiveBusinessId(businessId);
      }

      final res = await _firestore
          .collection('businesses')
          .doc(businessId)
          .collection('wallets')
          .get();

      double total = 0;
      final walletList = <Map<String, dynamic>>[];
      for (final doc in res.docs) {
        final w = doc.data();
        final balance = (w['balance'] as num?)?.toDouble() ?? 0.0;
        total += balance;
        walletList.add({
          'name': w['name'] ?? 'Wallet',
          'type': w['type'] ?? 'cash',
          'balance': balance,
        });
      }

      if (mounted) {
        setState(() {
          _totalNetWorth = total;
          _wallets = walletList;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'bank':
        return Icons.account_balance_rounded;
      case 'ewallet':
      case 'e-wallet':
        return Icons.account_balance_wallet_rounded;
      case 'cash':
      default:
        return Icons.payments_rounded;
    }
  }

  Color _colorForType(String type) {
    switch (type.toLowerCase()) {
      case 'bank':
        return const Color(0xFF2962FF);
      case 'ewallet':
      case 'e-wallet':
        return const Color(0xFF1A202C);
      case 'cash':
      default:
        return const Color(0xFF1A202C);
    }
  }

  Color _bgColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'bank':
        return const Color(0xFFE3F2FD);
      case 'ewallet':
      case 'e-wallet':
        return const Color(0xFFEDF2F7);
      case 'cash':
      default:
        return const Color(0xFFEDF2F7);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CoreAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadWallets,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                    Text(
                      _fmt.format(_totalNetWorth),
                      style: AppTypography.textTheme.displaySmall?.copyWith(
                        color: const Color(0xFF1A202C),
                        fontWeight: FontWeight.w800,
                      ),
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
                            backgroundColor: const Color(0xFF0D47A1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.add, color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Text('Tambah Dana', style: AppTypography.textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            backgroundColor: const Color(0xFFE3F2FD),
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
                          'Dompet Anda',
                          style: AppTypography.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1A202C),
                          ),
                        ),
                        Text(
                          'Kelola',
                          style: AppTypography.textTheme.labelMedium?.copyWith(
                            color: const Color(0xFF2962FF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (_wallets.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.account_balance_wallet_outlined,
                                size: 48, color: AppColors.onSurfaceVariant.withOpacity(0.4)),
                            const SizedBox(height: 12),
                            Text('Belum ada dompet',
                                style: AppTypography.textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                      )
                    else
                      ..._wallets.map((w) {
                        final type = w['type'] as String;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _WalletCard(
                            icon: _iconForType(type),
                            iconColor: _colorForType(type),
                            iconBg: _bgColorForType(type),
                            title: w['name'] as String,
                            amount: _fmt.format(w['balance'] as double),
                            subtitle: type.toUpperCase(),
                            dotColor: _colorForType(type),
                          ),
                        );
                      }),

                    const SizedBox(height: 100),
                  ],
                ),
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
