// ============================================================
// CORE: Utils — Responsive Helper
// lib/core/utils/responsive_helper.dart
// ============================================================

import 'package:flutter/material.dart';

/// Breakpoints and utilities for responsive layouts across
/// phones, tablets, and large tablets / iPads.
class ResponsiveHelper {
  ResponsiveHelper._();

  // ─── Breakpoints ──────────────────────────────────────────
  static const double phoneMaxWidth = 600;
  static const double tabletMaxWidth = 900;

  // ─── Device Queries ───────────────────────────────────────
  static bool isPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width < phoneMaxWidth;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= phoneMaxWidth && w < tabletMaxWidth;
  }

  static bool isLargeTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletMaxWidth;

  static bool isTabletOrLarger(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= phoneMaxWidth;

  // ─── Adaptive Values ──────────────────────────────────────

  /// Page horizontal padding that scales with screen width.
  static double pagePadding(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= tabletMaxWidth) return 32;
    if (w >= phoneMaxWidth) return 24;
    return 16;
  }

  /// Suggested number of grid columns.
  static int columns(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= tabletMaxWidth) return 3;
    if (w >= phoneMaxWidth) return 2;
    return 1;
  }

  /// Maximum content width for centering on large screens.
  static double maxContentWidth(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= tabletMaxWidth) return 840;
    if (w >= phoneMaxWidth) return 680;
    return double.infinity;
  }

  /// Wraps [child] in a centred ConstrainedBox so content
  /// does not stretch edge-to-edge on wide displays.
  static Widget constrainWidth({
    required BuildContext context,
    required Widget child,
    double? maxWidth,
  }) {
    final mw = maxWidth ?? maxContentWidth(context);
    if (mw == double.infinity) return child;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: mw),
        child: child,
      ),
    );
  }

  /// Adaptive font scale multiplier (slightly bigger on tablets).
  static double fontScale(BuildContext context) {
    if (isLargeTablet(context)) return 1.05;
    if (isTablet(context)) return 1.02;
    return 1.0;
  }

  /// Adaptive icon size.
  static double iconSize(BuildContext context, {double base = 24}) {
    if (isLargeTablet(context)) return base * 1.15;
    if (isTablet(context)) return base * 1.08;
    return base;
  }
}
