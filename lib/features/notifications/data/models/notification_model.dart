// ============================================================
// FEATURE: Notifications — Notification Model
// lib/features/notifications/data/models/notification_model.dart
// ============================================================

import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel extends Equatable {
  final String id;
  final String businessId;
  final String targetUserId;
  final String title;
  final String body;
  final String type; // 'info', 'success', 'warning', 'alert'
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  NotificationModel._({
    required this.id,
    required this.businessId,
    required this.targetUserId,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.type,
    required this.isRead,
    this.readAt,
  });

  factory NotificationModel({
    required String id,
    String businessId = '',
    String targetUserId = '',
    required String title,
    required String body,
    DateTime? timestamp,
    DateTime? createdAt,
    String type = 'info',
    bool isRead = false,
    DateTime? readAt,
  }) {
    return NotificationModel._(
      id: id,
      businessId: businessId,
      targetUserId: targetUserId,
      title: title,
      body: body,
      createdAt: createdAt ?? timestamp ?? DateTime.now(),
      type: type,
      isRead: isRead,
      readAt: readAt,
    );
  }

  DateTime get timestamp => createdAt;

  NotificationModel copyWith({
    String? id,
    String? businessId,
    String? targetUserId,
    String? title,
    String? body,
    DateTime? timestamp,
    DateTime? createdAt,
    String? type,
    bool? isRead,
    DateTime? readAt,
    bool clearReadAt = false,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      targetUserId: targetUserId ?? this.targetUserId,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? timestamp ?? this.createdAt,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      readAt: clearReadAt ? null : (readAt ?? this.readAt),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'business_id': businessId,
      'targetUserId': targetUserId,
      'target_user_id': targetUserId,
      'title': title,
      'body': body,
      'timestamp': createdAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'type': type,
      'isRead': isRead,
      'is_read': isRead,
      'readAt': readAt?.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      businessId:
          json['businessId'] as String? ?? json['business_id'] as String? ?? '',
      targetUserId: json['targetUserId'] as String? ??
          json['target_user_id'] as String? ??
          json['userId'] as String? ??
          '',
      title: json['title'] as String,
      body: json['body'] as String,
      createdAt: _readDateTime(
        json['createdAt'] ?? json['created_at'] ?? json['timestamp'],
      ),
      type: json['type'] as String? ?? 'info',
      isRead: json['isRead'] as bool? ?? json['is_read'] as bool? ?? false,
      readAt: _readNullableDateTime(json['readAt'] ?? json['read_at']),
    );
  }

  factory NotificationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return NotificationModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  static DateTime _readDateTime(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  static DateTime? _readNullableDateTime(Object? value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        businessId,
        targetUserId,
        title,
        body,
        createdAt,
        type,
        isRead,
        readAt,
      ];
}
