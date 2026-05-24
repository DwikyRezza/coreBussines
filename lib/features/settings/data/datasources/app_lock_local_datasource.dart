import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import '../../domain/entities/app_lock_settings.dart';

abstract class AppLockLocalDataSource {
  Future<AppLockSettings> getSettings();
  Future<void> setPin(String pin);
  Future<bool> verifyPin(String pin);
  Future<void> disablePin();
  Future<void> setBiometricEnabled(bool enabled);
  Future<bool> authenticateWithBiometric();
}

class AppLockLocalDataSourceImpl implements AppLockLocalDataSource {
  static const _pinEnabledKey = 'app_lock_pin_enabled';
  static const _pinHashKey = 'app_lock_pin_hash';
  static const _pinSaltKey = 'app_lock_pin_salt';
  static const _biometricEnabledKey = 'app_lock_biometric_enabled';

  final FlutterSecureStorage _secureStorage;
  final LocalAuthentication _localAuthentication;

  AppLockLocalDataSourceImpl({
    required FlutterSecureStorage secureStorage,
    required LocalAuthentication localAuthentication,
  })  : _secureStorage = secureStorage,
        _localAuthentication = localAuthentication;

  @override
  Future<AppLockSettings> getSettings() async {
    final pinEnabled = await _secureStorage.read(key: _pinEnabledKey) == 'true';
    final biometricEnabled =
        await _secureStorage.read(key: _biometricEnabledKey) == 'true';
    final biometricSupported = await _isBiometricSupported();
    final biometricEnrolled = await _isBiometricEnrolled();
    return AppLockSettings(
      pinEnabled: pinEnabled,
      biometricEnabled: biometricEnabled && biometricSupported && biometricEnrolled,
      biometricSupported: biometricSupported,
      biometricEnrolled: biometricEnrolled,
    );
  }

  @override
  Future<void> setPin(String pin) async {
    _validatePin(pin);
    final salt = _randomSalt();
    final hash = _hashPin(pin, salt);
    await _secureStorage.write(key: _pinSaltKey, value: salt);
    await _secureStorage.write(key: _pinHashKey, value: hash);
    await _secureStorage.write(key: _pinEnabledKey, value: 'true');
  }

  @override
  Future<bool> verifyPin(String pin) async {
    final salt = await _secureStorage.read(key: _pinSaltKey);
    final expectedHash = await _secureStorage.read(key: _pinHashKey);
    if (salt == null || expectedHash == null) return false;
    return _hashPin(pin, salt) == expectedHash;
  }

  @override
  Future<void> disablePin() async {
    await _secureStorage.delete(key: _pinEnabledKey);
    await _secureStorage.delete(key: _pinHashKey);
    await _secureStorage.delete(key: _pinSaltKey);
    await _secureStorage.delete(key: _biometricEnabledKey);
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    if (enabled && !await _isBiometricSupported()) {
      throw StateError('Perangkat tidak mendukung biometric.');
    }
    if (enabled && !await _isBiometricEnrolled()) {
      throw StateError('Belum ada biometric terdaftar.');
    }
    await _secureStorage.write(
      key: _biometricEnabledKey,
      value: enabled ? 'true' : 'false',
    );
  }

  @override
  Future<bool> authenticateWithBiometric() async {
    if (!await _isBiometricSupported() || !await _isBiometricEnrolled()) return false;
    return _localAuthentication.authenticate(
      localizedReason: 'Gunakan biometric untuk membuka CoreBusiness.',
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
      ),
    );
  }

  Future<bool> _isBiometricSupported() async {
    final canCheck = await _localAuthentication.canCheckBiometrics;
    final supported = await _localAuthentication.isDeviceSupported();
    return canCheck && supported;
  }

  Future<bool> _isBiometricEnrolled() async {
    if (!await _isBiometricSupported()) return false;
    final biometrics = await _localAuthentication.getAvailableBiometrics();
    return biometrics.isNotEmpty;
  }

  void _validatePin(String pin) {
    if (!RegExp(r'^\d{4,6}$').hasMatch(pin)) {
      throw ArgumentError('PIN wajib 4-6 digit angka.');
    }
  }

  String _hashPin(String pin, String salt) {
    final bytes = utf8.encode('$salt:$pin');
    return sha256.convert(bytes).toString();
  }

  String _randomSalt() {
    final random = Random.secure();
    final values = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(values);
  }
}
