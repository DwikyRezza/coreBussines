// ============================================================
// FEATURE: Transactions — Add Transaction Page
// lib/features/transactions/presentation/pages/add_transaction_page.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  int _transactionType = 0; // 0: Pengeluaran, 1: Pemasukan
  int _selectedCategory = 0;
  int _selectedWallet = 0;
  bool _isRecurring = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Tambah Transaksi',
          style: AppTypography.textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.receipt_long_rounded, color: AppColors.onBackground, size: 20),
            ),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type Segments
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _transactionType = 0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _transactionType == 0 ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: _transactionType == 0
                                    ? [BoxShadow(color: AppColors.shadow.withOpacity(0.05), blurRadius: 4)]
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Pengeluaran',
                                style: AppTypography.textTheme.labelLarge?.copyWith(
                                  color: _transactionType == 0 ? AppColors.primary : AppColors.onSurfaceVariant,
                                  fontWeight: _transactionType == 0 ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _transactionType = 1),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _transactionType == 1 ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: _transactionType == 1
                                    ? [BoxShadow(color: AppColors.shadow.withOpacity(0.05), blurRadius: 4)]
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Pemasukan',
                                style: AppTypography.textTheme.labelLarge?.copyWith(
                                  color: _transactionType == 1 ? AppColors.primary : AppColors.onSurfaceVariant,
                                  fontWeight: _transactionType == 1 ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Amount Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow.withOpacity(0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Jumlah Transaksi',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: AppColors.onBackground,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rp',
                              style: AppTypography.textTheme.headlineMedium?.copyWith(
                                color: AppColors.primary.withOpacity(0.6),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '0',
                              style: AppTypography.textTheme.displayMedium?.copyWith(
                                color: AppColors.outlineVariant,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Category
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kategori',
                        style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text('Lihat Semua', style: AppTypography.textTheme.labelMedium?.copyWith(color: AppColors.primary)),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 12,
                    children: [
                      _CategoryChip(icon: Icons.restaurant, label: 'Makanan', isSelected: _selectedCategory == 0, onTap: () => setState(() => _selectedCategory = 0)),
                      _CategoryChip(icon: Icons.directions_car, label: 'Transportasi', isSelected: _selectedCategory == 1, onTap: () => setState(() => _selectedCategory = 1)),
                      _CategoryChip(icon: Icons.shopping_bag, label: 'Belanja', isSelected: _selectedCategory == 2, onTap: () => setState(() => _selectedCategory = 2)),
                      _CategoryChip(icon: Icons.movie, label: 'Hiburan', isSelected: _selectedCategory == 3, onTap: () => setState(() => _selectedCategory = 3)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Wallet
                  Text(
                    'Pilih Dompet',
                    style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(child: _WalletCard(icon: Icons.account_balance, label: 'Bank', isSelected: _selectedWallet == 0, onTap: () => setState(() => _selectedWallet = 0))),
                      const SizedBox(width: 12),
                      Expanded(child: _WalletCard(icon: Icons.payments, label: 'Tunai', isSelected: _selectedWallet == 1, onTap: () => setState(() => _selectedWallet = 1))),
                      const SizedBox(width: 12),
                      Expanded(child: _WalletCard(icon: Icons.account_balance_wallet, label: 'E-Wallet', isSelected: _selectedWallet == 2, onTap: () => setState(() => _selectedWallet = 2))),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Notes
                  Text(
                    'Catatan',
                    style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: TextField(
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Tambahkan deskripsi transaksi di sini...',
                        hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Recurring
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.restore_rounded, color: AppColors.primary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Transaksi Berulang', style: AppTypography.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
                              Text('Setel sebagai pengeluaran bulanan', style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: _isRecurring,
                          onChanged: (val) => setState(() => _isRecurring = val),
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
          
          // Submit Button
          Container(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            decoration: BoxDecoration(
              color: AppColors.background,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Simpan Transaksi', style: AppTypography.textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({required this.icon, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? AppColors.primary : AppColors.onBackground),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: isSelected ? AppColors.primary : AppColors.onBackground,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _WalletCard({required this.icon, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.outlineVariant, width: isSelected ? 2 : 1),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))] : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.onBackground),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: isSelected ? AppColors.primary : AppColors.onBackground,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
