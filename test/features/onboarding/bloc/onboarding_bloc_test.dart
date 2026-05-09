// ============================================================
// UNIT TEST: OnboardingBloc
// test/features/onboarding/bloc/onboarding_bloc_test.dart
// ============================================================

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:corebussiness/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:corebussiness/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:corebussiness/features/onboarding/presentation/bloc/onboarding_state.dart';

void main() {
  group('OnboardingBloc', () {
    late OnboardingBloc bloc;

    setUp(() {
      bloc = OnboardingBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state has 3 slides and currentPage = 0', () {
      expect(bloc.state.currentPage, 0);
      expect(bloc.state.slides.length, 3);
      expect(bloc.state.isCompleted, false);
      expect(bloc.state.isLastPage, false);
    });

    blocTest<OnboardingBloc, OnboardingState>(
      'OnboardingNextPage increments currentPage from 0 to 1',
      build: () => OnboardingBloc(),
      act: (bloc) => bloc.add(const OnboardingNextPage()),
      expect: () => [
        isA<OnboardingState>().having((s) => s.currentPage, 'page', 1),
      ],
    );

    blocTest<OnboardingBloc, OnboardingState>(
      'OnboardingNextPage on last slide sets isCompleted = true',
      build: () => OnboardingBloc(),
      act: (bloc) {
        bloc.add(const OnboardingNextPage()); // -> page 1
        bloc.add(const OnboardingNextPage()); // -> page 2
        bloc.add(const OnboardingNextPage()); // -> completed
      },
      expect: () => [
        isA<OnboardingState>().having((s) => s.currentPage, 'page', 1),
        isA<OnboardingState>().having((s) => s.currentPage, 'page', 2),
        isA<OnboardingState>().having((s) => s.isCompleted, 'completed', true),
      ],
    );

    blocTest<OnboardingBloc, OnboardingState>(
      'OnboardingPreviousPage does nothing on first page',
      build: () => OnboardingBloc(),
      act: (bloc) => bloc.add(const OnboardingPreviousPage()),
      expect: () => [], // No state change
    );

    blocTest<OnboardingBloc, OnboardingState>(
      'OnboardingCompleted sets isCompleted = true from any page',
      build: () => OnboardingBloc(),
      act: (bloc) => bloc.add(const OnboardingCompleted()),
      expect: () => [
        isA<OnboardingState>().having((s) => s.isCompleted, 'completed', true),
      ],
    );

    blocTest<OnboardingBloc, OnboardingState>(
      'OnboardingPageChanged syncs currentPage',
      build: () => OnboardingBloc(),
      act: (bloc) => bloc.add(const OnboardingPageChanged(2)),
      expect: () => [
        isA<OnboardingState>().having((s) => s.currentPage, 'page', 2),
      ],
    );
  });
}
