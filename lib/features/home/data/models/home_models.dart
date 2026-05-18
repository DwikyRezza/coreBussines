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
    };
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
