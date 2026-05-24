import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:rxdart/rxdart.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/services/business_context_service.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Stream<List<NotificationModel>> watchNotifications();
  Stream<int> watchUnreadCount();
  Future<void> saveNotification(NotificationModel notification);
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String id);
  Future<void> deleteNotifications(List<String> ids);
  Future<void> deleteAllNotifications();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final FirebaseFirestore _firestore;
  final BusinessContextService _businessContext;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final LocalStorageService _localStorage = sl<LocalStorageService>();

  NotificationRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required BusinessContextService businessContext,
  })  : _firestore = firestore,
        _businessContext = businessContext;

  CollectionReference<Map<String, dynamic>> _ref(String businessId) {
    return _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('notifications');
  }

  @override
  Stream<List<NotificationModel>> watchNotifications() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
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

      return _ref(businessId)
          .where('targetUserId', isEqualTo: user.uid)
          .snapshots()
          .map((snapshot) {
            final list = snapshot.docs.map(NotificationModel.fromFirestore).toList();
            list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return list;
          });
    });
  }

  @override
  Stream<int> watchUnreadCount() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(0);
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

      return _ref(businessId)
          .where('targetUserId', isEqualTo: user.uid)
          .where('isRead', isEqualTo: false)
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
    });
  }

  @override
  Future<void> saveNotification(NotificationModel notification) async {
    final context = await _businessContext.getCurrentContext();
    final docRef = notification.id.isEmpty
        ? _ref(context.businessId).doc()
        : _ref(context.businessId).doc(notification.id);
    await docRef.set({
      'businessId': notification.businessId.isEmpty
          ? context.businessId
          : notification.businessId,
      'business_id': notification.businessId.isEmpty
          ? context.businessId
          : notification.businessId,
      'targetUserId': notification.targetUserId.isEmpty
          ? context.userId
          : notification.targetUserId,
      'target_user_id': notification.targetUserId.isEmpty
          ? context.userId
          : notification.targetUserId,
      'title': notification.title,
      'body': notification.body,
      'type': notification.type,
      'isRead': notification.isRead,
      'is_read': notification.isRead,
      'createdAt': Timestamp.fromDate(notification.createdAt),
      'created_at': Timestamp.fromDate(notification.createdAt),
      'readAt': notification.readAt == null
          ? null
          : Timestamp.fromDate(notification.readAt!),
      'read_at': notification.readAt == null
          ? null
          : Timestamp.fromDate(notification.readAt!),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> markAsRead(String id) async {
    final context = await _businessContext.getCurrentContext();
    await _ref(context.businessId).doc(id).set({
      'isRead': true,
      'is_read': true,
      'readAt': FieldValue.serverTimestamp(),
      'read_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> markAllAsRead() async {
    final context = await _businessContext.getCurrentContext();
    final snapshot = await _ref(context.businessId)
        .where('targetUserId', isEqualTo: context.userId)
        .where('isRead', isEqualTo: false)
        .get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.set(
          doc.reference,
          {
            'isRead': true,
            'is_read': true,
            'readAt': FieldValue.serverTimestamp(),
            'read_at': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));
    }
    await batch.commit();
  }

  @override
  Future<void> deleteNotification(String id) => deleteNotifications([id]);

  @override
  Future<void> deleteNotifications(List<String> ids) async {
    if (ids.isEmpty) return;
    final context = await _businessContext.getCurrentContext();
    final batch = _firestore.batch();
    for (final id in ids) {
      batch.delete(_ref(context.businessId).doc(id));
    }
    await batch.commit();
  }

  @override
  Future<void> deleteAllNotifications() async {
    final context = await _businessContext.getCurrentContext();
    final snapshot = await _ref(context.businessId)
        .where('targetUserId', isEqualTo: context.userId)
        .get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
