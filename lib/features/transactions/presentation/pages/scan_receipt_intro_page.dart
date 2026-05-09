// ============================================================
// FEATURE: Transactions — Scan Receipt Intro Page
// lib/features/transactions/presentation/pages/scan_receipt_intro_page.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class ScanReceiptIntroPage extends StatelessWidget {
  const ScanReceiptIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFF1A202C)),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),

              // Hero Graphic
              Container(
                width: 280,
                height: 280,
                decoration: const BoxDecoration(
                  color: Color(0xFFEDF2F7), // Light blue-grey background
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Mock Image of Phone scanning receipt
                      ClipRRect(
                        borderRadius: BorderRadius.circular(140),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=400&q=80',
                          fit: BoxFit.cover,
                          width: 240,
                          height: 240,
                          color: Colors.white.withOpacity(0.5),
                          colorBlendMode: BlendMode.lighten,
                        ),
                      ),
                      // Mock blue scan line over the image
                      Container(
                        width: 200,
                        height: 2,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2962FF),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2962FF).withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Text Content
              Text(
                'Pindai Struk',
                style: AppTypography.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A202C),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Ambil foto struk fisik Anda untuk mencatat pengeluaran secara otomatis dengan akurasi tinggi.',
                  textAlign: TextAlign.center,
                  style: AppTypography.textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF4A5568),
                    height: 1.5,
                  ),
                ),
              ),
              const Spacer(),

              // Action Buttons
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  backgroundColor: const Color(0xFF0D47A1), // Deep Blue
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Text('Buka Kamera', style: AppTypography.textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  backgroundColor: const Color(0xFFE2E8F0), // Light grey
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.photo_library_outlined, color: Color(0xFF0D47A1), size: 20),
                    const SizedBox(width: 12),
                    Text('Unggah dari Galeri', style: AppTypography.textTheme.labelLarge?.copyWith(color: const Color(0xFF0D47A1), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
