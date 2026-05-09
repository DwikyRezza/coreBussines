// ============================================================
// FEATURE: Onboarding — Splash Page
// lib/features/onboarding/presentation/pages/splash_page.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/app_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward().then((_) {
        if (mounted) {
          context.go(AppRoutes.onboarding);
        }
      });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C5CE5), // Deep blue matching screenshot
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),
            
            // 3D Chart Illustration Mock
            Center(
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2A3D54),
                      Color(0xFF1C2A39),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Grid lines
                    for (int i = 1; i <= 4; i++)
                      Positioned(
                        bottom: i * 40.0,
                        left: 20,
                        right: 20,
                        child: Container(height: 1, color: Colors.white.withOpacity(0.1)),
                      ),
                    
                    // Bars
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _build3DBar(80),
                        _build3DBar(120),
                        _build3DBar(60),
                        _build3DBar(160),
                        _build3DBar(100),
                      ],
                    ),
                    
                    // Trend lines
                    CustomPaint(
                      size: const Size(200, 200),
                      painter: _TrendLinePainter(),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppSpacing.xxl),
            
            // App Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.bar_chart_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            
            // App Title
            Text(
              'CoreFit',
              style: AppTypography.textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 36,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            
            // Subtitle
            Text(
              'Precision health & wealth\ntracking.',
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.9),
                height: 1.4,
              ),
            ),
            
            const Spacer(flex: 4),
            
            // Loading Bar
            SizedBox(
              width: 100,
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: _progressController.value,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 4,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Version Info
            Text(
              'v2.4.0',
              style: AppTypography.textTheme.labelSmall?.copyWith(
                color: Colors.white.withOpacity(0.7),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _build3DBar(double height) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: 18,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.5),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(4, 0),
          ),
        ],
      ),
    );
  }
}

class _TrendLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
      
    final paint2 = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path1 = Path()
      ..moveTo(20, size.height - 40)
      ..quadraticBezierTo(size.width * 0.5, size.height - 100, size.width - 40, 40);
      
    final path2 = Path()
      ..moveTo(20, size.height - 20)
      ..quadraticBezierTo(size.width * 0.6, size.height - 60, size.width - 20, 80);

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
    
    // Draw arrow heads
    canvas.drawCircle(const Offset(160, 40), 3, paint1..style = PaintingStyle.fill);
    canvas.drawCircle(const Offset(180, 80), 3, paint1..color = Colors.white.withOpacity(0.5));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
