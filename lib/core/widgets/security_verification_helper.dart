// ============================================================
// FEATURE: Core Security - Security Verification Helper
// lib/core/widgets/security_verification_helper.dart
// ============================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../di/service_locator.dart';
import '../services/app_lock_controller.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../../features/settings/domain/repositories/app_lock_repository.dart';

class SecurityVerificationHelper {
  /// Meminta verifikasi PIN atau Biometrik dari user untuk aksi sensitif.
  /// Mengembalikan [true] jika berhasil terverifikasi, dan [false] jika dibatalkan/gagal.
  static Future<bool> verifyAction(BuildContext context, String reason) async {
    final repo = sl<AppLockRepository>();
    final settings = await repo.getSettings();

    if (!context.mounted) return false;

    // Jika PIN belum diaktifkan, minta user untuk mendaftarkannya terlebih dahulu secara premium
    if (!settings.pinEnabled) {
      final success = await _showRegisterPinDialog(context, reason);
      if (!success) return false;
    }

    if (!context.mounted) return false;

    // Tampilkan dialog verifikasi PIN / Biometrik
    final verified = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'VerificationDialog',
      barrierColor: Colors.black.withOpacity(0.65),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return _SecurityVerificationDialog(reason: reason);
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim1, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: anim1,
              curve: const Interval(0.0, 1.0, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
    );

    return verified ?? false;
  }

  /// Menampilkan dialog registrasi PIN baru secara premium on-the-fly
  static Future<bool> _showRegisterPinDialog(
      BuildContext context, String reason) async {
    final pinController = TextEditingController();
    final confirmController = TextEditingController();
    int step = 1; // 1: Input PIN, 2: Konfirmasi PIN
    String tempPin = '';
    String? error;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final colors = Theme.of(context).colorScheme;

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            ),
            title: Row(
              children: [
                Icon(Icons.security_rounded, color: colors.primary, size: 28),
                const SizedBox(width: 12),
                const Text('Keamanan Diperlukan'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Untuk melakukan aksi sensitif ($reason), Anda wajib memiliki PIN Aplikasi.',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (step == 1) ...[
                    Text(
                      'Masukkan PIN Baru (4-6 digit):',
                      style: AppTypography.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: pinController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 6,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        hintText: 'PIN Baru',
                        counterText: '',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Ulangi PIN Baru untuk Konfirmasi:',
                      style: AppTypography.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: confirmController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 6,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        hintText: 'Konfirmasi PIN',
                        counterText: '',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                      ),
                    ),
                  ],
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      error!,
                      style: TextStyle(color: colors.error, fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () async {
                  error = null;
                  if (step == 1) {
                    final val = pinController.text.trim();
                    if (val.length < 4 || val.length > 6) {
                      setDialogState(() {
                        error = 'PIN harus terdiri dari 4 sampai 6 digit angka.';
                      });
                      return;
                    }
                    setDialogState(() {
                      tempPin = val;
                      step = 2;
                    });
                  } else {
                    final val = confirmController.text.trim();
                    if (val != tempPin) {
                      setDialogState(() {
                        error = 'PIN konfirmasi tidak cocok. Coba lagi.';
                      });
                      return;
                    }

                    // Simpan PIN ke secure storage
                    try {
                      await sl<AppLockRepository>().setPin(tempPin);
                      await sl<AppLockController>().reloadSettings();
                      if (context.mounted) Navigator.pop(context, true);
                    } catch (e) {
                      setDialogState(() {
                        error = 'Gagal menyimpan PIN: ${e.toString()}';
                      });
                    }
                  }
                },
                child: Text(step == 1 ? 'Lanjut' : 'Simpan PIN'),
              ),
            ],
          );
        },
      ),
    );

    pinController.dispose();
    confirmController.dispose();
    return result ?? false;
  }
}

class _SecurityVerificationDialog extends StatefulWidget {
  final String reason;
  const _SecurityVerificationDialog({required this.reason});

  @override
  State<_SecurityVerificationDialog> createState() =>
      _SecurityVerificationDialogState();
}

