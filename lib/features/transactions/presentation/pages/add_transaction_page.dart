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
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/utils/formatters.dart';
import '../../../notifications/data/models/notification_model.dart';
import '../../../notifications/data/datasources/notification_local_datasource.dart';
import '../../../notifications/data/services/notification_service.dart';
import '../bloc/transaction_bloc.dart';

// ─── Category model for the category picker ──────────────────
class _Category {
  final String label;
  final String iconKey;
  final IconData icon;
  const _Category({
    required this.label,
    required this.iconKey,
    required this.icon,
  });
}

const _expenseCategories = [
  _Category(label: 'Makanan', iconKey: 'food', icon: Icons.restaurant),
  _Category(label: 'Transportasi', iconKey: 'transport', icon: Icons.directions_car),
  _Category(label: 'Belanja', iconKey: 'shopping', icon: Icons.shopping_bag),
  _Category(label: 'Hiburan', iconKey: 'entertainment', icon: Icons.movie),
  _Category(label: 'Tagihan', iconKey: 'bill', icon: Icons.receipt_long),
  _Category(label: 'Kesehatan', iconKey: 'health', icon: Icons.local_hospital),
  _Category(label: 'Pendidikan', iconKey: 'education', icon: Icons.school),
  _Category(label: 'Lainnya', iconKey: 'other', icon: Icons.more_horiz),
];

const _incomeCategories = [
  _Category(label: 'Gaji', iconKey: 'income', icon: Icons.attach_money),
  _Category(label: 'Freelance', iconKey: 'income', icon: Icons.work),
  _Category(label: 'Investasi', iconKey: 'income', icon: Icons.trending_up),
  _Category(label: 'Bonus', iconKey: 'income', icon: Icons.card_giftcard),
  _Category(label: 'Lainnya', iconKey: 'income', icon: Icons.more_horiz),
];

const _wallets = ['Bank', 'Tunai', 'E-Wallet'];

class AddTransactionPage extends StatefulWidget {
  final int initialType;
  final String? initialAmount;
  final String? initialTitle;
  final String? initialCategory;
  final String? initialNotes;
  final String? receiptImagePath;

  const AddTransactionPage({
    super.key,
    this.initialType = 0,
    this.initialAmount,
    this.initialTitle,
    this.initialCategory,
    this.initialNotes,
    this.receiptImagePath,
  });

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  // Form state
  int _transactionType = 0; // 0 = Pengeluaran, 1 = Pemasukan
  int _selectedCategoryIndex = 0;
  int _selectedWalletIndex = 0;
  bool _isRecurring = false;
  String? _receiptImagePath;

