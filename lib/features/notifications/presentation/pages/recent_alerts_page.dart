// ============================================================
// FEATURE: Notifications - Recent Alerts Page
// lib/features/notifications/presentation/pages/recent_alerts_page.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/notification_model.dart';
import '../../domain/repositories/notification_repository.dart';

class RecentAlertsPage extends StatefulWidget {
  const RecentAlertsPage({super.key});

  @override
  State<RecentAlertsPage> createState() => _RecentAlertsPageState();
}

class _RecentAlertsPageState extends State<RecentAlertsPage> {
  final _repository = sl<NotificationRepository>();
  final Set<String> _selectedIds = {};
  bool _selectMode = false;

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
      _selectMode = _selectedIds.isNotEmpty;
    });
  }

  Future<void> _deleteSelected() async {
    final ids = _selectedIds.toList();
    if (ids.isEmpty) return;
    await _repository.deleteNotifications(ids);
    if (!mounted) return;
    setState(() {
      _selectedIds.clear();
      _selectMode = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifikasi terpilih berhasil dihapus.')),
    );
  }

  Future<void> _deleteAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus semua notifikasi?'),
        content: const Text(
          'Tindakan ini hanya menghapus notifikasi milik akun Anda.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await _repository.deleteAllNotifications();
    if (!mounted) return;
    setState(() {
      _selectedIds.clear();
      _selectMode = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Semua notifikasi berhasil dihapus.')),
    );
  }

  Future<void> _openNotification(NotificationModel notification) async {
    if (_selectMode) {
      _toggleSelection(notification.id);
      return;
    }
    if (!notification.isRead) {
      await _repository.markAsRead(notification.id);
    }
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: Text(notification.body),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final timeStr = DateFormat('HH:mm').format(dateTime);

    if (checkDate == today) return 'Hari Ini, $timeStr';
    if (checkDate == yesterday) return 'Kemarin, $timeStr';
    return '${DateFormat('dd MMM yyyy', 'id_ID').format(dateTime)}, $timeStr';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (_selectMode) {
              setState(() {
                _selectMode = false;
                _selectedIds.clear();
              });
            } else {
              context.pop();
            }
          },
          icon: Icon(
            _selectMode ? Icons.close_rounded : Icons.arrow_back_rounded,
            color: colors.onSurface,
          ),
        ),
        title:
            Text(_selectMode ? '${_selectedIds.length} dipilih' : 'Notifikasi'),
        actions: [
          if (_selectMode) ...[
            IconButton(
              tooltip: 'Hapus Terpilih',
              onPressed: _selectedIds.isEmpty ? null : _deleteSelected,
              icon: Icon(Icons.delete_outline_rounded, color: colors.error),
            ),
          ] else ...[
            IconButton(
              tooltip: 'Tandai Semua Dibaca',
              onPressed: _repository.markAllAsRead,
              icon: const Icon(Icons.done_all_rounded),
            ),
            IconButton(
              tooltip: 'Hapus Semua',
              onPressed: _deleteAll,
              icon: Icon(Icons.delete_sweep_rounded, color: colors.error),
            ),
          ],
        ],
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: _repository.watchNotifications(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 64, color: colors.error),
                    const SizedBox(height: 16),
                    Text(
                      'Gagal memuat notifikasi',
                      style: AppTypography.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data!;
          if (notifications.isEmpty) {
            return const _EmptyNotifications();
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pagePadding,
              AppSpacing.md,
              AppSpacing.pagePadding,
              100,
            ),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = notifications[index];
              return _NotificationCard(
                notification: item,
                formattedTime: _formatTimestamp(item.createdAt),
                selected: _selectedIds.contains(item.id),
                selectMode: _selectMode,
                onTap: () => _openNotification(item),
                onLongPress: () => _toggleSelection(item.id),
                onMarkRead:
                    item.isRead ? null : () => _repository.markAsRead(item.id),
                onDelete: () => _repository.deleteNotification(item.id),
              );
            },
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final String formattedTime;
  final bool selected;
  final bool selectMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback? onMarkRead;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.notification,
    required this.formattedTime,
    required this.selected,
    required this.selectMode,
    required this.onTap,
    required this.onLongPress,
    required this.onMarkRead,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final unread = !notification.isRead;
    final icon = switch (notification.type) {
      'success' => Icons.check_circle_outline_rounded,
      'warning' => Icons.warning_amber_rounded,
      'alert' => Icons.error_outline_rounded,
      _ => Icons.info_outline_rounded,
    };
    final iconColor = switch (notification.type) {
      'success' => Colors.green,
      'warning' => Colors.orange,
      'alert' => colors.error,
      _ => colors.primary,
    };

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? colors.primaryContainer
              : unread
                  ? colors.primaryContainer.withValues(alpha: 0.28)
                  : colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? colors.primary
                : unread
                    ? colors.primary.withValues(alpha: 0.22)
                    : colors.outlineVariant,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (selectMode)
              Padding(
                padding: const EdgeInsets.only(right: 12, top: 10),
                child: Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected ? colors.primary : colors.outline,
                ),
              ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor),
                ),
                if (unread)
                  Positioned(
                    right: -1,
                    top: -1,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: colors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.textTheme.titleMedium?.copyWith(
                            fontWeight:
                                unread ? FontWeight.w800 : FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formattedTime,
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (onMarkRead != null)
                        TextButton(
                          onPressed: onMarkRead,
                          child: const Text('Tandai Dibaca'),
                        ),
                      IconButton(
                        tooltip: 'Hapus',
                        onPressed: onDelete,
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: colors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'Belum Ada Notifikasi',
              style: AppTypography.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aktivitas bisnis dan ringkasan mingguan akan muncul di sini.',
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
