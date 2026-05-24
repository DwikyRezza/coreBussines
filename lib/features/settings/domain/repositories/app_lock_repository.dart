import '../entities/app_lock_settings.dart';

abstract class AppLockRepository {
  Future<AppLockSettings> getSettings();
  Future<void> setPin(String pin);
  Future<bool> verifyPin(String pin);
  Future<void> disablePin();
  Future<void> setBiometricEnabled(bool enabled);
  Future<bool> authenticateWithBiometric();
}
