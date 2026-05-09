// ============================================================
// CORE: Utils — Currency & Date Formatters
// lib/core/utils/formatters.dart
// ============================================================

import 'package:intl/intl.dart';

abstract class AppFormatter {
  /// Format to Rp currency: "Rp 1.200.000"
  static String currency(double amount, {bool showSign = false}) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final formatted = formatter.format(amount.abs());
    if (!showSign) return formatted;
    return amount >= 0 ? '+$formatted' : '-$formatted';
  }

  /// Format to compact: "+Rp 1.2jt" / "-Rp 450rb"
  static String compactCurrency(double amount) {
    final abs = amount.abs();
    final sign = amount >= 0 ? '+' : '-';
    if (abs >= 1000000) {
      return '${sign}Rp ${(abs / 1000000).toStringAsFixed(1).replaceAll('.', ',')}jt';
    } else if (abs >= 1000) {
      return '${sign}Rp ${(abs / 1000).toStringAsFixed(0)}rb';
    }
    return '${sign}Rp ${abs.toStringAsFixed(0)}';
  }

  /// Date: "Senin, 24 Mei 2024"
  static String fullDate(DateTime date) {
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
  }

  /// Date: "Sen, 25 Mar"
  static String shortDate(DateTime date) {
    return DateFormat('EEE, d MMM', 'id_ID').format(date);
  }

  /// Day abbreviation: "S", "R", "K", etc.
  static String dayAbbreviation(DateTime date) {
    const days = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
    return days[date.weekday % 7];
  }

  /// Time: "09:42 WIB"
  static String timeWib(DateTime date) {
    return '${DateFormat('HH:mm').format(date)} WIB';
  }

  /// Relative: "Hari ini", "Kemarin", or full date
  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'Hari ini';
    if (diff == 1) return 'Kemarin';
    return shortDate(date);
  }

  /// Percentage with 1 decimal: "14.2%"
  static String percentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }
}
