// ============================================================
// FEATURE: Home — Repository Implementation
// lib/features/home/data/repositories/home_repository_impl.dart
// ============================================================

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/home_entities.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_mock_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeDataSource _dataSource;

  const HomeRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, BalanceSummary>> getBalanceSummary() async {
    try {
      final model = await _dataSource.getBalanceSummary();
      return Right(model);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getRecentTransactions({
    int limit = 5,
  }) async {
    try {
      final models = await _dataSource.getRecentTransactions(limit: limit);
      return Right(models);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, InsightCard>> getCurrentInsight() async {
    try {
      final model = await _dataSource.getCurrentInsight();
      return Right(model);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
