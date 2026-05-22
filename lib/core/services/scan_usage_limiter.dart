import 'package:shared_preferences/shared_preferences.dart';

class ScanUsageStatus {
  final bool isPremium;
  final int used;
  final int limit;
  final Duration retryAfter;

  const ScanUsageStatus({
    required this.isPremium,
    required this.used,
    required this.limit,
    required this.retryAfter,
  });

  bool get canScan => isPremium || used < limit;
  int get remaining => isPremium ? -1 : (limit - used).clamp(0, limit).toInt();
}

class ScanUsageLimiter {
  static const _timestampsKey = 'scan_usage_timestamps';
  static const _premiumKey = 'scan_premium_enabled';
  static const limit = 5;
  static const window = Duration(minutes: 1);

  final SharedPreferences _prefs;

  ScanUsageLimiter(this._prefs);

  bool get isPremium => _prefs.getBool(_premiumKey) ?? false;

  Future<void> setPremium(bool value) async {
    await _prefs.setBool(_premiumKey, value);
  }

  ScanUsageStatus status() {
    final timestamps = _activeTimestamps();
    final retryAfter = timestamps.isEmpty
        ? Duration.zero
        : window - DateTime.now().difference(timestamps.first);

    return ScanUsageStatus(
      isPremium: isPremium,
      used: timestamps.length,
      limit: limit,
      retryAfter: retryAfter.isNegative ? Duration.zero : retryAfter,
    );
  }

  Future<ScanUsageStatus> recordScan() async {
    if (isPremium) return status();

    final timestamps = _activeTimestamps()..add(DateTime.now());
    await _prefs.setStringList(
      _timestampsKey,
      timestamps.map((date) => date.toIso8601String()).toList(),
    );
    return status();
  }

  List<DateTime> _activeTimestamps() {
    final now = DateTime.now();
    final values = _prefs.getStringList(_timestampsKey) ?? const [];

    return values
        .map(DateTime.tryParse)
        .whereType<DateTime>()
        .where((date) => now.difference(date) < window)
        .toList()
      ..sort();
  }
}
