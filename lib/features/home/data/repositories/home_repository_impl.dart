// ============================================================
// FEATURE: Home — Repository Implementation
// lib/features/home/data/repositories/home_repository_impl.dart
// ============================================================

import 'dart:convert';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../domain/entities/home_entities.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_datasource.dart';
import '../models/home_models.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeDataSource _dataSource;
  final LocalStorageService _localStorage;

  const HomeRepositoryImpl(this._dataSource, this._localStorage);

  static const _kHomeBalanceCache = 'home_balance_cache';
  static const _kHomeInsightCache = 'home_insight_cache';
  static const _kHomeRecentTxnCache = 'home_recent_txn_cache';

  @override
  Future<Either<Failure, BalanceSummary>> getBalanceSummary() async {
    try {
      final model = await _dataSource.getBalanceSummary();
      await _localStorage.setCachedJson(_kHomeBalanceCache, jsonEncode((model as BalanceSummaryModel).toJson()));
      return Right(model);
    } catch (e) {
      final cached = _localStorage.getCachedJson(_kHomeBalanceCache);
      if (cached != null) {
        try {
          return Right(BalanceSummaryModel.fromJson(jsonDecode(cached)));
        } catch (_) {}
      }
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getRecentTransactions({
    int limit = 5,
  }) async {
    try {
      final models = await _dataSource.getRecentTransactions(limit: limit);
      final jsonList = (models as List<TransactionModel>).map((m) => m.toJson()).toList();
      await _localStorage.setCachedJson(_kHomeRecentTxnCache, jsonEncode(jsonList));
      return Right(models);
    } catch (e) {
      final cached = _localStorage.getCachedJson(_kHomeRecentTxnCache);
      if (cached != null) {
        try {
          final list = jsonDecode(cached) as List<dynamic>;
          final models = list.map((json) => TransactionModel.fromJson(json)).toList();
          return Right(models);
        } catch (_) {}
      }
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, InsightCard>> getCurrentInsight() async {
    try {
      final model = await _dataSource.getCurrentInsight();
      await _localStorage.setCachedJson(_kHomeInsightCache, jsonEncode((model as InsightCardModel).toJson()));
      return Right(model);
    } catch (e) {
      final cached = _localStorage.getCachedJson(_kHomeInsightCache);
      if (cached != null) {
        try {
          return Right(InsightCardModel.fromJson(jsonDecode(cached)));
        } catch (_) {}
      }
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
