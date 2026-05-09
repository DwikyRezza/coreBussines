// ============================================================
// FEATURE: Transactions — Filter BLoC
// lib/features/transactions/presentation/bloc/filter_bloc.dart
// ============================================================

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/transaction_entities.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../../home/domain/entities/home_entities.dart';

// ─── Events ───────────────────────────────────────────────────
abstract class FilterEvent extends Equatable {
  const FilterEvent();
  @override
  List<Object?> get props => [];
}

class FilterTypeChanged extends FilterEvent {
  final TransactionType? type;
  const FilterTypeChanged(this.type);
  @override
  List<Object?> get props => [type];
}

class FilterDateRangeChanged extends FilterEvent {
  final DateRangeFilter dateRange;
  const FilterDateRangeChanged(this.dateRange);
  @override
  List<Object?> get props => [dateRange];
}

class FilterCategoryToggled extends FilterEvent {
  final String category;
  const FilterCategoryToggled(this.category);
  @override
  List<Object?> get props => [category];
}

class FilterApplied extends FilterEvent {
  const FilterApplied();
}

class FilterReset extends FilterEvent {
  const FilterReset();
}

class FilterInitialLoad extends FilterEvent {
  const FilterInitialLoad();
}

// ─── State ────────────────────────────────────────────────────
class FilterState extends Equatable {
  final TransactionFilter filter;
  final List<Transaction> results;
  final bool isLoading;
  final String? error;

  const FilterState({
    this.filter = const TransactionFilter(),
    this.results = const [],
    this.isLoading = false,
    this.error,
  });

  FilterState copyWith({
    TransactionFilter? filter,
    List<Transaction>? results,
    bool? isLoading,
    String? error,
  }) {
    return FilterState(
      filter: filter ?? this.filter,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [filter, results, isLoading, error];
}

// ─── BLoC ─────────────────────────────────────────────────────
class FilterBloc extends Bloc<FilterEvent, FilterState> {
  final TransactionRepository _repository;

  FilterBloc({required TransactionRepository repository})
      : _repository = repository,
        super(const FilterState()) {
    on<FilterInitialLoad>(_onInitialLoad);
    on<FilterTypeChanged>(_onTypeChanged);
    on<FilterDateRangeChanged>(_onDateRangeChanged);
    on<FilterCategoryToggled>(_onCategoryToggled);
    on<FilterApplied>(_onApplied);
    on<FilterReset>(_onReset);
  }

  Future<void> _onInitialLoad(
    FilterInitialLoad event,
    Emitter<FilterState> emit,
  ) async {
    await _fetchResults(emit, state.filter);
  }

  void _onTypeChanged(FilterTypeChanged event, Emitter<FilterState> emit) {
    final newFilter = event.type == state.filter.type
        ? state.filter.copyWith(clearType: true)
        : state.filter.copyWith(type: event.type);
    emit(state.copyWith(filter: newFilter));
  }

  void _onDateRangeChanged(
    FilterDateRangeChanged event,
    Emitter<FilterState> emit,
  ) {
    emit(state.copyWith(
      filter: state.filter.copyWith(dateRange: event.dateRange),
    ));
  }

  void _onCategoryToggled(
    FilterCategoryToggled event,
    Emitter<FilterState> emit,
  ) {
    final current = List<String>.from(state.filter.categories);
    if (current.contains(event.category)) {
      current.remove(event.category);
    } else {
      current.add(event.category);
    }
    emit(state.copyWith(
      filter: state.filter.copyWith(categories: current),
    ));
  }

  Future<void> _onApplied(
    FilterApplied event,
    Emitter<FilterState> emit,
  ) async {
    await _fetchResults(emit, state.filter);
  }

  Future<void> _onReset(FilterReset event, Emitter<FilterState> emit) async {
    const resetFilter = TransactionFilter();
    emit(state.copyWith(filter: resetFilter));
    await _fetchResults(emit, resetFilter);
  }

  Future<void> _fetchResults(
    Emitter<FilterState> emit,
    TransactionFilter filter,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    final result = await _repository.getFilteredTransactions(filter);
    result.fold(
      (f) => emit(state.copyWith(isLoading: false, error: f.message)),
      (txns) => emit(state.copyWith(isLoading: false, results: txns)),
    );
  }
}
