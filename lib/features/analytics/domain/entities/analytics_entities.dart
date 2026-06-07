// ============================================================
// FEATURE: Analytics — Domain Entities
// lib/features/analytics/domain/entities/analytics_entities.dart
// ============================================================

import 'package:equatable/equatable.dart';

class CashFlowPoint extends Equatable {
  final DateTime date;
  final double income;
  final double expense;

  const CashFlowPoint({
    required this.date,
    required this.income,
    required this.expense,
  });

  @override
  List<Object?> get props => [date, income, expense];
}

class DailyFlow extends Equatable {
  final DateTime date;
  final String dayLabel;
  final int transactionCount;
  final double netAmount;
  final bool isSurplus;

  const DailyFlow({
    required this.date,
    required this.dayLabel,
    required this.transactionCount,
    required this.netAmount,
    required this.isSurplus,
  });

  @override
  List<Object?> get props =>
      [date, dayLabel, transactionCount, netAmount, isSurplus];
}

class CashFlowSummary extends Equatable {
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;
  final double changeAmount;
  final double changePercent;
  final List<CashFlowPoint> trendPoints;
  final List<DailyFlow> dailyFlows;

  const CashFlowSummary({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.changeAmount,
    required this.changePercent,
    required this.trendPoints,
    required this.dailyFlows,
  });

  @override
  List<Object?> get props => [
        totalBalance,
        totalIncome,
        totalExpense,
        changeAmount,
        changePercent,
        trendPoints,
        dailyFlows
      ];
}
