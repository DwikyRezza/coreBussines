// ============================================================
// FEATURE: Settings — Security Settings Page
// lib/features/settings/presentation/pages/security_settings_page.dart
// ============================================================

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/core_app_bar.dart';

class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  bool _fingerprint = true;
  bool _faceUnlock = false;
  bool _requireAuth = true;

  void _showPinDialog() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah PIN'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'PIN baru',
            counterText: '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PIN berhasil diperbarui')),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showDeactivateDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nonaktifkan Akun?'),
        content: const Text(
          'Fitur ini belum dijalankan otomatis untuk menjaga data Anda tetap aman. Hubungi dukungan untuk penonaktifan permanen.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CoreAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
            Text(
              'Security Settings',
              style: AppTypography.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your authentication methods to keep your account secure.',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // PIN Option
            _SecurityOptionCard(
              icon: Icons.lock_outline_rounded,
              iconColor: Theme.of(context).colorScheme.primary,
              iconBgColor: const Color(0xFFE3F2FD),
              title: '4-Digit PIN',
              subtitle: 'Required for transactions',
              actionWidget: TextButton(
                onPressed: _showPinDialog,
                child: Text(
                  'Ubah',
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Fingerprint Toggle
            _SecurityOptionCard(
              icon: Icons.fingerprint_rounded,
              iconColor: Theme.of(context).colorScheme.primary,
              iconBgColor: const Color(0xFFE3F2FD),
              title: 'Fingerprint Unlock',
              subtitle: 'Fast and secure access using biometrics',
              actionWidget: Switch(
                value: _fingerprint,
                onChanged: (val) => setState(() => _fingerprint = val),
                activeColor: Colors.white,
                activeTrackColor: Theme.of(context).colorScheme.primary,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            const SizedBox(height: 16),

            // Face Unlock Toggle
            _SecurityOptionCard(
              icon: Icons.face_rounded,
              iconColor: Theme.of(context).colorScheme.onSurfaceVariant,
              iconBgColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              title: 'Face Unlock',
              subtitle: 'Unlock by looking at your device',
              actionWidget: Switch(
                value: _faceUnlock,
                onChanged: (val) => setState(() => _faceUnlock = val),
                activeColor: Colors.white,
                activeTrackColor: Theme.of(context).colorScheme.primary,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Advanced Section
            Text(
              'ADVANCED',
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.shadow.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Require authentication for purchases', style: AppTypography.textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                        Switch(
                          value: _requireAuth,
                          onChanged: (val) => setState(() => _requireAuth = val),
                          activeColor: Colors.white,
                          activeTrackColor: Theme.of(context).colorScheme.primary,
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
                  InkWell(
                    onTap: _showDeactivateDialog,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Deactivate Account', style: AppTypography.textTheme.titleMedium?.copyWith(color: const Color(0xFFC53030))),
                          Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100), // Bottom shell padding
          ],
        ),
      ),
    );
  }
}

class _SecurityOptionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final Widget actionWidget;

  const _SecurityOptionCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.actionWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.shadow.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTypography.textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.outline)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          actionWidget,
        ],
      ),
    );
  }
}