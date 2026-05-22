import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/transaction_detail_model.dart';
import '../../domain/entities/transaction_entities.dart';
import '../../../home/data/models/home_models.dart';
import '../../../../core/storage/local_storage_service.dart';

abstract class TransactionRemoteDataSource {
  Future<List<TransactionModel>> getFilteredTransactions(
    TransactionFilter filter,
  );
  Future<TransactionDetailModel> getTransactionDetail(String id);
  Future<void> addTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);
  Future<List<TransactionModel>> getRecentTransactions({int limit = 5});
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final firebase_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final LocalStorageService _localStorage;

  TransactionRemoteDataSourceImpl({
    required firebase_auth.FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required LocalStorageService localStorage,
  })  : _auth = auth,
        _firestore = firestore,
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
    final businessId =
        userDoc.data()?['active_business_id'] as String? ?? 'business_${user.uid}';
    await _localStorage.setActiveBusinessId(businessId);
    return businessId;
  }

  TransactionModel _transactionFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return _transactionFromMap(doc.id, doc.data());
  }

  TransactionModel _transactionFromMap(String id, Map<String, dynamic> data) {
    return TransactionModel(
      id: id,
      title: data['title'] as String? ?? 'Transaksi',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      isIncome:
          data['is_income'] as bool? ?? (data['type'] as String?) == 'income',
      category: data['category'] as String? ?? 'Lainnya',
      categoryIcon: data['category_icon'] as String? ?? 'category',
      dateTime: _readDateTime(data['date_time'] ?? data['transaction_date']),
    );
  }

  DateTime _readDateTime(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  @override
  Future<List<TransactionModel>> getFilteredTransactions(
    TransactionFilter filter,
  ) async {
    final businessId = await _getBusinessId();
    var query = _transactionsRef(businessId).orderBy(
      'date_time',
      descending: true,
    );

    if (filter.type == TransactionType.income) {
      query = query.where('type', isEqualTo: 'income');
    } else if (filter.type == TransactionType.expense) {
      query = query.where('type', isEqualTo: 'expense');
    }

    final snapshot = await query.get();
    var transactions = snapshot.docs.map(_transactionFromDoc).toList();

    if (filter.categories.isNotEmpty) {
      transactions = transactions
          .where((transaction) => filter.categories.contains(transaction.category))
          .toList();
    }

    final now = DateTime.now();
    transactions = transactions.where((transaction) {
      switch (filter.dateRange) {
        case DateRangeFilter.thisWeek:
          return transaction.dateTime.isAfter(
            now.subtract(const Duration(days: 7)),
          );
        case DateRangeFilter.thisMonth:
          return transaction.dateTime.year == now.year &&
              transaction.dateTime.month == now.month;
        case DateRangeFilter.thisYear:
          return transaction.dateTime.year == now.year;
        case DateRangeFilter.custom:
          return true;
      }
    }).toList();

    return transactions;
  }

  @override
  Future<TransactionDetailModel> getTransactionDetail(String id) async {
    final businessId = await _getBusinessId();
    final doc = await _transactionsRef(businessId).doc(id).get();

    if (!doc.exists || doc.data() == null) {
      throw StateError('Transaksi tidak ditemukan.');
    }

    final transaction = _transactionFromMap(doc.id, doc.data()!);
    return TransactionDetailModel(
      id: transaction.id,
      title: transaction.title,
      amount: transaction.amount,
      isIncome: transaction.isIncome,
      category: transaction.category,
      categoryIcon: transaction.categoryIcon,
      dateTime: transaction.dateTime,
      paymentMethod: doc.data()?['payment_method'] as String? ?? 'Cash',
      note: doc.data()?['note'] as String?,
      receiptImageUrl: doc.data()?['receipt_image_url'] as String?,
    );
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    final businessId = await _getBusinessId();
    final type = transaction.isIncome ? 'income' : 'expense';
    final walletRef = _walletsRef(businessId).doc('default_cash');
    final amountDelta = transaction.isIncome
        ? transaction.amount
        : -transaction.amount;

    await _firestore.runTransaction((firestoreTransaction) async {
      final walletSnapshot = await firestoreTransaction.get(walletRef);
      final currentBalance =
          (walletSnapshot.data()?['balance'] as num?)?.toDouble() ?? 0.0;

      final docRef = transaction.id.isEmpty
          ? _transactionsRef(businessId).doc()
          : _transactionsRef(businessId).doc(transaction.id);

      firestoreTransaction.set(docRef, {
        'title': transaction.title,
        'amount': transaction.amount,
        'is_income': transaction.isIncome,
        'type': type,
        'category': transaction.category,
        'category_icon': transaction.categoryIcon,
        'date_time': Timestamp.fromDate(transaction.dateTime),
        'wallet_id': walletRef.id,
        'payment_method': 'Cash',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      firestoreTransaction.set(walletRef, {
        'name': walletSnapshot.data()?['name'] ?? 'Cash',
        'type': walletSnapshot.data()?['type'] ?? 'cash',
        'balance': currentBalance + amountDelta,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final businessId = await _getBusinessId();
    final transactionRef = _transactionsRef(businessId).doc(id);
    final walletRef = _walletsRef(businessId).doc('default_cash');

    await _firestore.runTransaction((firestoreTransaction) async {
      final snapshot = await firestoreTransaction.get(transactionRef);
      if (!snapshot.exists || snapshot.data() == null) return;

      final data = snapshot.data()!;
      final isIncome =
          data['is_income'] as bool? ?? (data['type'] as String?) == 'income';
      final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
      final amountDelta = isIncome ? -amount : amount;
      final walletSnapshot = await firestoreTransaction.get(walletRef);
      final currentBalance =
          (walletSnapshot.data()?['balance'] as num?)?.toDouble() ?? 0.0;

      firestoreTransaction.delete(transactionRef);
      firestoreTransaction.set(walletRef, {
        'name': walletSnapshot.data()?['name'] ?? 'Cash',
        'type': walletSnapshot.data()?['type'] ?? 'cash',
        'balance': currentBalance + amountDelta,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
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
}
