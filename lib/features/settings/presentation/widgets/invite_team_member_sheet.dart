// ============================================================
// FEATURE: Settings — Invite Team Member Sheet
// lib/features/settings/presentation/widgets/invite_team_member_sheet.dart
// ============================================================

import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

class InviteTeamMemberSheet extends StatefulWidget {
  const InviteTeamMemberSheet({super.key});

  @override
  State<InviteTeamMemberSheet> createState() => _InviteTeamMemberSheetState();
}

class _InviteTeamMemberSheetState extends State<InviteTeamMemberSheet> {
  int _selectedRoleIndex = 0; // 0: Owner, 1: Admin, 2: Staff

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: AppSpacing.pagePadding,
            right: AppSpacing.pagePadding,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Invite Team Member',
                    style: AppTypography.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Divider(color: Theme.of(context).colorScheme.outlineVariant),
              const SizedBox(height: 24),

              // Form: Email
              Text('Email Address', style: AppTypography.textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 8),
              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'name@company.com',
                  hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.outline),
                  prefixIcon: Icon(Icons.mail_outline_rounded, color: Theme.of(context).colorScheme.outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
                ),
              ),
              const SizedBox(height: 24),

              // Form: Assign Role
              Text('Assign Role', style: AppTypography.textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 4),
              Text('Select the appropriate access level for this user.', style: AppTypography.textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline)),
              const SizedBox(height: 16),

              // Role Options
              _RoleOption(
                title: 'Owner',
                description: 'Full administrative access. Can manage billing, global settings, and all team members.',
                icon: Icons.shield_outlined,
                isSelected: _selectedRoleIndex == 0,
                onTap: () => setState(() => _selectedRoleIndex = 0),
              ),
              const SizedBox(height: 12),
              _RoleOption(
                title: 'Admin',
                description: 'Can manage most settings, view all data, and invite staff members. Cannot access billing.',
                icon: Icons.admin_panel_settings_outlined,
                isSelected: _selectedRoleIndex == 1,
                onTap: () => setState(() => _selectedRoleIndex = 1),
              ),
              const SizedBox(height: 12),
              _RoleOption(
                title: 'Staff',
                description: 'Standard access to perform daily tasks. Limited visibility into organizational settings.',
                icon: Icons.person_outline_rounded,
                isSelected: _selectedRoleIndex == 2,
                onTap: () => setState(() => _selectedRoleIndex = 2),
              ),
              const SizedBox(height: 32),

              // Action Button
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  backgroundColor: Theme.of(context).colorScheme.primary, // Deep Blue
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Send Invitation', style: AppTypography.textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleOption extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.surfaceContainerHighest : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(description, style: AppTypography.textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline, height: 1.4)),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary, size: 24),
          ],
        ),
      ),
    );
  }
}