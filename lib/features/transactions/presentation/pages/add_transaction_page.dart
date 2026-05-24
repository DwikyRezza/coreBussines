// ============================================================
// FEATURE: Transactions — Add Transaction Page (FUNCTIONAL)
// lib/features/transactions/presentation/pages/add_transaction_page.dart
//
// Migration from UI-only to full functional form:
// - Amount input with numeric keyboard
// - Category & wallet selection with real state
// - Form validation before submit
// - BLoC wiring with double-submit protection
// - Auto-refresh Home on success
// ============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/utils/formatters.dart';
import '../../../notifications/data/services/notification_service.dart';
import '../../../notifications/data/models/notification_model.dart';
import '../../../notifications/domain/repositories/notification_repository.dart';
import '../../domain/entities/transaction_entities.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../bloc/transaction_bloc.dart';
import 'package:dartz/dartz.dart' hide State;
import '../../../../core/error/failures.dart';



class AddTransactionPage extends StatefulWidget {
  final int initialType;
  final String? initialAmount;
  final String? initialTitle;
  final String? initialCategory;
  final String? initialNotes;
  final String? receiptImagePath;
  final bool isManualReceipt;

  const AddTransactionPage({
    super.key,
    this.initialType = 0,
    this.initialAmount,
    this.initialTitle,
    this.initialCategory,
    this.initialNotes,
    this.receiptImagePath,
    this.isManualReceipt = false,
  });

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  // Form state
  int _transactionType = 0; // 0 = Pengeluaran, 1 = Pemasukan
  int _selectedCategoryIndex = 0;
  bool _isRecurring = false;
  String? _receiptImagePath;
  DateTime _selectedDate = DateTime.now();
  String? _selectedWalletId;
  String? _selectedWalletName;

  // Controllers
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _titleController = TextEditingController();
  final _picker = ImagePicker();
  final _repository = sl<TransactionRepository>();

  bool _firstTimeCategoryLoad = true;
  List<TransactionCategory> _currentCategories = [];
  
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
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _transactionType = widget.initialType;
    _receiptImagePath = widget.receiptImagePath;

