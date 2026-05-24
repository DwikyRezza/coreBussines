// ============================================================
// FEATURE: Transactions — Use Case: Add Transaction
// lib/features/transactions/domain/usecases/add_transaction.dart
// ============================================================

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../home/domain/entities/home_entities.dart';
import '../entities/transaction_entities.dart' as transaction_entities;
import '../repositories/transaction_repository.dart';

class AddTransaction extends UseCase<void, AddTransactionParams> {
  final TransactionRepository repository;
  AddTransaction(this.repository);

  @override
  Future<Either<Failure, void>> call(AddTransactionParams params) {
    if (params.input != null) {
      return repository.addTransactionInput(params.input!);
    }
    return repository.addTransaction(params.transaction);
  }
}

class AddTransactionParams extends Equatable {
  final Transaction transaction;
  final transaction_entities.TransactionInput? input;

  const AddTransactionParams({
    required this.transaction,
    this.input,
  });

  factory AddTransactionParams.input(
    transaction_entities.TransactionInput input,
  ) {
    return AddTransactionParams(
      transaction: Transaction(
        id: input.id,
        title: input.title,
        amount: input.amount,
        isIncome: input.isIncome,
        category: input.category,
        categoryIcon: input.categoryIcon,
        dateTime: input.dateTime,
        walletId: input.walletId,
        walletName: input.walletName,
      ),
      input: input,
    );
  }

  @override
  List<Object?> get props => [transaction, input];
}
