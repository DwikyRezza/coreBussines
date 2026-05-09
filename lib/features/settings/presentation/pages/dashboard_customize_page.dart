// ============================================================
// FEATURE: Settings — Dashboard Customize Page
// lib/features/settings/presentation/pages/dashboard_customize_page.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/settings_bloc.dart';
import '../../domain/entities/dashboard_card_entity.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class DashboardCustomizePage extends StatelessWidget {
  const DashboardCustomizePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsBloc()..add(const SettingsLoadRequested()),
      child: const _DashboardCustomizeView(),
    );
  }
}

class _DashboardCustomizeView extends StatelessWidget {
  const _DashboardCustomizeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Atur Dashboard',
            style: AppTypography.textTheme.titleLarge?.copyWith(
              color: AppColors.primary, fontWeight: FontWeight.w700,
            )),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          // User avatar (matching screenshot 5)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.base),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.outlineVariant,
              child: Text('A',
                  style: AppTypography.textTheme.labelLarge?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  )),
            ),
          ),
        ],
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePadding, AppSpacing.base,
                    AppSpacing.pagePadding, AppSpacing.xl),
                child: Text(
                  'Pilih dan atur urutan kartu yang tampil di beranda.',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ),
              Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                  itemCount: state.dashboardCards.length,
                  onReorder: (oldIndex, newIndex) {
                    context.read<SettingsBloc>().add(
                          DashboardCardReordered(
                            oldIndex: oldIndex, newIndex: newIndex,
                          ),
                        );
                  },
                  itemBuilder: (context, index) {
                    final card = state.dashboardCards[index];
                    return _DashboardCardTile(
                      key: ValueKey(card.id),
                      card: card,
                      onToggle: () => context.read<SettingsBloc>()
                          .add(DashboardCardToggled(card.id)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }
}

class _DashboardCardTile extends StatelessWidget {
  final DashboardCardEntity card;
  final VoidCallback onToggle;
  const _DashboardCardTile({super.key, required this.card, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base, vertical: AppSpacing.md,
        ),
        child: Row(children: [
          // Icon
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: _iconBackground(card.iconName),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(_iconData(card.iconName),
                color: _iconColor(card.iconName), size: 20),
          ),
          const SizedBox(width: AppSpacing.md),

          // Title + subtitle
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(card.title,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
              Text(card.subtitle,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  )),
            ]),
          ),

          // Toggle switch
          Transform.scale(
            scale: 0.85,
            child: Switch.adaptive(
              value: card.isEnabled,
              onChanged: (_) => onToggle(),
              activeColor: AppColors.primary,
            ),
          ),

          // Drag handle
          const SizedBox(width: AppSpacing.xs),
          const Icon(Icons.drag_indicator_rounded,
              color: AppColors.onSurfaceVariant, size: 20),
        ]),
      ),
    );
  }

  Color _iconBackground(String name) {
    switch (name) {
      case 'wallet': return AppColors.primaryContainer;
      case 'bolt': return AppColors.primaryContainer;
      case 'chart': return const Color(0xFFFFEDD5);
      case 'ai': return AppColors.primaryContainer;
      case 'history': return AppColors.surfaceContainer;
      default: return AppColors.surfaceContainer;
    }
  }

  Color _iconColor(String name) {
    switch (name) {
      case 'wallet': return AppColors.primary;
      case 'bolt': return AppColors.primary;
      case 'chart': return const Color(0xFFE65100);
      case 'ai': return AppColors.primary;
      case 'history': return AppColors.onSurfaceVariant;
      default: return AppColors.onSurfaceVariant;
    }
  }

  IconData _iconData(String name) {
    switch (name) {
      case 'wallet': return Icons.account_balance_wallet_outlined;
      case 'bolt': return Icons.bolt_rounded;
      case 'chart': return Icons.bar_chart_rounded;
      case 'ai': return Icons.auto_awesome_outlined;
      case 'history': return Icons.history_rounded;
      default: return Icons.widgets_outlined;
    }
  }
}
