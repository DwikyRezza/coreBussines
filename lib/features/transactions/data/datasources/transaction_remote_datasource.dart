import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_storage/firebase_storage.dart';
import '../models/transaction_detail_model.dart';
import '../../domain/entities/transaction_entities.dart';
import '../../../home/data/models/home_models.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/services/business_context_service.dart';
import '../../../../core/utils/activity_logger.dart';

abstract class TransactionRemoteDataSource {
  Future<List<TransactionModel>> getFilteredTransactions(
    TransactionFilter filter,
  );
  Future<TransactionDetailModel> getTransactionDetail(String id);
  Stream<TransactionDetailModel> watchTransactionDetail(String id);
  Future<void> addTransaction(TransactionModel transaction);
  Future<void> addTransactionInput(TransactionInput input);
  Future<void> deleteTransaction(String id);
  Future<List<TransactionModel>> getRecentTransactions({int limit = 5});
  Stream<List<TransactionModel>> watchFilteredTransactions(
    TransactionFilter filter,
  );
  Stream<List<TransactionModel>> watchRecentTransactions({int limit = 5});
  Stream<List<WalletOption>> watchWalletOptions();
  Stream<List<TransactionCategory>> watchCategories();
  Future<void> addCategory(TransactionCategory category);
  Future<void> deleteCategory(String categoryId);
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final firebase_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final LocalStorageService _localStorage;
  final FirebaseStorage _storage;
  final BusinessContextService _businessContext;

  TransactionRemoteDataSourceImpl({
    required firebase_auth.FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required LocalStorageService localStorage,
    required FirebaseStorage storage,
    required BusinessContextService businessContext,
  })  : _auth = auth,
        _firestore = firestore,
        _localStorage = localStorage,
        _storage = storage,
        _businessContext = businessContext;

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

