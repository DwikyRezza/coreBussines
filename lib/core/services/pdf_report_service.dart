// ============================================================
// CORE: Services — PDF Report Service
// lib/core/services/pdf_report_service.dart
// ============================================================

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../features/home/domain/entities/home_entities.dart';

/// Generates and previews / shares PDF documents.
class PdfReportService {
  PdfReportService._();

  static final _currency =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  // ─── Monthly Analytics Report ─────────────────────────────

  /// Builds a full monthly report PDF and opens the system
  /// print / share dialog so the user can save or share it.
  static Future<void> generateMonthlyReport({
    required List<Transaction> transactions,
    required DateTime month,
  }) async {
    final doc = pw.Document(
      title:
          'Laporan Bulanan — ${DateFormat('MMMM yyyy', 'id_ID').format(month)}',
      author: 'CoreBusiness',
    );

    final monthLabel = DateFormat('MMMM yyyy', 'id_ID').format(month);

    // Filter transactions for the selected month
    final monthlyTxns = transactions
        .where((t) =>
            t.dateTime.year == month.year && t.dateTime.month == month.month)
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    final totalIncome = monthlyTxns
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpense = monthlyTxns
        .where((t) => !t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
    final balance = totalIncome - totalExpense;

    // Category breakdown
    final expenseByCategory = <String, double>{};
    for (final t in monthlyTxns.where((t) => !t.isIncome)) {
      expenseByCategory.update(t.category, (v) => v + t.amount,
          ifAbsent: () => t.amount);
    }
    final sortedCategories = expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(monthLabel),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          // Summary cards
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _summaryBox('Pemasukan', _currency.format(totalIncome),
                  PdfColors.blue800),
              pw.SizedBox(width: 16),
              _summaryBox('Pengeluaran', _currency.format(totalExpense),
                  PdfColors.red800),
              pw.SizedBox(width: 16),
              _summaryBox(
                'Saldo Bersih',
                _currency.format(balance),
                balance >= 0 ? PdfColors.green800 : PdfColors.red800,
              ),
            ],
          ),
          pw.SizedBox(height: 24),

