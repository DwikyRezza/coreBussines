// ============================================================
// FEATURE: Onboarding — Page
// lib/features/onboarding/presentation/pages/onboarding_page.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';
import '../widgets/onboarding_indicator.dart';
import '../widgets/onboarding_slide_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/app_router.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _animateToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingBloc(),
      child: BlocListener<OnboardingBloc, OnboardingState>(
        listenWhen: (previous, current) {
          return previous.currentPage != current.currentPage ||
              previous.isCompleted != current.isCompleted;
        },
        listener: (context, state) {
          if (state.isCompleted) {
            context.go(AppRoutes.login);
            return;
          }
          if (_pageController.hasClients &&
              _pageController.page?.round() != state.currentPage) {
            _animateToPage(state.currentPage);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: BlocBuilder<OnboardingBloc, OnboardingState>(
              builder: (context, state) {
                return Column(
                  children: [
                    // Top App Bar Area (Back arrow and Skip button)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.base,
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Back Button
                          state.currentPage > 0
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back_rounded,
                                    color: AppColors.primary,
                                  ),
                                  onPressed: () {
                                    context
                                        .read<OnboardingBloc>()
                                        .add(const OnboardingPreviousPage());
                                  },
                                )
                              : const SizedBox(width: 48, height: 48),

                          // Skip Button
                          TextButton(
                            onPressed: () {
                              context
                                  .read<OnboardingBloc>()
                                  .add(const OnboardingCompleted());
                            },
                            child: Text(
                              'Lewati',
                              style: AppTypography.textTheme.labelLarge?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // PageView for Illustration
                    Expanded(
                      flex: 5,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: state.slides.length,
                        onPageChanged: (index) {
                          context
                              .read<OnboardingBloc>()
                              .add(OnboardingPageChanged(index));
                        },
                        itemBuilder: (context, index) {
                          return OnboardingSlideCard(
                            slide: state.slides[index],
                            index: index,
                          );
                        },
                      ),
                    ),

                    // Content Area (Indicator, Title, Subtitle, Button)
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.pagePadding,
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: AppSpacing.md),
                            OnboardingIndicator(
                              totalSlides: state.slides.length,
                              currentPage: state.currentPage,
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            Text(
                              state.slides[state.currentPage].title,
                              textAlign: TextAlign.center,
                              style: AppTypography.textTheme.headlineMedium?.copyWith(
                                color: AppColors.onBackground,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              state.slides[state.currentPage].subtitle,
                              textAlign: TextAlign.center,
                              style: AppTypography.textTheme.bodyMedium?.copyWith(
                                color: AppColors.onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),
                            const Spacer(),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  context
                                      .read<OnboardingBloc>()
                                      .add(const OnboardingNextPage());
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  minimumSize: const Size.fromHeight(56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                                  ),
                                ),
                                child: Text(
                                  state.isLastPage ? 'Mulai Sekarang' : 'Lanjut',
                                  style: AppTypography.textTheme.labelLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
