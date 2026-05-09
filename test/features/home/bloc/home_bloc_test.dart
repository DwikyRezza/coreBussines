// ============================================================
// UNIT TEST: HomeBloc
// test/features/home/bloc/home_bloc_test.dart
// ============================================================

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:corebussiness/core/error/failures.dart';
import 'package:corebussiness/features/home/domain/entities/home_entities.dart';
import 'package:corebussiness/features/home/domain/repositories/home_repository.dart';
import 'package:corebussiness/features/home/presentation/bloc/home_bloc.dart';
import 'package:corebussiness/features/home/presentation/bloc/home_event.dart';
import 'package:corebussiness/features/home/presentation/bloc/home_state.dart';

// ─── Mocks ────────────────────────────────────────────────────
class MockHomeRepository extends Mock implements HomeRepository {}

// ─── Fake data ────────────────────────────────────────────────
const _fakeBalance = BalanceSummary(
  totalBalance: 42850000,
  monthlyChange: 2400000,
  monthlyChangePercent: 5.9,
  userName: 'Test User',
);

const _fakeInsight = InsightCard(
  title: 'Insight AI',
  message: 'Test message',
  type: 'info',
);

const _fakeTransactions = <Transaction>[];

void main() {
  late MockHomeRepository mockRepository;

  setUp(() {
    mockRepository = MockHomeRepository();
  });

  group('HomeBloc — Load', () {
    blocTest<HomeBloc, HomeState>(
      'emits [HomeLoading, HomeLoaded] on successful load',
      build: () {
        when(() => mockRepository.getBalanceSummary())
            .thenAnswer((_) async => const Right(_fakeBalance));
        when(() => mockRepository.getRecentTransactions(limit: 5))
            .thenAnswer((_) async => const Right(_fakeTransactions));
        when(() => mockRepository.getCurrentInsight())
            .thenAnswer((_) async => const Right(_fakeInsight));
        return HomeBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const HomeLoadRequested()),
      expect: () => [
        isA<HomeLoading>(),
        isA<HomeLoaded>()
            .having((s) => s.summary.userName, 'userName', 'Test User')
            .having((s) => s.isRefreshing, 'isRefreshing', false),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'emits [HomeLoading, HomeError] when repository fails',
      build: () {
        when(() => mockRepository.getBalanceSummary()).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Server error')),
        );
        when(() => mockRepository.getRecentTransactions(limit: 5))
            .thenAnswer((_) async => const Right(_fakeTransactions));
        when(() => mockRepository.getCurrentInsight())
            .thenAnswer((_) async => const Right(_fakeInsight));
        return HomeBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const HomeLoadRequested()),
      expect: () => [
        isA<HomeLoading>(),
        isA<HomeError>().having((s) => s.message, 'message', 'Server error'),
      ],
    );
  });

  group('HomeBloc — Refresh', () {
    blocTest<HomeBloc, HomeState>(
      'refresh from HomeLoaded keeps existing data visible',
      build: () {
        when(() => mockRepository.getBalanceSummary())
            .thenAnswer((_) async => const Right(_fakeBalance));
        when(() => mockRepository.getRecentTransactions(limit: 5))
            .thenAnswer((_) async => const Right(_fakeTransactions));
        when(() => mockRepository.getCurrentInsight())
            .thenAnswer((_) async => const Right(_fakeInsight));
        return HomeBloc(repository: mockRepository);
      },
      seed: () => const HomeLoaded(
        summary: _fakeBalance,
        recentTransactions: _fakeTransactions,
        insight: _fakeInsight,
      ),
      act: (bloc) => bloc.add(const HomeRefreshRequested()),
      expect: () => [
        isA<HomeLoaded>().having((s) => s.isRefreshing, 'isRefreshing', true),
        isA<HomeLoaded>().having((s) => s.isRefreshing, 'isRefreshing', false),
      ],
    );
  });
}
