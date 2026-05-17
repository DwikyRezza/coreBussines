// ============================================================
// FEATURE: Transactions — Use Case: Add Transaction
// lib/features/transactions/domain/usecases/add_transaction.dart
// ============================================================

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../home/domain/entities/home_entities.dart';
import '../repositories/transaction_repository.dart';

class AddTransaction extends UseCase<void, AddTransactionParams> {
  final TransactionRepository repository;
  AddTransaction(this.repository);

  @override
  Future<Either<Failure, void>> call(AddTransactionParams params) {
    return repository.addTransaction(params.transaction);
  }
}

class AddTransactionParams extends Equatable {
  final Transaction transaction;
  const AddTransactionParams({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}
