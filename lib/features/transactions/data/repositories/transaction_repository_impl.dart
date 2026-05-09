// ============================================================
// FEATURE: Transactions — Repository Implementation
// lib/features/transactions/data/repositories/transaction_repository_impl.dart
// ============================================================

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/transaction_entities.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../../home/domain/entities/home_entities.dart';
import '../datasources/transaction_mock_datasource.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionDataSource _dataSource;

  const TransactionRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, TransactionDetail>> getTransactionDetail(
    String id,
  ) async {
    try {
      final model = await _dataSource.getTransactionDetail(id);
      return Right(model);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getFilteredTransactions(
    TransactionFilter filter,
  ) async {
    try {
      final models = await _dataSource.getFilteredTransactions(filter);
      return Right(models);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String id) async {
    try {
      await _dataSource.deleteTransaction(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addTransaction(Transaction transaction) async {
    try {
      // Create a TransactionModel from the Transaction entity
      final model = TransactionModel(
        id: transaction.id,
        title: transaction.title,
        amount: transaction.amount,
        isIncome: transaction.isIncome,
        category: transaction.category,
        categoryIcon: transaction.categoryIcon,
        dateTime: transaction.dateTime,
      );
      await _dataSource.addTransaction(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
