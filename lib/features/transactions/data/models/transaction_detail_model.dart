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
    super.walletId,
    super.walletName,
    super.createdByUserId,
    super.createdByName,
    super.createdByEmail,
    super.createdByRole,
    super.createdAt,
    super.updatedAt,
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
      walletId: json['wallet_id'] as String?,
      walletName: json['wallet_name'] as String?,
      createdByUserId: json['created_by_user_id'] as String? ??
          json['createdByUserId'] as String?,
      createdByName: json['created_by_name'] as String? ??
          json['createdByName'] as String?,
      createdByEmail: json['created_by_email'] as String? ??
          json['createdByEmail'] as String?,
      createdByRole: json['created_by_role'] as String? ??
          json['createdByRole'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
    );
  }
}
