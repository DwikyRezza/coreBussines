// ============================================================
// FEATURE: Transactions — Mock Data Source
// lib/features/transactions/data/datasources/transaction_mock_datasource.dart
// ============================================================

import '../models/transaction_detail_model.dart';
import '../../../home/data/models/home_models.dart';
import '../../domain/entities/transaction_entities.dart';

abstract class TransactionDataSource {
  Future<TransactionDetailModel> getTransactionDetail(String id);
  Future<List<TransactionModel>> getFilteredTransactions(TransactionFilter filter);
  Future<void> deleteTransaction(String id);
  Future<void> addTransaction(TransactionModel transaction);
}

class TransactionMockDataSource implements TransactionDataSource {
  static final List<TransactionModel> _allTransactions = [
    TransactionModel(
      id: 'txn_001',
      title: 'Makan Siang',
      category: 'Makanan',
      categoryIcon: 'food',
      amount: 45000,
      isIncome: false,
      dateTime: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    TransactionModel(
      id: 'txn_002',
      title: 'Gaji Bulanan',
      category: 'Pendapatan',
      categoryIcon: 'income',
      amount: 15000000,
      isIncome: true,
      dateTime: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    ),
    TransactionModel(
      id: 'txn_003',
      title: 'Belanja Mingguan',
      category: 'Belanja',
      categoryIcon: 'shopping',
      amount: 850000,
      isIncome: false,
      dateTime: DateTime.now().subtract(const Duration(days: 15, hours: 5)),
    ),
    TransactionModel(
      id: 'txn_004',
      title: 'Langganan Gym Bulanan',
      category: 'Kesehatan & Kebugaran',
      categoryIcon: 'health',
      amount: 750000,
      isIncome: false,
      dateTime: DateTime(2024, 5, 24, 9, 42),
    ),
    TransactionModel(
      id: 'txn_005',
      title: 'Transfer ke Tabungan',
      category: 'Tabungan',
      categoryIcon: 'savings',
      amount: 2000000,
      isIncome: false,
      dateTime: DateTime.now().subtract(const Duration(days: 5)),
    ),
    TransactionModel(
      id: 'txn_006',
      title: 'Freelance Design',
      category: 'Pendapatan',
      categoryIcon: 'income',
      amount: 3500000,
      isIncome: true,
      dateTime: DateTime.now().subtract(const Duration(days: 7)),
    ),
    TransactionModel(
      id: 'txn_007',
      title: 'Token Listrik',
      category: 'Tagihan',
      categoryIcon: 'bill',
      amount: 200000,
      isIncome: false,
      dateTime: DateTime.now().subtract(const Duration(days: 10)),
    ),
    TransactionModel(
      id: 'txn_008',
      title: 'GoFood',
      category: 'Makanan',
      categoryIcon: 'food',
      amount: 85000,
      isIncome: false,
      dateTime: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  @override
  Future<TransactionDetailModel> getTransactionDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Return the Gym transaction as the detailed view (matching screenshots)
    if (id == 'txn_004') {
      return TransactionDetailModel(
        id: 'txn_004',
        title: 'Langganan Gym Bulanan',
        amount: 750000,
        isIncome: false,
        category: 'Kesehatan & Kebugaran',
        categoryIcon: 'health',
        dateTime: DateTime(2024, 5, 24, 9, 42),
        paymentMethod: 'Mandiri CoreBusiness Wallet',
        isMainPayment: true,
        note:
            "Pembayaran rutin untuk keanggotaan Gold Gym di Mall Central Park. Termasuk akses kolam renang dan personal trainer session untuk 4 kali pertemuan bulan ini. Kwitansi disimpan di folder 'Finansial 2024'.",
        receiptImageUrl: null,
      );
    }

    // Generic fallback
    final txn = _allTransactions.firstWhere(
      (t) => t.id == id,
      orElse: () => _allTransactions.first,
    );
    return TransactionDetailModel(
      id: txn.id,
      title: txn.title,
      amount: txn.amount,
      isIncome: txn.isIncome,
      category: txn.category,
      categoryIcon: txn.categoryIcon,
      dateTime: txn.dateTime,
      paymentMethod: 'CoreBusiness Wallet',
      isMainPayment: false,
    );
  }

  @override
  Future<List<TransactionModel>> getFilteredTransactions(
    TransactionFilter filter,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));

    var result = List<TransactionModel>.from(_allTransactions);

    // Filter by type
    if (filter.type == TransactionType.income) {
      result = result.where((t) => t.isIncome).toList();
    } else if (filter.type == TransactionType.expense) {
      result = result.where((t) => !t.isIncome).toList();
    }

    // Filter by categories
    if (filter.categories.isNotEmpty) {
      result = result
          .where((t) => filter.categories.contains(t.category))
          .toList();
    }

    return result;
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _allTransactions.removeWhere((t) => t.id == id);
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _allTransactions.insert(0, transaction); // Insert at the beginning
  }
}
