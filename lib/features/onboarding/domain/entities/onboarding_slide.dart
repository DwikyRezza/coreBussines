// ============================================================
// FEATURE: Onboarding — Domain Entity
// lib/features/onboarding/domain/entities/onboarding_slide.dart
// ============================================================

import 'package:equatable/equatable.dart';

class OnboardingSlide extends Equatable {
  final String title;
  final String subtitle;
  final String illustration; // Asset path or icon name
  final String accentTag;

  const OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.illustration,
    required this.accentTag,
  });

  @override
  List<Object?> get props => [title, subtitle, illustration, accentTag];
}
