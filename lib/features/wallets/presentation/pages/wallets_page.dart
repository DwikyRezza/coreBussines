// ============================================================
// FEATURE: Wallets — Wallets Page
// lib/features/wallets/presentation/pages/wallets_page.dart
// ============================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
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
  final _fmt =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  bool _isLoading = true;
  double _totalNetWorth = 0;
  List<Map<String, dynamic>> _wallets = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _walletSubscription;

  @override
  void initState() {
    super.initState();
    _loadWallets();
  }

  @override
  void dispose() {
    _walletSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadWallets() async {
    try {
      await _walletSubscription?.cancel();
      final user = _auth.currentUser;
      if (user == null) {
        throw StateError('User belum login.');
      }

      String? businessId = _localStorage.activeBusinessId;
      if (businessId == null) {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        businessId = userDoc.data()?['active_business_id'] as String? ??
            'business_${user.uid}';
        await _localStorage.setActiveBusinessId(businessId);
      }

      final query = _firestore
          .collection('businesses')
          .doc(businessId)
          .collection('wallets');

      _walletSubscription = query.snapshots().listen((res) {
        double total = 0;
        final walletList = <Map<String, dynamic>>[];
        for (final doc in res.docs) {
          final w = doc.data();
          final balance = (w['balance'] as num?)?.toDouble() ?? 0.0;
          total += balance;
          walletList.add({
            'id': doc.id,
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
      }, onError: (_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
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
        return Theme.of(context).colorScheme.primary;
      case 'ewallet':
      case 'e-wallet':
        return Theme.of(context).colorScheme.onSurface;
      case 'cash':
      default:
        return Theme.of(context).colorScheme.onSurface;
    }
  }

  Color _bgColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'bank':
        return const Color(0xFFE3F2FD);
      case 'ewallet':
      case 'e-wallet':
        return Theme.of(context).colorScheme.surfaceContainerHighest;
      case 'cash':
      default:
        return Theme.of(context).colorScheme.surfaceContainerHighest;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CoreAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadWallets,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pagePadding),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.xl),

                    // Total Net Worth Header
                    Text(
                      'TOTAL NET WORTH',
                      style: AppTypography.textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _fmt.format(_totalNetWorth),
                      style: AppTypography.textTheme.displaySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.add,
                                  color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Text('Tambah Dana',
                                  style: AppTypography.textTheme.labelLarge
                                      ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            backgroundColor: const Color(0xFFE3F2FD),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.swap_horiz_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 18),
                              const SizedBox(width: 8),
                              Text('Transfer',
                                  style: AppTypography.textTheme.labelLarge
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontWeight: FontWeight.w600)),
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
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Kelola',
                          style: AppTypography.textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
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
                                size: 48,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant
                                    .withOpacity(0.4)),
                            const SizedBox(height: 12),
                            Text('Belum ada dompet',
                                style: AppTypography.textTheme.bodyMedium
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant)),
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
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.03),
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
                    decoration:
                        BoxDecoration(color: iconBg, shape: BoxShape.circle),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(title,
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ),
              Icon(Icons.more_horiz_rounded,
                  color: Theme.of(context).colorScheme.outline),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            amount,
            style: AppTypography.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                  width: 8,
                  height: 8,
                  decoration:
                      BoxDecoration(color: dotColor, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(subtitle,
                  style: AppTypography.textTheme.bodyMedium
                      ?.copyWith(color: Theme.of(context).colorScheme.outline)),
            ],
          ),
        ],
      ),
    );
  }
}
