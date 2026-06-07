// ============================================================
// FEATURE: Transactions — Invoice Detail Page
// lib/features/transactions/presentation/pages/invoice_detail_page.dart
// ============================================================

import 'package:flutter/material.dart';
import '../../../../core/services/pdf_report_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/core_app_bar.dart';

class InvoiceDetailPage extends StatelessWidget {
  const InvoiceDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CoreAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.md),
            Text(
              'Detail Tagihan',
              style: AppTypography.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Tinjau informasi tagihan Anda di bawah ini.',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Invoice Paper Mock
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top blue edge
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary, // Deep Blue
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(8)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CoreBusiness',
                                  style: AppTypography.textTheme.headlineSmall
                                      ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Jl. Sudirman Kav. 50\nJakarta Selatan, 12190',
                                  style: AppTypography.textTheme.bodySmall
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'INVOICE',
                                  style: AppTypography.textTheme.titleMedium
                                      ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '#INV-2023-1042',
                                  style: AppTypography.textTheme.bodySmall
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '24 Okt 2023',
                                  style: AppTypography.textTheme.bodySmall
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Divider(
                            color:
                                Theme.of(context).colorScheme.outlineVariant),
                        const SizedBox(height: 24),

                        // Billed To
                        Text(
                          'DITAGIHKAN KEPADA',
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                              letterSpacing: 1.0),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Budi Santoso',
                          style: AppTypography.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'budi.santoso@example.com',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                        ),
                        const SizedBox(height: 32),

                        // Highlight Box
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest, // Very light blue
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Total Pembayaran',
                                  style: AppTypography.textTheme.bodyMedium
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant)),
                              const SizedBox(height: 8),
                              Text(
                                'Rp 3.500.000',
                                style: AppTypography.textTheme.displaySmall
                                    ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle_outline_rounded,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        size: 16),
                                    const SizedBox(width: 4),
                                    Text('Lunas',
                                        style: AppTypography
                                            .textTheme.labelMedium
                                            ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Line Items Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Deskripsi',
                                style: AppTypography.textTheme.labelMedium
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant)),
                            Text('Jumlah',
                                style: AppTypography.textTheme.labelMedium
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Divider(
                            color:
                                Theme.of(context).colorScheme.outlineVariant),
                        const SizedBox(height: 16),

                        // Line Items
                        _InvoiceLineItem(
                          title: 'Paket Personal Training Elite',
                          subtitle: '10 Sesi (Valid 30 Hari)',
                          amount: 'Rp 3.000.000',
                        ),
                        const SizedBox(height: 16),
                        _InvoiceLineItem(
                          title: 'Konsultasi Nutrisi Awal',
                          subtitle: '1 Sesi (60 Menit)',
                          amount: 'Rp 500.000',
                        ),
                        const SizedBox(height: 24),
                        Divider(
                            color:
                                Theme.of(context).colorScheme.outlineVariant),
                        const SizedBox(height: 24),

                        // Totals
                        _InvoiceTotalLine(
                            label: 'Subtotal', amount: 'Rp 3.500.000'),
                        const SizedBox(height: 12),
                        _InvoiceTotalLine(label: 'Pajak (0%)', amount: 'Rp 0'),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Keseluruhan',
                                style: AppTypography.textTheme.titleMedium
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface)),
                            Text('Rp 3.500.000',
                                style: AppTypography.textTheme.titleMedium
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Dashed Divider
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return Flex(
                              direction: Axis.horizontal,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(
                                  (constraints.constrainWidth() / 8).floor(),
                                  (index) {
                                return SizedBox(
                                  width: 4,
                                  height: 1,
                                  child: DecoratedBox(
                                      decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outlineVariant)),
                                );
                              }),
                            );
                          },
                        ),
                        const SizedBox(height: 32),

                        // QR Code Mock
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outlineVariant),
                                ),
                                child: Icon(Icons.qr_code_2_rounded,
                                    size: 48,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Pindai kode QR untuk verifikasi\nkeaslian dokumen ini.',
                                textAlign: TextAlign.center,
                                style: AppTypography.textTheme.bodySmall
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100), // Bottom padding
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Menyiapkan dokumen untuk dibagikan...'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    await PdfReportService.generateInvoicePdf(
                      invoiceNumber: '#INV-2023-1042',
                      companyName: 'CoreBusiness',
                      companyAddress:
                          'Jl. Sudirman Kav. 50\nJakarta Selatan, 12190',
                      clientName: 'Budi Santoso',
                      clientEmail: 'budi.santoso@example.com',
                      date: '24 Okt 2023',
                      lineItems: const [
                        {
                          'title': 'Paket Personal Training Elite',
                          'subtitle': '10 Sesi (Valid 30 Hari)',
                          'amount': 'Rp 3.000.000',
                        },
                        {
                          'title': 'Konsultasi Nutrisi Awal',
                          'subtitle': '1 Sesi (60 Menit)',
                          'amount': 'Rp 500.000',
                        },
                      ],
                      subtotal: 'Rp 3.500.000',
                      tax: 'Rp 0',
                      total: 'Rp 3.500.000',
                      status: 'Lunas',
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Gagal membagikan invoice. Silakan coba lagi nanti.',
                        ),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest, // Light grey blue
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.share_outlined,
                        color: Theme.of(context).colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text('Bagikan',
                        style: AppTypography.textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mengunduh dokumen PDF...'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    await PdfReportService.generateInvoicePdf(
                      invoiceNumber: '#INV-2023-1042',
                      companyName: 'CoreBusiness',
                      companyAddress:
                          'Jl. Sudirman Kav. 50\nJakarta Selatan, 12190',
                      clientName: 'Budi Santoso',
                      clientEmail: 'budi.santoso@example.com',
                      date: '24 Okt 2023',
                      lineItems: const [
                        {
                          'title': 'Paket Personal Training Elite',
                          'subtitle': '10 Sesi (Valid 30 Hari)',
                          'amount': 'Rp 3.000.000',
                        },
                        {
                          'title': 'Konsultasi Nutrisi Awal',
                          'subtitle': '1 Sesi (60 Menit)',
                          'amount': 'Rp 500.000',
                        },
                      ],
                      subtotal: 'Rp 3.500.000',
                      tax: 'Rp 0',
                      total: 'Rp 3.500.000',
                      status: 'Lunas',
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Gagal mengunduh invoice PDF. Silakan coba lagi nanti.',
                        ),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  backgroundColor:
                      Theme.of(context).colorScheme.primary, // Deep blue
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.download_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text('Unduh PDF',
                        style: AppTypography.textTheme.labelLarge?.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _InvoiceLineItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;

  const _InvoiceLineItem(
      {required this.title, required this.subtitle, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
        Text(amount,
            style: AppTypography.textTheme.bodyMedium
                ?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
      ],
    );
  }
}

class _InvoiceTotalLine extends StatelessWidget {
  final String label;
  final String amount;

  const _InvoiceTotalLine({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
        Text(amount,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }
}
