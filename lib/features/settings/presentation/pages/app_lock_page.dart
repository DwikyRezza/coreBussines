import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/app_lock_controller.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/repositories/app_lock_repository.dart';

class AppLockPage extends StatefulWidget {
  const AppLockPage({super.key});

  @override
  State<AppLockPage> createState() => _AppLockPageState();
}

class _AppLockPageState extends State<AppLockPage> {
  final _pinController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final settings = sl<AppLockController>().settings;
    if (settings.biometricEnabled) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _unlockWithBiometric());
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _unlockWithBiometric() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final ok = await sl<AppLockRepository>().authenticateWithBiometric();
      if (ok) {
        sl<AppLockController>().markUnlocked();
        if (mounted) context.go(AppRoutes.home);
      } else if (mounted) {
        setState(() => _error = 'Biometric gagal. Gunakan PIN jika aktif.');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Biometric tidak bisa digunakan saat ini.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _unlockWithPin() async {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) {
      setState(() => _error = 'Masukkan PIN terlebih dahulu.');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final ok = await sl<AppLockRepository>().verifyPin(pin);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (!ok) {
      setState(() => _error = 'PIN salah. Coba lagi.');
      return;
    }
    sl<AppLockController>().markUnlocked();
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final settings = sl<AppLockController>().settings;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline_rounded, size: 72, color: colors.primary),
              const SizedBox(height: 24),
              Text(
                'CoreBusiness Terkunci',
                style: AppTypography.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Autentikasi diperlukan sebelum masuk dashboard.',
                textAlign: TextAlign.center,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              if (settings.pinEnabled) ...[
                TextField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    labelText: 'PIN',
                    counterText: '',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _unlockWithPin(),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _unlockWithPin,
                    child: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Buka dengan PIN'),
                  ),
                ),
              ],
              if (settings.biometricEnabled) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _unlockWithBiometric,
                    icon: const Icon(Icons.fingerprint_rounded),
                    label: const Text('Gunakan Biometric'),
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.error),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
