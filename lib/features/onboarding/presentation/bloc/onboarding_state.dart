// ============================================================
// FEATURE: Onboarding — BLoC State
// lib/features/onboarding/presentation/bloc/onboarding_state.dart
// ============================================================

import 'package:equatable/equatable.dart';
import '../../domain/entities/onboarding_slide.dart';

class OnboardingState extends Equatable {
  final List<OnboardingSlide> slides;
  final int currentPage;
  final bool isCompleted;

  const OnboardingState({
    required this.slides,
    this.currentPage = 0,
    this.isCompleted = false,
  });

  bool get isLastPage => currentPage == slides.length - 1;

  OnboardingState copyWith({
    List<OnboardingSlide>? slides,
    int? currentPage,
    bool? isCompleted,
  }) {
    return OnboardingState(
      slides: slides ?? this.slides,
      currentPage: currentPage ?? this.currentPage,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [slides, currentPage, isCompleted];
}
