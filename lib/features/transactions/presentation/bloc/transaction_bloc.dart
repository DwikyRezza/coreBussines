// ============================================================
// FEATURE: Transactions — BLoC (Detail + Filter + Add + Delete)
// lib/features/transactions/presentation/bloc/transaction_bloc.dart
// ============================================================

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/error_mapper.dart';
import '../../domain/entities/transaction_entities.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../../home/domain/entities/home_entities.dart';
import '../../domain/usecases/add_transaction.dart';
import '../../domain/usecases/delete_transaction.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/datasources/ai_receipt_scanner.dart';

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

/// Fired when user presses "Simpan Transaksi".
/// All fields must be validated by the UI before dispatching.
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

/// Resets BLoC to idle after UI has reacted to success/failure.
class TransactionReset extends TransactionEvent {
  const TransactionReset();
}

class TransactionScanRequested extends TransactionEvent {
  final XFile photo;
  const TransactionScanRequested(this.photo);

  @override
  List<Object?> get props => [photo.path];
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

/// Covers both add-success and delete-success.
class TransactionSuccess extends TransactionState {
  final String message;
  const TransactionSuccess({this.message = 'Transaksi berhasil disimpan.'});
  @override
  List<Object?> get props => [message];
}

/// Legacy alias kept for backward compat with TransactionDetailPage.
class TransactionDeleteSuccess extends TransactionState {
  const TransactionDeleteSuccess();
}

class TransactionScanSuccess extends TransactionState {
  final Transaction scannedTransaction;
  const TransactionScanSuccess(this.scannedTransaction);
  @override
  List<Object?> get props => [scannedTransaction];
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
  final AddTransaction? _addTransaction;
  final DeleteTransaction? _deleteUseCase;
  final AiReceiptScanner? _scanner;

  TransactionBloc({
    required TransactionRepository repository,
    AddTransaction? addTransaction,
    DeleteTransaction? deleteTransaction,
    AiReceiptScanner? scanner,
  })  : _repository = repository,
        _addTransaction = addTransaction,
        _deleteUseCase = deleteTransaction,
        _scanner = scanner,
        super(const TransactionInitial()) {
    on<TransactionDetailRequested>(_onDetailRequested);
    on<TransactionDeleteRequested>(_onDeleteRequested);
    on<TransactionSubmitRequested>(_onSubmitRequested);
    on<TransactionReset>(_onReset);
    on<TransactionScanRequested>(_onScanRequested);
  }

  Future<void> _onScanRequested(
    TransactionScanRequested event,
    Emitter<TransactionState> emit,
  ) async {
    if (_scanner == null) {
      emit(const TransactionError('AI Scanner belum dikonfigurasi.'));
      return;
    }
    emit(const TransactionLoading());
    try {
      final result = await _scanner.scanReceipt(event.photo);
      
      final scannedTxn = Transaction(
        id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
        title: result['title'] ?? 'Scan Struk Baru',
        amount: (result['amount'] as num?)?.toDouble() ?? 0.0,
        isIncome: result['isIncome'] ?? false,
        category: result['category'] ?? 'Lainnya',
        categoryIcon: 'bill', // Default icon
        dateTime: DateTime.now(),
      );
      
      // Auto save the scanned transaction directly (or emit success to open form pre-filled)
      // Based on user request: "langsung mengscan struk dengan kamera belakang, lalu ai akan menyimpan hasil scan ke database"
      final saveResult = _addTransaction != null
          ? await _addTransaction.call(AddTransactionParams(transaction: scannedTxn))
          : await _repository.addTransaction(scannedTxn);

      saveResult.fold(
        (f) => emit(TransactionError(f.message)),
        (_) => emit(TransactionScanSuccess(scannedTxn)),
      );
    } catch (e) {
      emit(TransactionError('Gagal memproses struk: ${ErrorMapper.mapToFailure(e).message}'));
    }
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
    // State-based double-submit guard (more reliable than a boolean flag)
    if (state is TransactionLoading) return;

    emit(const TransactionLoading());

    final result = _deleteUseCase != null
        ? await _deleteUseCase.call(DeleteTransactionParams(id: event.id))
        : await _repository.deleteTransaction(event.id);

    result.fold(
      (f) => emit(TransactionError(f.message)),
      (_) => emit(
        const TransactionSuccess(message: 'Transaksi berhasil dihapus.'),
      ),
    );
  }

  Future<void> _onSubmitRequested(
    TransactionSubmitRequested event,
    Emitter<TransactionState> emit,
  ) async {
    // State-based double-submit guard
    if (state is TransactionLoading) return;

    emit(const TransactionLoading());

    final transaction = Transaction(
      id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
      title: event.title,
      amount: event.amount,
      isIncome: event.isIncome,
      category: event.category,
      categoryIcon: event.categoryIcon,
      dateTime: DateTime.now(),
    );

    final result = _addTransaction != null
        ? await _addTransaction.call(AddTransactionParams(transaction: transaction))
        : await _repository.addTransaction(transaction);

    result.fold(
      (f) => emit(TransactionError(f.message)),
      (_) => emit(const TransactionSuccess()),
    );
  }

  void _onReset(TransactionReset event, Emitter<TransactionState> emit) {
    emit(const TransactionInitial());
  }
}
