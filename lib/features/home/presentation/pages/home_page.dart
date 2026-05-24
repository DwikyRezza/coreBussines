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
import '../../../../core/services/business_context_service.dart';
import '../../../notifications/data/services/weekly_summary_notification_service.dart';
import '../../../notifications/domain/repositories/notification_repository.dart';
import '../widgets/business_setup_score_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        sl<WeeklySummaryNotificationService>()
            .ensureCurrentWeekSummary()
            .catchError((_) {});
        return sl<HomeBloc>()..add(const HomeLoadRequested());
      },
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
// MAIN CONTENT (ADAPTIVE & PREMIUM)
// ─────────────────────────────────────────────────────────────
class _HomeContent extends StatelessWidget {
  final HomeLoaded state;

  const _HomeContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.pagePadding(context);

    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      onRefresh: () async {
        final bloc = context.read<HomeBloc>();
        bloc.add(const HomeRefreshRequested());
        await bloc.stream
            .firstWhere((state) => state is HomeLoaded || state is HomeError);
      },
      child: ResponsiveHelper.constrainWidth(
        context: context,
        child: FutureBuilder<BusinessContext>(
          future: sl<BusinessContextService>().getCurrentContext(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final businessContext = snapshot.data!;
            final role = businessContext.role;
            final cleanRole = role.toLowerCase();

            // Build dynamic list of widgets for CustomScrollView
            return CustomScrollView(
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
                  title: _HomeAppBar(state: state, role: role),
                ),

                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: AppSpacing.base),

                    const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.pagePadding),
                      child: BusinessSetupScoreCard(),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // 1. TAMPILKAN METRIK UTAMA ADAPTIF BERDASARKAN ROLE
                    _buildAdaptiveHeaderCard(context, cleanRole),

                    const SizedBox(height: AppSpacing.xl),

                    // 2. TAMPILKAN TOMBOL PINTASAN CEPAT CEPAT SECARA ADAPTIF
                    _buildAdaptiveQuickActions(context, cleanRole),

                    const SizedBox(height: AppSpacing.xl),

                    // 3. TAMPILKAN AI INSIGHTS JIKA BUKAN KASIR / INVENTORY
                    if (cleanRole != 'cashier' && cleanRole != 'inventory') ...[
                      HomeInsightCard(insight: state.insight),
                      const SizedBox(height: AppSpacing.xl),
                    ],

                    // 4. TAMPILKAN GRAFIK CASHFLOW HANYA UNTUK OWNER, ADMIN, FINANCE, AUDITOR
                    if (cleanRole == 'owner' ||
                        cleanRole == 'admin' ||
                        cleanRole == 'finance' ||
                        cleanRole == 'auditor') ...[
                      _FinanceChartSection(transactions: state.allTransactions),
                      const SizedBox(height: AppSpacing.xl),
                    ],

                    // 5. TRANSAKSI TERAKHIR (Daftar)
                    SectionHeader(
                      title: cleanRole == 'cashier' || cleanRole == 'sales'
                          ? 'Transaksi Terakhir Saya'
                          : 'Transaksi Terakhir',
                      actionLabel: 'Semua',
                      onAction: () => context.go(AppRoutes.history),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Rendering List Transaksi
                    if (state.recentTransactions.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'Belum ada transaksi tercatat.',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                    else
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
                    const SizedBox(height: 120), // Bottom nav clearance
                  ]),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Card Metrik Utama Adaptif
  Widget _buildAdaptiveHeaderCard(BuildContext context, String role) {
    final colors = Theme.of(context).colorScheme;

    if (role == 'cashier') {
      // Dashboard Kasir: Sembunyikan profit penuh & total saldo bisnis
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.primary, colors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'DASHBOARD KASIR AKTIF',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.circle, color: Colors.green, size: 8),
                      SizedBox(width: 4),
                      Text('Online',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Mesin Kasir Siap',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 26,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Catat transaksi penjualan & scan struk pelanggan Anda secara cepat.',
              style:
                  TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
            ),
          ],
        ),
      );
    } else if (role == 'inventory') {
      // Dashboard Inventory: Tampilkan log stok & persediaan barang
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.tertiaryContainer, colors.primaryContainer],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
          border: Border.all(color: colors.outlineVariant.withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'INVENTORY STAFF',
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
                Icon(Icons.warehouse_rounded, color: colors.primary),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Stok Aman & Terkendali',
              style: TextStyle(
                color: colors.onSurface,
                fontWeight: FontWeight.w800,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Peringatan: 3 Item stok hampir habis! Periksa katalog inventaris segera.',
              style: TextStyle(
                  color: colors.error,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    } else if (role == 'sales') {
      // Dashboard Sales: Ringkasan kinerja penjualan saya
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.secondaryContainer, colors.surfaceContainerHighest],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SALES KINERJA HARI INI',
                  style: TextStyle(
                    color: colors.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
                Icon(Icons.trending_up_rounded, color: colors.secondary),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Fokus Target Penjualan',
              style: TextStyle(
                color: colors.onSurface,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Catat semua pencapaian deals & transaksi penjualan Anda secara real-time.',
              style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
            ),
          ],
        ),
      );
    }

    // Default Owner/Admin/Finance/Auditor/Manager: Balance card lengkap
    return BalanceCard(summary: state.summary);
  }

  // Quick actions dinamis berdasarkan role
  Widget _buildAdaptiveQuickActions(BuildContext context, String role) {
    final colors = Theme.of(context).colorScheme;

    if (role == 'viewer' || role == 'auditor') {
      return const SizedBox
          .shrink(); // Viewer / Auditor tidak punya aksi penambahan data
    }

    final List<_QuickActionCustomItem> actions = [];

    if (role == 'cashier') {
      actions.add(_QuickActionCustomItem(
        icon: Icons.add_circle_outline_rounded,
        label: 'Tambah\nTransaksi',
        onTap: () => context.push('${AppRoutes.addTransaction}?type=expense'),
      ));
      actions.add(_QuickActionCustomItem(
        icon: Icons.qr_code_scanner_rounded,
        label: 'Scan\nStruk',
        onTap: () => context.push(AppRoutes.scanReceiptIntro),
      ));
    } else if (role == 'inventory') {
      actions.add(_QuickActionCustomItem(
        icon: Icons.warehouse_outlined,
        label: 'Stok\nOverview',
        onTap: () => context.push(AppRoutes.inventoryOverview),
      ));
      actions.add(_QuickActionCustomItem(
        icon: Icons.qr_code_scanner_rounded,
        label: 'Scan\nStruk Masuk',
        onTap: () => context.push(AppRoutes.scanReceiptIntro),
      ));
    } else if (role == 'sales') {
      actions.add(_QuickActionCustomItem(
        icon: Icons.add_circle_outline_rounded,
        label: 'Tambah\nPenjualan',
        onTap: () => context.push('${AppRoutes.addTransaction}?type=income'),
      ));
      actions.add(_QuickActionCustomItem(
        icon: Icons.qr_code_scanner_rounded,
        label: 'Scan\nStruk',
        onTap: () => context.push(AppRoutes.scanReceiptIntro),
      ));
    } else {
      // Owner, Admin, Finance, Secretary, Manager
      actions.add(_QuickActionCustomItem(
        icon: Icons.add_circle_outline_rounded,
        label: 'Tambah\nPemasukan',
        onTap: () => context.push('${AppRoutes.addTransaction}?type=income'),
      ));
      actions.add(_QuickActionCustomItem(
        icon: Icons.remove_circle_outline_rounded,
        label: 'Tambah\nPengeluaran',
        onTap: () => context.push('${AppRoutes.addTransaction}?type=expense'),
      ));
      actions.add(_QuickActionCustomItem(
        icon: Icons.qr_code_scanner_rounded,
        label: 'Scan\nStruk',
        onTap: () => context.push(AppRoutes.scanReceiptIntro),
      ));
      actions.add(_QuickActionCustomItem(
        icon: Icons.calendar_month_rounded,
        label: 'Jadwal',
        onTap: () => context.push(AppRoutes.addSchedule),
      ));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: actions.map((act) {
          return Column(
            children: [
              Material(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                child: InkWell(
                  onTap: act.onTap,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(
                        color: colors.outlineVariant.withOpacity(0.5),
                      ),
                    ),
                    child: Icon(
                      act.icon,
                      color: colors.primary,
                      size: 26,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                act.label,
                textAlign: TextAlign.center,
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _QuickActionCustomItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickActionCustomItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _HomeAppBar extends StatelessWidget {
  final HomeLoaded state;
  final String role;

  const _HomeAppBar({required this.state, required this.role});

  String _getRoleLabel(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
        return 'Owner / Pemilik';
      case 'admin':
        return 'Administrator';
      case 'finance':
        return 'Staf Finance';
      case 'secretary':
        return 'Sekretaris';
      case 'cashier':
        return 'Kasir Aktif';
      case 'inventory':
        return 'Staf Logistik';
      case 'sales':
        return 'Sales Eksekutif';
      case 'manager':
        return 'Manajer Divisi';
      case 'viewer':
        return 'Viewer (Read-only)';
      case 'auditor':
        return 'Auditor Bisnis';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: colors.primaryContainer,
              backgroundImage: state.summary.userPhotoUrl != null
                  ? NetworkImage(state.summary.userPhotoUrl!)
                  : null,
              child: state.summary.userPhotoUrl == null
                  ? Text(
                      state.summary.userName[0].toUpperCase(),
                      style: AppTypography.textTheme.titleSmall?.copyWith(
                        color: colors.primary,
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
                  _getRoleLabel(role),
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  state.summary.userName,
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Notification Bell
        StreamBuilder<int>(
          stream: sl<NotificationRepository>().watchUnreadCount(),
          builder: (context, snapshot) {
            final unreadCount = snapshot.data ?? 0;
            return IconButton(
              icon: unreadCount > 0
                  ? Badge(
                      label: Text(
                        '$unreadCount',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                      backgroundColor: colors.error,
                      child: const Icon(Icons.notifications_outlined),
                    )
                  : const Icon(Icons.notifications_outlined),
              color: colors.onSurface,
              onPressed: () => context.push(AppRoutes.alerts),
            );
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CHART METRICS PERIOD CHIPS AND CUSTOM RANGES
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
          margin:
              const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color:
                  Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _PeriodChip(
                      label: 'Mingguan',
                      selected: _period == _ChartPeriod.weekly,
                      onTap: () =>
                          setState(() => _period = _ChartPeriod.weekly),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _PeriodChip(
                      label: 'Bulanan',
                      selected: _period == _ChartPeriod.monthly,
                      onTap: () =>
                          setState(() => _period = _ChartPeriod.monthly),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _PeriodChip(
                      label: 'Tahunan',
                      selected: _period == _ChartPeriod.yearly,
                      onTap: () =>
                          setState(() => _period = _ChartPeriod.yearly),
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
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
                  _LegendDot(
                      color: Theme.of(context).colorScheme.primary,
                      label: 'Pemasukan'),
                  const SizedBox(width: 16),
                  _LegendDot(
                      color: Theme.of(context).colorScheme.error,
                      label: 'Pengeluaran'),
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
          return _bucketFor(
              DateFormat('MMM', 'id_ID').format(start), start, end);
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
          color: selected
              ? AppColors.primary
              : Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.textTheme.labelSmall?.copyWith(
            color: selected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SKELETON LOADER
// ─────────────────────────────────────────────────────────────
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
          const SkeletonBox(
            width: double.infinity,
            height: 140,
            borderRadius: AppSpacing.radiusXl,
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              4,
              (_) => const SkeletonBox(
                  width: 64, height: 80, borderRadius: AppSpacing.radiusLg),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SkeletonBox(
              width: double.infinity,
              height: 80,
              borderRadius: AppSpacing.radiusLg),
          const SizedBox(height: AppSpacing.xl),
          ...List.generate(
            4,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                children: [
                  const SkeletonBox(
                      width: 46, height: 46, borderRadius: AppSpacing.radiusMd),
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
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withOpacity(0.5),
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
