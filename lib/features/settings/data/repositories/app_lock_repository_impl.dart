import '../../domain/entities/app_lock_settings.dart';
import '../../domain/repositories/app_lock_repository.dart';
import '../datasources/app_lock_local_datasource.dart';

class AppLockRepositoryImpl implements AppLockRepository {
  final AppLockLocalDataSource _localDataSource;

  const AppLockRepositoryImpl(this._localDataSource);

  @override
  Future<AppLockSettings> getSettings() => _localDataSource.getSettings();

  @override
  Future<void> setPin(String pin) => _localDataSource.setPin(pin);

  @override
  Future<bool> verifyPin(String pin) => _localDataSource.verifyPin(pin);

  @override
  Future<void> disablePin() => _localDataSource.disablePin();

  @override
  Future<void> setBiometricEnabled(bool enabled) {
    return _localDataSource.setBiometricEnabled(enabled);
  }

  @override
  Future<bool> authenticateWithBiometric() {
    return _localDataSource.authenticateWithBiometric();
  }
}
