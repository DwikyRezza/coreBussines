import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/home_models.dart'; // TransactionModel is here
import 'home_datasource.dart'; // For the HomeDataSource interface
import '../../../auth/data/repositories/auth_repository_impl.dart';

import '../../../../core/storage/local_storage_service.dart';

class HomeRemoteDataSourceImpl implements HomeDataSource {
  final SupabaseClient _supabase;
  final AuthRepositoryImpl _authRepository;
  final LocalStorageService _localStorage;

  HomeRemoteDataSourceImpl({
    required SupabaseClient supabase,
    required AuthRepositoryImpl authRepository,
    required LocalStorageService localStorage,
  })  : _supabase = supabase,
        _authRepository = authRepository,
        _localStorage = localStorage;

  @override
  Future<BalanceSummaryModel> getBalanceSummary() async {
    // We need the user's business ID first
    String? businessId = _localStorage.activeBusinessId;

    if (businessId == null) {
      final businessRes = await _supabase.from('business_members')
          .select('business_id')
          .eq('user_id', _supabase.auth.currentUser!.id)
          .limit(1)
          .single();
      
      businessId = businessRes['business_id'] as String;
      await _localStorage.setActiveBusinessId(businessId);
    }

    // Call the RPC get_dashboard_summary
    final response = await _supabase.rpc('get_dashboard_summary', params: {
      'p_business_id': businessId,
    }).single();

    final totalIncome = (response['total_income'] as num?)?.toDouble() ?? 0.0;
    final totalExpense = (response['total_expense'] as num?)?.toDouble() ?? 0.0;
    final totalBalance = totalIncome - totalExpense;

    // Monthly change could be calculated by calling get_monthly_cashflow or just estimating.
    // For now, we will use totalIncome and totalExpense as the monthly change (since RPC defaults to this month)
    final monthlyChange = totalBalance;
    final monthlyChangePercent = totalBalance > 0 ? 100.0 : 0.0; 

    // Read real user from cache
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
    final response = await _supabase.from('transactions').select('''
      id,
      amount,
      type,
      title,
      transaction_date,
      categories (name, icon)
    ''').order('transaction_date', ascending: false).limit(limit);

    final List<dynamic> data = response;
    return data.map((json) {
      return TransactionModel(
        id: json['id'] as String,
        title: json['title'] as String? ?? 'Transaksi',
        amount: (json['amount'] as num).toDouble(),
        isIncome: json['type'] == 'income',
        category: json['categories']?['name'] as String? ?? 'Lainnya',
        categoryIcon: json['categories']?['icon'] as String? ?? 'category',
        dateTime: DateTime.parse(json['transaction_date'] as String),
      );
    }).toList();
  }

  @override
  Future<InsightCardModel> getCurrentInsight() async {
    // A simplified insight generator based on summary
    try {
      final summary = await getBalanceSummary();
      final totalBalance = summary.totalBalance;
      
      if (totalBalance < 0) {
        return const InsightCardModel(
          title: 'Perhatian: Defisit Anggaran',
          message: 'Pengeluaran Anda bulan ini lebih besar dari pemasukan. Tinjau kembali pengeluaran Anda.',
          type: 'warning',
        );
      } else if (totalBalance > 0) {
        return const InsightCardModel(
          title: 'Arus Kas Positif!',
          message: 'Bagus! Anda memiliki arus kas yang positif bulan ini. Pertahankan kebiasaan ini.',
          type: 'success',
        );
      } else {
        return const InsightCardModel(
          title: 'Belum Ada Transaksi',
          message: 'Catat transaksi pertama Anda untuk mulai memantau arus kas.',
          type: 'info',
        );
      }
    } catch (e) {
      return const InsightCardModel(
        title: 'Arus Kas Stabil',
        message: 'Arus kas bulan ini terkendali. Pertahankan pola ini untuk mencapai target keuangan Anda.',
        type: 'info',
      );
    }
  }
}
