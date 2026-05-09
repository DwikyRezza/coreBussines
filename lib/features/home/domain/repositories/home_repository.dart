// ============================================================
// FEATURE: Home — Repository Interface
// lib/features/home/domain/repositories/home_repository.dart
// ============================================================

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/home_entities.dart';

abstract class HomeRepository {
  Future<Either<Failure, BalanceSummary>> getBalanceSummary();
  Future<Either<Failure, List<Transaction>>> getRecentTransactions({int limit});
  Future<Either<Failure, InsightCard>> getCurrentInsight();
}
