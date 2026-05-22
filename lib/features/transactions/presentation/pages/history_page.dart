// ============================================================
// FEATURE: Transactions - History Page
// lib/features/transactions/presentation/pages/history_page.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/core_app_bar.dart';
import '../../../home/domain/entities/home_entities.dart';
import '../../domain/entities/transaction_entities.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../../../core/utils/responsive_helper.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _repository = sl<TransactionRepository>();
  final _searchController = TextEditingController();
  final _currency =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final _dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
  bool _isLoading = true;
  String? _error;
  String _query = '';
  TransactionType? _typeFilter;
  List<Transaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
    _loadTransactions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _repository.getFilteredTransactions(
      const TransactionFilter(dateRange: DateRangeFilter.custom),
    );

    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _error = failure.message;
        _isLoading = false;
      }),
      (transactions) => setState(() {
        _transactions = transactions.toList()
          ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
        _isLoading = false;
      }),
    );
  }

  List<Transaction> get _visibleTransactions {
    return _transactions.where((transaction) {
      final matchesType = _typeFilter == null ||
          (_typeFilter == TransactionType.income && transaction.isIncome) ||
          (_typeFilter == TransactionType.expense && !transaction.isIncome);
      final matchesQuery = _query.isEmpty ||
          transaction.title.toLowerCase().contains(_query) ||
          transaction.category.toLowerCase().contains(_query);
      return matchesType && matchesQuery;
    }).toList();
  }

  double get _totalIncome => _visibleTransactions
      .where((transaction) => transaction.isIncome)
      .fold(0.0, (sum, transaction) => sum + transaction.amount);

  double get _totalExpense => _visibleTransactions
      .where((transaction) => !transaction.isIncome)
      .fold(0.0, (sum, transaction) => sum + transaction.amount);

  Map<DateTime, List<Transaction>> get _groupedTransactions {
    final grouped = <DateTime, List<Transaction>>{};
    for (final transaction in _visibleTransactions) {
      final date = DateTime(
        transaction.dateTime.year,
        transaction.dateTime.month,
        transaction.dateTime.day,
      );
      grouped.putIfAbsent(date, () => []).add(transaction);
    }
    return Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Riwayat',
                style: AppTypography.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              _FilterTile(
                title: 'Semua Transaksi',
                selected: _typeFilter == null,
                onTap: () {
                  setState(() => _typeFilter = null);
                  Navigator.pop(context);
                },
              ),
              _FilterTile(
                title: 'Pemasukan',
                selected: _typeFilter == TransactionType.income,
                onTap: () {
                  setState(() => _typeFilter = TransactionType.income);
                  Navigator.pop(context);
                },
              ),
              _FilterTile(
                title: 'Pengeluaran',
                selected: _typeFilter == TransactionType.expense,
                onTap: () {
                  setState(() => _typeFilter = TransactionType.expense);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.pagePadding(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CoreAppBar(),
      body: ResponsiveHelper.constrainWidth(
        context: context,
        child: RefreshIndicator(
          onRefresh: _loadTransactions,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                              child: Row(
                                children: [
                                  Icon(Icons.search_rounded,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant, size: 22),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Cari transaksi...',
                                        hintStyle:
                                            AppTypography.textTheme.bodyMedium?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          SizedBox(
                            height: 52,
                            child: FilledButton.icon(
                              onPressed: _showFilterSheet,
                              icon: const Icon(Icons.filter_list_rounded),
                              label: const Text('Filter'),
                              style: FilledButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            title: 'Total Pemasukan',
                            amount: _currency.format(_totalIncome),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _SummaryCard(
                            title: 'Total Pengeluaran',
                            amount: _currency.format(_totalExpense),
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _HistoryMessage(message: _error!),
              )
            else if (_visibleTransactions.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _HistoryMessage(
                  message: 'Belum ada transaksi real yang cocok.',
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final entries = _groupedTransactions.entries.toList();
                      final entry = entries[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DateHeader(
                            label: _dateLabel(entry.key),
                            date: _dateFormat.format(entry.key),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          if (ResponsiveHelper.isTabletOrLarger(context))
                            Builder(
                              builder: (context) {
                                final totalWidth = MediaQuery.sizeOf(context).width;
                                final contentWidth = totalWidth > ResponsiveHelper.maxContentWidth(context)
                                    ? ResponsiveHelper.maxContentWidth(context)
                                    : totalWidth;
                                final availableWidth = contentWidth - 2 * padding;
                                final cardWidth = (availableWidth - 16) / 2;
                                return Wrap(
                                  spacing: 16,
                                  runSpacing: 12,
                                  children: [
                                    for (final transaction in entry.value)
                                      SizedBox(
                                        width: cardWidth,
                                        child: _TransactionItem(
                                          icon: _iconFor(transaction),
                                          iconColor: transaction.isIncome
                                              ? Theme.of(context).colorScheme.primary
                                              : Theme.of(context).colorScheme.error,
                                          iconBg: transaction.isIncome
                                              ? Theme.of(context).colorScheme.primaryContainer
                                              : Theme.of(context).colorScheme.errorContainer,
                                          title: transaction.title,
                                          category: transaction.category,
                                          amount:
                                              '${transaction.isIncome ? '+' : '-'} ${_currency.format(transaction.amount)}',
                                          time: DateFormat('HH:mm').format(transaction.dateTime),
                                          isIncome: transaction.isIncome,
                                          onTap: () => context.push(
                                            AppRoutes.transactionDetail.replaceAll(
                                              ':id',
                                              transaction.id,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              }
                            )
                          else
                            for (final transaction in entry.value)
                              _TransactionItem(
                                icon: _iconFor(transaction),
                                iconColor: transaction.isIncome
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.error,
                                iconBg: transaction.isIncome
                                    ? Theme.of(context).colorScheme.primaryContainer
                                    : Theme.of(context).colorScheme.errorContainer,
                                title: transaction.title,
                                category: transaction.category,
                                amount:
                                    '${transaction.isIncome ? '+' : '-'} ${_currency.format(transaction.amount)}',
                                time: DateFormat('HH:mm').format(transaction.dateTime),
                                isIncome: transaction.isIncome,
                                onTap: () => context.push(
                                  AppRoutes.transactionDetail.replaceAll(
                                    ':id',
                                    transaction.id,
                                  ),
                                ),
                              ),
                          const SizedBox(height: AppSpacing.lg),
                          if (index == entries.length - 1) const SizedBox(height: 82),
                        ],
                      );
                    },
                    childCount: _groupedTransactions.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      ),
    );
  }

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (date == today) return 'HARI INI';
    if (date == yesterday) return 'KEMARIN';
    return DateFormat('EEEE', 'id_ID').format(date).toUpperCase();
  }

  IconData _iconFor(Transaction transaction) {
    final text = '${transaction.category} ${transaction.categoryIcon}'.toLowerCase();
    if (transaction.isIncome) return Icons.payments_rounded;
    if (text.contains('makan') || text.contains('food')) return Icons.restaurant_rounded;
    if (text.contains('transport')) return Icons.directions_car_rounded;
    if (text.contains('tagihan') || text.contains('bill') || text.contains('listrik')) {
      return Icons.receipt_long_rounded;
    }
    if (text.contains('kesehatan') || text.contains('health')) {
      return Icons.health_and_safety_rounded;
    }
    return Icons.shopping_bag_rounded;
  }
}

class _FilterTile extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _FilterTile({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: Icon(
        selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
        color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -16,
            top: -16,
            bottom: -16,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                amount,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  final String label;
  final String date;

  const _DateHeader({required this.label, required this.date});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          date,
          style: AppTypography.textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String category;
  final String amount;
  final String time;
  final bool isIncome;
  final VoidCallback onTap;

  const _TransactionItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.category,
    required this.amount,
    required this.time,
    required this.isIncome,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    category,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 132),
                  child: Text(
                    amount,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isIncome ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryMessage extends StatelessWidget {
  final String message;

  const _HistoryMessage({required this.message});

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