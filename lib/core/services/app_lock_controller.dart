import 'package:flutter/foundation.dart';

import '../../features/settings/domain/entities/app_lock_settings.dart';
import '../../features/settings/domain/repositories/app_lock_repository.dart';

class AppLockController extends ChangeNotifier {
  final AppLockRepository _repository;

  AppLockSettings _settings = const AppLockSettings(
    pinEnabled: false,
    biometricEnabled: false,
    biometricSupported: false,
    biometricEnrolled: false,
  );
  bool _isUnlocked = false;
  bool _isReady = false;

  AppLockController(this._repository);

  AppLockSettings get settings => _settings;
  bool get isReady => _isReady;
  bool get isUnlocked => _isUnlocked;
  bool get requiresUnlock => _settings.requiresUnlock && !_isUnlocked;

  Future<void> load() async {
    _settings = await _repository.getSettings();
    _isUnlocked = !_settings.requiresUnlock;
    _isReady = true;
    notifyListeners();
  }

  Future<void> reloadSettings() async {
    _settings = await _repository.getSettings();
    if (!_settings.requiresUnlock) _isUnlocked = true;
    notifyListeners();
  }

  void markLocked() {
    if (_settings.requiresUnlock) {
      _isUnlocked = false;
      notifyListeners();
    }
  }

  void markUnlocked() {
    _isUnlocked = true;
    notifyListeners();
  }
}
