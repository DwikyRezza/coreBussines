// ============================================================
// FEATURE: Transactions - Transaction Detail Page
// lib/features/transactions/presentation/pages/transaction_detail_page.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/core_app_bar.dart';
import '../../domain/entities/transaction_entities.dart';
import '../../domain/repositories/transaction_repository.dart';

class TransactionDetailPage extends StatelessWidget {
  final String transactionId;

  const TransactionDetailPage({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context) {
    final repository = sl<TransactionRepository>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CoreAppBar(),
      body: StreamBuilder(
        stream: repository.watchTransactionDetail(transactionId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return snapshot.data!.fold(
            (failure) => _MessageView(message: failure.message),
            (detail) => _TransactionDetailContent(
              detail: detail,
              onDelete: () => _confirmDelete(context, repository, detail.id),
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    TransactionRepository repository,
    String id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus transaksi?'),
        content: const Text(
          'Saldo wallet akan dikembalikan sesuai nominal transaksi ini.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    final result = await repository.deleteTransaction(id);
    if (!context.mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi berhasil dihapus.')),
        );
        context.pop();
      },
    );
  }
}

class _TransactionDetailContent extends StatelessWidget {
  final TransactionDetail detail;
  final VoidCallback onDelete;

  const _TransactionDetailContent({
    required this.detail,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final amountColor = detail.isIncome ? colors.primary : colors.error;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: amountColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        detail.isIncome
                            ? Icons.trending_up_rounded
                            : Icons.receipt_long_rounded,
                        color: amountColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            detail.title,
                            style: AppTypography.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            detail.category,
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  AppFormatter.currency(
                    detail.isIncome ? detail.amount : -detail.amount,
                    showSign: true,
                  ),
                  style: AppTypography.textTheme.displaySmall?.copyWith(
                    color: amountColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                _InfoRow(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Wallet',
                  value: detail.walletName ?? detail.paymentMethod,
                ),
                _InfoRow(
                  icon: Icons.calendar_month_outlined,
                  label: 'Tanggal',
                  value:
                      '${AppFormatter.fullDate(detail.dateTime)} ${AppFormatter.timeWib(detail.dateTime)}',
                ),
                _InfoRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Dicatat oleh',
                  value: detail.createdByName ?? 'Pengguna',
                ),
                if (detail.createdByRole != null)
                  _InfoRow(
                    icon: Icons.verified_user_outlined,
                    label: 'Role',
                    value: detail.createdByRole == 'owner' ? 'Owner' : 'Staff',
                  ),
                if (detail.note?.trim().isNotEmpty == true)
                  _InfoRow(
                    icon: Icons.notes_rounded,
                    label: 'Catatan',
                    value: detail.note!,
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (detail.receiptImageUrl != null) ...[
            Text(
              'Bukti Pembayaran',
              style: AppTypography.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                detail.receiptImageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 160,
                  alignment: Alignment.center,
                  color: colors.surfaceContainerHighest,
                  child: const Text('Gagal memuat gambar struk.'),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
          OutlinedButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Hapus Transaksi'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.error,
              side: BorderSide(color: colors.error),
              minimumSize: const Size.fromHeight(52),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
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
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  final String message;

  const _MessageView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTypography.textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
