// ============================================================
// FEATURE: Onboarding — Animated Indicator Bar Widget
// lib/features/onboarding/presentation/widgets/onboarding_indicator.dart
// ============================================================

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Animated expanding indicator dots for onboarding PageView.
/// The active indicator expands to a pill shape.
class OnboardingIndicator extends StatelessWidget {
  final int totalSlides;
  final int currentPage;

  const OnboardingIndicator({
    super.key,
    required this.totalSlides,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSlides, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: currentPage == index ? 32 : 8,
          decoration: BoxDecoration(
            color: currentPage == index
                ? AppColors.primary
                : Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
        );
      }),
    );
  }
}
