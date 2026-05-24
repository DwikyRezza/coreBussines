// ============================================================
// FEATURE: Settings — Category Management Page
// lib/features/settings/presentation/pages/category_management_page.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart' hide State;
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/core_app_bar.dart';
import '../../../../core/error/failures.dart';
import '../../../transactions/domain/entities/transaction_entities.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../../../core/services/business_context_service.dart';

class CategoryManagementPage extends StatefulWidget {
  const CategoryManagementPage({super.key});

  @override
  State<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage>
    with SingleTickerProviderStateMixin {
  final _repository = sl<TransactionRepository>();
  final _contextService = sl<BusinessContextService>();

  late TabController _tabController;
  BusinessContext? _businessContext;
  bool _loadingContext = true;

  final Map<String, IconData> _iconList = {
    'food': Icons.restaurant_rounded,
    'transport': Icons.directions_car_rounded,
    'shopping': Icons.shopping_bag_rounded,
    'entertainment': Icons.movie_rounded,
    'bill': Icons.receipt_long_rounded,
    'health': Icons.local_hospital_rounded,
    'education': Icons.school_rounded,
    'income': Icons.attach_money_rounded,
    'freelance': Icons.work_rounded,
    'investment': Icons.trending_up_rounded,
    'bonus': Icons.card_giftcard_rounded,
    'other': Icons.more_horiz_rounded,
    'business': Icons.business_rounded,
    'travel': Icons.flight_rounded,
    'fitness': Icons.fitness_center_rounded,
    'home': Icons.home_rounded,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadContext();
  }

  Future<void> _loadContext() async {
    try {
      final ctx = await _contextService.getCurrentContext();
      setState(() {
        _businessContext = ctx;
        _loadingContext = false;
      });
    } catch (_) {
      setState(() {
        _loadingContext = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddCategoryDialog(BuildContext context) {
    if (_businessContext == null || !_businessContext!.isOwner) return;

    final nameController = TextEditingController();
    String selectedIconKey = _iconList.keys.first;
    bool isIncome = _tabController.index == 1;

    showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Tambah Kategori Baru',
            style: AppTypography.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Kategori',
                    hintText: 'Masukkan nama kategori...',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                Text(
                  'Tipe Transaksi',
                  style: AppTypography.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Pengeluaran')),
                        selected: !isIncome,
                        onSelected: (selected) {
                          if (selected) setStateDialog(() => isIncome = false);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Pemasukan')),
                        selected: isIncome,
                        onSelected: (selected) {
                          if (selected) setStateDialog(() => isIncome = true);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Pilih Ikon Kategori',
                  style: AppTypography.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  width: double.maxFinite,
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: _iconList.length,
                    itemBuilder: (context, idx) {
                      final key = _iconList.keys.elementAt(idx);
                      final icon = _iconList[key]!;
                      final isSelected = key == selectedIconKey;
                      return InkWell(
                        onTap: () =>
                            setStateDialog(() => selectedIconKey = key),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            icon,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;

                Navigator.pop(context);
                final res = await _repository.addCategory(
                  TransactionCategory(
                    id: '',
                    name: name,
                    iconKey: selectedIconKey,
                    isIncome: isIncome,
                  ),
                );

                if (!context.mounted) return;
                res.fold(
                  (failure) => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Gagal menambah kategori: ${failure.message}'),
                        backgroundColor: Theme.of(context).colorScheme.error),
                  ),
                  (_) => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Kategori berhasil ditambahkan!')),
                  ),
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteCategory(
      BuildContext context, TransactionCategory category) {
    if (_businessContext == null || !_businessContext!.isOwner) return;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kategori?'),
        content: Text(
            'Apakah Anda yakin ingin menghapus kategori "${category.name}"? Transaksi lama dengan kategori ini tidak akan terhapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.pop(context);
              final res = await _repository.deleteCategory(category.id);
              if (!context.mounted) return;
              res.fold(
                (failure) => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('Gagal menghapus kategori: ${failure.message}'),
                      backgroundColor: Theme.of(context).colorScheme.error),
                ),
                (_) => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Kategori berhasil dihapus.')),
                ),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingContext) {
      return const Scaffold(
        appBar: CoreAppBar(),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isOwner = _businessContext?.isOwner ?? false;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CoreAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Kategori Transaksi',
                  style: AppTypography.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Atur kategori transaksi kustom untuk bisnis Anda di sini.',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                if (!isOwner) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.errorContainer.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            color: colors.error, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Hanya Pemilik Bisnis (Owner) yang dapat menambah atau menghapus kategori.',
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: colors.onErrorContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: const [
                    Tab(text: 'Pengeluaran'),
                    Tab(text: 'Pemasukan'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<Either<Failure, List<TransactionCategory>>>(
              stream: _repository.watchCategories(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Terjadi kesalahan: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return snapshot.data!.fold(
                  (failure) => Center(
                      child: Text('Gagal memuat kategori: ${failure.message}')),
                  (categories) {
                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _buildCategoryTabList(
                          categories.where((c) => !c.isIncome).toList(),
                          isOwner,
                        ),
                        _buildCategoryTabList(
                          categories.where((c) => c.isIncome).toList(),
                          isOwner,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: isOwner
          ? FloatingActionButton.extended(
              onPressed: () => _showAddCategoryDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Kategori Baru'),
            )
          : null,
    );
  }

  Widget _buildCategoryTabList(
      List<TransactionCategory> categories, bool isOwner) {
    if (categories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.category_outlined,
                  size: 64, color: Theme.of(context).colorScheme.outline),
              const SizedBox(height: 16),
              Text(
                'Belum ada kategori',
                style: AppTypography.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Kategori baru akan muncul di sini setelah ditambahkan.',
                textAlign: TextAlign.center,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.pagePadding, AppSpacing.md, AppSpacing.pagePadding, 100),
      itemCount: categories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final cat = categories[index];
        final icon = _iconList[cat.iconKey] ?? Icons.category_rounded;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cat.name,
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cat.isIncome ? 'Pemasukan' : 'Pengeluaran',
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isOwner)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Colors.red),
                  onPressed: () => _confirmDeleteCategory(context, cat),
                ),
            ],
          ),
        );
      },
    );
  }
}
