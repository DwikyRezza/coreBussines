import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction_detail_model.dart';
import '../../domain/entities/transaction_entities.dart';
import '../../../home/data/models/home_models.dart'; // TransactionModel is here
import 'transaction_local_datasource.dart';

// Actually, let's define TransactionRemoteDataSourceImpl that implements TransactionLocalDataSource (we'll rename the abstract class later if needed, or just implement it for now so we can hot-swap it).

class TransactionRemoteDataSourceImpl implements TransactionLocalDataSource {
  final SupabaseClient _supabase;

  TransactionRemoteDataSourceImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<List<TransactionModel>> getFilteredTransactions(TransactionFilter filter) async {
    // Determine the user's business ID first.
    // In a real app, this might be cached, but we can query it or use the RPC.
    // However, RLS policies only return transactions for the user's business anyway!
    // So we can just query the `transactions` table directly.

    var query = _supabase.from('transactions').select('''
      id,
      amount,
      type,
      title,
      transaction_date,
      categories (name, icon)
    ''');

    // For type filtering
    if (filter.type == TransactionType.income) {
      query = query.eq('type', 'income');
    } else if (filter.type == TransactionType.expense) {
      query = query.eq('type', 'expense');
    }

    // For categories
    // PostgREST filtering on joined tables can be tricky, so we filter locally if needed, or we just fetch all and filter.
    // We will just order them.
    final response = await query.order('transaction_date', ascending: false);

    final List<dynamic> data = response;
    var all = data.map((json) {
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

    // Local filtering for dates and categories
    if (filter.categories.isNotEmpty) {
      all = all.where((t) => filter.categories.contains(t.category)).toList();
    }

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
          return true;
      }
    }).toList();

    return all;
  }

  @override
  Future<TransactionDetailModel> getTransactionDetail(String id) async {
    final response = await _supabase.from('transactions').select('''
      id,
      amount,
      type,
      title,
      transaction_date,
      categories (name, icon)
    ''').eq('id', id).single();

    return TransactionDetailModel(
      id: response['id'] as String,
      title: response['title'] as String? ?? 'Transaksi',
      amount: (response['amount'] as num).toDouble(),
      isIncome: response['type'] == 'income',
      category: response['categories']?['name'] as String? ?? 'Lainnya',
      categoryIcon: response['categories']?['icon'] as String? ?? 'category',
      dateTime: DateTime.parse(response['transaction_date'] as String),
      paymentMethod: 'Cash', // Default for now
    );
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    // 1. Get the current user's business ID and default wallet and category
    // Since we need business_id to insert, we can fetch it via RPC or querying businesses
    final businessRes = await _supabase.from('business_members')
        .select('business_id')
        .eq('user_id', _supabase.auth.currentUser!.id)
        .limit(1)
        .single();
    
    final businessId = businessRes['business_id'];

    // For simplicity, we just pick the first wallet and a matching category
    final walletRes = await _supabase.from('wallets').select('id').eq('business_id', businessId).limit(1).single();
    final walletId = walletRes['id'];

    // Find category id
    final typeStr = transaction.isIncome ? 'income' : 'expense';
    final catRes = await _supabase.from('categories')
        .select('id')
        .eq('business_id', businessId)
        .eq('type', typeStr)
        .limit(1);
    
    String? categoryId;
    if (catRes.isNotEmpty) {
      categoryId = catRes.first['id'] as String;
    }

    await _supabase.from('transactions').insert({
      'business_id': businessId,
      'wallet_id': walletId,
      'category_id': categoryId,
      'type': typeStr,
      'amount': transaction.amount,
      'title': transaction.title,
      'transaction_date': transaction.dateTime.toIso8601String(),
    });
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _supabase.from('transactions').delete().eq('id', id);
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
}
