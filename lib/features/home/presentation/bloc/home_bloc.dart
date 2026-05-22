// ============================================================
// FEATURE: Home — BLoC
// lib/features/home/presentation/bloc/home_bloc.dart
// ============================================================

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/home_entities.dart';
import '../../domain/repositories/home_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository _repository;

  HomeBloc({required HomeRepository repository})
      : _repository = repository,
        super(const HomeInitial()) {
    on<HomeLoadRequested>(_onLoadRequested);
    on<HomeRefreshRequested>(_onRefreshRequested);
    on<HomeTabChanged>(_onTabChanged);
  }

  Future<void> _onLoadRequested(
    HomeLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    await _loadData(emit);
  }

  Future<void> _onRefreshRequested(
    HomeRefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    // Show refresh indicator without clearing existing data
    if (state is HomeLoaded) {
      emit((state as HomeLoaded).copyWith(isRefreshing: true));
    }
    await _loadData(emit);
  }

  Future<void> _onTabChanged(
    HomeTabChanged event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeLoaded) {
      emit((state as HomeLoaded).copyWith(selectedTabIndex: event.tabIndex));
      // In production: reload data for the selected period
      await _loadData(emit, tabIndex: event.tabIndex);
    }
  }

  Future<void> _loadData(
    Emitter<HomeState> emit, {
    int tabIndex = 0,
  }) async {
    // Parallel fetch — all 3 requests execute simultaneously
    final (
      Either<Failure, BalanceSummary> summaryResult,
      Either<Failure, List<Transaction>> transactionsResult,
      Either<Failure, InsightCard> insightResult,
    ) = await (
      _repository.getBalanceSummary(),
      _repository.getRecentTransactions(limit: 5),
      _repository.getCurrentInsight(),
    ).wait;

    // Fold all results — if any fails, emit error
    final summary = summaryResult.fold<BalanceSummary?>((f) => null, (s) => s);
    final transactions = transactionsResult.fold<List<Transaction>?>(
      (f) => null,
      (t) => t,
    );
    final insight = insightResult.fold<InsightCard?>((f) => null, (i) => i);

    if (summary == null || transactions == null || insight == null) {
      final errorMessage =
          summaryResult.fold((f) => f.message, (_) => null) ??
          transactionsResult.fold((f) => f.message, (_) => null) ??
          insightResult.fold((f) => f.message, (_) => null);

      emit(HomeError(errorMessage ?? 'Terjadi kesalahan.'));
      return;
    }

    emit(HomeLoaded(
      summary: summary,
      recentTransactions: transactions,
      insight: insight,
      selectedTabIndex: tabIndex,
      isRefreshing: false,
    ));
  }
}
