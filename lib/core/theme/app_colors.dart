// ============================================================
// CORE: Theme — App Colors & Material 3 Color Scheme
// lib/core/theme/app_colors.dart
// ============================================================

import 'package:flutter/material.dart';

/// All color tokens for CoreBusiness.
/// Primary: 0xFF003EC6 | Background: 0xFFFBF8FF
abstract class AppColors {
  // --- Brand Colors ---
  static const Color primary = Color(0xFF003EC6);
  static const Color primaryDark = Color(0xFF002A8A);
  static const Color primaryLight = Color(0xFF4068D4);
  static const Color primaryContainer = Color(0xFFDDE3FF);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF001170);

  // --- Background & Surface ---
  static const Color background = Color(0xFFFBF8FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFE7E0EC);
  static const Color surfaceContainer = Color(0xFFF3F0FF);
  static const Color onBackground = Color(0xFF1B1B1F);
  static const Color onSurface = Color(0xFF1B1B1F);
  static const Color onSurfaceVariant = Color(0xFF49454F);

  // --- Semantic Colors ---
  static const Color income = Color(0xFF003EC6);
  static const Color expense = Color(0xFFBA1A1A);
  static const Color incomeLight = Color(0xFFDDE3FF);
  static const Color expenseLight = Color(0xFFFFDAD6);
  static const Color surplus = Color(0xFF003EC6);
  static const Color deficit = Color(0xFFBA1A1A);
  static const Color surplusBackground = Color(0xFFDDE3FF);
  static const Color deficitBackground = Color(0xFFFFDAD6);

  // --- Neutral ---
  static const Color outline = Color(0xFF79747E);
  static const Color outlineVariant = Color(0xFFCAC4D0);
  static const Color shadow = Color(0xFF000000);
  static const Color disabled = Color(0xFF1C1B1F);

  // --- Glassmorphism ---
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);

  // --- Chart Colors ---
  static const Color chartIncome = Color(0xFF003EC6);
  static const Color chartExpense = Color(0xFFBA1A1A);
  static const Color chartGrid = Color(0xFFE7E0EC);

  // --- Gradient ---
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF003EC6), Color(0xFF0A56E8)],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFBF8FF), Color(0xFFEEEBFF)],
  );
}
