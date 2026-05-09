// ============================================================
// FEATURE: Transactions — BLoC (Detail + Filter + History)
// lib/features/transactions/presentation/bloc/transaction_bloc.dart
// ============================================================

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/transaction_entities.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../../home/domain/entities/home_entities.dart';

// ─── Events ───────────────────────────────────────────────────
abstract class TransactionEvent extends Equatable {
  const TransactionEvent();
  @override
  List<Object?> get props => [];
}

class TransactionDetailRequested extends TransactionEvent {
  final String id;
  const TransactionDetailRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class TransactionDeleteRequested extends TransactionEvent {
  final String id;
  const TransactionDeleteRequested(this.id);
  @override
  List<Object?> get props => [id];
}

// ─── States ───────────────────────────────────────────────────
abstract class TransactionState extends Equatable {
  const TransactionState();
  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {
  const TransactionInitial();
}

class TransactionLoading extends TransactionState {
  const TransactionLoading();
}

class TransactionDetailLoaded extends TransactionState {
  final TransactionDetail detail;
  const TransactionDetailLoaded(this.detail);
  @override
  List<Object?> get props => [detail];
}

class TransactionDeleteSuccess extends TransactionState {
  const TransactionDeleteSuccess();
}

class TransactionError extends TransactionState {
  final String message;
  const TransactionError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── BLoC ─────────────────────────────────────────────────────
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository _repository;
  bool _isProcessing = false; // Double-submit guard

  TransactionBloc({required TransactionRepository repository})
      : _repository = repository,
        super(const TransactionInitial()) {
    on<TransactionDetailRequested>(_onDetailRequested);
    on<TransactionDeleteRequested>(_onDeleteRequested);
  }

  Future<void> _onDetailRequested(
    TransactionDetailRequested event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionLoading());
    final result = await _repository.getTransactionDetail(event.id);
    result.fold(
      (f) => emit(TransactionError(f.message)),
      (detail) => emit(TransactionDetailLoaded(detail)),
    );
  }

  Future<void> _onDeleteRequested(
    TransactionDeleteRequested event,
    Emitter<TransactionState> emit,
  ) async {
    if (_isProcessing) return; // Prevent double-tap on delete
    _isProcessing = true;

    emit(const TransactionLoading());
    final result = await _repository.deleteTransaction(event.id);
    result.fold(
      (f) {
        _isProcessing = false;
        emit(TransactionError(f.message));
      },
      (_) {
        _isProcessing = false;
        emit(const TransactionDeleteSuccess());
      },
    );
  }
}
