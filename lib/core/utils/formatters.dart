// ============================================================
// CORE: Utils — Currency & Date Formatters
// lib/core/utils/formatters.dart
// ============================================================

import 'package:intl/intl.dart';
import '../di/service_locator.dart';
import '../storage/local_storage_service.dart';

abstract class AppFormatter {
  static String get _currencySymbol {
    try {
      final currency = sl<LocalStorageService>().activeCurrency;
      return currency == 'USD' ? '\$ ' : 'Rp ';
    } catch (_) {
      return 'Rp ';
    }
  }

  /// Format to currency based on settings: "Rp 1.200.000" or "$ 120,000"
  static String currency(double amount, {bool showSign = false}) {
    final symbol = _currencySymbol;
    final locale = symbol.contains('\$') ? 'en_US' : 'id_ID';

    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
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
    final symbol = _currencySymbol;
    final isUsd = symbol.contains('\$');

    if (abs >= 1000000) {
      final val = abs / 1000000;
      final formattedVal = isUsd
          ? val.toStringAsFixed(1)
          : val.toStringAsFixed(1).replaceAll('.', ',');
      final suffix = isUsd ? 'M' : 'jt';
      return '$sign$symbol$formattedVal$suffix';
    } else if (abs >= 1000) {
      final val = abs / 1000;
      final formattedVal = val.toStringAsFixed(0);
      final suffix = isUsd ? 'k' : 'rb';
      return '$sign$symbol$formattedVal$suffix';
    }
    return '$sign$symbol${abs.toStringAsFixed(0)}';
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
