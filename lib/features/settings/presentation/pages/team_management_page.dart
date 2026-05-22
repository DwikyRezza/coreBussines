// ============================================================
// FEATURE: Settings — Team Management Page
// lib/features/settings/presentation/pages/team_management_page.dart
// ============================================================

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/core_app_bar.dart';
import '../widgets/invite_team_member_sheet.dart';

class TeamManagementPage extends StatelessWidget {
  const TeamManagementPage({super.key});

  void _showInviteSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const InviteTeamMemberSheet(),
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
              'Team Management',
              style: AppTypography.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Manage your organization\'s members',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('8 Members', style: AppTypography.textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Invite Member Button
            ElevatedButton(
              onPressed: () => _showInviteSheet(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: Theme.of(context).colorScheme.primary, // Deep Blue
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text('Invite Member', style: AppTypography.textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Member List
            _MemberCard(
              name: 'Marcus Johnson',
              email: 'marcus.j@CoreBusiness.inc',
              role: 'Owner',
              initials: 'MJ',
              isHighlighted: true,
            ),
            const SizedBox(height: 16),
            _MemberCard(
              name: 'Sarah Jenkins',
              email: 's.jenkins@CoreBusiness.inc',
              role: 'Admin',
              initials: 'SJ',
            ),
            const SizedBox(height: 16),
            _MemberCard(
              name: 'Emily Chen',
              email: 'emily.c@CoreBusiness.inc',
              role: 'Staff',
              initials: 'EC',
            ),
            const SizedBox(height: 16),
            _MemberCard(
              name: 'David Rodriguez',
              email: 'd.rodriguez@CoreBusiness.inc',
              role: 'Staff',
              initials: 'DR',
            ),
            const SizedBox(height: 100), // Bottom shell padding
          ],
        ),
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final String? avatarUrl;
  final String? initials;
  final bool isHighlighted;

  const _MemberCard({
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.initials,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlighted ? Theme.of(context).colorScheme.surfaceContainerHighest : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isHighlighted ? Theme.of(context).colorScheme.primary.withOpacity(0.2) : Colors.transparent),
        boxShadow: [
          if (!isHighlighted)
            BoxShadow(color: Theme.of(context).colorScheme.shadow.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          if (avatarUrl != null)
            CircleAvatar(radius: 24, backgroundImage: NetworkImage(avatarUrl!))
          else if (initials != null)
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFE3F2FD),
              child: Text(initials!, style: AppTypography.textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700)),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 4),
                Text(email, style: AppTypography.textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.outline)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isHighlighted ? const Color(0xFFD6E4FF) : Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              role,
              style: AppTypography.textTheme.labelSmall?.copyWith(
                color: isHighlighted ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (!isHighlighted) ...[
            const SizedBox(width: 8),
            Icon(Icons.more_vert_rounded, color: Theme.of(context).colorScheme.outline),
          ],
        ],
      ),
    );
  }
}