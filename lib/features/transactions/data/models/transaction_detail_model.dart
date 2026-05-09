// ============================================================
// FEATURE: Transactions — Detail Model
// lib/features/transactions/data/models/transaction_detail_model.dart
// ============================================================

import '../../domain/entities/transaction_entities.dart';

class TransactionDetailModel extends TransactionDetail {
  const TransactionDetailModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.isIncome,
    required super.category,
    required super.categoryIcon,
    required super.dateTime,
    required super.paymentMethod,
    super.isMainPayment,
    super.note,
    super.receiptImageUrl,
  });

  factory TransactionDetailModel.fromJson(Map<String, dynamic> json) {
    return TransactionDetailModel(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      isIncome: json['is_income'] as bool,
      category: json['category'] as String,
      categoryIcon: json['category_icon'] as String,
      dateTime: DateTime.parse(json['date_time'] as String),
      paymentMethod: json['payment_method'] as String,
      isMainPayment: json['is_main_payment'] as bool? ?? false,
      note: json['note'] as String?,
      receiptImageUrl: json['receipt_image_url'] as String?,
    );
  }
}
