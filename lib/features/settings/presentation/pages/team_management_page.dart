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
      backgroundColor: const Color(0xFFF8FAFC),
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
                color: const Color(0xFF1A202C),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Manage your organization\'s members',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF4A5568),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('8 Members', style: AppTypography.textTheme.labelSmall?.copyWith(color: const Color(0xFF4A5568))),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Invite Member Button
            ElevatedButton(
              onPressed: () => _showInviteSheet(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: const Color(0xFF0D47A1), // Deep Blue
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
        color: isHighlighted ? const Color(0xFFF0F4FF) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isHighlighted ? const Color(0xFF0D47A1).withOpacity(0.2) : Colors.transparent),
        boxShadow: [
          if (!isHighlighted)
            BoxShadow(color: AppColors.shadow.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
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
              child: Text(initials!, style: AppTypography.textTheme.titleMedium?.copyWith(color: const Color(0xFF0D47A1), fontWeight: FontWeight.w700)),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF1A202C))),
                const SizedBox(height: 4),
                Text(email, style: AppTypography.textTheme.bodyMedium?.copyWith(color: const Color(0xFF718096))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isHighlighted ? const Color(0xFFD6E4FF) : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              role,
              style: AppTypography.textTheme.labelSmall?.copyWith(
                color: isHighlighted ? const Color(0xFF0D47A1) : const Color(0xFF4A5568),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (!isHighlighted) ...[
            const SizedBox(width: 8),
            const Icon(Icons.more_vert_rounded, color: Color(0xFF718096)),
          ],
        ],
      ),
    );
  }
}