          // Category breakdown
          if (sortedCategories.isNotEmpty) ...[
            pw.Text('Breakdown Pengeluaran per Kategori',
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 12),
            pw.Table.fromTextArray(
              headerStyle:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
              cellStyle: const pw.TextStyle(fontSize: 10),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blue50),
              cellAlignment: pw.Alignment.centerLeft,
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(1),
              },
              headers: ['Kategori', 'Jumlah', '%'],
              data: sortedCategories.map((entry) {
                final pct = totalExpense > 0
                    ? ((entry.value / totalExpense) * 100).toStringAsFixed(1)
                    : '0';
                return [
                  entry.key,
                  _currency.format(entry.value),
                  '$pct%',
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 24),
          ],

          // Transaction list
          pw.Text('Rincian Transaksi',
              style:
                  pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),
          if (monthlyTxns.isEmpty)
            pw.Text('Tidak ada transaksi di bulan ini.',
                style: const pw.TextStyle(fontSize: 10))
          else
            pw.Table.fromTextArray(
              headerStyle:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
              cellStyle: const pw.TextStyle(fontSize: 9),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blue50),
              cellAlignment: pw.Alignment.centerLeft,
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(3),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(1.5),
                4: const pw.FlexColumnWidth(2),
              },
              headers: ['Tanggal', 'Keterangan', 'Kategori', 'Tipe', 'Jumlah'],
              data: monthlyTxns.map((t) {
                return [
                  DateFormat('dd MMM', 'id_ID').format(t.dateTime),
                  t.title,
                  t.category,
                  t.isIncome ? 'Masuk' : 'Keluar',
                  _currency.format(t.amount),
                ];
              }).toList(),
            ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) => doc.save(),
      name: 'Laporan_$monthLabel.pdf',
    );
  }

  // ─── Invoice PDF ──────────────────────────────────────────

  /// Builds a styled invoice PDF and opens the print/share dialog.
  static Future<void> generateInvoicePdf({
    required String invoiceNumber,
    required String companyName,
    required String companyAddress,
    required String clientName,
    required String clientEmail,
    required String date,
    required List<Map<String, String>> lineItems,
    required String subtotal,
    required String tax,
    required String total,
    required String status,
  }) async {
    final doc = pw.Document(
      title: 'Invoice $invoiceNumber',
      author: companyName,
    );

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(companyName,
                          style: pw.TextStyle(
                              fontSize: 22,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue900)),
                      pw.SizedBox(height: 8),
                      pw.Text(companyAddress,
                          style: const pw.TextStyle(
                              fontSize: 10, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('INVOICE',
                          style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 1.5)),
                      pw.SizedBox(height: 4),
                      pw.Text(invoiceNumber,
                          style: const pw.TextStyle(
                              fontSize: 10, color: PdfColors.grey700)),
                      pw.SizedBox(height: 4),
                      pw.Text(date,
                          style: const pw.TextStyle(
                              fontSize: 10, color: PdfColors.grey700)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 32),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 24),

              // Billed to
              pw.Text('DITAGIHKAN KEPADA',
                  style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey600,
                      letterSpacing: 1)),
              pw.SizedBox(height: 8),
              pw.Text(clientName,
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text(clientEmail,
                  style: const pw.TextStyle(
                      fontSize: 10, color: PdfColors.grey700)),
              pw.SizedBox(height: 32),

              // Total box
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(24),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    pw.Text('Total Pembayaran',
                        style: const pw.TextStyle(
                            fontSize: 10, color: PdfColors.grey700)),
                    pw.SizedBox(height: 8),
                    pw.Text(total,
                        style: pw.TextStyle(
                            fontSize: 28,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue900)),
                    pw.SizedBox(height: 8),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.green50,
                        borderRadius: pw.BorderRadius.circular(12),
                      ),
                      child: pw.Text(status,
                          style: pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.green800,
                              fontWeight: pw.FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 32),

              // Line items
              pw.Table.fromTextArray(
                headerStyle:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                cellStyle: const pw.TextStyle(fontSize: 10),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.grey100),
                cellAlignment: pw.Alignment.centerLeft,
                columnWidths: {
                  0: const pw.FlexColumnWidth(4),
                  1: const pw.FlexColumnWidth(2),
                },
                headers: ['Deskripsi', 'Jumlah'],
                data: lineItems
                    .map((item) => [
                          '${item['title']}\n${item['subtitle'] ?? ''}',
                          item['amount'] ?? '',
                        ])
                    .toList(),
              ),
              pw.SizedBox(height: 24),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 16),

              // Totals
              _invoiceTotalRow('Subtotal', subtotal),
              pw.SizedBox(height: 8),
              _invoiceTotalRow('Pajak', tax),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total Keseluruhan',
                      style: pw.TextStyle(
                          fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  pw.Text(total,
                      style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900)),
                ],
              ),
              pw.Spacer(),

              // Footer
              pw.Center(
                child: pw.Text(
                  'Dokumen ini dibuat secara otomatis oleh CoreBusiness.',
                  style:
                      const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) => doc.save(),
      name: 'Invoice_$invoiceNumber.pdf',
    );
  }

  // ─── Private Helpers ──────────────────────────────────────

  static pw.Widget _buildHeader(String monthLabel) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('CoreBusiness',
                style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900)),
            pw.Text('Laporan Keuangan Bulanan',
                style:
                    const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Text('Periode: $monthLabel',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        pw.Divider(color: PdfColors.blue900, thickness: 2),
        pw.SizedBox(height: 16),
      ],
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Dibuat oleh CoreBusiness — ${DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
            ),
            pw.Text(
              'Halaman ${context.pageNumber} dari ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Expanded _summaryBox(String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label,
                style:
                    const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
            pw.SizedBox(height: 4),
            pw.Text(value,
                style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: color)),
          ],
        ),
      ),
    );
  }

  static pw.Widget _invoiceTotalRow(String label, String amount) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        pw.Text(amount,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
      ],
    );
  }
}
