// ============================================================
// CORE: Shared AppBar — Uses real user avatar from AuthRepository
// lib/core/widgets/core_app_bar.dart
// ============================================================

import 'package:flutter/material.dart';
import '../di/service_locator.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../router/app_router.dart';
import 'package:go_router/go_router.dart';

/// A consistent AppBar used across all pages.
/// Pulls the real user's name and avatar from [AuthRepositoryImpl.cachedUser].
class CoreAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;

  const CoreAppBar({super.key, this.title, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final user = sl<AuthRepositoryImpl>().cachedUser;
    final avatarUrl = user?.photoUrl;
    final initial = (user?.name ?? 'U')[0].toUpperCase();

    return AppBar(
      titleSpacing: AppSpacing.pagePadding,
      title: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: colors.primaryContainer,
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
            child: avatarUrl == null
                ? Text(
                    initial,
                    style: AppTypography.textTheme.labelMedium?.copyWith(
                      color: colors.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            title ?? 'CoreBusiness',
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      actions: actions ??
          [
            StreamBuilder<int>(
              stream: sl<NotificationRepository>().watchUnreadCount(),
              builder: (context, snapshot) {
                final unreadCount = snapshot.data ?? 0;
                return IconButton(
                  icon: unreadCount > 0
                      ? Badge(
                          label: Text(
                            '$unreadCount',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 10),
                          ),
                          backgroundColor: Theme.of(context).colorScheme.error,
                          child: const Icon(Icons.notifications_outlined),
                        )
                      : const Icon(Icons.notifications_none_rounded),
                  color: colors.primary,
                  onPressed: () => context.push(AppRoutes.alerts),
                );
              },
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
      elevation: 0,
      backgroundColor: Colors.transparent,
    );
  }
}