  DateTime _readDateTime(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  DateTime? _readNullableDateTime(Object? value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  Query<Map<String, dynamic>> _baseTransactionQuery(
    String businessId,
    TransactionFilter filter,
  ) {
    Query<Map<String, dynamic>> query = _transactionsRef(businessId).orderBy(
      'date_time',
      descending: true,
    );

    if (filter.type == TransactionType.income) {
      query = query.where('type', isEqualTo: 'income');
    } else if (filter.type == TransactionType.expense) {
      query = query.where('type', isEqualTo: 'expense');
    }
    return query;
  }

  List<TransactionModel> _applyClientFilter(
    List<TransactionModel> transactions,
    TransactionFilter filter,
  ) {
    var result = transactions;
    if (filter.categories.isNotEmpty) {
      result = result
          .where(
              (transaction) => filter.categories.contains(transaction.category))
          .toList();
    }
    if (filter.wallets.isNotEmpty) {
      result = result
          .where((transaction) =>
              transaction.walletId != null &&
              filter.wallets.contains(transaction.walletId))
          .toList();
    }

    final now = DateTime.now();
    return result.where((transaction) {
      switch (filter.dateRange) {
        case DateRangeFilter.thisWeek:
          final startOfWeek = DateTime(now.year, now.month, now.day)
              .subtract(Duration(days: now.weekday - 1));
          return !transaction.dateTime.isBefore(startOfWeek);
        case DateRangeFilter.thisMonth:
          return transaction.dateTime.year == now.year &&
              transaction.dateTime.month == now.month;
        case DateRangeFilter.thisYear:
          return transaction.dateTime.year == now.year;
        case DateRangeFilter.custom:
          return true;
      }
    }).toList();
  }

  @override
  Future<List<TransactionModel>> getFilteredTransactions(
    TransactionFilter filter,
  ) async {
    final businessId = await _getBusinessId();
    final snapshot = await _baseTransactionQuery(businessId, filter).get();
    return _applyClientFilter(
      snapshot.docs.map(_transactionFromDoc).toList(),
      filter,
    );
  }

  @override
  Stream<List<TransactionModel>> watchFilteredTransactions(
    TransactionFilter filter,
  ) async* {
    final businessId = await _getBusinessId();
    yield* _baseTransactionQuery(businessId, filter).snapshots().map(
          (snapshot) => _applyClientFilter(
            snapshot.docs.map(_transactionFromDoc).toList(),
            filter,
          ),
        );
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
      walletId: transaction.walletId,
      walletName: transaction.walletName,
      createdByUserId: transaction.createdByUserId,
      createdByName: transaction.createdByName,
      createdByEmail: transaction.createdByEmail,
      createdByRole: transaction.createdByRole,
      createdAt: transaction.createdAt,
      updatedAt: transaction.updatedAt,
    );
  }

  @override
  Stream<TransactionDetailModel> watchTransactionDetail(String id) async* {
    final businessId = await _getBusinessId();
    yield* _transactionsRef(businessId).doc(id).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        throw StateError('Transaksi tidak ditemukan.');
      }
      final data = doc.data()!;
      final transaction = _transactionFromMap(doc.id, data);
      return TransactionDetailModel(
        id: transaction.id,
        title: transaction.title,
        amount: transaction.amount,
        isIncome: transaction.isIncome,
        category: transaction.category,
        categoryIcon: transaction.categoryIcon,
        dateTime: transaction.dateTime,
        paymentMethod: data['payment_method'] as String? ?? 'Cash',
        note: data['note'] as String?,
        receiptImageUrl: transaction.receiptImageUrl,
        walletId: transaction.walletId,
        walletName: transaction.walletName,
        createdByUserId: transaction.createdByUserId,
        createdByName: transaction.createdByName,
        createdByEmail: transaction.createdByEmail,
        createdByRole: transaction.createdByRole,
        createdAt: transaction.createdAt,
        updatedAt: transaction.updatedAt,
      );
    });
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    await addTransactionInput(TransactionInput(
      id: transaction.id,
      title: transaction.title,
      amount: transaction.amount,
      isIncome: transaction.isIncome,
      category: transaction.category,
      categoryIcon: transaction.categoryIcon,
      walletId: transaction.walletId ?? 'default_cash',
      walletName: transaction.walletName ?? 'Cash',
      dateTime: transaction.dateTime,
      source: 'ai_scan',
    ));
  }

  @override
  Future<void> addTransactionInput(TransactionInput input) async {
    if (input.amount <= 0) {
      throw ArgumentError('Nominal wajib lebih dari 0.');
    }
    if (input.walletId.trim().isEmpty) {
      throw ArgumentError('Wallet wajib dipilih.');
    }
    if (input.category.trim().isEmpty) {
      throw ArgumentError('Kategori wajib dipilih.');
    }
    if (input.requiresReceipt &&
        (input.receiptImagePath == null || input.receiptImagePath!.isEmpty)) {
      throw ArgumentError('Bukti pembayaran wajib dilampirkan.');
    }

    final context = await _businessContext.getCurrentContext();
    final type = input.isIncome ? 'income' : 'expense';
    final docRef = input.id.isEmpty
        ? _transactionsRef(context.businessId).doc()
        : _transactionsRef(context.businessId).doc(input.id);
    final walletRef = _walletsRef(context.businessId).doc(input.walletId);
    final amountDelta = input.isIncome ? input.amount : -input.amount;
    final receiptUrl = input.receiptImagePath == null
        ? null
        : await _uploadReceiptImage(
            businessId: context.businessId,
            transactionId: docRef.id,
            path: input.receiptImagePath!,
          );

    await _firestore.runTransaction((firestoreTransaction) async {
      final walletSnapshot = await firestoreTransaction.get(walletRef);
      final walletData = walletSnapshot.data();
      final currentBalance =
          (walletData?['balance'] as num?)?.toDouble() ?? 0.0;
      final walletName = walletData?['name'] as String? ?? input.walletName;
      final walletType = walletData?['type'] as String? ?? 'cash';

      firestoreTransaction.set(docRef, {
        'title': input.title,
        'amount': input.amount,
        'is_income': input.isIncome,
        'type': type,
        'category': input.category,
        'category_icon': input.categoryIcon,
        'date_time': Timestamp.fromDate(input.dateTime),
        'transaction_date': Timestamp.fromDate(input.dateTime),
        'wallet_id': walletRef.id,
        'walletId': walletRef.id,
        'wallet_name': walletName,
        'walletName': walletName,
        'payment_method': walletName,
        'note': input.note,
        'receipt_image_url': receiptUrl,
        'receiptImageUrl': receiptUrl,
        'source': input.source,
        'business_id': context.businessId,
        'businessId': context.businessId,
        'created_by_user_id': context.userId,
        'createdByUserId': context.userId,
        'created_by_name': context.userName,
        'createdByName': context.userName,
        'created_by_email': context.userEmail,
        'createdByEmail': context.userEmail,
        'created_by_role': context.role,
        'createdByRole': context.role,
        'created_at': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      firestoreTransaction.set(
          walletRef,
          {
            'name': walletName,
            'type': walletType,
            'balance': currentBalance + amountDelta,
            'updated_at': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));
    });

    final actionDesc = input.isIncome
        ? 'menambahkan transaksi pemasukan "${input.title}" sebesar Rp ${input.amount.toInt()}'
        : 'menambahkan transaksi pengeluaran "${input.title}" sebesar Rp ${input.amount.toInt()}';
    await ActivityLogger.log(
      action: 'add_transaction',
      targetType: 'transaction',
      targetId: docRef.id,
      description: '${context.userName} $actionDesc',
    );
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final businessId = await _getBusinessId();
    final transactionRef = _transactionsRef(businessId).doc(id);
    final context = await _businessContext.getCurrentContext();

    final snapshot = await transactionRef.get();
    if (!snapshot.exists || snapshot.data() == null) return;
    final data = snapshot.data()!;
    final title = data['title'] as String? ?? 'Transaksi';
    final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;

    await _firestore.runTransaction((firestoreTransaction) async {
      final freshSnapshot = await firestoreTransaction.get(transactionRef);
      if (!freshSnapshot.exists || freshSnapshot.data() == null) return;

      final freshData = freshSnapshot.data()!;
      final freshIsIncome =
          freshData['is_income'] as bool? ?? (freshData['type'] as String?) == 'income';
      final freshAmount = (freshData['amount'] as num?)?.toDouble() ?? 0.0;
      final amountDelta = freshIsIncome ? -freshAmount : freshAmount;
      final walletId = freshData['wallet_id'] as String? ??
          freshData['walletId'] as String? ??
          'default_cash';
      final walletRef = _walletsRef(businessId).doc(walletId);
      final walletSnapshot = await firestoreTransaction.get(walletRef);
      final currentBalance =
          (walletSnapshot.data()?['balance'] as num?)?.toDouble() ?? 0.0;

      firestoreTransaction.delete(transactionRef);
      firestoreTransaction.set(
          walletRef,
          {
            'name': walletSnapshot.data()?['name'] ?? 'Cash',
            'type': walletSnapshot.data()?['type'] ?? 'cash',
            'balance': currentBalance + amountDelta,
            'updated_at': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));
    });

    final actionDesc = 'menghapus transaksi "$title" sebesar Rp ${amount.toInt()}';
    await ActivityLogger.log(
      action: 'delete_transaction',
      targetType: 'transaction',
      targetId: id,
      description: '${context.userName} $actionDesc',
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
  Stream<List<TransactionModel>> watchRecentTransactions(
      {int limit = 5}) async* {
    final businessId = await _getBusinessId();
    yield* _transactionsRef(businessId)
        .orderBy('date_time', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_transactionFromDoc).toList());
  }

  @override
  Stream<List<WalletOption>> watchWalletOptions() async* {
    final businessId = await _getBusinessId();
    yield* _walletsRef(businessId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return WalletOption(
          id: doc.id,
          name: data['name'] as String? ?? 'Wallet',
          type: data['type'] as String? ?? 'cash',
          balance: (data['balance'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();
    });
  }

  CollectionReference<Map<String, dynamic>> _categoriesRef(String businessId) {
    return _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('categories');
  }

  @override
  Stream<List<TransactionCategory>> watchCategories() async* {
    final businessId = await _getBusinessId();
    final ref = _categoriesRef(businessId);
    
    yield* ref.snapshots().asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) {
        final defaults = [
          const TransactionCategory(id: 'food', name: 'Makanan', iconKey: 'food', isIncome: false),
          const TransactionCategory(id: 'transport', name: 'Transportasi', iconKey: 'transport', isIncome: false),
          const TransactionCategory(id: 'shopping', name: 'Belanja', iconKey: 'shopping', isIncome: false),
          const TransactionCategory(id: 'entertainment', name: 'Hiburan', iconKey: 'entertainment', isIncome: false),
          const TransactionCategory(id: 'bill', name: 'Tagihan', iconKey: 'bill', isIncome: false),
          const TransactionCategory(id: 'health', name: 'Kesehatan', iconKey: 'health', isIncome: false),
          const TransactionCategory(id: 'education', name: 'Pendidikan', iconKey: 'education', isIncome: false),
          const TransactionCategory(id: 'other', name: 'Lainnya', iconKey: 'other', isIncome: false),
          const TransactionCategory(id: 'salary', name: 'Gaji', iconKey: 'income', isIncome: true),
          const TransactionCategory(id: 'freelance', name: 'Freelance', iconKey: 'freelance', isIncome: true),
          const TransactionCategory(id: 'investment', name: 'Investasi', iconKey: 'investment', isIncome: true),
          const TransactionCategory(id: 'bonus', name: 'Bonus', iconKey: 'bonus', isIncome: true),
          const TransactionCategory(id: 'other_income', name: 'Lainnya', iconKey: 'other', isIncome: true),
        ];

        final batch = _firestore.batch();
        for (final cat in defaults) {
          final doc = ref.doc();
          batch.set(doc, cat.toFirestore());
        }
        await batch.commit();
      }
      
      return snapshot.docs.map((doc) => TransactionCategory.fromFirestore(doc.data(), doc.id)).toList();
    });
  }

  @override
  Future<void> addCategory(TransactionCategory category) async {
    final businessId = await _getBusinessId();
    final ref = _categoriesRef(businessId).doc();
    await ref.set(category.toFirestore());
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    final businessId = await _getBusinessId();
    await _categoriesRef(businessId).doc(categoryId).delete();
  }

  Future<String> _uploadReceiptImage({
    required String businessId,
    required String transactionId,
    required String path,
  }) async {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final file = File(path);
    if (!await file.exists()) {
      throw StateError('File bukti pembayaran tidak ditemukan.');
    }

    final extension = path.split('.').last.toLowerCase();
    final safeExtension =
        ['jpg', 'jpeg', 'png', 'webp'].contains(extension) ? extension : 'jpg';
    final metadata = SettableMetadata(
      contentType: safeExtension == 'png'
          ? 'image/png'
          : safeExtension == 'webp'
              ? 'image/webp'
              : 'image/jpeg',
    );
    final ref = _storage
        .ref()
        .child('businesses/$businessId/receipts/$transactionId.$safeExtension');
    await ref.putFile(file, metadata);
    return ref.getDownloadURL();
  }
}
