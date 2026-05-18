// ============================================================
// CORE: Shared AppBar — Uses real user avatar from AuthRepository
// lib/core/widgets/core_app_bar.dart
// ============================================================

import 'package:flutter/material.dart';
import '../di/service_locator.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';

/// A consistent AppBar used across all pages.
/// Pulls the real user's name and avatar from [AuthRepositoryImpl.cachedUser].
class CoreAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;

  const CoreAppBar({super.key, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final user = sl<AuthRepositoryImpl>().cachedUser;
    final avatarUrl = user?.photoUrl;
    final initial = (user?.name ?? 'U')[0].toUpperCase();

    return AppBar(
      titleSpacing: AppSpacing.pagePadding,
      title: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryContainer,
            backgroundImage:
                avatarUrl != null ? NetworkImage(avatarUrl) : null,
            child: avatarUrl == null
                ? Text(
                    initial,
                    style: AppTypography.textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : null,
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
      actions: actions ??
          [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded,
                  color: AppColors.primary),
              onPressed: () {},
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
      elevation: 0,
      backgroundColor: Colors.transparent,
    );
  }
}
