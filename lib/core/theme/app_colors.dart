// ============================================================
// CORE: Theme — App Colors & Material 3 Color Scheme
// lib/core/theme/app_colors.dart
// ============================================================

import 'package:flutter/material.dart';

/// Refined Slate + Indigo Color System for premium, calm, and readable UI.
abstract class AppColors {
  // --- Core Brand Colors ---
  static const Color obsidian = Color(0xFF0F172A); // Slate 900 (Deep Charcoal)
  static const Color graphite = Color(0xFF334155); // Slate 700 (Secondary Text)
  static const Color slate = Color(0xFF64748B);    // Slate 500 (Muted Text)
  static const Color mist = Color(0xFF94A3B8);     // Slate 400 (Disabled)
  static const Color silver = Color(0xFFE2E8F0);   // Slate 200 (Borders/Dividers)
  static const Color bone = Color(0xFFF8FAFC);     // Slate 50 (Scaffold Background)
  static const Color paper = Color(0xFFFFFFFF);    // White (Surface/Cards)
  static const Color lilacBloom = Color(0xFF4F46E5); // Indigo 600 (Primary Accent)
  static const Color skyVeil = Color(0xFF3B82F6);    // Blue 500 (Secondary Accent)

  // --- Semantic Colors ---
  static const Color income = Color(0xFF10B981);   // Emerald 500
  static const Color expense = Color(0xFFEF4444);  // Red 500
  static const Color warning = Color(0xFFF59E0B);  // Amber 500
  static const Color info = Color(0xFF0EA5E9);     // Sky 500

  // --- Compatibility Mappings for Existing Code ---
  static const Color primary = lilacBloom;
  static const Color onPrimary = paper;
  static const Color primaryContainer = Color(0xFFEEF2FF); // Indigo 50
  static const Color onPrimaryContainer = lilacBloom;
  static const Color background = bone;
  static const Color surface = paper;
  static const Color surfaceContainer = Color(0xFFF1F5F9); // Slate 100
  static const Color onBackground = obsidian;
  static const Color onSurface = obsidian;
  static const Color onSurfaceVariant = graphite;
  static const Color outline = silver;
  static const Color outlineVariant = silver;
  static const Color disabled = mist;
  static const Color shadow = Color(0x0F0F172A); // Smooth Slate Shadow

  // --- Gradients ---
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lilacBloom, skyVeil],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bone, paper],
  );
}
