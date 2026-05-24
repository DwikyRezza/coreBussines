import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:rxdart/rxdart.dart';
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

  CollectionReference<Map<String, dynamic>> _walletsRef(String businessId) {
    return _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('wallets');
  }

  Future<String> _getBusinessId() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User belum login.');
    }

    final cachedBusinessId = _localStorage.activeBusinessId;
    if (cachedBusinessId != null) return cachedBusinessId;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final businessId = userDoc.data()?['active_business_id'] as String? ??
        'business_${user.uid}';
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
      walletId: data['wallet_id'] as String? ?? data['walletId'] as String?,
      walletName:
          data['wallet_name'] as String? ?? data['walletName'] as String?,
      receiptImageUrl: data['receipt_image_url'] as String? ??
          data['receiptImageUrl'] as String?,
      createdByUserId: data['created_by_user_id'] as String? ??
          data['createdByUserId'] as String?,
      createdByName: data['created_by_name'] as String? ??
          data['createdByName'] as String?,
      createdByEmail: data['created_by_email'] as String? ??
          data['createdByEmail'] as String?,
      createdByRole: data['created_by_role'] as String? ??
          data['createdByRole'] as String?,
      createdAt: _readNullableDateTime(data['created_at'] ?? data['createdAt']),
      updatedAt: _readNullableDateTime(data['updated_at'] ?? data['updatedAt']),
    );
  }

  DateTime? _readNullableDateTime(Object? value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
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
          message:
              'Pengeluaran Anda bulan ini lebih besar dari pemasukan. Tinjau kembali pengeluaran Anda.',
          type: 'warning',
        );
      } else if (monthlyChange > 0) {
        return const InsightCardModel(
          title: 'Arus Kas Positif!',
          message:
              'Bagus! Anda memiliki arus kas yang positif bulan ini. Pertahankan kebiasaan ini.',
          type: 'success',
        );
      } else {
        return const InsightCardModel(
          title: 'Belum Ada Transaksi',
          message:
              'Catat transaksi pertama Anda untuk mulai memantau arus kas.',
          type: 'info',
        );
      }
    } catch (e) {
      return const InsightCardModel(
        title: 'Arus Kas Stabil',
        message:
            'Arus kas bulan ini terkendali. Pertahankan pola ini untuk mencapai target keuangan Anda.',
        type: 'info',
      );
    }
  }

  @override
  Stream<HomeDashboardDataModel> watchDashboardData() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.error(StateError('User belum login.'));
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .switchMap((userSnap) {
      final userData = userSnap.data();
      final businessId = userData?['active_business_id'] as String? ??
          _localStorage.activeBusinessId ??
          'business_${user.uid}';

      final transactionsStream = _transactionsRef(businessId)
          .orderBy('date_time', descending: true)
          .snapshots();
      final walletsStream = _walletsRef(businessId).snapshots();

      return Rx.combineLatest2<QuerySnapshot<Map<String, dynamic>>,
          QuerySnapshot<Map<String, dynamic>>, HomeDashboardDataModel>(
        transactionsStream,
        walletsStream,
        (transactionSnapshot, walletSnapshot) {
          final transactions =
              transactionSnapshot.docs.map(_transactionFromDoc).toList();
          final now = DateTime.now();

          double totalIncome = 0.0;
          double totalExpense = 0.0;
          double monthIncome = 0.0;
          double monthExpense = 0.0;

          for (final transaction in transactions) {
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

          final walletBalance = walletSnapshot.docs.fold<double>(
            0,
            (runningTotal, doc) =>
                runningTotal + ((doc.data()['balance'] as num?)?.toDouble() ?? 0),
          );
          final fallbackBalance = totalIncome - totalExpense;
          final monthlyChange = monthIncome - monthExpense;
          final monthlyChangePercent =
              monthIncome == 0 ? 0.0 : (monthlyChange / monthIncome) * 100;

          final cached = _authRepository.cachedUser;
          final summary = BalanceSummaryModel(
            totalBalance:
                walletSnapshot.docs.isEmpty ? fallbackBalance : walletBalance,
            monthlyChange: monthlyChange,
            monthlyChangePercent: monthlyChangePercent,
            userName: cached?.name ?? 'Pengguna',
            userPhotoUrl: cached?.photoUrl,
          );

          final insight = _buildInsight(monthlyChange);
          return HomeDashboardDataModel(
            summary: summary,
            recentTransactions: transactions.take(5).toList(),
            allTransactions: transactions,
            insight: insight,
          );
        },
      );
    });
  }

  InsightCardModel _buildInsight(double monthlyChange) {
    if (monthlyChange < 0) {
      return const InsightCardModel(
        title: 'Perhatian: Defisit Anggaran',
        message:
            'Pengeluaran bulan ini lebih besar dari pemasukan. Tinjau kembali pengeluaran bisnis.',
        type: 'warning',
      );
    }
    if (monthlyChange > 0) {
      return const InsightCardModel(
        title: 'Arus Kas Positif!',
        message: 'Bisnis memiliki arus kas positif bulan ini.',
        type: 'success',
      );
    }
    return const InsightCardModel(
      title: 'Belum Ada Transaksi',
      message: 'Catat transaksi pertama untuk mulai memantau arus kas.',
      type: 'info',
    );
  }
}
