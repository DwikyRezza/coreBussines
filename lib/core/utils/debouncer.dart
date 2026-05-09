// ============================================================
// CORE: Utils — Debouncer (Protects rapid interactions)
// lib/core/utils/debouncer.dart
// ============================================================

import 'dart:async';

/// Debounce rapid user interactions (search, filter, etc.)
/// Usage:
///   final _debouncer = Debouncer(milliseconds: 300);
///   _debouncer.run(() => _doSearch());
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({this.milliseconds = 300});

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void cancel() {
    _timer?.cancel();
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

/// Throttle ensures action is only called once per interval,
/// even if triggered multiple times. Use for scroll events.
class Throttler {
  final int milliseconds;
  bool _isReady = true;
  Timer? _timer;

  Throttler({this.milliseconds = 500});

  void run(void Function() action) {
    if (!_isReady) return;
    _isReady = false;
    action();
    _timer = Timer(Duration(milliseconds: milliseconds), () {
      _isReady = true;
    });
  }

  void dispose() {
    _timer?.cancel();
  }
}
