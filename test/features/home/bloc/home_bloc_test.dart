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

class MockHomeRepository extends Mock implements HomeRepository {}

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

const _fakeDashboard = HomeDashboardData(
  summary: _fakeBalance,
  recentTransactions: _fakeTransactions,
  allTransactions: _fakeTransactions,
  insight: _fakeInsight,
);

void main() {
  late MockHomeRepository mockRepository;

  setUp(() {
    mockRepository = MockHomeRepository();
  });

  group('HomeBloc - real-time dashboard', () {
    blocTest<HomeBloc, HomeState>(
      'emits [HomeLoading, HomeLoaded] on successful stream update',
      build: () {
        when(() => mockRepository.watchDashboardData()).thenAnswer(
          (_) => Stream.value(const Right(_fakeDashboard)),
        );
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
      'emits [HomeLoading, HomeError] when stream emits failure',
      build: () {
        when(() => mockRepository.watchDashboardData()).thenAnswer(
          (_) => Stream.value(
            const Left(ServerFailure(message: 'Server error')),
          ),
        );
        return HomeBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const HomeLoadRequested()),
      expect: () => [
        isA<HomeLoading>(),
        isA<HomeError>().having((s) => s.message, 'message', 'Server error'),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'refresh from HomeLoaded keeps existing data visible until stream updates',
      build: () {
        when(() => mockRepository.watchDashboardData()).thenAnswer(
          (_) => Stream.value(const Right(_fakeDashboard)),
        );
        return HomeBloc(repository: mockRepository);
      },
      seed: () => const HomeLoaded(
        summary: _fakeBalance,
        recentTransactions: _fakeTransactions,
        allTransactions: _fakeTransactions,
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
