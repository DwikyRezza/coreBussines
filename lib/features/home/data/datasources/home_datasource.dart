// ============================================================
// FEATURE: Home — Data Source
// lib/features/home/data/datasources/home_datasource.dart
// ============================================================

import '../models/home_models.dart';

abstract class HomeDataSource {
  Future<BalanceSummaryModel> getBalanceSummary();
  Future<List<TransactionModel>> getRecentTransactions({int limit = 10});
  Future<InsightCardModel> getCurrentInsight();
  Stream<HomeDashboardDataModel> watchDashboardData();
}
