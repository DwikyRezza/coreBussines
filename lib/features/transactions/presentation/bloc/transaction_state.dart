// ============================================================
// FEATURE: Transactions — BLoC States
// lib/features/transactions/presentation/bloc/transaction_state.dart
// ============================================================

import 'package:equatable/equatable.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();
  @override
  List<Object?> get props => [];
}

/// Default idle state — form is empty and ready.
class TransactionInitial extends TransactionState {
  const TransactionInitial();
}

/// In-flight — prevents double submit. UI shows loading indicator.
class TransactionSubmitting extends TransactionState {
  const TransactionSubmitting();
}

/// Operation completed. UI should navigate back & refresh Home.
class TransactionSuccess extends TransactionState {
  final String message;
  const TransactionSuccess({this.message = 'Transaksi berhasil disimpan.'});

  @override
  List<Object?> get props => [message];
}

/// Operation failed. UI shows SnackBar with reason.
class TransactionFailure extends TransactionState {
  final String message;
  const TransactionFailure(this.message);

  @override
  List<Object?> get props => [message];
}