class _SecurityVerificationDialogState
    extends State<_SecurityVerificationDialog> {
  String _enteredPin = '';
  bool _isLoading = false;
  String? _error;
  bool _biometricPrompted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndTriggerBiometrics();
    });
  }

  Future<void> _checkAndTriggerBiometrics() async {
    final settings = sl<AppLockController>().settings;
    if (settings.biometricEnabled && !_biometricPrompted) {
      _biometricPrompted = true;
      _triggerBiometrics();
    }
  }

  Future<void> _triggerBiometrics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final success =
          await sl<AppLockRepository>().authenticateWithBiometric();
      if (!mounted) return;
      if (success) {
        Navigator.pop(context, true);
      } else {
        setState(() {
          _error = 'Otentikasi biometrik dibatalkan/gagal.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Gagal menggunakan biometrik: ${e.toString()}';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onKeyPress(String digit) {
    if (_isLoading) return;
    HapticFeedback.lightImpact();
    setState(() {
      _error = null;
      if (_enteredPin.length < 6) {
        _enteredPin += digit;
      }
    });

    // Auto submit jika mencapai 6 digit
    if (_enteredPin.length == 6) {
      _verifyPin();
    }
  }

  void _onBackspace() {
    if (_isLoading || _enteredPin.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _error = null;
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
    });
  }

  Future<void> _verifyPin() async {
    if (_enteredPin.length < 4) {
      setState(() {
        _error = 'PIN minimal 4 digit.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final isCorrect = await sl<AppLockRepository>().verifyPin(_enteredPin);
      if (!mounted) return;

      if (isCorrect) {
        HapticFeedback.mediumImpact();
        Navigator.pop(context, true);
      } else {
        HapticFeedback.vibrate();
        setState(() {
          _enteredPin = '';
          _error = 'PIN salah. Silakan coba lagi.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Terjadi kesalahan saat memverifikasi PIN.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildKey(String value) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onKeyPress(value),
        customBorder: const CircleBorder(),
        child: Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: colors.outlineVariant.withOpacity(0.5)),
            color: colors.surface.withOpacity(0.3),
          ),
          child: Text(
            value,
            style: AppTypography.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final settings = sl<AppLockController>().settings;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(AppSpacing.pagePadding),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePadding,
            vertical: 24,
          ),
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: colors.surface.withOpacity(0.85),
            borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
            border: Border.all(color: colors.primary.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 25,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon & Header
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shield_outlined,
                      size: 40,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Verifikasi Keamanan',
                    style: AppTypography.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.reason,
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Indicator Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      final active = index < _enteredPin.length;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: active
                              ? colors.primary
                              : colors.outlineVariant.withOpacity(0.7),
                          border: active
                              ? Border.all(color: colors.primaryContainer)
                              : null,
                          boxShadow: active
                              ? [
                                  BoxShadow(
                                    color: colors.primary.withOpacity(0.4),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Loading or Error message
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: CircularProgressIndicator(),
                    )
                  else if (_error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.error,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 20),

                  const SizedBox(height: 12),

                  // Custom Numeric Keyboard Grid
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildKey('1'),
                          _buildKey('2'),
                          _buildKey('3'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildKey('4'),
                          _buildKey('5'),
                          _buildKey('6'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildKey('7'),
                          _buildKey('8'),
                          _buildKey('9'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Button 10: Backspace
                          IconButton(
                            onPressed: _onBackspace,
                            iconSize: 28,
                            icon: Icon(
                              Icons.backspace_outlined,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          _buildKey('0'),
                          // Button 12: Biometrics or Checkmark
                          if (settings.biometricEnabled)
                            IconButton(
                              onPressed: _triggerBiometrics,
                              iconSize: 32,
                              icon: Icon(
                                Icons.fingerprint_rounded,
                                color: colors.primary,
                              ),
                            )
                          else
                            IconButton(
                              onPressed: _enteredPin.length >= 4
                                  ? _verifyPin
                                  : null,
                              iconSize: 32,
                              icon: Icon(
                                Icons.check_circle_rounded,
                                color: _enteredPin.length >= 4
                                    ? colors.primary
                                    : colors.outlineVariant.withOpacity(0.5),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  // Cancel Button
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      'Batal',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
