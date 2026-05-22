// ============================================================
// FEATURE: Analytics — Report Export Page
// lib/features/analytics/presentation/pages/report_export_page.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/pdf_report_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../home/domain/entities/home_entities.dart';
import '../../../transactions/domain/entities/transaction_entities.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';

class ReportExportPage extends StatefulWidget {
  const ReportExportPage({super.key});

  @override
  State<ReportExportPage> createState() => _ReportExportPageState();
}

class _ReportExportPageState extends State<ReportExportPage> {
  int _selectedFormat = 0; // 0 for PDF, 1 for Excel
  final _repository = sl<TransactionRepository>();
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  String? _error;
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _repository.getFilteredTransactions(
      const TransactionFilter(dateRange: DateRangeFilter.custom),
    );

    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _error = failure.message;
        _isLoading = false;
      }),
      (transactions) => setState(() {
        _transactions = transactions;
        _isLoading = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Light background matching screenshot
      appBar: AppBar(
        leading: TextButton.icon(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
          label: Text('Kembali', style: AppTypography.textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ),
        leadingWidth: 100,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Ekspor Laporan',
              style: AppTypography.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Atur parameter di bawah ini untuk mengunduh rekap aktivitas latihan dan metrik kesehatan Anda.',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Rentang Waktu
            Text('Rentang Waktu', style: AppTypography.textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_month_outlined, color: Theme.of(context).colorScheme.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '1 Mei - 31 Mei 2024',
                      style: AppTypography.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Format Dokumen
            Text('Format Dokumen', style: AppTypography.textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFormat = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedFormat == 0 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
                          width: _selectedFormat == 0 ? 2 : 1,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_selectedFormat == 0)
                            Positioned(
                              top: -12,
                              right: 8,
                              child: Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: 20),
                            ),
                          Column(
                            children: [
                              Icon(Icons.picture_as_pdf_rounded, color: _selectedFormat == 0 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant, size: 36),
                              const SizedBox(height: 12),
                              Text('PDF', style: AppTypography.textTheme.labelLarge?.copyWith(color: _selectedFormat == 0 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFormat = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedFormat == 1 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
                          width: _selectedFormat == 1 ? 2 : 1,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_selectedFormat == 1)
                            Positioned(
                              top: -12,
                              right: 8,
                              child: Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: 20),
                            ),
                          Column(
                            children: [
                              Icon(Icons.table_chart_rounded, color: _selectedFormat == 1 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant, size: 36),
                              const SizedBox(height: 12),
                              Text('Excel', style: AppTypography.textTheme.labelLarge?.copyWith(color: _selectedFormat == 1 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Pratinjau Layout
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Pratinjau Layout', style: AppTypography.textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                Text('Perbesar', style: AppTypography.textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant, // Grey background
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Mock paper
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 180,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mock header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(width: 80, height: 10, decoration: BoxDecoration(color: Theme.of(context).colorScheme.outline, borderRadius: BorderRadius.circular(4))),
                            Container(width: 40, height: 10, decoration: BoxDecoration(color: Theme.of(context).colorScheme.outline, borderRadius: BorderRadius.circular(4))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(width: 60, height: 6, decoration: BoxDecoration(color: Theme.of(context).colorScheme.outlineVariant, borderRadius: BorderRadius.circular(4))),
                        const SizedBox(height: 16),
                        Divider(color: Theme.of(context).colorScheme.outlineVariant),
                        const SizedBox(height: 16),
                        // Mock Cards
                        Row(
                          children: [
                            Expanded(child: Container(height: 30, decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(4)))),
                            const SizedBox(width: 8),
                            Expanded(child: Container(height: 30, decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(4)))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Mock Chart
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(width: 20, height: 20, color: const Color(0xFF4299E1)),
                                Container(width: 20, height: 40, color: const Color(0xFF3182CE)),
                                Container(width: 20, height: 70, color: const Color(0xFF2B6CB0)),
                                Container(width: 20, height: 30, color: const Color(0xFF4299E1)),
                                Container(width: 20, height: 60, color: const Color(0xFF3182CE)),
                              ],
                            ),
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
        child: ElevatedButton(
          onPressed: () async {
            if (_selectedFormat == 1) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ekspor ke Excel sedang dikembangkan. Gunakan PDF untuk saat ini.'),
                  duration: Duration(seconds: 2),
                ),
              );
              return;
            }

            if (_isLoading) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sedang memuat data transaksi...')),
              );
              return;
            }

            try {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Laporan PDF sedang disiapkan...'),
                  duration: Duration(seconds: 2),
                ),
              );

              await PdfReportService.generateMonthlyReport(
                transactions: _transactions,
                month: _selectedMonth,
              );
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Gagal membuat laporan PDF. Silakan periksa izin penyimpanan atau coba lagi nanti.',
                  ),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            backgroundColor: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            elevation: 4,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.download_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('Unduh Laporan', style: AppTypography.textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}