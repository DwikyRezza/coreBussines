// ============================================================
// FEATURE: Onboarding — Slide Card Widget
// lib/features/onboarding/presentation/widgets/onboarding_slide_card.dart
// ============================================================

import 'package:flutter/material.dart';
import '../../domain/entities/onboarding_slide.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class OnboardingSlideCard extends StatelessWidget {
  final OnboardingSlide slide;
  final int index;

  const OnboardingSlideCard({
    super.key,
    required this.slide,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Illustration Area specific to the slide
        _IllustrationArea(index: index),
      ],
    );
  }
}

class _IllustrationArea extends StatelessWidget {
  final int index;

  const _IllustrationArea({required this.index});

  @override
  Widget build(BuildContext context) {
    switch (index) {
      case 0:
        return const _IllustrationSlide1();
      case 1:
        return const _IllustrationSlide2();
      case 2:
        return const _IllustrationSlide3();
      default:
        return const SizedBox();
    }
  }
}

// ─── Slide 1: Dashboard Mock ──────────────────────────────────
class _IllustrationSlide1 extends StatelessWidget {
  const _IllustrationSlide1();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Simulated Dashboard UI
          Container(
            width: 240,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.account_balance_wallet,
                          color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 60, height: 6, color: Theme.of(context).colorScheme.outlineVariant),
                        const SizedBox(height: 4),
                        Container(width: 100, height: 8, color: Theme.of(context).colorScheme.outlineVariant),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(width: 30, height: 40, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Container(width: 30, height: 60, color: Theme.of(context).colorScheme.primaryContainer),
                    const SizedBox(width: 8),
                    Container(width: 30, height: 20, color: Theme.of(context).colorScheme.surfaceContainer),
                  ],
                ),
              ],
            ),
          ),
          // Floating overlay mock
          Positioned(
            bottom: 20,
            left: -10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.storefront_rounded, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 60, height: 8, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(height: 6),
                      Container(width: 40, height: 6, color: Theme.of(context).colorScheme.outlineVariant),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.outlineVariant),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Slide 2: Analytics Chart Mock ────────────────────────────
class _IllustrationSlide2 extends StatelessWidget {
  const _IllustrationSlide2();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 320,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Bar Chart abstract representation
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar(60),
              _buildBar(100),
              _buildBar(140),
              _buildBar(80),
              _buildBar(180, isPrimary: true),
              _buildBar(120),
            ],
          ),
          // Insight AI Floating Badge
          Positioned(
            bottom: -20, // To hang over the edge slightly
            child: Container(
              width: 280,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Insight AI',
                          style: AppTypography.textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Berdasarkan data minggu ini, diproyeksikan pendapatan Anda akan meningkat 15%.',
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double height, {bool isPrimary = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: 24,
      height: height,
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.primary : Colors.white.withOpacity(0.5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
      ),
    );
  }
}

// ─── Slide 3: Calendar/Schedule Mock ──────────────────────────
class _IllustrationSlide3 extends StatelessWidget {
  const _IllustrationSlide3();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: const Color(0xFF6DA5B0), // Soft teal matching screenshot
        borderRadius: BorderRadius.circular(32),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Floating Calendar Mock
          Transform.rotate(
            angle: -0.15,
            child: Container(
              width: 220,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 16,
                    offset: const Offset(4, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5))),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(24, (i) {
                          return Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: i == 12 ? AppColors.primary : Theme.of(context).colorScheme.surfaceContainer,
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Top Right Badge: Pengingat Aktif
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFEBEE), // Light red
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications_active_rounded, color: Color(0xFFE53935), size: 16),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pengingat Aktif',
                        style: AppTypography.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '09:00 AM',
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Left Badge: Jadwal Pengiriman
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Jadwal Pengiriman',
                        style: AppTypography.textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'Hari ini',
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '3 Pesanan',
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}