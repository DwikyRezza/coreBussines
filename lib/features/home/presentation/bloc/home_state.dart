// ============================================================
// FEATURE: Home — BLoC States
// lib/features/home/presentation/bloc/home_state.dart
// ============================================================

import 'package:equatable/equatable.dart';
import '../../domain/entities/home_entities.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final BalanceSummary summary;
  final List<Transaction> recentTransactions;
  final InsightCard insight;
  final int selectedTabIndex;
  final bool isRefreshing;

  const HomeLoaded({
    required this.summary,
    required this.recentTransactions,
    required this.insight,
    this.selectedTabIndex = 0,
    this.isRefreshing = false,
  });

  HomeLoaded copyWith({
    BalanceSummary? summary,
    List<Transaction>? recentTransactions,
    InsightCard? insight,
    int? selectedTabIndex,
    bool? isRefreshing,
  }) {
    return HomeLoaded(
      summary: summary ?? this.summary,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      insight: insight ?? this.insight,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
        summary,
        recentTransactions,
        insight,
        selectedTabIndex,
        isRefreshing,
      ];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
