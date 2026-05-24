// ============================================================
// FEATURE: Transactions — Scan Receipt Intro Page
// lib/features/transactions/presentation/pages/scan_receipt_intro_page.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/scan_usage_limiter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/app_router.dart';
import '../bloc/transaction_bloc.dart';

class ScanReceiptIntroPage extends StatelessWidget {
  const ScanReceiptIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TransactionBloc>(),
      child: const _ScanReceiptView(),
    );
  }
}

class _ScanReceiptView extends StatelessWidget {
  const _ScanReceiptView();

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final limiter = sl<ScanUsageLimiter>();
    final status = limiter.status();
    if (!status.canScan) {
      _showPremiumSheet(context, status);
      return;
    }

    final bloc = context.read<TransactionBloc>();
    final picker = ImagePicker();
    final photo = await picker.pickImage(source: source);
    
    if (photo != null) {
      await limiter.recordScan();
      bloc.add(TransactionScanRequested(photo));
    }
  }

  void _showPremiumSheet(BuildContext context, ScanUsageStatus status) {
    final seconds = status.retryAfter.inSeconds.clamp(1, 60);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 40,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Limit Scan Tercapai',
                style: AppTypography.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Anda bisa scan maksimal 5x dalam 1 menit. Tunggu $seconds detik atau upgrade Premium untuk scan tanpa batas.',
                textAlign: TextAlign.center,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await sl<ScanUsageLimiter>().setPremium(true);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Premium aktif. Scan tanpa batas sudah terbuka.'),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.lock_open_rounded),
                  label: const Text('Upgrade Premium'),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Nanti Saja'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionScanSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Struk berhasil diproses dan disimpan!'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
          context.pop(); // Kembali ke home/sebelumnya
        } else if (state is TransactionError) {
          final photoPath = state.photoPath;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
              duration: const Duration(seconds: 8),
              action: photoPath != null
                  ? SnackBarAction(
                      label: 'Input Manual',
                      textColor: Colors.white,
                      onPressed: () {
                        context.push('${AppRoutes.addTransaction}?imagePath=${Uri.encodeComponent(photoPath)}');
                      },
                    )
                  : null,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is TransactionLoading;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.close_rounded, color: Theme.of(context).colorScheme.onSurface),
              onPressed: () => context.pop(),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Stack(
            children: [
              SafeArea(
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
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest, // Light blue-grey background
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
                                  color: Theme.of(context).colorScheme.primary,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
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
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Ambil foto struk fisik Anda untuk mencatat pengeluaran secara otomatis menggunakan AI.',
                          textAlign: TextAlign.center,
                          style: AppTypography.textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const Spacer(),

                      // Action Buttons
                      ElevatedButton(
                        onPressed: isLoading ? null : () => _pickImage(context, ImageSource.camera),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          backgroundColor: Theme.of(context).colorScheme.primary, // Deep Blue
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
                        onPressed: isLoading ? null : () => _pickImage(context, ImageSource.gallery),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          backgroundColor: Theme.of(context).colorScheme.outlineVariant, // Light grey
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.photo_library_outlined, color: Theme.of(context).colorScheme.primary, size: 20),
                            const SizedBox(width: 12),
                            Text('Unggah dari Galeri', style: AppTypography.textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                context.push(AppRoutes.addTransaction);
                              },
                        child: Text(
                          'Input Struk Manual',
                          style: AppTypography.textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
              
              // Loading Overlay
              if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.4),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
                          const SizedBox(height: 16),
                          Text(
                            'AI sedang membaca struk...',
                            style: AppTypography.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}