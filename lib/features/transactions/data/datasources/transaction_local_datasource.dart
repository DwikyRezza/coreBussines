// ============================================================
// FEATURE: Transactions — Local Data Source (SharedPreferences)
// lib/features/transactions/data/datasources/transaction_local_datasource.dart
//
// Persists transactions to device storage so data survives app restarts.
// TODO: API INTEGRATION — Replace read/write calls with HTTP requests:
//   GET    /api/v1/transactions?limit={n}  → getFilteredTransactions
//   POST   /api/v1/transactions            → addTransaction
//   DELETE /api/v1/transactions/{id}       → deleteTransaction
//   GET    /api/v1/transactions/{id}       → getTransactionDetail
// ============================================================

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_detail_model.dart';
import '../../../home/data/models/home_models.dart';
import '../../domain/entities/transaction_entities.dart';

abstract class TransactionLocalDataSource {
  Future<List<TransactionModel>> getFilteredTransactions(TransactionFilter filter);
  Future<TransactionDetailModel> getTransactionDetail(String id);
  Future<void> addTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);
  Future<List<TransactionModel>> getRecentTransactions({int limit = 5});
}

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  final SharedPreferences prefs;

  static const _kTransactionsKey = 'cached_transactions';

  TransactionLocalDataSourceImpl({required this.prefs});

  // ── Internal helpers ──────────────────────────────────────

  List<TransactionModel> _readAll() {
    final raw = prefs.getString(_kTransactionsKey);
    if (raw == null || raw.isEmpty) return _seedData();
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _seedData();
    }
  }

  Future<void> _writeAll(List<TransactionModel> transactions) async {
    final encoded = jsonEncode(transactions.map((t) => t.toJson()).toList());
    await prefs.setString(_kTransactionsKey, encoded);
  }

  /// Provide initial seed data for a fresh install so the UI is not empty.
  List<TransactionModel> _seedData() {
    final seeds = [
      TransactionModel(
        id: 'txn_seed_001',
        title: 'Makan Siang',
        category: 'Makanan',
        categoryIcon: 'food',
        amount: 45000,
        isIncome: false,
        dateTime: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      TransactionModel(
        id: 'txn_seed_002',
        title: 'Gaji Bulanan',
        category: 'Pendapatan',
        categoryIcon: 'income',
        amount: 15000000,
        isIncome: true,
        dateTime: DateTime.now().subtract(const Duration(days: 1)),
      ),
      TransactionModel(
        id: 'txn_seed_003',
        title: 'Belanja Mingguan',
        category: 'Belanja',
        categoryIcon: 'shopping',
        amount: 850000,
        isIncome: false,
        dateTime: DateTime.now().subtract(const Duration(days: 3)),
      ),
      TransactionModel(
        id: 'txn_seed_004',
        title: 'Freelance Design',
        category: 'Pendapatan',
        categoryIcon: 'income',
        amount: 3500000,
        isIncome: true,
        dateTime: DateTime.now().subtract(const Duration(days: 7)),
      ),
      TransactionModel(
        id: 'txn_seed_005',
        title: 'Token Listrik',
        category: 'Tagihan',
        categoryIcon: 'bill',
        amount: 200000,
        isIncome: false,
        dateTime: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
    // Persist seeds so next read doesn't regenerate them.
    _writeAll(seeds);
    return seeds;
  }

  // ── Public API ────────────────────────────────────────────

  @override
  Future<List<TransactionModel>> getFilteredTransactions(
    TransactionFilter filter,
  ) async {
    // TODO: API INTEGRATION → GET /api/v1/transactions?type=&date_range=&categories=
    var all = _readAll();

    // Filter by income/expense type
    if (filter.type == TransactionType.income) {
      all = all.where((t) => t.isIncome).toList();
    } else if (filter.type == TransactionType.expense) {
      all = all.where((t) => !t.isIncome).toList();
    }

    // Filter by category
    if (filter.categories.isNotEmpty) {
      all = all.where((t) => filter.categories.contains(t.category)).toList();
    }

    // Filter by date range
    final now = DateTime.now();
    all = all.where((t) {
      switch (filter.dateRange) {
        case DateRangeFilter.thisWeek:
          return t.dateTime.isAfter(now.subtract(const Duration(days: 7)));
        case DateRangeFilter.thisMonth:
          return t.dateTime.year == now.year && t.dateTime.month == now.month;
        case DateRangeFilter.thisYear:
          return t.dateTime.year == now.year;
        case DateRangeFilter.custom:
          return true; // Let caller handle custom range
      }
    }).toList();

    // Sort newest first
    all.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return all;
  }

  @override
  Future<TransactionDetailModel> getTransactionDetail(String id) async {
    // TODO: API INTEGRATION → GET /api/v1/transactions/{id}
    final all = _readAll();
    final txn = all.firstWhere(
      (t) => t.id == id,
      orElse: () => throw Exception('Transaction $id not found'),
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
    );
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    // TODO: API INTEGRATION → POST /api/v1/transactions  {body: transaction.toJson()}
    final all = _readAll();
    all.insert(0, transaction); // Newest first
    await _writeAll(all);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    // TODO: API INTEGRATION → DELETE /api/v1/transactions/{id}
    final all = _readAll();
    all.removeWhere((t) => t.id == id);
    await _writeAll(all);
  }

  @override
  Future<List<TransactionModel>> getRecentTransactions({int limit = 5}) async {
    // TODO: API INTEGRATION → GET /api/v1/transactions?limit={limit}&sort=date_desc
    final all = _readAll();
    all.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return all.take(limit).toList();
  }
}
