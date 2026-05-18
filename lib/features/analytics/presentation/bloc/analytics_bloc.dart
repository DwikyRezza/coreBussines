// ============================================================
// FEATURE: Analytics — BLoC (Events + States + BLoC)
// lib/features/analytics/presentation/bloc/analytics_bloc.dart
// ============================================================

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/analytics_entities.dart';
import '../../../transactions/domain/entities/transaction_entities.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../../home/domain/entities/home_entities.dart';

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
  final TransactionRepository _transactionRepository;

  AnalyticsBloc({required TransactionRepository transactionRepository}) 
      : _transactionRepository = transactionRepository,
        super(const AnalyticsInitial()) {
    on<AnalyticsLoadRequested>(_onLoadRequested);
    on<AnalyticsTabChanged>(_onTabChanged);
  }

  Future<void> _onLoadRequested(
    AnalyticsLoadRequested event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());
    await _fetchAndEmitSummary(event.tabIndex, emit);
  }

  Future<void> _onTabChanged(
    AnalyticsTabChanged event,
    Emitter<AnalyticsState> emit,
  ) async {
    if (state is AnalyticsLoaded) {
      emit((state as AnalyticsLoaded).copyWith(selectedTabIndex: event.tabIndex));
    }
    emit(const AnalyticsLoading());
    await _fetchAndEmitSummary(event.tabIndex, emit);
  }

  Future<void> _fetchAndEmitSummary(int tabIndex, Emitter<AnalyticsState> emit) async {
    // Determine the date range based on tabIndex
    DateRangeFilter filterType;
    switch (tabIndex) {
      case 0:
        filterType = DateRangeFilter.thisWeek;
        break;
      case 1:
        filterType = DateRangeFilter.thisMonth;
        break;
      case 2:
      default:
        filterType = DateRangeFilter.thisYear;
        break;
    }

    final result = await _transactionRepository.getFilteredTransactions(
        TransactionFilter(dateRange: filterType));

    result.fold(
      (failure) => emit(AnalyticsError(failure.message)),
      (transactions) {
        final summary = _generateSummary(transactions, filterType);
        emit(AnalyticsLoaded(
          summary: summary,
          selectedTabIndex: tabIndex,
        ));
      },
    );
  }

  CashFlowSummary _generateSummary(List<Transaction> transactions, DateRangeFilter filterType) {
    double totalIncome = 0;
    double totalExpense = 0;
    
    // Calculate totals
    for (var txn in transactions) {
      if (txn.isIncome) {
        totalIncome += txn.amount;
      } else {
        totalExpense += txn.amount;
      }
    }
    
    final totalBalance = totalIncome - totalExpense;
    final changeAmount = totalBalance; // Simplified
    final changePercent = totalIncome > 0 ? (totalBalance / totalIncome) * 100 : 0.0;

    // Group transactions by date
    final Map<DateTime, CashFlowPoint> pointsMap = {};
    for (var txn in transactions) {
      final date = DateTime(txn.dateTime.year, txn.dateTime.month, txn.dateTime.day);
      if (!pointsMap.containsKey(date)) {
        pointsMap[date] = CashFlowPoint(date: date, income: 0, expense: 0);
      }
      final current = pointsMap[date]!;
      pointsMap[date] = CashFlowPoint(
        date: date,
        income: current.income + (txn.isIncome ? txn.amount : 0),
        expense: current.expense + (!txn.isIncome ? txn.amount : 0),
      );
    }

    final trendPoints = pointsMap.values.toList()..sort((a, b) => a.date.compareTo(b.date));

    // Daily flows
    final dailyFlows = trendPoints.map((p) {
      final isSurplus = p.income > p.expense;
      final netAmount = (p.income - p.expense).abs();
      // simplified transaction count
      final count = transactions.where((t) => 
        t.dateTime.year == p.date.year && 
        t.dateTime.month == p.date.month && 
        t.dateTime.day == p.date.day).length;
        
      return DailyFlow(
        date: p.date,
        dayLabel: p.date.weekday.toString(), // e.g., '1' for Monday
        transactionCount: count,
        netAmount: netAmount,
        isSurplus: isSurplus,
      );
    }).toList();

    return CashFlowSummary(
      totalBalance: totalBalance,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      changeAmount: changeAmount,
      changePercent: changePercent,
      trendPoints: trendPoints,
      dailyFlows: dailyFlows,
    );
  }
}
