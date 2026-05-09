// ============================================================
// CORE: Shell — App Shell (Bottom Navigation)
// lib/core/shell/app_shell.dart
// ============================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../router/app_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith(AppRoutes.history)) return 1;
    if (location.startsWith(AppRoutes.analytics)) return 2;
    if (location.startsWith(AppRoutes.settings)) return 3;
    return 0;
  }

  void _onTabTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.history);
        break;
      case 2:
        context.go(AppRoutes.analytics);
        break;
      case 3:
        context.go(AppRoutes.settings);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _locationToIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: _AppBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) => _onTabTapped(context, index),
      ),
      floatingActionButton: const _ExpandableFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _AppBottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Beranda',
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.history_outlined,
                activeIcon: Icons.history_rounded,
                label: 'Riwayat',
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              const SizedBox(width: 56), // Gap for FAB
              _NavItem(
                icon: Icons.bar_chart_outlined,
                activeIcon: Icons.bar_chart_rounded,
                label: 'Analisis',
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings_rounded,
                label: 'Pengaturan',
                isActive: currentIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
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
              color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.textTheme.labelSmall?.copyWith(
                color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
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
  const _ExpandableFAB();

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
    return OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Blurred Background
            GestureDetector(
              onTap: _toggle,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 4 * _controller.value,
                      sigmaY: 4 * _controller.value,
                    ),
                    child: Container(
                      color: AppColors.background.withOpacity(0.8 * _controller.value),
                    ),
                  );
                },
              ),
            ),
            
            // Expanded FAB buttons
            Positioned(
              bottom: 40 + MediaQuery.of(context).padding.bottom,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 320,
                  height: 320,
                  child: AnimatedBuilder(
                    animation: _expandAnimation,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          // 1. Tambah Pemasukan (Left)
                          _buildActionItem(
                            icon: Icons.add,
                            label: 'Tambah Pemasukan',
                            angle: -0.6,
                            distance: 110,
                            color: AppColors.primary,
                            onTap: () {
                              _toggle();
                              // Add Income Action
                            },
                          ),
                          // 2. Tambah Pengeluaran (Top Left)
                          _buildActionItem(
                            icon: Icons.remove,
                            label: 'Tambah Pengeluaran',
                            angle: -0.2,
                            distance: 140,
                            color: AppColors.expense,
                            onTap: () {
                              _toggle();
                              // Add Expense Action
                            },
                          ),
                          // 3. Scan Struk (Top Right)
                          _buildActionItem(
                            icon: Icons.receipt_long_rounded,
                            label: 'Scan Struk',
                            angle: 0.2,
                            distance: 140,
                            color: AppColors.onBackground,
                            onTap: () {
                              _toggle();
                              // Scan Receipt Action
                            },
                          ),
                          // 4. Tambah Jadwal (Right)
                          _buildActionItem(
                            icon: Icons.calendar_today_rounded,
                            label: 'Tambah Jadwal',
                            angle: 0.6,
                            distance: 110,
                            color: AppColors.expense,
                            onTap: () {
                              _toggle();
                              // Add Schedule Action
                            },
                          ),
                          
                          // Close Button (Center Bottom)
                          Positioned(
                            bottom: 0,
                            child: Transform.rotate(
                              angle: _expandAnimation.value * 3.14159 / 4, // rotate + to x
                              child: FloatingActionButton(
                                elevation: 0,
                                backgroundColor: AppColors.primary,
                                onPressed: _toggle,
                                child: const Icon(Icons.close, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
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
    required IconData icon,
    required String label,
    required double angle, // angle from vertical top
    required double distance,
    required Color color,
    required VoidCallback onTap,
  }) {
    // Math to position icons in an arc
    final double rad = angle * 3.14159;
    // We adjust bottom offset. Bottom center is the origin.
    final double dx = distance * -rad; // approximation for horizontal spread
    final double dy = distance * (1 - angle.abs()) + 40; // approximation for vertical arc

    return Positioned(
      bottom: _expandAnimation.value * dy,
      left: 160 + (_expandAnimation.value * dx) - 40, // 160 is half of 320 width
      child: Transform.scale(
        scale: _expandAnimation.value,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 4,
              child: InkWell(
                onTap: onTap,
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Icon(icon, color: color, size: 24),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                label,
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: AppColors.onBackground,
                  fontWeight: FontWeight.w600,
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
    return FloatingActionButton(
      onPressed: _toggle,
      backgroundColor: AppColors.primary,
      elevation: 4,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}
