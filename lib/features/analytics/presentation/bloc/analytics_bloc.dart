// ============================================================
// FEATURE: Analytics - BLoC (real-time)
// lib/features/analytics/presentation/bloc/analytics_bloc.dart
// ============================================================

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/analytics_entities.dart';
import '../../../transactions/domain/entities/transaction_entities.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../../home/domain/entities/home_entities.dart';

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

class AnalyticsLoadRequested extends AnalyticsEvent {
  final int tabIndex;

  const AnalyticsLoadRequested({this.tabIndex = 2});

  @override
  List<Object?> get props => [tabIndex];
}

class AnalyticsTabChanged extends AnalyticsEvent {
  final int tabIndex;

  const AnalyticsTabChanged(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}

class _AnalyticsTransactionsUpdated extends AnalyticsEvent {
  final Either<Failure, List<Transaction>> result;
  final DateRangeFilter filterType;
  final int tabIndex;

  const _AnalyticsTransactionsUpdated({
    required this.result,
    required this.filterType,
    required this.tabIndex,
  });

  @override
  List<Object?> get props => [result, filterType, tabIndex];
}

abstract class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object?> get props => [];
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

  @override
  List<Object?> get props => [summary, selectedTabIndex];
}

class AnalyticsError extends AnalyticsState {
  final String message;

  const AnalyticsError(this.message);

  @override
  List<Object?> get props => [message];
}

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final TransactionRepository _transactionRepository;
  StreamSubscription<Either<Failure, List<Transaction>>>?
      _transactionsSubscription;

  AnalyticsBloc({required TransactionRepository transactionRepository})
      : _transactionRepository = transactionRepository,
        super(const AnalyticsInitial()) {
    on<AnalyticsLoadRequested>(_onLoadRequested);
    on<AnalyticsTabChanged>(_onTabChanged);
    on<_AnalyticsTransactionsUpdated>(_onTransactionsUpdated);
  }

  Future<void> _onLoadRequested(
    AnalyticsLoadRequested event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());
    await _subscribeTransactions(event.tabIndex);
  }

  Future<void> _onTabChanged(
    AnalyticsTabChanged event,
    Emitter<AnalyticsState> emit,
  ) async {
    if (state is AnalyticsLoaded) {
      emit((state as AnalyticsLoaded)
          .copyWith(selectedTabIndex: event.tabIndex));
    }
    emit(const AnalyticsLoading());
    await _subscribeTransactions(event.tabIndex);
  }

  Future<void> _subscribeTransactions(int tabIndex) async {
    await _transactionsSubscription?.cancel();
    final filterType = _filterForTab(tabIndex);
    _transactionsSubscription = _transactionRepository
        .watchFilteredTransactions(TransactionFilter(dateRange: filterType))
        .listen((result) => add(_AnalyticsTransactionsUpdated(
              result: result,
              filterType: filterType,
              tabIndex: tabIndex,
            )));
  }

  void _onTransactionsUpdated(
    _AnalyticsTransactionsUpdated event,
    Emitter<AnalyticsState> emit,
  ) {
    event.result.fold(
      (failure) => emit(AnalyticsError(failure.message)),
      (transactions) => emit(AnalyticsLoaded(
        summary: _generateSummary(transactions, event.filterType),
        selectedTabIndex: event.tabIndex,
      )),
    );
  }

  DateRangeFilter _filterForTab(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return DateRangeFilter.thisWeek;
      case 1:
        return DateRangeFilter.thisMonth;
      case 2:
      default:
        return DateRangeFilter.thisYear;
    }
  }

  CashFlowSummary _generateSummary(
    List<Transaction> transactions,
    DateRangeFilter filterType,
  ) {
    double totalIncome = 0;
    double totalExpense = 0;

    for (final txn in transactions) {
      if (txn.isIncome) {
        totalIncome += txn.amount;
      } else {
        totalExpense += txn.amount;
      }
    }

    final totalBalance = totalIncome - totalExpense;
    final changeAmount = totalBalance;
    final changePercent =
        totalIncome > 0 ? (totalBalance / totalIncome) * 100 : 0.0;

    final pointsMap = <DateTime, CashFlowPoint>{};
    for (final txn in transactions) {
      final date =
          DateTime(txn.dateTime.year, txn.dateTime.month, txn.dateTime.day);
      final current =
          pointsMap[date] ?? CashFlowPoint(date: date, income: 0, expense: 0);
      pointsMap[date] = CashFlowPoint(
        date: date,
        income: current.income + (txn.isIncome ? txn.amount : 0),
        expense: current.expense + (!txn.isIncome ? txn.amount : 0),
      );
    }

    final trendPoints = pointsMap.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final dailyFlows = trendPoints.map((point) {
      final count = transactions.where((txn) {
        return txn.dateTime.year == point.date.year &&
            txn.dateTime.month == point.date.month &&
            txn.dateTime.day == point.date.day;
      }).length;
      final isSurplus = point.income >= point.expense;
      return DailyFlow(
        date: point.date,
        dayLabel: point.date.weekday.toString(),
        transactionCount: count,
        netAmount: (point.income - point.expense).abs(),
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

  @override
  Future<void> close() async {
    await _transactionsSubscription?.cancel();
    return super.close();
  }
}
