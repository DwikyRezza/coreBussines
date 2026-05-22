// ============================================================
// FEATURE: Analytics - Page
// lib/features/analytics/presentation/pages/analytics_page.dart
// ============================================================

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/core_app_bar.dart';
import '../../../home/domain/entities/home_entities.dart';
import '../../../transactions/domain/entities/transaction_entities.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final _repository = sl<TransactionRepository>();
  final _currency =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  late DateTime _selectedMonth;
  bool _isLoading = true;
  String? _error;
  List<Transaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
    _loadTransactions();
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
        _transactions = transactions;
        _isLoading = false;
      }),
    );
  }

  List<Transaction> get _monthlyTransactions {
    return _transactions.where((transaction) {
      return transaction.dateTime.year == _selectedMonth.year &&
          transaction.dateTime.month == _selectedMonth.month;
    }).toList();
  }

  double get _totalIncome => _monthlyTransactions
      .where((transaction) => transaction.isIncome)
      .fold(0.0, (sum, transaction) => sum + transaction.amount);

  double get _totalExpense => _monthlyTransactions
      .where((transaction) => !transaction.isIncome)
      .fold(0.0, (sum, transaction) => sum + transaction.amount);

  Map<String, double> get _expenseByCategory {
    final grouped = <String, double>{};
    for (final transaction in _monthlyTransactions.where((t) => !t.isIncome)) {
      grouped.update(
        transaction.category,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }
    return Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
  }

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(DateTime.now().year + 1, 12, 31),
      helpText: 'Pilih bulan laporan',
      fieldLabelText: 'Bulan laporan',
    );
    if (picked == null) return;
    setState(() => _selectedMonth = DateTime(picked.year, picked.month));
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat('MMMM yyyy', 'id_ID').format(_selectedMonth);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CoreAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadTransactions,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Ringkasan\nBulanan',
                      style: AppTypography.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _pickMonth,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 112),
                            child: Text(
                              monthLabel,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.textTheme.labelMedium?.copyWith(
                                color: AppColors.primary,
                                height: 1.15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.keyboard_arrow_down_rounded,
                              color: AppColors.primary, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                _MessageCard(message: _error!)
              else ...[
                _SummaryCard(
                  title: 'Omzet Bulan Ini',
                  amount: _currency.format(_totalIncome),
                  trend: _totalIncome > 0 ? 'Aktif' : '-',
                  isPositiveTrend: _totalIncome > 0,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.md),
                _SummaryCard(
                  title: 'Total Pengeluaran',
                  amount: _currency.format(_totalExpense),
                  trend: _totalExpense > 0 ? 'Tercatat' : '-',
                  isPositiveTrend: false,
                  color: const Color(0xFF993300),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Kategori Pengeluaran Terbesar',
                  style: AppTypography.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _CategoryBreakdown(
                  categories: _expenseByCategory,
                  totalExpense: _totalExpense,
                ),
                const SizedBox(height: AppSpacing.xl),
                _InsightCard(
                  monthLabel: DateFormat('MMMM', 'id_ID').format(_selectedMonth),
                  income: _totalIncome,
                  expense: _totalExpense,
                  topCategory:
                      _expenseByCategory.isEmpty ? null : _expenseByCategory.keys.first,
                ),
                const SizedBox(height: AppSpacing.xl),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Laporan PDF sedang disiapkan')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    backgroundColor: const Color(0xFF0D47A1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.picture_as_pdf_outlined,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Unduh Laporan PDF',
                        style: AppTypography.textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  final Map<String, double> categories;
  final double totalExpense;

  const _CategoryBreakdown({
    required this.categories,
    required this.totalExpense,
  });

  static const _colors = [
    Color(0xFF0D47A1),
    Color(0xFF993300),
    Color(0xFF757575),
    Color(0xFF2E7D32),
    Color(0xFF6A1B9A),
  ];

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty || totalExpense <= 0) {
      return const _MessageCard(message: 'Belum ada pengeluaran di bulan ini.');
    }

    final entries = categories.entries.take(5).toList();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                    sections: [
                      for (var i = 0; i < entries.length; i++)
                        PieChartSectionData(
                          color: _colors[i % _colors.length],
                          value: entries[i].value,
                          radius: 20,
                          showTitle: false,
                        ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Total',
                        style: AppTypography.textTheme.labelSmall
                            ?.copyWith(color: AppColors.onSurfaceVariant)),
                    Text('100%',
                        style: AppTypography.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < entries.length; i++) ...[
                  _LegendItem(
                    color: _colors[i % _colors.length],
                    label: entries[i].key,
                    value: '${((entries[i].value / totalExpense) * 100).round()}%',
                  ),
                  if (i != entries.length - 1) const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String monthLabel;
  final double income;
  final double expense;
  final String? topCategory;

  const _InsightCard({
    required this.monthLabel,
    required this.income,
    required this.expense,
    required this.topCategory,
  });

  @override
  Widget build(BuildContext context) {
    final balance = income - expense;
    final message = income == 0 && expense == 0
        ? 'Belum ada data transaksi untuk bulan $monthLabel. Tambahkan transaksi agar insight bisa dihitung.'
        : balance >= 0
            ? 'Berdasarkan data bulan $monthLabel, arus kas Anda positif. Kategori pengeluaran terbesar: ${topCategory ?? 'belum tersedia'}.'
            : 'Berdasarkan data bulan $monthLabel, pengeluaran lebih besar dari pemasukan. Tinjau kategori ${topCategory ?? 'pengeluaran utama'} untuk menjaga arus kas.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFF1A237E), size: 24),
            const SizedBox(width: 8),
            Text(
              'AI Insight',
              style: AppTypography.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryContainer),
          ),
          child: Text(
            message,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF37474F),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _MessageCard extends StatelessWidget {
  final String message;

  const _MessageCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final String trend;
  final bool isPositiveTrend;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.trend,
    required this.isPositiveTrend,
    required this.color,
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
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -24,
            top: -24,
            bottom: -24,
            child: Container(
              width: 6,
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
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      amount,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.textTheme.headlineMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.trending_up_rounded,
                    color: isPositiveTrend ? const Color(0xFF4CAF50) : AppColors.expense,
                    size: 16,
                  ),
                  Text(
                    trend,
                    style: AppTypography.textTheme.labelMedium?.copyWith(
                      color:
                          isPositiveTrend ? const Color(0xFF4CAF50) : AppColors.expense,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.textTheme.bodyMedium
                ?.copyWith(color: AppColors.onBackground),
          ),
        ),
        Text(
          value,
          style: AppTypography.textTheme.bodyMedium
              ?.copyWith(color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }
}
