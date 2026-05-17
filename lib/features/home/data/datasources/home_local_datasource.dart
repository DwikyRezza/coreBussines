// ============================================================
// FEATURE: Home — Local Data Source (SharedPreferences-backed)
// lib/features/home/data/datasources/home_local_datasource.dart
//
// Computes BalanceSummary from persisted transaction data.
// Reads the real logged-in user name from AuthRepositoryImpl cache.
//
// TODO: API INTEGRATION
//   GET /api/v1/home/summary          → getBalanceSummary
//   GET /api/v1/home/insight          → getCurrentInsight
//   GET /api/v1/transactions?limit={n}→ getRecentTransactions
// ============================================================

import '../models/home_models.dart';
import '../datasources/home_mock_datasource.dart';
import '../../../transactions/data/datasources/transaction_local_datasource.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';

/// Extends the existing [HomeDataSource] interface — fits
/// [HomeRepositoryImpl] without any changes.
class HomeLocalDataSourceImpl implements HomeDataSource {
  final TransactionLocalDataSource _transactionDataSource;
  final AuthRepositoryImpl _authRepository;

  const HomeLocalDataSourceImpl({
    required TransactionLocalDataSource transactionDataSource,
    required AuthRepositoryImpl authRepository,
  })  : _transactionDataSource = transactionDataSource,
        _authRepository = authRepository;

  @override
  Future<BalanceSummaryModel> getBalanceSummary() async {
    // TODO: API INTEGRATION → GET /api/v1/home/summary
    final allTransactions = await _transactionDataSource.getRecentTransactions(
      limit: 9999,
    );

    double totalIncome = 0;
    double totalExpense = 0;
    double monthlyIncome = 0;
    double monthlyExpense = 0;
    final now = DateTime.now();

    for (final t in allTransactions) {
      if (t.isIncome) {
        totalIncome += t.amount;
      } else {
        totalExpense += t.amount;
      }
      if (t.dateTime.year == now.year && t.dateTime.month == now.month) {
        if (t.isIncome) {
          monthlyIncome += t.amount;
        } else {
          monthlyExpense += t.amount;
        }
      }
    }

    final totalBalance = totalIncome - totalExpense;
    final monthlyChange = monthlyIncome - monthlyExpense;
    final monthlyChangePercent =
        totalBalance > 0 ? (monthlyChange / totalBalance) * 100 : 0.0;

    // Read real user from the synchronous cachedUser getter — no async needed
    final cached = _authRepository.cachedUser;
    final userName = cached?.name ?? 'Pengguna';
    final userPhotoUrl = cached?.photoUrl;

    return BalanceSummaryModel(
      totalBalance: totalBalance,
      monthlyChange: monthlyChange,
      monthlyChangePercent: monthlyChangePercent,
      userName: userName,
      userPhotoUrl: userPhotoUrl,
    );
  }

  @override
  Future<List<TransactionModel>> getRecentTransactions({int limit = 5}) async {
    // TODO: API INTEGRATION → GET /api/v1/transactions?limit={limit}&sort=date_desc
    return _transactionDataSource.getRecentTransactions(limit: limit);
  }

  @override
  Future<InsightCardModel> getCurrentInsight() async {
    // TODO: API INTEGRATION → GET /api/v1/home/insight (AI-generated narrative)
    final transactions = await _transactionDataSource.getRecentTransactions(
      limit: 9999,
    );

    double monthlyExpense = 0;
    double monthlyIncome = 0;
    final now = DateTime.now();

    for (final t in transactions) {
      if (t.dateTime.year == now.year && t.dateTime.month == now.month) {
        if (t.isIncome) {
          monthlyIncome += t.amount;
        } else {
          monthlyExpense += t.amount;
        }
      }
    }

    final savingsRate = monthlyIncome > 0
        ? ((monthlyIncome - monthlyExpense) / monthlyIncome) * 100
        : 0.0;

    if (monthlyExpense > monthlyIncome && monthlyIncome > 0) {
      return const InsightCardModel(
        title: 'Perhatian: Defisit Anggaran',
        message:
            'Pengeluaran bulan ini melebihi pemasukan. Tinjau kategori terbesar dan kurangi pengeluaran tidak perlu.',
        type: 'warning',
      );
    }

    if (savingsRate >= 30) {
      return InsightCardModel(
        title: 'Luar Biasa!',
        message:
            'Tingkat tabungan Anda bulan ini ${savingsRate.toStringAsFixed(0)}%. Pertahankan pola keuangan yang sangat baik ini.',
        type: 'success',
      );
    }

    return const InsightCardModel(
      title: 'Arus Kas Stabil',
      message:
          'Arus kas bulan ini terkendali. Pertahankan pola ini untuk mencapai target keuangan Anda.',
      type: 'info',
    );
  }
}
