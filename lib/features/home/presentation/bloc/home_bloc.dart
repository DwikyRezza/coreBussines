// ============================================================
// FEATURE: Home — BLoC
// lib/features/home/presentation/bloc/home_bloc.dart
// ============================================================

import 'package:flutter_bloc/flutter_bloc.dart';
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
    final (summaryResult, transactionsResult, insightResult) = await (
      _repository.getBalanceSummary(),
      _repository.getRecentTransactions(limit: 5),
      _repository.getCurrentInsight(),
    ).wait;

    // Fold all results — if any fails, emit error
    final summary = summaryResult.fold((f) => null, (s) => s);
    final transactions = transactionsResult.fold((f) => null, (t) => t);
    final insight = insightResult.fold((f) => null, (i) => i);

    if (summary == null || transactions == null || insight == null) {
      final failure = [summaryResult, transactionsResult, insightResult]
          .firstWhere((r) => r.isLeft())
          .fold((f) => f, (_) => null);
      emit(HomeError(failure?.message ?? 'Terjadi kesalahan.'));
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
