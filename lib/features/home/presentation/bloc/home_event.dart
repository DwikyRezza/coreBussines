// ============================================================
// FEATURE: Home — BLoC Events
// lib/features/home/presentation/bloc/home_event.dart
// ============================================================

import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Initial load triggered when screen opens
class HomeLoadRequested extends HomeEvent {
  const HomeLoadRequested();
}

/// Pull-to-refresh triggered by user
class HomeRefreshRequested extends HomeEvent {
  const HomeRefreshRequested();
}

/// Tab changed: Harian / Mingguan / Bulanan
class HomeTabChanged extends HomeEvent {
  final int tabIndex;
  const HomeTabChanged(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}
