// ============================================================
// FEATURE: Analytics — BLoC (Events + States + BLoC)
// lib/features/analytics/presentation/bloc/analytics_bloc.dart
// ============================================================

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/analytics_entities.dart';

// ─── Events ──────────────────────────────────────────────────
abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();
  @override List<Object?> get props => [];
}

class AnalyticsLoadRequested extends AnalyticsEvent {
  final int tabIndex; // 0=Harian, 1=Mingguan, 2=Bulanan
  const AnalyticsLoadRequested({this.tabIndex = 2});
  @override List<Object?> get props => [tabIndex];
}

class AnalyticsTabChanged extends AnalyticsEvent {
  final int tabIndex;
  const AnalyticsTabChanged(this.tabIndex);
  @override List<Object?> get props => [tabIndex];
}

// ─── States ──────────────────────────────────────────────────
abstract class AnalyticsState extends Equatable {
  const AnalyticsState();
  @override List<Object?> get props => [];
}

class AnalyticsInitial extends AnalyticsState {
  const AnalyticsInitial();
}

class AnalyticsLoading extends AnalyticsState {
  const AnalyticsLoading();
}

class AnalyticsLoaded extends AnalyticsState {
  final CashFlowSummary summary;
  final int selectedTabIndex;

  const AnalyticsLoaded({required this.summary, this.selectedTabIndex = 2});

  AnalyticsLoaded copyWith({CashFlowSummary? summary, int? selectedTabIndex}) {
    return AnalyticsLoaded(
      summary: summary ?? this.summary,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
    );
  }

  @override List<Object?> get props => [summary, selectedTabIndex];
}

class AnalyticsError extends AnalyticsState {
  final String message;
  const AnalyticsError(this.message);
  @override List<Object?> get props => [message];
}

// ─── BLoC ────────────────────────────────────────────────────
class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  AnalyticsBloc() : super(const AnalyticsInitial()) {
    on<AnalyticsLoadRequested>(_onLoadRequested);
    on<AnalyticsTabChanged>(_onTabChanged);
  }

  Future<void> _onLoadRequested(
    AnalyticsLoadRequested event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    emit(AnalyticsLoaded(
      summary: _mockSummary(),
      selectedTabIndex: event.tabIndex,
    ));
  }

  Future<void> _onTabChanged(
    AnalyticsTabChanged event,
    Emitter<AnalyticsState> emit,
  ) async {
    if (state is AnalyticsLoaded) {
      emit((state as AnalyticsLoaded).copyWith(selectedTabIndex: event.tabIndex));
    }
    emit(const AnalyticsLoading());
    await Future.delayed(const Duration(milliseconds: 300));
    emit(AnalyticsLoaded(
      summary: _mockSummary(),
      selectedTabIndex: event.tabIndex,
    ));
  }

  CashFlowSummary _mockSummary() {
    final now = DateTime.now();
    return CashFlowSummary(
      totalBalance: 12450000,
      changeAmount: 12450000,
      changePercent: 14.2,
      trendPoints: List.generate(30, (i) {
        final date = DateTime(now.year, 3, i + 1);
        final income = 400000 + (i * 15000) + (i % 5 == 0 ? 500000 : 0);
        final expense = 250000 + (i * 8000) + (i % 7 == 0 ? 200000 : 0);
        return CashFlowPoint(
          date: date, income: income.toDouble(), expense: expense.toDouble(),
        );
      }),
      dailyFlows: [
        DailyFlow(
          date: DateTime(2024, 3, 25), dayLabel: 'S',
          transactionCount: 3, netAmount: 1200000, isSurplus: true,
        ),
        DailyFlow(
          date: DateTime(2024, 3, 26), dayLabel: 'S',
          transactionCount: 5, netAmount: 450000, isSurplus: false,
        ),
        DailyFlow(
          date: DateTime(2024, 3, 27), dayLabel: 'R',
          transactionCount: 2, netAmount: 2800000, isSurplus: true,
        ),
        DailyFlow(
          date: DateTime(2024, 3, 28), dayLabel: 'K',
          transactionCount: 8, netAmount: 1120000, isSurplus: false,
        ),
      ],
    );
  }
}
