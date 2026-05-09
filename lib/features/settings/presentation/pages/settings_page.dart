// ============================================================
// FEATURE: Settings — Settings Page & Dashboard Customize Page
// lib/features/settings/presentation/pages/settings_page.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/settings_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/app_router.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          // User profile section
          _ProfileHeader(),
          const Divider(height: 1),

          // General settings
          _SettingsSection(title: 'Tampilan', items: [
            _SettingsTile(
              icon: Icons.dashboard_customize_rounded,
              title: 'Atur Dashboard',
              subtitle: 'Pilih dan susun kartu beranda',
              onTap: () => context.push(AppRoutes.dashboardCustomize),
            ),
            _SettingsTile(
              icon: Icons.color_lens_outlined,
              title: 'Tema Aplikasi',
              subtitle: 'Terang / Gelap / Sistem',
              onTap: () {},
            ),
          ]),

          _SettingsSection(title: 'Akun', items: [
            _SettingsTile(
              icon: Icons.notifications_outlined,
              title: 'Notifikasi',
              subtitle: 'Kelola pengingat transaksi',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.lock_outline_rounded,
              title: 'Keamanan',
              subtitle: 'PIN, biometrik',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.backup_outlined,
              title: 'Backup Data',
              subtitle: 'Sinkronisasi ke cloud',
              onTap: () {},
            ),
          ]),

          _SettingsSection(title: 'Lainnya', items: [
            _SettingsTile(
              icon: Icons.help_outline_rounded,
              title: 'Bantuan & FAQ',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.info_outline_rounded,
              title: 'Tentang Aplikasi',
              subtitle: 'CoreBusiness v1.0.0',
              onTap: () {},
            ),
          ]),

          // Sign out
          Padding(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout_rounded, color: AppColors.expense),
              label: const Text('Keluar',
                  style: TextStyle(color: AppColors.expense, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                side: const BorderSide(color: AppColors.expense),
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      color: AppColors.surface,
      child: Row(children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: AppColors.primaryContainer,
          child: Text('A',
              style: AppTypography.textTheme.headlineSmall?.copyWith(
                color: AppColors.primary, fontWeight: FontWeight.w700,
              )),
        ),
        const SizedBox(width: AppSpacing.base),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Alex Chen',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                )),
            Text('alex.chen@gmail.com',
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                )),
          ]),
        ),
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
          onPressed: () {},
        ),
      ]),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> items;
  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePadding, AppSpacing.base, AppSpacing.pagePadding, AppSpacing.xs),
        child: Text(title,
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
              letterSpacing: 0.8,
            )),
      ),
      Container(
        color: AppColors.surface,
        child: Column(children: [
          ...items.map((item) => Column(children: [
            item,
            if (item != items.last)
              Divider(height: 1, indent: 56, color: AppColors.outlineVariant.withOpacity(0.4)),
          ])),
        ]),
      ),
      const SizedBox(height: AppSpacing.base),
    ]);
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  const _SettingsTile({required this.icon, required this.title,
      this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 18),
      ),
      title: Text(title, style: AppTypography.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w500,
      )),
      subtitle: subtitle != null
          ? Text(subtitle!, style: AppTypography.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant))
          : null,
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppColors.onSurfaceVariant, size: 18),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding, vertical: AppSpacing.xs,
      ),
    );
  }
}
