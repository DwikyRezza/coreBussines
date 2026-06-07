// ============================================================
// FEATURE: Transactions — Domain Entities
// lib/features/transactions/domain/entities/transaction_entities.dart
// ============================================================

import 'package:equatable/equatable.dart';

class TransactionDetail extends Equatable {
  final String id;
  final String title;
  final double amount;
  final bool isIncome;
  final String category;
  final String categoryIcon;
  final DateTime dateTime;
  final String paymentMethod;
  final bool isMainPayment;
  final String? note;
  final String? receiptImageUrl;
  final String? walletId;
  final String? walletName;
  final String? createdByUserId;
  final String? createdByName;
  final String? createdByEmail;
  final String? createdByRole;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TransactionDetail({
    required this.id,
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.category,
    required this.categoryIcon,
    required this.dateTime,
    required this.paymentMethod,
    this.isMainPayment = false,
    this.note,
    this.receiptImageUrl,
    this.walletId,
    this.walletName,
    this.createdByUserId,
    this.createdByName,
    this.createdByEmail,
    this.createdByRole,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        amount,
        isIncome,
        category,
        dateTime,
        paymentMethod,
        note,
        receiptImageUrl,
        walletId,
        walletName,
        createdByUserId,
        createdByName,
        createdByEmail,
        createdByRole,
        createdAt,
        updatedAt,
      ];
}

class WalletOption extends Equatable {
  final String id;
  final String name;
  final String type;
  final double balance;

  const WalletOption({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
  });

  @override
  List<Object?> get props => [id, name, type, balance];
}

class TransactionInput extends Equatable {
  final String id;
  final String title;
  final double amount;
  final bool isIncome;
  final String category;
  final String categoryIcon;
  final String walletId;
  final String walletName;
  final DateTime dateTime;
  final String? note;
  final String? receiptImagePath;
  final String source;

  const TransactionInput({
    this.id = '',
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.category,
    required this.categoryIcon,
    required this.walletId,
    required this.walletName,
    required this.dateTime,
    this.note,
    this.receiptImagePath,
    this.source = 'manual',
  });

  bool get requiresReceipt => false;

  @override
  List<Object?> get props => [
        id,
        title,
        amount,
        isIncome,
        category,
        categoryIcon,
        walletId,
        walletName,
        dateTime,
        note,
        receiptImagePath,
        source,
      ];
}

class TransactionFilter extends Equatable {
  final TransactionType? type; // income | expense | null (all)
  final DateRangeFilter dateRange;
  final List<String> categories;
  final List<String> wallets;

  const TransactionFilter({
    this.type,
    this.dateRange = DateRangeFilter.thisMonth,
    this.categories = const [],
    this.wallets = const [],
  });

  bool get hasActiveFilters =>
      type != null ||
      dateRange != DateRangeFilter.thisMonth ||
      categories.isNotEmpty ||
      wallets.isNotEmpty;

  TransactionFilter copyWith({
    TransactionType? type,
    DateRangeFilter? dateRange,
    List<String>? categories,
    List<String>? wallets,
    bool clearType = false,
  }) {
    return TransactionFilter(
      type: clearType ? null : (type ?? this.type),
      dateRange: dateRange ?? this.dateRange,
      categories: categories ?? this.categories,
      wallets: wallets ?? this.wallets,
    );
  }

  @override
  List<Object?> get props => [type, dateRange, categories, wallets];
}

enum TransactionType { income, expense }

enum DateRangeFilter { thisWeek, thisMonth, thisYear, custom }

class TransactionCategory extends Equatable {
  final String id;
  final String name;
  final String iconKey;
  final bool isIncome;

  const TransactionCategory({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.isIncome,
  });

  @override
  List<Object?> get props => [id, name, iconKey, isIncome];

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'iconKey': iconKey,
      'icon_key': iconKey,
      'isIncome': isIncome,
      'is_income': isIncome,
    };
  }

  factory TransactionCategory.fromFirestore(
      Map<String, dynamic> data, String docId) {
    return TransactionCategory(
      id: docId,
      name: data['name'] as String? ?? '',
      iconKey: (data['iconKey'] ?? data['icon_key']) as String? ?? 'other',
      isIncome: (data['isIncome'] ?? data['is_income']) as bool? ?? false,
    );
  }
}
