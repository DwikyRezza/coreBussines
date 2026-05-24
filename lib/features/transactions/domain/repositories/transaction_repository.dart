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
  Stream<Either<Failure, TransactionDetail>> watchTransactionDetail(String id);
  Future<Either<Failure, List<Transaction>>> getFilteredTransactions(
    TransactionFilter filter,
  );
  Stream<Either<Failure, List<Transaction>>> watchFilteredTransactions(
    TransactionFilter filter,
  );
  Stream<Either<Failure, List<Transaction>>> watchRecentTransactions(
      {int limit});
  Stream<Either<Failure, List<WalletOption>>> watchWalletOptions();
  Stream<Either<Failure, List<TransactionCategory>>> watchCategories();
  Future<Either<Failure, void>> addCategory(TransactionCategory category);
  Future<Either<Failure, void>> deleteCategory(String categoryId);
  Future<Either<Failure, void>> deleteTransaction(String id);
  Future<Either<Failure, void>> addTransaction(Transaction transaction);
  Future<Either<Failure, void>> addTransactionInput(TransactionInput input);
}
