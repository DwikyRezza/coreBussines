// ============================================================
// FEATURE: Home - BLoC
// lib/features/home/presentation/bloc/home_bloc.dart
// ============================================================

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/home_entities.dart';
import '../../domain/repositories/home_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository _repository;
  StreamSubscription<Either<Failure, HomeDashboardData>>?
      _dashboardSubscription;

  HomeBloc({required HomeRepository repository})
      : _repository = repository,
        super(const HomeInitial()) {
    on<HomeLoadRequested>(_onLoadRequested);
    on<HomeRefreshRequested>(_onRefreshRequested);
    on<HomeTabChanged>(_onTabChanged);
    on<_HomeDashboardDataChanged>(_onDashboardDataChanged);
  }

  Future<void> _onLoadRequested(
    HomeLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    await _subscribeDashboard();
  }

  Future<void> _onRefreshRequested(
    HomeRefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeLoaded) {
      emit((state as HomeLoaded).copyWith(isRefreshing: true));
    }
    await _subscribeDashboard();
  }

  void _onTabChanged(
    HomeTabChanged event,
    Emitter<HomeState> emit,
  ) {
    if (state is HomeLoaded) {
      emit((state as HomeLoaded).copyWith(selectedTabIndex: event.tabIndex));
    }
  }

  Future<void> _subscribeDashboard() async {
    await _dashboardSubscription?.cancel();
    _dashboardSubscription = _repository.watchDashboardData().listen(
          (result) => add(_HomeDashboardDataChanged(result)),
        );
  }

  void _onDashboardDataChanged(
    _HomeDashboardDataChanged event,
    Emitter<HomeState> emit,
  ) {
    event.result.fold(
      (failure) => emit(HomeError(failure.message)),
      (data) => emit(
        HomeLoaded(
          summary: data.summary,
          recentTransactions: data.recentTransactions,
          allTransactions: data.allTransactions,
          insight: data.insight,
          selectedTabIndex:
              state is HomeLoaded ? (state as HomeLoaded).selectedTabIndex : 0,
          isRefreshing: false,
        ),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _dashboardSubscription?.cancel();
    return super.close();
  }
}

class _HomeDashboardDataChanged extends HomeEvent {
  final Either<Failure, HomeDashboardData> result;

  const _HomeDashboardDataChanged(this.result);

  @override
  List<Object?> get props => [result];
}
