// ============================================================
// FEATURE: Home — Data Models
// lib/features/home/data/models/home_models.dart
// ============================================================

import '../../domain/entities/home_entities.dart';

class BalanceSummaryModel extends BalanceSummary {
  const BalanceSummaryModel({
    required super.totalBalance,
    required super.monthlyChange,
    required super.monthlyChangePercent,
    required super.userName,
    super.userPhotoUrl,
  });

  factory BalanceSummaryModel.fromJson(Map<String, dynamic> json) {
    return BalanceSummaryModel(
      totalBalance: (json['total_balance'] as num).toDouble(),
      monthlyChange: (json['monthly_change'] as num).toDouble(),
      monthlyChangePercent: (json['monthly_change_percent'] as num).toDouble(),
      userName: json['user_name'] as String,
      userPhotoUrl: json['user_photo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_balance': totalBalance,
      'monthly_change': monthlyChange,
      'monthly_change_percent': monthlyChangePercent,
      'user_name': userName,
      'user_photo_url': userPhotoUrl,
    };
  }
}

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.title,
    required super.category,
    required super.categoryIcon,
    required super.amount,
    required super.isIncome,
    required super.dateTime,
    super.walletId,
    super.walletName,
    super.receiptImageUrl,
    super.createdByUserId,
    super.createdByName,
    super.createdByEmail,
    super.createdByRole,
    super.createdAt,
    super.updatedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      categoryIcon: json['category_icon'] as String,
      amount: (json['amount'] as num).toDouble(),
      isIncome: json['is_income'] as bool,
      dateTime: DateTime.parse(json['date_time'] as String),
      walletId: json['wallet_id'] as String?,
      walletName: json['wallet_name'] as String?,
      receiptImageUrl: json['receipt_image_url'] as String?,
      createdByUserId: json['created_by_user_id'] as String? ??
          json['createdByUserId'] as String?,
      createdByName: json['created_by_name'] as String? ??
          json['createdByName'] as String?,
      createdByEmail: json['created_by_email'] as String? ??
          json['createdByEmail'] as String?,
      createdByRole: json['created_by_role'] as String? ??
          json['createdByRole'] as String?,
      createdAt: _dateTimeFromJson(json['created_at'] ?? json['createdAt']),
      updatedAt: _dateTimeFromJson(json['updated_at'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'category_icon': categoryIcon,
      'amount': amount,
      'is_income': isIncome,
      'date_time': dateTime.toIso8601String(),
      'wallet_id': walletId,
      'wallet_name': walletName,
      'receipt_image_url': receiptImageUrl,
      'created_by_user_id': createdByUserId,
      'created_by_name': createdByName,
      'created_by_email': createdByEmail,
      'created_by_role': createdByRole,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  static DateTime? _dateTimeFromJson(Object? value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

class InsightCardModel extends InsightCard {
  const InsightCardModel({
    required super.title,
    required super.message,
    required super.type,
  });

  factory InsightCardModel.fromJson(Map<String, dynamic> json) {
    return InsightCardModel(
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'message': message,
      'type': type,
    };
  }
}

class HomeDashboardDataModel extends HomeDashboardData {
  const HomeDashboardDataModel({
    required super.summary,
    required super.recentTransactions,
    required super.allTransactions,
    required super.insight,
  });
}
