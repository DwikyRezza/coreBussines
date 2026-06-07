// ============================================================
// FEATURE: Settings - Security Settings Page
// lib/features/settings/presentation/pages/security_settings_page.dart
// ============================================================

import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/services/app_lock_controller.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/core_app_bar.dart';
import '../../domain/entities/app_lock_settings.dart';
import '../../domain/repositories/app_lock_repository.dart';

class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  AppLockSettings? _settings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await sl<AppLockRepository>().getSettings();
    if (!mounted) return;
    setState(() {
      _settings = settings;
      _isLoading = false;
    });
  }

  Future<void> _reloadLockController() async {
    await sl<AppLockController>().reloadSettings();
    await _load();
  }

  Future<void> _showPinDialog({bool requireCurrentPin = false}) async {
    final pinController = TextEditingController();
    final confirmController = TextEditingController();
    final currentController = TextEditingController();
    String? error;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(requireCurrentPin ? 'Ubah PIN' : 'Aktifkan PIN'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (requireCurrentPin) ...[
                TextField(
                  controller: currentController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    labelText: 'PIN saat ini',
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 8),
              ],
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'PIN baru (4-6 digit)',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'Ulangi PIN baru',
                  counterText: '',
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(error!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                final repo = sl<AppLockRepository>();
                if (requireCurrentPin &&
                    !await repo.verifyPin(currentController.text.trim())) {
                  setDialogState(() => error = 'PIN saat ini salah.');
                  return;
                }
                if (pinController.text.trim() !=
                    confirmController.text.trim()) {
                  setDialogState(() => error = 'Konfirmasi PIN tidak sama.');
                  return;
                }
                try {
                  await repo.setPin(pinController.text.trim());
                  if (context.mounted) Navigator.pop(context, true);
                } catch (e) {
                  setDialogState(() => error =
                      e.toString().replaceFirst('Invalid argument(s): ', ''));
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );

    pinController.dispose();
    confirmController.dispose();
    currentController.dispose();

    if (ok == true) {
      await _reloadLockController();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN berhasil disimpan.')),
      );
    }
  }

  Future<void> _disablePin() async {
    await sl<AppLockRepository>().disablePin();
    await _reloadLockController();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PIN dan biometric berhasil dimatikan.')),
    );
  }

  Future<void> _showBiometricEnrollmentDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.fingerprint_rounded,
                color: Theme.of(context).colorScheme.primary, size: 28),
            const SizedBox(width: 12),
            const Text('Biometrik Belum Aktif'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sensor biometrik terdeteksi pada perangkat Anda, namun Anda belum mendaftarkan sidik jari atau pemindai wajah di HP Anda.',
              style: TextStyle(height: 1.4),
            ),
            const SizedBox(height: 14),
            Text(
              'Silakan ikuti langkah berikut:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            const _BulletPoint(
                text: 'Buka menu Pengaturan Keamanan di HP Anda'),
            const _BulletPoint(
                text:
                    'Daftarkan sidik jari (fingerprint) atau wajah (face unlock) baru Anda'),
            const _BulletPoint(
                text:
                    'Kembali ke aplikasi CoreBusiness untuk mengaktifkan fitur ini'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Future<void> _setBiometric(bool enabled) async {
    try {
      await sl<AppLockRepository>().setBiometricEnabled(enabled);
      await _reloadLockController();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(enabled
              ? 'Biometric berhasil diaktifkan.'
              : 'Biometric berhasil dimatikan.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      if (enabled && _settings != null && !_settings!.biometricEnrolled) {
        _showBiometricEnrollmentDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Biometric tidak tersedia. Pastikan perangkat mendukung dan sudah ada biometric terdaftar.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CoreAppBar(),
      body: _isLoading || settings == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding),
              children: [
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Keamanan',
                  style: AppTypography.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'PIN disimpan sebagai hash di secure storage. Biometric memakai autentikasi sistem perangkat.',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _SecurityTile(
                  icon: Icons.pin_outlined,
                  title: 'PIN Aplikasi',
                  subtitle: settings.pinEnabled ? 'Aktif' : 'Belum aktif',
                  trailing: settings.pinEnabled
                      ? Wrap(
                          spacing: 8,
                          children: [
                            TextButton(
                              onPressed: () =>
                                  _showPinDialog(requireCurrentPin: true),
                              child: const Text('Ubah'),
                            ),
                            TextButton(
                              onPressed: _disablePin,
                              child: const Text('Matikan'),
                            ),
                          ],
                        )
                      : FilledButton(
                          onPressed: _showPinDialog,
                          child: const Text('Aktifkan'),
                        ),
                ),
                const SizedBox(height: 12),
                _SecurityTile(
                  icon: Icons.fingerprint_rounded,
                  title: 'Biometric',
                  subtitle: settings.biometricSupported
                      ? (settings.biometricEnabled
                          ? 'Aktif'
                          : (settings.biometricEnrolled
                              ? 'Tersedia'
                              : 'Tersedia (belum ada sidik jari terdaftar di HP)'))
                      : 'Sensor biometrik tidak tersedia pada perangkat ini',
                  trailing: Switch.adaptive(
                    value: settings.biometricEnabled,
                    onChanged:
                        settings.biometricSupported && settings.pinEnabled
                            ? _setBiometric
                            : null,
                  ),
                ),
                if (!settings.pinEnabled) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Aktifkan PIN terlebih dahulu agar biometric punya fallback yang aman.',
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 100),
              ],
            ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;
  const _BulletPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary)),
          Expanded(
              child: Text(text,
                  style: const TextStyle(fontSize: 13, height: 1.3))),
        ],
      ),
    );
  }
}

class _SecurityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SecurityTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          trailing,
        ],
      ),
    );
  }
}
