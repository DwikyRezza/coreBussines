// ============================================================
// FEATURE: Settings — Security Settings Page
// lib/features/settings/presentation/pages/security_settings_page.dart
// ============================================================

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  bool _fingerprint = true;
  bool _faceUnlock = false;
  bool _requireAuth = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        titleSpacing: AppSpacing.pagePadding,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=11'),
              backgroundColor: AppColors.surfaceContainer,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'CoreBusiness',
              style: AppTypography.textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.primary),
            onPressed: () {},
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
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
                color: const Color(0xFF1A202C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your authentication methods to keep your account secure.',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF4A5568),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // PIN Option
            _SecurityOptionCard(
              icon: Icons.lock_outline_rounded,
              iconColor: const Color(0xFF0D47A1),
              iconBgColor: const Color(0xFFE3F2FD),
              title: '4-Digit PIN',
              subtitle: 'Required for transactions',
              actionWidget: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Change', style: AppTypography.textTheme.labelMedium?.copyWith(color: const Color(0xFF0D47A1), fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 16),

            // Fingerprint Toggle
            _SecurityOptionCard(
              icon: Icons.fingerprint_rounded,
              iconColor: const Color(0xFF2962FF),
              iconBgColor: const Color(0xFFE3F2FD),
              title: 'Fingerprint Unlock',
              subtitle: 'Fast and secure access using biometrics',
              actionWidget: Switch(
                value: _fingerprint,
                onChanged: (val) => setState(() => _fingerprint = val),
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF0D47A1),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFFCBD5E0),
              ),
            ),
            const SizedBox(height: 16),

            // Face Unlock Toggle
            _SecurityOptionCard(
              icon: Icons.face_rounded,
              iconColor: const Color(0xFF4A5568),
              iconBgColor: const Color(0xFFEDF2F7),
              title: 'Face Unlock',
              subtitle: 'Unlock by looking at your device',
              actionWidget: Switch(
                value: _faceUnlock,
                onChanged: (val) => setState(() => _faceUnlock = val),
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF0D47A1),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFFCBD5E0),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Advanced Section
            Text(
              'ADVANCED',
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: const Color(0xFF4A5568),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppColors.shadow.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Require authentication for purchases', style: AppTypography.textTheme.titleMedium?.copyWith(color: const Color(0xFF1A202C))),
                        Switch(
                          value: _requireAuth,
                          onChanged: (val) => setState(() => _requireAuth = val),
                          activeColor: Colors.white,
                          activeTrackColor: const Color(0xFF0D47A1),
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: const Color(0xFFCBD5E0),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Deactivate Account', style: AppTypography.textTheme.titleMedium?.copyWith(color: const Color(0xFFC53030))),
                        const Icon(Icons.chevron_right_rounded, color: Color(0xFF4A5568)),
                      ],
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
        boxShadow: [BoxShadow(color: AppColors.shadow.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
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
                Text(title, style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF1A202C))),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTypography.textTheme.bodyMedium?.copyWith(color: const Color(0xFF718096))),
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
