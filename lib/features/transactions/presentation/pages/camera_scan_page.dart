// ============================================================
// FEATURE: Transactions — Camera Scan Page
// lib/features/transactions/presentation/pages/camera_scan_page.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_typography.dart';

class CameraScanPage extends StatelessWidget {
  const CameraScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Simulated Camera Feed (Receipt Image)
          Image.network(
            'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=800&q=80',
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.3), // Darken the feed slightly
            colorBlendMode: BlendMode.darken,
          ),

          // Camera Overlay UI
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white),
                          onPressed: () => context.pop(),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.flash_auto_rounded, color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Text('Auto', style: AppTypography.textTheme.labelMedium?.copyWith(color: Colors.white)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),

                // Scanner Reticle
                SizedBox(
                  width: 300,
                  height: 400,
                  child: Stack(
                    children: [
                      // Grid lines mock
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(3, (index) => const Divider(color: Colors.white24, height: 1)),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(3, (index) => const VerticalDivider(color: Colors.white24, width: 1)),
                      ),
                      // Corners
                      Align(
                        alignment: Alignment.topLeft,
                        child: _CornerBracket(angle: 0),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: _CornerBracket(angle: 1),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: _CornerBracket(angle: 3),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: _CornerBracket(angle: 2),
                      ),
                      // Scanning Line
                      Align(
                        alignment: const Alignment(0, -0.3), // Mock animated position
                        child: Container(
                          height: 2,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary, // Bright blue
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),
              ],
            ),
          ),

          // Bottom Sheet Mock
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Animated Loading Circle Mock
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: 0.7,
                          strokeWidth: 4,
                          color: Theme.of(context).colorScheme.primary,
                          backgroundColor: Theme.of(context).colorScheme.outlineVariant,
                        ),
                        Icon(Icons.receipt_long_rounded, color: Theme.of(context).colorScheme.primary, size: 32),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Menganalisis Struk...',
                    style: AppTypography.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Memproses data transaksi Anda. Pastikan\nperangkat tetap stabil.',
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.5,
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
}

class _CornerBracket extends StatelessWidget {
  final int angle; // 0: TL, 1: TR, 2: BR, 3: BL

  const _CornerBracket({required this.angle});

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: angle,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Theme.of(context).colorScheme.primary, width: 4),
            left: BorderSide(color: Theme.of(context).colorScheme.primary, width: 4),
          ),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(12)),
        ),
      ),
    );
  }
}