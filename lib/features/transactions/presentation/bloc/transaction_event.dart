// ============================================================
// FEATURE: Transactions — BLoC Events
// lib/features/transactions/presentation/bloc/transaction_event.dart
// ============================================================

import 'package:equatable/equatable.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();
  @override
  List<Object?> get props => [];
}

/// Fired when user presses "Simpan Transaksi" on AddTransactionPage.
/// All form fields are validated before this event is dispatched.
class TransactionSubmitRequested extends TransactionEvent {
  final String title;
  final double amount;
  final bool isIncome;
  final String category;
  final String categoryIcon;
  final String walletName;
  final String? note;

  const TransactionSubmitRequested({
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.category,
    required this.categoryIcon,
    required this.walletName,
    this.note,
  });

  @override
  List<Object?> get props =>
      [title, amount, isIncome, category, categoryIcon, walletName, note];
}

/// Fired when user confirms delete on TransactionDetailPage.
class TransactionDeleteRequested extends TransactionEvent {
  final String id;
  const TransactionDeleteRequested(this.id);

  @override
  List<Object?> get props => [id];
}

/// Reset BLoC back to idle — called after navigating away from success.
class TransactionReset extends TransactionEvent {
  const TransactionReset();
}
