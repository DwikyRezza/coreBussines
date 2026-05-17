// ============================================================
// FEATURE: Analytics — Report Export Page
// lib/features/analytics/presentation/pages/report_export_page.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class ReportExportPage extends StatefulWidget {
  const ReportExportPage({super.key});

  @override
  State<ReportExportPage> createState() => _ReportExportPageState();
}

class _ReportExportPageState extends State<ReportExportPage> {
  int _selectedFormat = 0; // 0 for PDF, 1 for Excel

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Light background matching screenshot
      appBar: AppBar(
        leading: TextButton.icon(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF4A5568), size: 20),
          label: Text('Kembali', style: AppTypography.textTheme.labelMedium?.copyWith(color: const Color(0xFF4A5568))),
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
                color: const Color(0xFF1A202C),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Atur parameter di bawah ini untuk mengunduh rekap aktivitas latihan dan metrik kesehatan Anda.',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF4A5568),
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Rentang Waktu
            Text('Rentang Waktu', style: AppTypography.textTheme.titleMedium?.copyWith(color: const Color(0xFF4A5568))),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_outlined, color: Color(0xFF0D47A1), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '1 Mei - 31 Mei 2024',
                      style: AppTypography.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Color(0xFF4A5568)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Format Dokumen
            Text('Format Dokumen', style: AppTypography.textTheme.titleMedium?.copyWith(color: const Color(0xFF4A5568))),
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
                          color: _selectedFormat == 0 ? const Color(0xFF0D47A1) : const Color(0xFFE2E8F0),
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
                              child: const Icon(Icons.check_circle, color: Color(0xFF0D47A1), size: 20),
                            ),
                          Column(
                            children: [
                              Icon(Icons.picture_as_pdf_rounded, color: _selectedFormat == 0 ? const Color(0xFF0D47A1) : const Color(0xFF4A5568), size: 36),
                              const SizedBox(height: 12),
                              Text('PDF', style: AppTypography.textTheme.labelLarge?.copyWith(color: _selectedFormat == 0 ? const Color(0xFF0D47A1) : const Color(0xFF4A5568), fontWeight: FontWeight.w600)),
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
                          color: _selectedFormat == 1 ? const Color(0xFF0D47A1) : const Color(0xFFE2E8F0),
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
                              child: const Icon(Icons.check_circle, color: Color(0xFF0D47A1), size: 20),
                            ),
                          Column(
                            children: [
                              Icon(Icons.table_chart_rounded, color: _selectedFormat == 1 ? const Color(0xFF0D47A1) : const Color(0xFF4A5568), size: 36),
                              const SizedBox(height: 12),
                              Text('Excel', style: AppTypography.textTheme.labelLarge?.copyWith(color: _selectedFormat == 1 ? const Color(0xFF0D47A1) : const Color(0xFF4A5568), fontWeight: FontWeight.w600)),
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
                Text('Pratinjau Layout', style: AppTypography.textTheme.titleMedium?.copyWith(color: const Color(0xFF4A5568))),
                Text('Perbesar', style: AppTypography.textTheme.labelMedium?.copyWith(color: const Color(0xFF0D47A1))),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0), // Grey background
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
                            Container(width: 80, height: 10, decoration: BoxDecoration(color: const Color(0xFFA0AEC0), borderRadius: BorderRadius.circular(4))),
                            Container(width: 40, height: 10, decoration: BoxDecoration(color: const Color(0xFFA0AEC0), borderRadius: BorderRadius.circular(4))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(width: 60, height: 6, decoration: BoxDecoration(color: const Color(0xFFCBD5E0), borderRadius: BorderRadius.circular(4))),
                        const SizedBox(height: 16),
                        const Divider(color: Color(0xFFE2E8F0)),
                        const SizedBox(height: 16),
                        // Mock Cards
                        Row(
                          children: [
                            Expanded(child: Container(height: 30, decoration: BoxDecoration(color: const Color(0xFFEDF2F7), borderRadius: BorderRadius.circular(4)))),
                            const SizedBox(width: 8),
                            Expanded(child: Container(height: 30, decoration: BoxDecoration(color: const Color(0xFFEDF2F7), borderRadius: BorderRadius.circular(4)))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Mock Chart
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7FAFC),
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
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            backgroundColor: const Color(0xFF0D47A1),
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
