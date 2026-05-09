// ============================================================
// FEATURE: Onboarding — BLoC Events
// lib/features/onboarding/presentation/bloc/onboarding_event.dart
// ============================================================

import 'package:equatable/equatable.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

/// User swiped/tapped to next slide
class OnboardingNextPage extends OnboardingEvent {
  const OnboardingNextPage();
}

/// User tapped back
class OnboardingPreviousPage extends OnboardingEvent {
  const OnboardingPreviousPage();
}

/// PageView notified page changed
class OnboardingPageChanged extends OnboardingEvent {
  final int pageIndex;
  const OnboardingPageChanged(this.pageIndex);

  @override
  List<Object?> get props => [pageIndex];
}

/// User tapped "Skip" or "Mulai"
class OnboardingCompleted extends OnboardingEvent {
  const OnboardingCompleted();
}
