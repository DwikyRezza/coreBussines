// ============================================================
// FEATURE: Settings — Settings Page & Dashboard Customize Page
// lib/features/settings/presentation/pages/settings_page.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
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
              onTap: () => context.push(AppRoutes.themeSettings),
            ),
          ]),

          _SettingsSection(title: 'Akun', items: [
            _SettingsTile(
              icon: Icons.notifications_outlined,
              title: 'Notifikasi',
              subtitle: 'Kelola pengingat transaksi',
              onTap: () => context.push(AppRoutes.alerts),
            ),
            _SettingsTile(
              icon: Icons.lock_outline_rounded,
              title: 'Keamanan',
              subtitle: 'PIN, biometrik',
              onTap: () => context.push(AppRoutes.securitySettings),
            ),
            _SettingsTile(
              icon: Icons.backup_outlined,
              title: 'Backup Data',
              subtitle: 'Sinkronisasi ke cloud',
              onTap: () => context.push(AppRoutes.syncSettings),
            ),
          ]),

          _SettingsSection(title: 'Lainnya', items: [
            _SettingsTile(
              icon: Icons.help_outline_rounded,
              title: 'Bantuan & FAQ',
              onTap: () => context.push(AppRoutes.helpFaq),
            ),
            _SettingsTile(
              icon: Icons.info_outline_rounded,
              title: 'Tentang Aplikasi',
              subtitle: 'CoreBusiness v1.0.0',
              onTap: () => context.push(AppRoutes.about),
            ),
          ]),

          // Sign out
          Padding(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            child: OutlinedButton.icon(
              onPressed: () {
                context.read<AuthBloc>().add(const AuthSignOutRequested());
              },
              icon: Icon(Icons.logout_rounded, color: colors.error),
              label: Text(
                'Keluar',
                style: TextStyle(
                  color: colors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                side: BorderSide(color: colors.error),
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
    final colors = Theme.of(context).colorScheme;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String name = 'Pengguna';
        String email = '';
        String? avatarUrl;

        if (state is AuthAuthenticated) {
          name = state.user.fullName ?? 'Pengguna';
          email = state.user.email;
          avatarUrl = state.user.avatarUrl;
        }

        return Container(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          color: colors.surface,
          child: Row(children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: colors.primaryContainer,
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
              child: avatarUrl == null 
                  ? Text(name.isNotEmpty ? name[0].toUpperCase() : 'U',
                      style: AppTypography.textTheme.headlineSmall?.copyWith(
                        color: colors.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ))
                  : null,
            ),
            const SizedBox(width: AppSpacing.base),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name,
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                    )),
                Text(email,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    )),
              ]),
            ),
            IconButton(
              icon: Icon(Icons.edit_outlined, color: colors.primary),
              onPressed: () => context.push(AppRoutes.editProfile),
            ),
          ]),
        );
      },
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> items;
  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePadding, AppSpacing.base, AppSpacing.pagePadding, AppSpacing.xs),
        child: Text(title,
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: colors.onSurfaceVariant,
              letterSpacing: 0.8,
            )),
      ),
      Container(
        color: colors.surface,
        child: Column(children: [
          ...items.map((item) => Column(children: [
            item,
            if (item != items.last)
              Divider(height: 1, indent: 56, color: colors.outlineVariant.withOpacity(0.4)),
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
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: colors.primary, size: 18),
      ),
      title: Text(title, style: AppTypography.textTheme.bodyMedium?.copyWith(
        color: colors.onSurface,
        fontWeight: FontWeight.w500,
      )),
      subtitle: subtitle != null
          ? Text(subtitle!, style: AppTypography.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant))
          : null,
      trailing: Icon(Icons.chevron_right_rounded,
          color: colors.onSurfaceVariant, size: 18),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding, vertical: AppSpacing.xs,
      ),
    );
  }
}
