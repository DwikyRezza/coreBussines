// ============================================================
// FEATURE: Home — Domain Entities
// lib/features/home/domain/entities/home_entities.dart
// ============================================================

import 'package:equatable/equatable.dart';

/// Summary card at top of home screen
class BalanceSummary extends Equatable {
  final double totalBalance;
  final double monthlyChange;
  final double monthlyChangePercent;
  final String userName;
  final String? userPhotoUrl;

  const BalanceSummary({
    required this.totalBalance,
    required this.monthlyChange,
    required this.monthlyChangePercent,
    required this.userName,
    this.userPhotoUrl,
  });

  @override
  List<Object?> get props => [
        totalBalance,
        monthlyChange,
        monthlyChangePercent,
        userName,
        userPhotoUrl,
      ];
}

/// A single transaction item
class Transaction extends Equatable {
  final String id;
  final String title;
  final String category;
  final String categoryIcon; // icon name
  final double amount;
  final bool isIncome;
  final DateTime dateTime;

  const Transaction({
    required this.id,
    required this.title,
    required this.category,
    required this.categoryIcon,
    required this.amount,
    required this.isIncome,
    required this.dateTime,
  });

  @override
  List<Object?> get props => [id, title, category, amount, isIncome, dateTime];
}

/// AI Insight card data
class InsightCard extends Equatable {
  final String title;
  final String message;
  final String type; // 'warning' | 'info' | 'success'

  const InsightCard({
    required this.title,
    required this.message,
    required this.type,
  });

  @override
  List<Object?> get props => [title, message, type];
}

/// Quick action button definition
class QuickAction extends Equatable {
  final String id;
  final String label;
  final String iconName;

  const QuickAction({
    required this.id,
    required this.label,
    required this.iconName,
  });

  @override
  List<Object?> get props => [id, label, iconName];
}
