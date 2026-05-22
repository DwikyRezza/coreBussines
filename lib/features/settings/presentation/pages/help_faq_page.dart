import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class HelpFaqPage extends StatelessWidget {
  const HelpFaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Bantuan & FAQ')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        children: const [
          _FaqItem(
            question: 'Bagaimana cara menambah transaksi?',
            answer: 'Tekan tombol + di bagian bawah, lalu pilih pemasukan atau pengeluaran.',
          ),
          _FaqItem(
            question: 'Bagaimana scan struk bekerja?',
            answer: 'Ambil foto struk dengan jelas. AI akan membaca nama toko, total, kategori, dan catatan barang.',
          ),
          _FaqItem(
            question: 'Apakah data saya tersimpan online?',
            answer: 'Ya. Data akun, dompet, dan transaksi tersinkron ke Firebase Cloud Firestore.',
          ),
          _FaqItem(
            question: 'Bagaimana cara keluar akun?',
            answer: 'Buka Pengaturan, lalu tekan tombol Keluar di bagian bawah halaman.',
          ),
        ],
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(
          question,
          style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              answer,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
