// ============================================================
// FEATURE: Settings — Manager Access Page
// lib/features/settings/presentation/pages/manager_access_page.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class ManagerAccessPage extends StatefulWidget {
  const ManagerAccessPage({super.key});

  @override
  State<ManagerAccessPage> createState() => _ManagerAccessPageState();
}

class _ManagerAccessPageState extends State<ManagerAccessPage> {
  bool _userManagement = true;
  bool _systemConfig = false;
  
  bool _viewTransactions = true;
  bool _approveRefunds = true;
  bool _initiateWire = false;
  
  bool _performanceDashboards = true;
  bool _rawDataExport = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        titleSpacing: AppSpacing.pagePadding,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary, // Blue
              child: Text('AM', style: AppTypography.textTheme.labelMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'CoreBusiness',
              style: AppTypography.textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, color: Theme.of(context).colorScheme.primary),
            onPressed: () => context.push(AppRoutes.alerts),
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
            
            // Header
            Row(
              children: [
                Icon(Icons.shield_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 16),
                const SizedBox(width: 8),
                Text(
                  'ROLE MANAGEMENT',
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Manager Access',
              style: AppTypography.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Configure granular system permissions for users assigned to the Manager role. Changes take effect immediately upon toggling.',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Access Settings Group
            Text('Access Settings', style: AppTypography.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.shadow.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  _SettingsRow(
                    title: 'User Management',
                    subtitle: 'Allow role to create, suspend, and modify standard user accounts across the platform.',
                    value: _userManagement,
                    onChanged: (val) => setState(() => _userManagement = val),
                  ),
                  Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
                  _SettingsRow(
                    title: 'System Configuration',
                    subtitle: 'Grant access to global application settings, API keys, and integration webhooks.',
                    value: _systemConfig,
                    onChanged: (val) => setState(() => _systemConfig = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Transaction Permissions Group
            Text('Transaction Permissions', style: AppTypography.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.shadow.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  _SettingsRow(
                    title: 'View Transactions',
                    subtitle: 'Read-only access to all inbound and outbound financial ledgers.',
                    value: _viewTransactions,
                    onChanged: (val) => setState(() => _viewTransactions = val),
                  ),
                  Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
                  _SettingsRow(
                    title: 'Approve Refunds',
                    subtitle: 'Authorization to process customer refunds up to the standard daily limit.',
                    value: _approveRefunds,
                    onChanged: (val) => setState(() => _approveRefunds = val),
                  ),
                  Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
                  _SettingsRow(
                    title: 'Initiate Wire Transfers',
                    subtitle: 'Permission to create new outbound bulk payouts and wire transfers.',
                    value: _initiateWire,
                    onChanged: (val) => setState(() => _initiateWire = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Analytics Access Group
            Text('Analytics Access', style: AppTypography.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.shadow.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  _SettingsRow(
                    title: 'Performance Dashboards',
                    subtitle: 'View high-level metrics, user engagement charts, and revenue summaries.',
                    value: _performanceDashboards,
                    onChanged: (val) => setState(() => _performanceDashboards = val),
                  ),
                  Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
                  _SettingsRow(
                    title: 'Raw Data Export (CSV/API)',
                    subtitle: 'Ability to download unfiltered historical data tables and access reporting APIs.',
                    value: _rawDataExport,
                    onChanged: (val) => setState(() => _rawDataExport = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48), // Bottom padding
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsRow({
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 8),
                Text(subtitle, style: AppTypography.textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: Theme.of(context).colorScheme.primary, // Deep blue
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Theme.of(context).colorScheme.outlineVariant,
          ),
        ],
      ),
    );
  }
}