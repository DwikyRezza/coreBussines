// ============================================================
// FEATURE: Settings — Sync Settings Page
// lib/features/settings/presentation/pages/sync_settings_page.dart
// ============================================================

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class SyncSettingsPage extends StatefulWidget {
  const SyncSettingsPage({super.key});

  @override
  State<SyncSettingsPage> createState() => _SyncSettingsPageState();
}

class _SyncSettingsPageState extends State<SyncSettingsPage> {
  bool _autoSync = true;
  bool _wifiOnly = false;

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
              'CoreFit',
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
              'Pencadangan & Sinkronisasi',
              style: AppTypography.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A202C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kelola bagaimana data kebugaran Anda disimpan.',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF4A5568),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Main Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppColors.shadow.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEDF2F7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.cloud_done_outlined, color: Color(0xFF0D47A1), size: 40),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Semua data sinkron',
                    style: AppTypography.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A202C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Terakhir disinkronkan: Hari ini, 09:41',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF718096),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFFE3F2FD),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_upload_outlined, color: Color(0xFF0D47A1), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Cadangkan Sekarang',
                          style: AppTypography.textTheme.labelLarge?.copyWith(color: const Color(0xFF0D47A1), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Advanced Settings
            Text(
              'PENGATURAN LANJUTAN',
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: const Color(0xFF718096),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            
            // Toggles
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppColors.shadow.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  _SettingsToggle(
                    icon: Icons.sync_rounded,
                    title: 'Auto Sync',
                    subtitle: 'Sinkronisasi otomatis ke cloud.',
                    value: _autoSync,
                    onChanged: (val) => setState(() => _autoSync = val),
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  _SettingsToggle(
                    icon: Icons.wifi_rounded,
                    title: 'Hanya melalui Wi-Fi',
                    subtitle: 'Hemat data seluler Anda.',
                    value: _wifiOnly,
                    onChanged: (val) => setState(() => _wifiOnly = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Cloud Storage Indicator
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppColors.shadow.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEDF2F7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.cloud_outlined, color: Color(0xFF4A5568), size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Penyimpanan Cloud', style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF1A202C))),
                            const SizedBox(height: 4),
                            Text('Terkoneksi ke akun Utama', style: AppTypography.textTheme.bodyMedium?.copyWith(color: const Color(0xFF718096))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const LinearProgressIndicator(
                      value: 0.05, // 45MB / 5GB approx
                      backgroundColor: Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2962FF)),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('45MB digunakan', style: AppTypography.textTheme.labelMedium?.copyWith(color: const Color(0xFF2962FF), fontWeight: FontWeight.w600)),
                      Text('5GB total', style: AppTypography.textTheme.bodySmall?.copyWith(color: const Color(0xFF718096))),
                    ],
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

class _SettingsToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFEDF2F7),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF4A5568), size: 20),
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF0D47A1), // Deep blue
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFCBD5E0),
          ),
        ],
      ),
    );
  }
}