    if (widget.initialTitle != null) {
      _titleController.text = widget.initialTitle!;
    }
    if (widget.initialAmount != null) {
      final doubleAmount = double.tryParse(widget.initialAmount!);
      if (doubleAmount != null) {
        final intAmount = doubleAmount.toInt();
        _amountController.text = _formatThousands(intAmount);
      } else {
        _amountController.text = widget.initialAmount!;
      }
    }
    if (widget.initialNotes != null) {
      _notesController.text = widget.initialNotes!;
    }
  }

  String _formatThousands(int number) {
    final str = number.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  Future<void> _pickReceipt(ImageSource source) async {
    final image = await _picker.pickImage(
      source: source,
      imageQuality: 82,
      maxWidth: 1600,
    );
    if (image == null) return;
    setState(() => _receiptImagePath = image.path);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
    );
    if (picked == null) return;
    setState(() {
      _selectedDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _selectedDate.hour,
        _selectedDate.minute,
      );
    });
  }

  /// Validate and dispatch submit event to BLoC.
  void _onSave(BuildContext context) {
    final amountText = _amountController.text.replaceAll('.', '').trim();
    final title = _titleController.text.trim();

    final amount = double.tryParse(amountText);

    // Validation
    if (amountText.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal wajib angka dan lebih dari 0.')),
      );
      return;
    }
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul transaksi tidak boleh kosong.')),
      );
      return;
    }
    if (_selectedWalletId == null || _selectedWalletName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wallet wajib dipilih.')),
      );
      return;
    }
    if (_currentCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kategori belum selesai dimuat.')),
      );
      return;
    }
    if (widget.isManualReceipt && (_receiptImagePath == null || _receiptImagePath!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bukti pembayaran wajib dilampirkan untuk input manual.')),
      );
      return;
    }
    final category = _currentCategories[_selectedCategoryIndex];
    final note = _notesController.text.trim().isEmpty
        ? null
        : _notesController.text.trim();

    context.read<TransactionBloc>().add(
          TransactionSubmitRequested(
            title: title,
            amount: amount,
            isIncome: _transactionType == 1,
            category: category.name,
            categoryIcon: category.iconKey,
            walletId: _selectedWalletId!,
            walletName: _selectedWalletName!,
            dateTime: _selectedDate,
            note: note,
            receiptImagePath: _receiptImagePath,
            source: 'manual',
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TransactionBloc>(),
      child: BlocConsumer<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );

            // Pemicu Notifikasi HP Native & Riwayat Lokal
            final notifTitle = 'Transaksi Berhasil Dicatat';
            final amountText =
                _amountController.text.replaceAll('.', '').trim();
            final amount = double.tryParse(amountText) ?? 0.0;
            final isIncome = _transactionType == 1;
            final notifBody =
                'Mencatat ${isIncome ? "pemasukan" : "pengeluaran"} "${_titleController.text.trim()}" sebesar ${AppFormatter.currency(amount)} ke dompet ${_selectedWalletName ?? '-'}.';

            sl<NotificationRepository>().saveNotification(
              NotificationModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: notifTitle,
                body: notifBody,
                createdAt: DateTime.now(),
                type: 'success',
                isRead: false,
              ),
            );

            sl<NotificationService>()
                .showInstantNotification(notifTitle, notifBody);

            context.pop(); // Go back to home/history
          } else if (state is TransactionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
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
                icon: Icon(Icons.close_rounded,
                    color: Theme.of(context).colorScheme.primary),
                onPressed: () => context.pop(),
              ),
              title: Text(
                'Tambah Transaksi',
                style: AppTypography.textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              centerTitle: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
            ),
            body: ResponsiveHelper.constrainWidth(
              context: context,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.pagePadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.isManualReceipt) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer.withAlpha(76),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.primary.withAlpha(51),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.receipt_long_rounded,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Mode Input Manual',
                                          style: AppTypography.textTheme.labelLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Foto bukti pembayaran wajib dilampirkan.',
                                          style: AppTypography.textTheme.bodySmall?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                          ],
                          // ── Type Selector ────────────────────────────
                          _TypeSelector(
                            selected: _transactionType,
                            onChanged: (v) => setState(() {
                              _transactionType = v;
                              _selectedCategoryIndex = 0;
                            }),
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // ── Amount Input ─────────────────────────────
                          _AmountCard(controller: _amountController),
                          const SizedBox(height: AppSpacing.lg),

                          // ── Title Input ──────────────────────────────
                          Text(
                            'Judul Transaksi',
                            style: AppTypography.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _TextInputCard(
                            controller: _titleController,
                            hint: 'Contoh: Makan Siang, Gaji Bulan Ini...',
                            maxLines: 1,
                          ),
                          const SizedBox(height: AppSpacing.xl),

                           // ── Category ─────────────────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Kategori',
                                style: AppTypography.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              IconButton(
                                icon: const Icon(Icons.settings_outlined),
                                tooltip: 'Kelola Kategori',
                                onPressed: () => context.push(AppRoutes.categoryManagement),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          StreamBuilder<Either<Failure, List<TransactionCategory>>>(
                            stream: _repository.watchCategories(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text(
                                  'Gagal memuat kategori: ${snapshot.error}',
                                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                                );
                              }
                              if (!snapshot.hasData) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              return snapshot.data!.fold(
                                (failure) => Text(
                                  'Gagal memuat kategori: ${failure.message}',
                                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                                ),
                                (allCategories) {
                                  final isCurrentIncome = _transactionType == 1;
                                  final categories = allCategories
                                      .where((c) => c.isIncome == isCurrentIncome)
                                      .toList();

                                  if (categories.isEmpty) {
                                    return const Text('Tidak ada kategori tersedia.');
                                  }

                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    if (mounted) {
                                      _currentCategories = categories;
                                      if (_selectedCategoryIndex >= categories.length) {
                                        setState(() {
                                          _selectedCategoryIndex = 0;
                                        });
                                      }
                                      if (widget.initialCategory != null && _firstTimeCategoryLoad) {
                                        final idx = categories.indexWhere(
                                          (c) => c.name.toLowerCase() == widget.initialCategory!.toLowerCase(),
                                        );
                                        if (idx != -1) {
                                          setState(() {
                                            _selectedCategoryIndex = idx;
                                          });
                                        }
                                        _firstTimeCategoryLoad = false;
                                      }
                                    }
                                  });

                                  return Wrap(
                                    spacing: 8,
                                    runSpacing: 10,
                                    children: List.generate(categories.length, (i) {
                                      final cat = categories[i];
                                      final icon = _iconList[cat.iconKey] ?? Icons.category_rounded;
                                      return _CategoryChip(
                                        icon: icon,
                                        label: cat.name,
                                        isSelected: _selectedCategoryIndex == i,
                                        onTap: () => setState(() => _selectedCategoryIndex = i),
                                      );
                                    }),
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // ── Wallet ───────────────────────────────────
                          Text(
                            'Pilih Dompet',
                            style: AppTypography.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          StreamBuilder(
                            stream: _repository.watchWalletOptions(),
                            builder: (context, snapshot) {
                              final walletResult = snapshot.data;
                              final wallets = walletResult?.fold(
                                    (failure) => <WalletOption>[],
                                    (items) => items,
                                  ) ??
                                  const <WalletOption>[];

                              if (wallets.isNotEmpty &&
                                  _selectedWalletId == null) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  if (!mounted || _selectedWalletId != null)
                                    return;
                                  setState(() {
                                    _selectedWalletId = wallets.first.id;
                                    _selectedWalletName = wallets.first.name;
                                  });
                                });
                              }

                              if (walletResult != null &&
                                  walletResult.isLeft()) {
                                return Text(
                                  'Gagal memuat wallet. Coba buka ulang halaman.',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                );
                              }

                              if (wallets.isEmpty) {
                                return const _EmptyWalletNotice();
                              }

                              return Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: wallets.map((wallet) {
                                  return SizedBox(
                                    width: 112,
                                    child: _WalletCard(
                                      icon: _walletIcon(wallet.type),
                                      label: wallet.name,
                                      isSelected:
                                          _selectedWalletId == wallet.id,
                                      onTap: () => setState(() {
                                        _selectedWalletId = wallet.id;
                                        _selectedWalletName = wallet.name;
                                      }),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          Text(
                            'Tanggal Transaksi',
                            style: AppTypography.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: _pickDate,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month_rounded,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      AppFormatter.fullDate(_selectedDate),
                                      style: AppTypography.textTheme.bodyLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // ── Notes ────────────────────────────────────
                          Text(
                            'Catatan (Opsional)',
                            style: AppTypography.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _TextInputCard(
                            controller: _notesController,
                            hint: 'Tambahkan deskripsi transaksi di sini...',
                            maxLines: 4,
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // ── Attachment Card ─────────────────────────
                          _ReceiptPickerCard(
                            imagePath: _receiptImagePath,
                            onCamera: () => _pickReceipt(ImageSource.camera),
                            onGallery: () => _pickReceipt(ImageSource.gallery),
                            onRemove: () =>
                                setState(() => _receiptImagePath = null),
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // ── Recurring Toggle ─────────────────────────
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer
                                  .withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.restore_rounded,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Transaksi Berulang',
                                        style: AppTypography
                                            .textTheme.labelLarge
                                            ?.copyWith(
                                                fontWeight: FontWeight.w700),
                                      ),
                                      Text(
                                        'Setel sebagai pengeluaran bulanan',
                                        style: AppTypography.textTheme.bodySmall
                                            ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch.adaptive(
                                  value: _isRecurring,
                                  onChanged: (val) =>
                                      setState(() => _isRecurring = val),
                                  activeColor:
                                      Theme.of(context).colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                        ],
                      ),
                    ),
                  ),

                  // ── Submit Button ─────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.pagePadding),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .shadow
                              .withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () => _onSave(context),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Simpan Transaksi',
                                style: AppTypography.textTheme.labelLarge
                                    ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Sub-Widgets ───────────────────────────────────────────────

class _TypeSelector extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  const _TypeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: ['Pengeluaran', 'Pemasukan'].asMap().entries.map((e) {
          final isActive = selected == e.key;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isActive
                      ? Theme.of(context).colorScheme.surface
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: Text(
                  e.value,
                  style: AppTypography.textTheme.labelLarge?.copyWith(
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AmountCard extends StatelessWidget {
  final TextEditingController controller;
  const _AmountCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Jumlah Transaksi',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Rp ',
                style: AppTypography.textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Flexible(
                child: IntrinsicWidth(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _ThousandsSeparatorInputFormatter(),
                    ],
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.displaySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: AppTypography.textTheme.displaySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        fontWeight: FontWeight.w700,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TextInputCard extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  const _TextInputCard({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTypography.textTheme.bodyMedium
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _walletIcon(String type) {
  switch (type.toLowerCase()) {
    case 'bank':
      return Icons.account_balance_rounded;
    case 'ewallet':
    case 'e-wallet':
      return Icons.account_balance_wallet_rounded;
    case 'cash':
    default:
      return Icons.payments_rounded;
  }
}

class _EmptyWalletNotice extends StatelessWidget {
  const _EmptyWalletNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .errorContainer
            .withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'Belum ada wallet yang bisa dipilih.',
        style: AppTypography.textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.error,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ReceiptPickerCard extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onRemove;

  const _ReceiptPickerCard({
    required this.imagePath,
    required this.onCamera,
    required this.onGallery,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bukti Pembayaran',
          style: AppTypography.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: imagePath == null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Foto struk wajib dilampirkan.',
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onCamera,
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: const Text('Kamera'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onGallery,
                            icon: const Icon(Icons.photo_library_outlined),
                            label: const Text('Galeri'),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(imagePath!),
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 56,
                            height: 56,
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            child: Icon(
                              Icons.receipt_long,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            imagePath!.split(RegExp(r'[/\\]')).last,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.textTheme.labelMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'Struk siap diunggah',
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      onPressed: onRemove,
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _WalletCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _WalletCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Formats numbers with thousands separator as the user types.
/// e.g. 1500000 → 1.500.000
class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final number = int.tryParse(newValue.text.replaceAll('.', ''));
    if (number == null) return oldValue;
    final formatted = _format(number);
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _format(int number) {
    final str = number.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}
