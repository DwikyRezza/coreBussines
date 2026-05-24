// ============================================================
// CORE: Router - GoRouter Auth/Lock Notifier
// lib/core/router/router_notifier.dart
// ============================================================

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../features/auth/domain/repositories/auth_repository.dart';
import '../services/app_lock_controller.dart';

class RouterAuthNotifier extends ChangeNotifier {
  final AuthRepository _authRepository;
  final AppLockController _appLockController;
  late final StreamSubscription<dynamic> _subscription;

  RouterAuthNotifier(this._authRepository, this._appLockController) {
    _subscription = _authRepository.authStateChanges.listen((_) {
      notifyListeners();
    });
    _appLockController.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _subscription.cancel();
    _appLockController.removeListener(notifyListeners);
    super.dispose();
  }
}
