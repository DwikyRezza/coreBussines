// ============================================================
// FEATURE: Settings — BLoC (Events + States + BLoC)
// lib/features/settings/presentation/bloc/settings_bloc.dart
// ============================================================

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/dashboard_card_entity.dart';

// ─── Events ──────────────────────────────────────────────────
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override List<Object?> get props => [];
}

class SettingsLoadRequested extends SettingsEvent {
  const SettingsLoadRequested();
}

class DashboardCardToggled extends SettingsEvent {
  final String cardId;
  const DashboardCardToggled(this.cardId);
  @override List<Object?> get props => [cardId];
}

class DashboardCardReordered extends SettingsEvent {
  final int oldIndex;
  final int newIndex;
  const DashboardCardReordered({required this.oldIndex, required this.newIndex});
  @override List<Object?> get props => [oldIndex, newIndex];
}

// ─── State ────────────────────────────────────────────────────
class SettingsState extends Equatable {
  final List<DashboardCardEntity> dashboardCards;
  final bool isLoading;

  const SettingsState({this.dashboardCards = const [], this.isLoading = false});

  SettingsState copyWith({List<DashboardCardEntity>? dashboardCards, bool? isLoading}) {
    return SettingsState(
      dashboardCards: dashboardCards ?? this.dashboardCards,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [dashboardCards, isLoading];
}

// ─── BLoC ─────────────────────────────────────────────────────
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState()) {
    on<SettingsLoadRequested>(_onLoadRequested);
    on<DashboardCardToggled>(_onCardToggled);
    on<DashboardCardReordered>(_onCardReordered);
  }

  Future<void> _onLoadRequested(
    SettingsLoadRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    await Future.delayed(const Duration(milliseconds: 200));
    emit(state.copyWith(isLoading: false, dashboardCards: _defaultCards));
  }

  void _onCardToggled(DashboardCardToggled event, Emitter<SettingsState> emit) {
    final updated = state.dashboardCards.map((card) {
      if (card.id == event.cardId) {
        return card.copyWith(isEnabled: !card.isEnabled);
      }
      return card;
    }).toList();
    emit(state.copyWith(dashboardCards: updated));
  }

  void _onCardReordered(DashboardCardReordered event, Emitter<SettingsState> emit) {
    final list = List<DashboardCardEntity>.from(state.dashboardCards);
    final item = list.removeAt(event.oldIndex);
    final adjustedIndex = event.newIndex > event.oldIndex
        ? event.newIndex - 1
        : event.newIndex;
    list.insert(adjustedIndex, item);
    // Reassign sort orders
    final reordered = list.asMap().entries
        .map((e) => e.value.copyWith(sortOrder: e.key))
        .toList();
    emit(state.copyWith(dashboardCards: reordered));
  }

  static final List<DashboardCardEntity> _defaultCards = [
    const DashboardCardEntity(
      id: 'balance', title: 'Saldo Utama',
      subtitle: 'Menampilkan total aset Anda',
      iconName: 'wallet', isEnabled: true, sortOrder: 0,
    ),
    const DashboardCardEntity(
      id: 'quick_actions', title: 'Quick Actions',
      subtitle: 'Akses cepat transaksi favorit',
      iconName: 'bolt', isEnabled: true, sortOrder: 1,
    ),
    const DashboardCardEntity(
      id: 'weekly_chart', title: 'Grafik Mingguan',
      subtitle: 'Visualisasi pengeluaran 7 hari',
      iconName: 'chart', isEnabled: true, sortOrder: 2,
    ),
    const DashboardCardEntity(
      id: 'ai_insight', title: 'Insight AI',
      subtitle: 'Rekomendasi finansial cerdas',
      iconName: 'ai', isEnabled: false, sortOrder: 3,
    ),
    const DashboardCardEntity(
      id: 'recent_txn', title: 'Transaksi Terakhir',
      subtitle: 'Daftar riwayat aktivitas terbaru',
      iconName: 'history', isEnabled: true, sortOrder: 4,
    ),
  ];
}
