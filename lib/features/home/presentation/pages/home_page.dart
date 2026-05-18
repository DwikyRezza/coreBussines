import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/home_widgets.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/app_router.dart';

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
      backgroundColor: AppColors.background,
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
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      onRefresh: () async {
        final bloc = context.read<HomeBloc>();
        bloc.add(const HomeRefreshRequested());
        // Tunggu hingga state berubah menjadi Loaded atau Error
        await bloc.stream.firstWhere(
            (state) => state is HomeLoaded || state is HomeError);
      },
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // AppBar
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            titleSpacing: AppSpacing.pagePadding,
            title: _HomeAppBar(state: state),
          ),

          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: AppSpacing.base),

              // Balance Card
              BalanceCard(summary: state.summary),
              const SizedBox(height: AppSpacing.xl),

              // Quick Actions
              const QuickActionsGrid(),
              const SizedBox(height: AppSpacing.xl),

              // Insight Card
              HomeInsightCard(insight: state.insight),
              const SizedBox(height: AppSpacing.xl),

              // Weekly Chart Placeholder
              _WeeklyChartSection(),
              const SizedBox(height: AppSpacing.xl),

              // Recent Transactions
              SectionHeader(
                title: 'Transaksi Terakhir',
                actionLabel: 'Semua',
                onAction: () => context.go(AppRoutes.history),
              ),
              const SizedBox(height: AppSpacing.md),

              // Transaction List
              ...state.recentTransactions.map(
                (txn) => Column(
                  children: [
                    TransactionTile(transaction: txn),
                    if (txn != state.recentTransactions.last)
                      Divider(
                        height: 1,
                        indent: AppSpacing.pagePadding,
                        endIndent: AppSpacing.pagePadding,
                        color: AppColors.outlineVariant.withOpacity(0.4),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 100), // Bottom nav clearance
            ]),
          ),
        ],
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
              backgroundColor: AppColors.primaryContainer,
              backgroundImage: state.summary.userPhotoUrl != null
                  ? NetworkImage(state.summary.userPhotoUrl!)
                  : null,
              child: state.summary.userPhotoUrl == null
                  ? Text(
                      state.summary.userName[0].toUpperCase(),
                      style: AppTypography.textTheme.titleSmall?.copyWith(
                        color: AppColors.primary,
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
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  state.summary.userName,
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
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
            backgroundColor: AppColors.expense,
            child: const Icon(Icons.notifications_outlined),
          ),
          color: AppColors.onBackground,
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
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
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
                                : AppColors.primaryContainer,
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
                          : AppColors.onSurfaceVariant,
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
              color: AppColors.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.base),
            Text(
              'Gagal Memuat Data',
              style: AppTypography.textTheme.titleMedium?.copyWith(
                color: AppColors.onBackground,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
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
