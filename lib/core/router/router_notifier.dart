// ============================================================
// CORE: Router — GoRouter Auth Notifier
// lib/core/router/router_notifier.dart
//
// Bridges AuthRepository stream to GoRouter's refreshListenable.
// When auth state changes, GoRouter re-evaluates the redirect callback.
// ============================================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

class RouterAuthNotifier extends ChangeNotifier {
  final AuthRepository _authRepository;
  late final StreamSubscription<dynamic> _subscription;

  RouterAuthNotifier(this._authRepository) {
    // Subscribe to auth stream — any change triggers GoRouter re-evaluation
    _subscription = _authRepository.authStateChanges.listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
