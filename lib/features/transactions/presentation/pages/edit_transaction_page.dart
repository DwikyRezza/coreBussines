// ============================================================
// FEATURE: Transactions — Edit Transaction Page
// lib/features/transactions/presentation/pages/edit_transaction_page.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class EditTransactionPage extends StatelessWidget {
  final String transactionId;

  const EditTransactionPage({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Ubah Transaksi',
          style: AppTypography.textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.expense),
            onPressed: () {},
          ),
        ],
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              child: Column(
                children: [
                  // Amount Display
                  Text(
                    'Jumlah Pengeluaran',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rp',
                        style: AppTypography.textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '45.000',
                        style: AppTypography.textTheme.displayMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Main Form Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kategori',
                            style: AppTypography.textTheme.bodyMedium
                                ?.copyWith(color: AppColors.onSurfaceVariant)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFDECEA),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.restaurant_rounded,
                                    color: AppColors.expense, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Makan & Minum',
                                        style: AppTypography
                                            .textTheme.labelLarge
                                            ?.copyWith(
                                                fontWeight: FontWeight.w700)),
                                    Text('Pengeluaran Rutin',
                                        style: AppTypography.textTheme.bodySmall
                                            ?.copyWith(
                                                color: AppColors
                                                    .onSurfaceVariant)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.onSurfaceVariant),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text('Judul Transaksi',
                            style: AppTypography.textTheme.bodyMedium
                                ?.copyWith(color: AppColors.onSurfaceVariant)),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          child: TextField(
                            controller:
                                TextEditingController(text: 'Makan Siang'),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Wallet & Date Row
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Dompet',
                                  style: AppTypography.textTheme.bodyMedium
                                      ?.copyWith(
                                          color: AppColors.onSurfaceVariant)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                      Icons.account_balance_wallet_outlined,
                                      color: AppColors.primary,
                                      size: 18),
                                  const SizedBox(width: 8),
                                  Text('Wallet: Cash',
                                      style: AppTypography.textTheme.labelMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.w700)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('Saldo: Rp 1.200.000',
                                  style: AppTypography.textTheme.bodySmall
                                      ?.copyWith(
                                          color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tanggal',
                                  style: AppTypography.textTheme.bodyMedium
                                      ?.copyWith(
                                          color: AppColors.onSurfaceVariant)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined,
                                      color: AppColors.primary, size: 18),
                                  const SizedBox(width: 8),
                                  Text('24 Mei 2024',
                                      style: AppTypography.textTheme.labelMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.w700)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('12:45 WIB',
                                  style: AppTypography.textTheme.bodySmall
                                      ?.copyWith(
                                          color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Notes
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Catatan (Opsional)',
                            style: AppTypography.textTheme.bodyMedium
                                ?.copyWith(color: AppColors.onSurfaceVariant)),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          child: TextField(
                            controller: TextEditingController(
                                text:
                                    'Makan siang bersama tim di Warung Padang.'),
                            maxLines: 3,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Attachment
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.receipt_long,
                              color: AppColors.outlineVariant), // Mock image
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Struk Terlampir',
                                  style: AppTypography.textTheme.labelMedium
                                      ?.copyWith(fontWeight: FontWeight.w700)),
                              Text('receipt_lunch_2405.jpg',
                                  style: AppTypography.textTheme.bodySmall
                                      ?.copyWith(
                                          color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        const Icon(Icons.edit_rounded,
                            color: AppColors.primary, size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100), // Space for floating button
                ],
              ),
            ),
          ),

          // Save Button (Floating above bottom nav)
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.pagePadding, 0,
                AppSpacing.pagePadding, AppSpacing.pagePadding),
            child: ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
              child: Text('Simpan Perubahan',
                  style: AppTypography.textTheme.labelLarge?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(
              height:
                  80), // Additional bottom padding because ShellRoute's BottomNav might overlay
        ],
      ),
    );
  }
}
