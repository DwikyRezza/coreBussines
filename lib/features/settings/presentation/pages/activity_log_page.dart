import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/business_context_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/core_app_bar.dart';
import '../../../../core/utils/formatters.dart';

class ActivityLogPage extends StatefulWidget {
  const ActivityLogPage({super.key});

  @override
  State<ActivityLogPage> createState() => _ActivityLogPageState();
}

class _ActivityLogPageState extends State<ActivityLogPage> {
  String _selectedTargetType = 'all'; // all, transaction, employee, wallet
  String? _selectedStaffName; // null means all staff
  String _selectedDateRange = 'all'; // all, today, week, month

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return FutureBuilder<BusinessContext>(
      future: sl<BusinessContextService>().getCurrentContext(),
      builder: (context, contextSnapshot) {
        if (!contextSnapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final businessContext = contextSnapshot.data!;
        if (businessContext.role != 'owner') {
          return const Scaffold(
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'Hanya Pemilik (Owner) yang dapat mengakses Log Aktivitas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        }

        final businessId = businessContext.businessId;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: const CoreAppBar(
            title: 'Log Aktivitas Tim',
          ),
          body: Column(
            children: [
              // Filters Section
              _buildFilters(colors, businessId),
              const Divider(height: 1),
              // Logs List
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('businesses')
                      .doc(businessId)
                      .collection('activity_logs')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            'Gagal memuat log aktivitas: ${snapshot.error}',
                            style: TextStyle(color: colors.error),
                          ),
                        ),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return _buildEmptyState(colors);
                    }

                    // Apply client-side filters
                    final filteredDocs = docs.where((doc) {
                      final data = doc.data();
                      
                      // 1. Filter Target Type
                      if (_selectedTargetType != 'all') {
                        final type = data['targetType'] as String? ?? '';
                        if (type != _selectedTargetType) return false;
                      }

                      // 2. Filter Staff
                      if (_selectedStaffName != null) {
                        final performedBy = data['performedByName'] as String? ?? '';
                        if (performedBy != _selectedStaffName) return false;
                      }

                      // 3. Filter Date
                      if (_selectedDateRange != 'all') {
                        final createdAtStamp = data['createdAt'] as Timestamp?;
                        if (createdAtStamp == null) return false;
                        final createdAt = createdAtStamp.toDate();
                        final now = DateTime.now();
                        if (_selectedDateRange == 'today') {
                          final todayStart = DateTime(now.year, now.month, now.day);
                          if (createdAt.isBefore(todayStart)) return false;
                        } else if (_selectedDateRange == 'week') {
                          final weekStart = now.subtract(const Duration(days: 7));
                          if (createdAt.isBefore(weekStart)) return false;
                        } else if (_selectedDateRange == 'month') {
                          final monthStart = now.subtract(const Duration(days: 30));
                          if (createdAt.isBefore(monthStart)) return false;
                        }
                      }

                      return true;
                    }).toList();

                    if (filteredDocs.isEmpty) {
                      return _buildEmptyState(colors, isFilterEmpty: true);
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.pagePadding,
                        vertical: AppSpacing.md,
                      ),
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        final data = filteredDocs[index].data();
                        final docId = filteredDocs[index].id;
                        return _buildLogCard(context, colors, data, docId);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilters(ColorScheme colors, String businessId) {
    return Container(
      color: colors.surface,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Target Type Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Semua Target',
                  selected: _selectedTargetType == 'all',
                  onSelected: (val) => setState(() => _selectedTargetType = 'all'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Transaksi',
                  selected: _selectedTargetType == 'transaction',
                  onSelected: (val) => setState(() => _selectedTargetType == 'transaction'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Karyawan',
                  selected: _selectedTargetType == 'employee',
                  onSelected: (val) => setState(() => _selectedTargetType == 'employee'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Dompet',
                  selected: _selectedTargetType == 'wallet',
                  onSelected: (val) => setState(() => _selectedTargetType == 'wallet'),
                ),
              ],
            ),
          ),
          
          // Staff and Date Row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                // Staff Dropdown / Chip
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('businesses')
                        .doc(businessId)
                        .collection('members')
                        .snapshots(),
                    builder: (context, snapshot) {
                      final members = snapshot.data?.docs ?? [];
                      final List<String> staffNames = members
                          .map((doc) => doc.data()['name'] as String? ?? '')
                          .where((name) => name.isNotEmpty)
                          .toList();

                      // Include owner themselves
                      if (!staffNames.contains('Owner')) {
                        staffNames.add('Owner');
                      }

                      return DropdownButtonFormField<String?>(
                        value: _selectedStaffName,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          isDense: true,
                          labelText: 'Pilih Staff',
                          labelStyle: AppTypography.textTheme.bodySmall,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Semua Staff')),
                          ...staffNames.map((name) => DropdownMenuItem(value: name, child: Text(name))),
                        ],
                        onChanged: (val) => setState(() => _selectedStaffName = val),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Date Range
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedDateRange,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      isDense: true,
                      labelText: 'Periode Waktu',
                      labelStyle: AppTypography.textTheme.bodySmall,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Semua Waktu')),
                      DropdownMenuItem(value: 'today', child: Text('Hari Ini')),
                      DropdownMenuItem(value: 'week', child: Text('7 Hari Terakhir')),
                      DropdownMenuItem(value: 'month', child: Text('30 Hari Terakhir')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedDateRange = val);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogCard(BuildContext context, ColorScheme colors, Map<String, dynamic> data, String docId) {
    final description = data['description'] as String? ?? '';
    final performedByName = data['performedByName'] as String? ?? 'Seseorang';
    final performedByRole = data['performedByRole'] as String? ?? '';
    final createdAtStamp = data['createdAt'] as Timestamp?;
    final createdAt = createdAtStamp?.toDate() ?? DateTime.now();
    final targetType = data['targetType'] as String? ?? '';

    IconData icon;
    Color iconColor;
    switch (targetType) {
      case 'transaction':
        icon = Icons.receipt_long_rounded;
        iconColor = colors.primary;
        break;
      case 'employee':
        icon = Icons.badge_outlined;
        iconColor = colors.secondary;
        break;
      case 'wallet':
        icon = Icons.account_balance_wallet_rounded;
        iconColor = colors.tertiary;
        break;
      default:
        icon = Icons.history_rounded;
        iconColor = colors.outline;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant.withAlpha(128)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Oleh: $performedByName ($performedByRole)',
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        AppFormatter.fullDate(createdAt),
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: colors.outline,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colors, {bool isFilterEmpty = false}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isFilterEmpty ? Icons.filter_list_off_rounded : Icons.history_toggle_off_rounded,
              size: 72,
              color: colors.outline.withAlpha(128),
            ),
            const SizedBox(height: 16),
            Text(
              isFilterEmpty ? 'Tidak ada hasil filter' : 'Belum ada aktivitas tercatat',
              style: AppTypography.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFilterEmpty
                  ? 'Silakan ubah kriteria filter untuk menemukan aktivitas tim.'
                  : 'Seluruh audit trail penting tim Anda akan otomatis tercatat di sini.',
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: colors.primaryContainer,
      backgroundColor: colors.surfaceContainerLowest,
      labelStyle: TextStyle(
        color: selected ? colors.primary : colors.onSurfaceVariant,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
