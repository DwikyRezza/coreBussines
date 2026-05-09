// ============================================================
// FEATURE: Home — Mock Data Source (production: replace with API)
// lib/features/home/data/datasources/home_mock_datasource.dart
// ============================================================

import '../models/home_models.dart';

abstract class HomeDataSource {
  Future<BalanceSummaryModel> getBalanceSummary();
  Future<List<TransactionModel>> getRecentTransactions({int limit = 10});
  Future<InsightCardModel> getCurrentInsight();
}

/// Mock implementation — mirrors data from the screenshots exactly.
/// Replace with real API datasource in production.
class HomeMockDataSource implements HomeDataSource {
  @override
  Future<BalanceSummaryModel> getBalanceSummary() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return BalanceSummaryModel(
      totalBalance: 42850000,
      monthlyChange: 2400000,
      monthlyChangePercent: 5.9,
      userName: 'Alex Chen',
      userPhotoUrl: null,
    );
  }

  @override
  Future<List<TransactionModel>> getRecentTransactions({int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
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
        dateTime: DateTime.now().subtract(const Duration(days: 16, hours: 1)),
      ),
    ].take(limit).toList();
  }

  @override
  Future<InsightCardModel> getCurrentInsight() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return InsightCardModel(
      title: 'Insight AI',
      message:
          'Arus kas Anda minggu ini lebih stabil dari minggu lalu. Pertahankan pola pengeluaran ini untuk mencapai target tabungan Anda.',
      type: 'info',
    );
  }
}
