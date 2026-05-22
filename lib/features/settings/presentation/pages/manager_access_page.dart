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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        titleSpacing: AppSpacing.pagePadding,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF0D47A1), // Blue
              child: Text('AM', style: AppTypography.textTheme.labelMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
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
                const Icon(Icons.shield_outlined, color: Color(0xFF4A5568), size: 16),
                const SizedBox(width: 8),
                Text(
                  'ROLE MANAGEMENT',
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF4A5568),
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
                color: const Color(0xFF1A202C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Configure granular system permissions for users assigned to the Manager role. Changes take effect immediately upon toggling.',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF4A5568),
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
                boxShadow: [BoxShadow(color: AppColors.shadow.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  _SettingsRow(
                    title: 'User Management',
                    subtitle: 'Allow role to create, suspend, and modify standard user accounts across the platform.',
                    value: _userManagement,
                    onChanged: (val) => setState(() => _userManagement = val),
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
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
                boxShadow: [BoxShadow(color: AppColors.shadow.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  _SettingsRow(
                    title: 'View Transactions',
                    subtitle: 'Read-only access to all inbound and outbound financial ledgers.',
                    value: _viewTransactions,
                    onChanged: (val) => setState(() => _viewTransactions = val),
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  _SettingsRow(
                    title: 'Approve Refunds',
                    subtitle: 'Authorization to process customer refunds up to the standard daily limit.',
                    value: _approveRefunds,
                    onChanged: (val) => setState(() => _approveRefunds = val),
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
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
                boxShadow: [BoxShadow(color: AppColors.shadow.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  _SettingsRow(
                    title: 'Performance Dashboards',
                    subtitle: 'View high-level metrics, user engagement charts, and revenue summaries.',
                    value: _performanceDashboards,
                    onChanged: (val) => setState(() => _performanceDashboards = val),
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
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
                Text(title, style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF1A202C))),
                const SizedBox(height: 8),
                Text(subtitle, style: AppTypography.textTheme.bodyMedium?.copyWith(color: const Color(0xFF4A5568))),
              ],
            ),
          ),
          const SizedBox(width: 16),
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
