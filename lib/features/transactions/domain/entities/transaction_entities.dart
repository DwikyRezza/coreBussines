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
  });

  @override
  List<Object?> get props => [
        id, title, amount, isIncome, category,
        dateTime, paymentMethod, note, receiptImageUrl,
      ];
}

class TransactionFilter extends Equatable {
  final TransactionType? type;        // income | expense | null (all)
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
