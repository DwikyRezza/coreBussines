// ============================================================
// FEATURE: Transactions — Repository Interface
// lib/features/transactions/domain/repositories/transaction_repository.dart
// ============================================================

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction_entities.dart';
import '../../../home/domain/entities/home_entities.dart';

abstract class TransactionRepository {
  Future<Either<Failure, TransactionDetail>> getTransactionDetail(String id);
  Future<Either<Failure, List<Transaction>>> getFilteredTransactions(
    TransactionFilter filter,
  );
  Future<Either<Failure, void>> deleteTransaction(String id);
  Future<Either<Failure, void>> addTransaction(Transaction transaction);
}
