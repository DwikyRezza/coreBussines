import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class HelpFaqPage extends StatefulWidget {
  const HelpFaqPage({super.key});

  @override
  State<HelpFaqPage> createState() => _HelpFaqPageState();
}

class _HelpFaqPageState extends State<HelpFaqPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, String>> _faqs = [
    {
      'q': 'Bagaimana cara menambah transaksi?',
      'a': 'Tekan tombol + di bagian bawah, lalu pilih pemasukan atau pengeluaran.',
    },
    {
      'q': 'Bagaimana scan struk bekerja?',
      'a': 'Ambil foto struk dengan jelas. AI akan membaca nama toko, total, kategori, dan catatan barang.',
    },
    {
      'q': 'Apakah data saya tersimpan online?',
      'a': 'Ya. Data akun, dompet, dan transaksi tersinkron ke Firebase Cloud Firestore.',
    },
    {
      'q': 'Bagaimana cara keluar akun?',
      'a': 'Buka Pengaturan, lalu tekan tombol Keluar di bagian bawah halaman.',
    },
    {
      'q': 'Bagaimana cara membuat atau berpindah portofolio bisnis?',
      'a': 'Buka Pengaturan, lalu ketuk \'Portfolio Bisnis\' di bawah \'Bisnis & Tim\'. Di sana Anda dapat membuat bisnis baru atau beralih ke workspace yang sudah ada.',
    },
    {
      'q': 'Bagaimana cara mengundang anggota tim baru?',
      'a': 'Masuk ke \'Manajemen Tim\' di Pengaturan, ketuk tombol \'Undang Anggota\' di bagian bawah (hanya untuk Owner), isi email dan pilih role, lalu simpan undangan.',
    },
    {
      'q': 'Apa perbedaan peran/role Owner, Admin, dan Cashier?',
      'a': 'Owner memiliki akses penuh untuk mengatur bisnis, wallet, kategori, dan tim. Admin dapat mencatat transaksi, melihat wallet, dan mengelola inventaris/katalog. Cashier hanya dapat mencatat transaksi miliknya sendiri dan memiliki akses terbatas ke dashboard.',
    },
    {
      'q': 'Bagaimana cara mengatur izin khusus role Manager?',
      'a': 'Buka Pengaturan, lalu pilih \'Akses Manager\'. Di sana Anda dapat mengaktifkan atau menonaktifkan izin granular seperti User Management, System Config, dan Refund Approval.',
    },
    {
      'q': 'Mengapa saya tidak bisa menghapus kategori transaksi?',
      'a': 'Hanya pemilik bisnis (Owner) yang memiliki izin untuk menambah atau menghapus kategori transaksi demi menjaga konsistensi laporan keuangan tim.',
    },
    {
      'q': 'Bagaimana cara mengubah PIN keamanan aplikasi?',
      'a': 'Masuk ke Pengaturan > Keamanan, lalu pilih opsi untuk mengubah atau mereset PIN keamanan Anda.',
    },
    {
      'q': 'Apakah aplikasi dapat digunakan secara offline?',
      'a': 'Aplikasi mendukung penyimpanan lokal sementara (offline cache) melalui Firestore. Ketika koneksi internet terhubung kembali, data akan otomatis disinkronkan ke cloud.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final filteredFaqs = _faqs.where((faq) {
      final q = faq['q']!.toLowerCase();
      final a = faq['a']!.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return q.contains(query) || a.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Bantuan & FAQ')),
      body: Column(
        children: [
          // Search Box
          Padding(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari solusi atau ketik masalah Anda...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: colors.surface,
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
          ),
          // FAQ List
          Expanded(
            child: filteredFaqs.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded,
                              size: 64, color: colors.outline),
                          const SizedBox(height: 16),
                          const Text(
                            'Solusi tidak ditemukan',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Coba ketik kata kunci yang berbeda atau hubungi admin.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.pagePadding),
                    itemCount: filteredFaqs.length,
                    itemBuilder: (context, index) {
                      final faq = filteredFaqs[index];
                      return _FaqItem(
                        question: faq['q']!,
                        answer: faq['a']!,
                      );
                    },
                  ),
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
          style: AppTypography.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
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
