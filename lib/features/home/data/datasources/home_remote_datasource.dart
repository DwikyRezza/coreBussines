import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/home_models.dart';
import 'home_datasource.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';

import '../../../../core/storage/local_storage_service.dart';

class HomeRemoteDataSourceImpl implements HomeDataSource {
  final firebase_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final AuthRepositoryImpl _authRepository;
  final LocalStorageService _localStorage;

  HomeRemoteDataSourceImpl({
    required firebase_auth.FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required AuthRepositoryImpl authRepository,
    required LocalStorageService localStorage,
  })  : _auth = auth,
        _firestore = firestore,
        _authRepository = authRepository,
        _localStorage = localStorage;

  CollectionReference<Map<String, dynamic>> _transactionsRef(
    String businessId,
  ) {
    return _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('transactions');
  }

  Future<String> _getBusinessId() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User belum login.');
    }

    final cachedBusinessId = _localStorage.activeBusinessId;
    if (cachedBusinessId != null) return cachedBusinessId;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final businessId =
        userDoc.data()?['active_business_id'] as String? ?? 'business_${user.uid}';
    await _localStorage.setActiveBusinessId(businessId);
    return businessId;
  }

  DateTime _readDateTime(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  TransactionModel _transactionFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return TransactionModel(
      id: doc.id,
      title: data['title'] as String? ?? 'Transaksi',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      isIncome:
          data['is_income'] as bool? ?? (data['type'] as String?) == 'income',
      category: data['category'] as String? ?? 'Lainnya',
      categoryIcon: data['category_icon'] as String? ?? 'category',
      dateTime: _readDateTime(data['date_time'] ?? data['transaction_date']),
    );
  }

  @override
  Future<BalanceSummaryModel> getBalanceSummary() async {
    final businessId = await _getBusinessId();
    final snapshot = await _transactionsRef(businessId).get();
    final now = DateTime.now();

    double totalIncome = 0.0;
    double totalExpense = 0.0;
    double monthIncome = 0.0;
    double monthExpense = 0.0;

    for (final doc in snapshot.docs) {
      final transaction = _transactionFromDoc(doc);
      if (transaction.isIncome) {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount;
      }

      if (transaction.dateTime.year == now.year &&
          transaction.dateTime.month == now.month) {
        if (transaction.isIncome) {
          monthIncome += transaction.amount;
        } else {
          monthExpense += transaction.amount;
        }
      }
    }

    final totalBalance = totalIncome - totalExpense;
    final monthlyChange = monthIncome - monthExpense;
    final monthlyChangePercent =
        monthIncome == 0 ? 0.0 : (monthlyChange / monthIncome) * 100;

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
    final businessId = await _getBusinessId();
    final snapshot = await _transactionsRef(businessId)
        .orderBy('date_time', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map(_transactionFromDoc).toList();
  }

  @override
  Future<InsightCardModel> getCurrentInsight() async {
    try {
      final summary = await getBalanceSummary();
      final monthlyChange = summary.monthlyChange;

      if (monthlyChange < 0) {
        return const InsightCardModel(
          title: 'Perhatian: Defisit Anggaran',
          message: 'Pengeluaran Anda bulan ini lebih besar dari pemasukan. Tinjau kembali pengeluaran Anda.',
          type: 'warning',
        );
      } else if (monthlyChange > 0) {
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