  // Controllers
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _titleController = TextEditingController();

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
    if (widget.initialCategory != null) {
      final index = _categories.indexWhere(
        (c) => c.label.toLowerCase() == widget.initialCategory!.toLowerCase(),
      );
      if (index != -1) {
        _selectedCategoryIndex = index;
      }
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

  List<_Category> get _categories =>
      _transactionType == 0 ? _expenseCategories : _incomeCategories;

  /// Validate and dispatch submit event to BLoC.
  void _onSave(BuildContext context) {
    final amountText = _amountController.text.replaceAll('.', '').trim();
    final title = _titleController.text.trim();

    // Validation
    if (amountText.isEmpty || double.tryParse(amountText) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan jumlah transaksi yang valid.')),
      );
      return;
    }
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul transaksi tidak boleh kosong.')),
      );
      return;
    }

    final category = _categories[_selectedCategoryIndex];
    final amount = double.parse(amountText);

    final receiptFileName = _receiptImagePath != null ? _receiptImagePath!.split(RegExp(r'[/\\]')).last : '';
    final String? note;
    if (_notesController.text.trim().isNotEmpty) {
      note = _receiptImagePath != null
          ? '${_notesController.text.trim()}\n\n[Struk: $receiptFileName]'
          : _notesController.text.trim();
    } else {
      note = _receiptImagePath != null ? '[Struk: $receiptFileName]' : null;
    }

    context.read<TransactionBloc>().add(
          TransactionSubmitRequested(
            title: title,
            amount: amount,
            isIncome: _transactionType == 1,
            category: category.label,
            categoryIcon: category.iconKey,
            walletName: _wallets[_selectedWalletIndex],
            note: note,
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
            final category = _categories[_selectedCategoryIndex];
            final amountText = _amountController.text.replaceAll('.', '').trim();
            final amount = double.tryParse(amountText) ?? 0.0;
            final isIncome = _transactionType == 1;
            final notifBody = 'Mencatat ${isIncome ? "pemasukan" : "pengeluaran"} "${_titleController.text.trim()}" sebesar ${AppFormatter.currency(amount)} ke dompet ${_wallets[_selectedWalletIndex]}.';

            sl<NotificationLocalDataSource>().saveNotification(
              NotificationModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: notifTitle,
                body: notifBody,
                timestamp: DateTime.now(),
                type: 'success',
                isRead: false,
              ),
            );

            sl<NotificationService>().showInstantNotification(notifTitle, notifBody);

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
                icon: Icon(Icons.close_rounded, color: Theme.of(context).colorScheme.primary),
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
                          Text(
                            'Kategori',
                            style: AppTypography.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: 8,
                            runSpacing: 10,
                            children: List.generate(_categories.length, (i) {
                              return _CategoryChip(
                                icon: _categories[i].icon,
                                label: _categories[i].label,
                                isSelected: _selectedCategoryIndex == i,
                                onTap: () =>
                                    setState(() => _selectedCategoryIndex = i),
                              );
                            }),
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // ── Wallet ───────────────────────────────────
                          Text(
                            'Pilih Dompet',
                            style: AppTypography.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: List.generate(_wallets.length, (i) {
                              final icons = [
                                Icons.account_balance,
                                Icons.payments,
                                Icons.account_balance_wallet,
                              ];
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      right: i < _wallets.length - 1 ? 12 : 0),
                                  child: _WalletCard(
                                    icon: icons[i],
                                    label: _wallets[i],
                                    isSelected: _selectedWalletIndex == i,
                                    onTap: () => setState(
                                        () => _selectedWalletIndex = i),
                                  ),
                                ),
                              );
                            }),
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
                          if (_receiptImagePath != null) ...[
                            Text(
                              'Struk Terlampir',
                              style: AppTypography.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(_receiptImagePath!),
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 48,
                                          height: 48,
                                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                          child: Icon(Icons.receipt_long, color: Theme.of(context).colorScheme.outlineVariant),
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
                                          _receiptImagePath!.split(RegExp(r'[/\\]')).last,
                                          style: AppTypography.textTheme.labelMedium
                                              ?.copyWith(fontWeight: FontWeight.w700),
                                        ),
                                        Text(
                                          'Struk berhasil dilampirkan',
                                          style: AppTypography.textTheme.bodySmall?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.error),
                                    onPressed: () {
                                      setState(() {
                                        _receiptImagePath = null;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                          ],

                          // ── Recurring Toggle ─────────────────────────
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primaryContainer,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.restore_rounded,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Transaksi Berulang',
                                        style: AppTypography.textTheme.labelLarge
                                            ?.copyWith(fontWeight: FontWeight.w700),
                                      ),
                                      Text(
                                        'Setel sebagai pengeluaran bulanan',
                                        style: AppTypography.textTheme.bodySmall
                                            ?.copyWith(
                                                color: Theme.of(context).colorScheme.onSurfaceVariant),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch.adaptive(
                                  value: _isRecurring,
                                  onChanged: (val) =>
                                      setState(() => _isRecurring = val),
                                  activeColor: Theme.of(context).colorScheme.primary,
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
                          color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
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
                          backgroundColor: Theme.of(context).colorScheme.primary,
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
                                style:
                                    AppTypography.textTheme.labelLarge?.copyWith(
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
                  color: isActive ? Theme.of(context).colorScheme.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: Text(
                  e.value,
                  style: AppTypography.textTheme.labelLarge?.copyWith(
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.w400,
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
          color: isSelected ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
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
                color:
                    isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
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
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
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
                color:
                    isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
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