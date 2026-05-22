import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/home_entities.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/home_widgets.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/responsive_helper.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Use DI — avoids hardcoded datasource, fully testable via sl mock swap
      create: (_) => sl<HomeBloc>()..add(const HomeLoadRequested()),
      child: const _HomeView(),
    );
  }
}


class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return _HomeSkeletonLoader();
          }
          if (state is HomeError) {
            return _HomeErrorView(message: state.message);
          }
          if (state is HomeLoaded) {
            return _HomeContent(state: state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// MAIN CONTENT
// ─────────────────────────────────────────────────────────────
class _HomeContent extends StatelessWidget {
  final HomeLoaded state;

  const _HomeContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.pagePadding(context);
    final isTablet = ResponsiveHelper.isTabletOrLarger(context);

    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      onRefresh: () async {
        final bloc = context.read<HomeBloc>();
        bloc.add(const HomeRefreshRequested());
        await bloc.stream.firstWhere(
            (state) => state is HomeLoaded || state is HomeError);
      },
      child: ResponsiveHelper.constrainWidth(
        context: context,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // AppBar
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              scrolledUnderElevation: 0,
              titleSpacing: padding,
              title: _HomeAppBar(state: state),
            ),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: AppSpacing.base),

                  if (isTablet)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left column
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BalanceCard(summary: state.summary),
                              const SizedBox(height: AppSpacing.xl),
                              const QuickActionsGrid(),
                              const SizedBox(height: AppSpacing.xl),
                              HomeInsightCard(insight: state.insight),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Right column
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FinanceChartSection(transactions: state.allTransactions),
                              const SizedBox(height: AppSpacing.xl),
                              SectionHeader(
                                title: 'Transaksi Terakhir',
                                actionLabel: 'Semua',
                                onAction: () => context.go(AppRoutes.history),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              ...state.recentTransactions.map(
                                (txn) => Column(
                                  children: [
                                    TransactionTile(transaction: txn),
                                    if (txn != state.recentTransactions.last)
                                      Divider(
                                        height: 1,
                                        indent: AppSpacing.pagePadding,
                                        endIndent: AppSpacing.pagePadding,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outlineVariant
                                            .withOpacity(0.4),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BalanceCard(summary: state.summary),
                        const SizedBox(height: AppSpacing.xl),
                        const QuickActionsGrid(),
                        const SizedBox(height: AppSpacing.xl),
                        HomeInsightCard(insight: state.insight),
                        const SizedBox(height: AppSpacing.xl),
                        _FinanceChartSection(transactions: state.allTransactions),
                        const SizedBox(height: AppSpacing.xl),
                        SectionHeader(
                          title: 'Transaksi Terakhir',
                          actionLabel: 'Semua',
                          onAction: () => context.go(AppRoutes.history),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ...state.recentTransactions.map(
                          (txn) => Column(
                            children: [
                              TransactionTile(transaction: txn),
                              if (txn != state.recentTransactions.last)
                                Divider(
                                  height: 1,
                                  indent: AppSpacing.pagePadding,
                                  endIndent: AppSpacing.pagePadding,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant
                                      .withOpacity(0.4),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 100), // Bottom nav clearance
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeAppBar extends StatelessWidget {
  final HomeLoaded state;

  const _HomeAppBar({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar + Greeting
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              backgroundImage: state.summary.userPhotoUrl != null
                  ? NetworkImage(state.summary.userPhotoUrl!)
                  : null,
              child: state.summary.userPhotoUrl == null
                  ? Text(
                      state.summary.userName[0].toUpperCase(),
                      style: AppTypography.textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo,',
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  state.summary.userName,
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Notification Bell
        IconButton(
          icon: Badge(
            smallSize: 8,
            backgroundColor: Theme.of(context).colorScheme.error,
            child: const Icon(Icons.notifications_outlined),
          ),
          color: Theme.of(context).colorScheme.onSurface,
          onPressed: () {},
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// WEEKLY CHART SECTION (Bar chart placeholder + tab)
// ─────────────────────────────────────────────────────────────
class _WeeklyChartSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    // Mock bar heights (normalized 0.0–1.0)
    const values = [0.6, 0.3, 0.85, 0.45, 0.7, 0.55, 0.2];
    const activeDay = 4; // Friday

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Analisis Mingguan',
          actionLabel: 'Lihat Detail',
          onAction: () => context.go(AppRoutes.analytics),
        ),
        const SizedBox(height: AppSpacing.base),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              // Bar chart
              SizedBox(
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (i) {
                    final isActive = i == activeDay;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300 + i * 50),
                          curve: Curves.easeOutBack,
                          width: 28,
                          height: values[i] * 80,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primary
                                : Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Day labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (i) {
                  final isActive = i == activeDay;
                  return Text(
                    days[i],
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: isActive
                          ? AppColors.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight:
                          isActive ? FontWeight.w700 : FontWeight.w400,
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SKELETON LOADER
// ─────────────────────────────────────────────────────────────
enum _ChartPeriod { weekly, monthly, yearly, custom }

class _FinanceChartSection extends StatefulWidget {
  final List<Transaction> transactions;

  const _FinanceChartSection({required this.transactions});

  @override
  State<_FinanceChartSection> createState() => _FinanceChartSectionState();
}

class _FinanceChartSectionState extends State<_FinanceChartSection> {
  _ChartPeriod _period = _ChartPeriod.weekly;
  DateTimeRange? _customRange;

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _customRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 6)),
            end: now,
          ),
    );

    if (range == null) return;
    setState(() {
      _period = _ChartPeriod.custom;
      _customRange = range;
    });
  }

  @override
  Widget build(BuildContext context) {
    final buckets = _buildBuckets();
    final maxValue = buckets.fold<double>(0, (max, bucket) {
      final bucketMax =
          bucket.income > bucket.expense ? bucket.income : bucket.expense;
      return max > bucketMax ? max : bucketMax;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: _title,
          actionLabel: 'Lihat Detail',
          onAction: () => context.go(AppRoutes.analytics),
        ),
        const SizedBox(height: AppSpacing.base),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _PeriodChip(
                      label: 'Mingguan',
                      selected: _period == _ChartPeriod.weekly,
                      onTap: () => setState(() => _period = _ChartPeriod.weekly),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _PeriodChip(
                      label: 'Bulanan',
                      selected: _period == _ChartPeriod.monthly,
                      onTap: () => setState(() => _period = _ChartPeriod.monthly),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _PeriodChip(
                      label: 'Tahunan',
                      selected: _period == _ChartPeriod.yearly,
                      onTap: () => setState(() => _period = _ChartPeriod.yearly),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _pickCustomRange,
                  icon: const Icon(Icons.date_range_rounded, size: 18),
                  label: Text(
                    _customRangeLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              SizedBox(
                height: 130,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: buckets.map((bucket) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _FinanceBar(
                              value: bucket.income,
                              maxValue: maxValue,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            _FinanceBar(
                              value: bucket.expense,
                              maxValue: maxValue,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SizedBox(
                          width: 38,
                          child: Text(
                            bucket.label,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LegendDot(color: Theme.of(context).colorScheme.primary, label: 'Pemasukan'),
                  SizedBox(width: 16),
                  _LegendDot(color: Theme.of(context).colorScheme.error, label: 'Pengeluaran'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String get _title {
    switch (_period) {
      case _ChartPeriod.weekly:
        return 'Analisis Mingguan';
      case _ChartPeriod.monthly:
        return 'Analisis Bulanan';
      case _ChartPeriod.yearly:
        return 'Analisis Tahunan';
      case _ChartPeriod.custom:
        return 'Analisis Kustom';
    }
  }

  String get _customRangeLabel {
    if (_customRange == null) return 'Pilih tanggal sendiri';
    final formatter = DateFormat('d MMM yyyy', 'id_ID');
    return '${formatter.format(_customRange!.start)} - ${formatter.format(_customRange!.end)}';
  }

  List<_ChartBucket> _buildBuckets() {
    final now = DateTime.now();
    switch (_period) {
      case _ChartPeriod.weekly:
        final start = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));
        const labels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
        return List.generate(7, (index) {
          final date = start.add(Duration(days: index));
          return _bucketFor(labels[index], date, date);
        });
      case _ChartPeriod.monthly:
        final first = DateTime(now.year, now.month);
        return List.generate(5, (index) {
          final start = first.add(Duration(days: index * 7));
          final end = start.add(const Duration(days: 6));
          return _bucketFor('M${index + 1}', start, end);
        });
      case _ChartPeriod.yearly:
        return List.generate(12, (index) {
          final start = DateTime(now.year, index + 1);
          final end =
              DateTime(now.year, index + 2).subtract(const Duration(days: 1));
          return _bucketFor(DateFormat('MMM', 'id_ID').format(start), start, end);
        });
      case _ChartPeriod.custom:
        final range = _customRange ??
            DateTimeRange(
              start: now.subtract(const Duration(days: 6)),
              end: now,
            );
        final totalDays = range.end.difference(range.start).inDays + 1;
        if (totalDays <= 10) {
          return List.generate(totalDays, (index) {
            final date = range.start.add(Duration(days: index));
            return _bucketFor(DateFormat('d/M').format(date), date, date);
          });
        }

        const bucketCount = 6;
        final step = (totalDays / bucketCount).ceil();
        return List.generate(bucketCount, (index) {
          final start = range.start.add(Duration(days: index * step));
          var end = start.add(Duration(days: step - 1));
          if (end.isAfter(range.end)) end = range.end;
          return _bucketFor(DateFormat('d/M').format(start), start, end);
        });
    }
  }

  _ChartBucket _bucketFor(String label, DateTime start, DateTime end) {
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day, 23, 59, 59);
    double income = 0;
    double expense = 0;

    for (final transaction in widget.transactions) {
      final date = transaction.dateTime;
      if (date.isBefore(normalizedStart) || date.isAfter(normalizedEnd)) {
        continue;
      }

      if (transaction.isIncome) {
        income += transaction.amount;
      } else {
        expense += transaction.amount;
      }
    }

    return _ChartBucket(label: label, income: income, expense: expense);
  }
}

class _ChartBucket {
  final String label;
  final double income;
  final double expense;

  const _ChartBucket({
    required this.label,
    required this.income,
    required this.expense,
  });
}

class _FinanceBar extends StatelessWidget {
  final double value;
  final double maxValue;
  final Color color;

  const _FinanceBar({
    required this.value,
    required this.maxValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final height = maxValue <= 0 ? 6.0 : 8 + (value / maxValue * 82);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      width: 12,
      height: height,
      decoration: BoxDecoration(
        color: value <= 0 ? color.withOpacity(0.18) : color,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTypography.textTheme.labelSmall),
      ],
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.textTheme.labelSmall?.copyWith(
            color: selected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _HomeSkeletonLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        80,
        AppSpacing.pagePadding,
        AppSpacing.pagePadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance card skeleton
          const SkeletonBox(
            width: double.infinity,
            height: 140,
            borderRadius: AppSpacing.radiusXl,
          ),
          const SizedBox(height: AppSpacing.xl),
          // Quick actions skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              4,
              (_) => const SkeletonBox(width: 64, height: 80, borderRadius: AppSpacing.radiusLg),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Insight card skeleton
          const SkeletonBox(width: double.infinity, height: 80, borderRadius: AppSpacing.radiusLg),
          const SizedBox(height: AppSpacing.xl),
          // Transaction list skeletons
          ...List.generate(
            4,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                children: [
                  const SkeletonBox(width: 46, height: 46, borderRadius: AppSpacing.radiusMd),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SkeletonBox(width: 120, height: 14),
                      SizedBox(height: 6),
                      SkeletonBox(width: 80, height: 12),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ERROR VIEW
// ─────────────────────────────────────────────────────────────
class _HomeErrorView extends StatelessWidget {
  final String message;

  const _HomeErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.base),
            Text(
              'Gagal Memuat Data',
              style: AppTypography.textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () {
                context.read<HomeBloc>().add(const HomeLoadRequested());
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}