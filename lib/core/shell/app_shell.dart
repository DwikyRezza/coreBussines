// ============================================================
// CORE: Shell — App Shell (Bottom Navigation)
// lib/core/shell/app_shell.dart
// ============================================================

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../di/service_locator.dart';
import '../security/permission_policy.dart';
import '../services/business_context_service.dart';
import '../theme/app_typography.dart';
import '../router/app_router.dart';

class _TabItem {
  final String route;
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _TabItem({
    required this.route,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class AppShell extends StatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  BusinessContext? _cachedContext;
  bool _isLoadingContext = true;
  StreamSubscription<BusinessContext>? _contextSubscription;

  List<_TabItem> _getTabsForContext(BusinessContext context) {
    final permissions = context.permissions;
    final List<_TabItem> tabs = [
      const _TabItem(
        route: AppRoutes.home,
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'Beranda',
      ),
      const _TabItem(
        route: AppRoutes.history,
        icon: Icons.history_outlined,
        activeIcon: Icons.history_rounded,
        label: 'Riwayat',
      ),
    ];

    if (permissions.contains(PermissionKeys.canViewAnalytics)) {
      tabs.add(
        const _TabItem(
          route: AppRoutes.analytics,
          icon: Icons.bar_chart_outlined,
          activeIcon: Icons.bar_chart_rounded,
          label: 'Analisis',
        ),
      );
    }

    tabs.add(
      const _TabItem(
        route: AppRoutes.settings,
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings_rounded,
        label: 'Pengaturan',
      ),
    );

    return tabs;
  }

  int _locationToIndex(String location, List<_TabItem> tabs) {
    for (int i = 0; i < tabs.length; i++) {
      if (location == tabs[i].route ||
          location.startsWith('${tabs[i].route}/')) {
        return i;
      }
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    _subscribeContext();
  }

  void _subscribeContext() {
    _contextSubscription =
        sl<BusinessContextService>().watchCurrentContext().listen(
      (ctx) {
        if (!mounted) return;
        setState(() {
          _cachedContext = ctx;
          _isLoadingContext = false;
        });
      },
      onError: (_) {
        if (!mounted) return;
        setState(() => _isLoadingContext = false);
      },
    );
  }

  @override
  void dispose() {
    _contextSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    if (_isLoadingContext || _cachedContext == null) {
      return Scaffold(body: widget.child);
    }

    final businessContext = _cachedContext!;
    final tabs = _getTabsForContext(businessContext);
    final currentIndex = _locationToIndex(location, tabs);

    final showFab = businessContext.hasPermission(
      PermissionKeys.canCreateTransaction,
    );

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: _AppBottomNavBar(
        currentIndex: currentIndex,
        tabs: tabs,
        onTap: (index) {
          context.go(tabs[index].route);
        },
      ),
      floatingActionButton:
          showFab ? _ExpandableFAB(contextData: businessContext) : null,
      floatingActionButtonLocation:
          showFab ? FloatingActionButtonLocation.centerDocked : null,
    );
  }
}

class _AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final List<_TabItem> tabs;
  final ValueChanged<int> onTap;

  const _AppBottomNavBar({
    required this.currentIndex,
    required this.tabs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final showFabSpace = tabs.length > 3; // Beri spasi FAB jika ada banyak tab

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:
                List.generate(tabs.length + (showFabSpace ? 1 : 0), (index) {
              // Jika ini adalah posisi tengah, beri gap untuk FAB
              if (showFabSpace && index == tabs.length ~/ 2) {
                return const SizedBox(width: 56);
              }

              final tabIndex = (showFabSpace && index > tabs.length ~/ 2)
                  ? index - 1
                  : index;
              final tab = tabs[tabIndex];

              return _NavItem(
                icon: tab.icon,
                activeIcon: tab.activeIcon,
                label: tab.label,
                isActive: currentIndex == tabIndex,
                onTap: () => onTap(tabIndex),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? colors.primary : colors.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.textTheme.labelSmall?.copyWith(
                color: isActive ? colors.primary : colors.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandableFAB extends StatefulWidget {
  final BusinessContext contextData;
  const _ExpandableFAB({required this.contextData});

  @override
  State<_ExpandableFAB> createState() => _ExpandableFABState();
}

class _ExpandableFABState extends State<_ExpandableFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _toggle() {
    if (_controller.isDismissed) {
      _showOverlay();
      _controller.forward();
    } else {
      _controller.reverse().then((_) => _removeOverlay());
    }
  }

  void _showOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    final cleanRole = widget.contextData.role.toLowerCase();
    final canUploadReceipt = widget.contextData.hasPermission(
      PermissionKeys.canUploadReceipt,
    );

    return OverlayEntry(
      builder: (context) {
        final bottomPadding = MediaQuery.of(context).padding.bottom;
        final actionWidth = ((MediaQuery.of(context).size.width - 46) / 2)
            .clamp(128.0, 164.0)
            .toDouble();

        // Bangun baris menu FAB secara adaptif berdasarkan role
        final List<Widget> menuRows = [];

        if (cleanRole == 'cashier') {
          // Kasir hanya boleh Tambah Transaksi dan Scan Struk
          menuRows.add(
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionItem(
                  context: context,
                  icon: Icons.add_rounded,
                  label: 'Tambah Transaksi',
                  width: actionWidth,
                  color: Theme.of(context).colorScheme.primary,
                  onTap: () {
                    _toggle();
                    context.push('${AppRoutes.addTransaction}?type=expense');
                  },
                ),
                const SizedBox(width: 14),
                if (canUploadReceipt)
                  _buildActionItem(
                    context: context,
                    icon: Icons.receipt_long_rounded,
                    label: 'Scan Struk',
                    width: actionWidth,
                    color: Theme.of(context).colorScheme.onSurface,
                    onTap: () {
                      _toggle();
                      context.push(AppRoutes.scanReceiptIntro);
                    },
                  ),
              ],
            ),
          );
        } else if (cleanRole == 'inventory') {
          // Inventory Staff hanya boleh scan struk masuk / log
          menuRows.add(
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionItem(
                  context: context,
                  icon: Icons.receipt_long_rounded,
                  label: 'Scan Struk Masuk',
                  width: actionWidth * 1.5,
                  color: Theme.of(context).colorScheme.primary,
                  onTap: () {
                    _toggle();
                    context.push(AppRoutes.scanReceiptIntro);
                  },
                ),
              ],
            ),
          );
        } else if (cleanRole == 'sales') {
          // Sales boleh tambah pemasukan dan scan struk
          menuRows.add(
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionItem(
                  context: context,
                  icon: Icons.add_rounded,
                  label: 'Tambah Penjualan',
                  width: actionWidth,
                  color: Theme.of(context).colorScheme.primary,
                  onTap: () {
                    _toggle();
                    context.push('${AppRoutes.addTransaction}?type=income');
                  },
                ),
                const SizedBox(width: 14),
                if (canUploadReceipt)
                  _buildActionItem(
                    context: context,
                    icon: Icons.receipt_long_rounded,
                    label: 'Scan Struk',
                    width: actionWidth,
                    color: Theme.of(context).colorScheme.onSurface,
                    onTap: () {
                      _toggle();
                      context.push(AppRoutes.scanReceiptIntro);
                    },
                  ),
              ],
            ),
          );
        } else {
          // Owner, Admin, Finance, Secretary, Manager, dll (Menu penuh)
          menuRows.add(
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionItem(
                  context: context,
                  icon: Icons.add_rounded,
                  label: 'Tambah Pemasukan',
                  width: actionWidth,
                  color: Theme.of(context).colorScheme.primary,
                  onTap: () {
                    _toggle();
                    context.push('${AppRoutes.addTransaction}?type=income');
                  },
                ),
                const SizedBox(width: 14),
                _buildActionItem(
                  context: context,
                  icon: Icons.remove_rounded,
                  label: 'Tambah Pengeluaran',
                  width: actionWidth,
                  color: Theme.of(context).colorScheme.error,
                  onTap: () {
                    _toggle();
                    context.push('${AppRoutes.addTransaction}?type=expense');
                  },
                ),
              ],
            ),
          );
          menuRows.add(const SizedBox(height: 14));
          menuRows.add(
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (canUploadReceipt)
                  _buildActionItem(
                    context: context,
                    icon: Icons.receipt_long_rounded,
                    label: 'Scan Struk',
                    width: actionWidth,
                    color: Theme.of(context).colorScheme.onSurface,
                    onTap: () {
                      _toggle();
                      context.push(AppRoutes.scanReceiptIntro);
                    },
                  ),
                const SizedBox(width: 14),
                _buildActionItem(
                  context: context,
                  icon: Icons.calendar_today_rounded,
                  label: 'Tambah Jadwal',
                  width: actionWidth,
                  color: Theme.of(context).colorScheme.error,
                  onTap: () {
                    _toggle();
                    context.push(AppRoutes.addSchedule);
                  },
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            GestureDetector(
              onTap: _toggle,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final bgColor = Theme.of(context).scaffoldBackgroundColor;
                  return BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 4 * _controller.value,
                      sigmaY: 4 * _controller.value,
                    ),
                    child: Container(
                      color: bgColor.withOpacity(0.8 * _controller.value),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 74 + bottomPadding,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 240,
                  child: AnimatedBuilder(
                    animation: _expandAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _expandAnimation.value,
                        alignment: Alignment.bottomCenter,
                        child: Opacity(
                          opacity: _controller.value.clamp(0.0, 1.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: menuRows,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required double width,
    required Color color,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: cs.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: cs.shadow.withOpacity(0.16),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: width,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: cs.surface.withOpacity(0.94),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: cs.shadow.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  textAlign: TextAlign.center,
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return FloatingActionButton(
      onPressed: _toggle,
      backgroundColor: colors.primary,
      elevation: 4,
      child: Icon(Icons.add, color: colors.onPrimary),
    );
  }
}
