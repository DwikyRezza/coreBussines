import 'package:equatable/equatable.dart';

class AppLockSettings extends Equatable {
  final bool pinEnabled;
  final bool biometricEnabled;
  final bool biometricSupported;
  final bool biometricEnrolled;

  const AppLockSettings({
    required this.pinEnabled,
    required this.biometricEnabled,
    required this.biometricSupported,
    required this.biometricEnrolled,
  });

  bool get requiresUnlock => pinEnabled || biometricEnabled;

  @override
  List<Object?> get props => [
        pinEnabled,
        biometricEnabled,
        biometricSupported,
        biometricEnrolled,
      ];
}
