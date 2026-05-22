import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/error_mapper.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../domain/entities/transaction_entities.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../../home/domain/entities/home_entities.dart';
import '../datasources/transaction_local_datasource.dart';
import '../datasources/transaction_remote_datasource.dart';
import '../../../home/data/models/home_models.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource localDataSource;
  final TransactionRemoteDataSource remoteDataSource;
  final LocalStorageService localStorage;

  const TransactionRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.localStorage,
  });

  @override
  Future<Either<Failure, TransactionDetail>> getTransactionDetail(
    String id,
  ) async {
    try {
      final model = await remoteDataSource.getTransactionDetail(id);
      return Right(model);
    } catch (e) {
      try {
        final localModel = await localDataSource.getTransactionDetail(id);
        return Right(localModel);
      } catch (_) {
        return Left(ErrorMapper.mapToFailure(e));
      }
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getFilteredTransactions(
    TransactionFilter filter,
  ) async {
    try {
      final models = await remoteDataSource.getFilteredTransactions(filter);
      // Optional: Sync down to local cache here
      return Right(models);
    } catch (e) {
      try {
        final localModels = await localDataSource.getFilteredTransactions(filter);
        return Right(localModels);
      } catch (_) {
        return Left(ErrorMapper.mapToFailure(e));
      }
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String id) async {
    try {
      await remoteDataSource.deleteTransaction(id);
      await localDataSource.deleteTransaction(id);
      return const Right(null);
    } catch (e) {
      return Left(ErrorMapper.mapToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> addTransaction(Transaction transaction) async {
    final model = TransactionModel(
      id: transaction.id,
      title: transaction.title,
      amount: transaction.amount,
      isIncome: transaction.isIncome,
      category: transaction.category,
      categoryIcon: transaction.categoryIcon,
      dateTime: transaction.dateTime,
    );

    try {
      await remoteDataSource.addTransaction(model);
      // Update local cache so UI is consistent
      await localDataSource.addTransaction(model);
      return const Right(null);
    } catch (e) {
      // OFFLINE QUEUE (Option B): Save to local storage for immediate UI feedback.
      await localDataSource.addTransaction(model);
      return const Right(null);
    }
  }
}
