// ============================================================
// FEATURE: Schedule — Schedule Page
// lib/features/schedule/presentation/pages/schedule_page.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/core_app_bar.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_router.dart';
import '../../data/datasources/schedule_local_datasource.dart';
import '../../data/models/schedule_model.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime _selectedDate = DateTime.now();
  List<ScheduleModel> _allSchedules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() {
      _isLoading = true;
    });
    final list = await sl<ScheduleLocalDataSource>().getSchedules();
    setState(() {
      _allSchedules = list;
      _isLoading = false;
    });
  }

  List<ScheduleModel> get _filteredSchedules {
    final filtered = _allSchedules.where((s) {
      return s.dateTime.year == _selectedDate.year &&
          s.dateTime.month == _selectedDate.month &&
          s.dateTime.day == _selectedDate.day;
    }).toList();
    // Sort chronologically
    filtered.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return filtered;
  }

  List<DateTime> get _dateList {
    // Generate 7 days centered around the selected date
    final baseDate = _selectedDate.subtract(const Duration(days: 3));
    return List.generate(7, (index) => baseDate.add(Duration(days: index)));
  }

  Future<void> _jumpToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)), // Past 2 years
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)), // Future 10 years
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _toggleCompletion(String id) async {
    await sl<ScheduleLocalDataSource>().toggleScheduleCompletion(id);
    _loadSchedules();
  }

  Future<void> _deleteSchedule(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Hapus Jadwal',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus jadwal ini?',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await sl<ScheduleLocalDataSource>().deleteSchedule(id);
      _loadSchedules();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jadwal berhasil dihapus.')),
        );
      }
    }
  }

  Future<void> _navigateToAddOrEdit([ScheduleModel? schedule]) async {
    final result = await context.push<bool>(AppRoutes.addSchedule, extra: schedule);
    if (result == true) {
      _loadSchedules();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final schedules = _filteredSchedules;
    final formattedDateTitle = DateFormat('MMMM yyyy', 'id_ID').format(_selectedDate);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CoreAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadSchedules,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formattedDateTitle.toUpperCase(),
                          style: AppTypography.textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Jadwal Bisnis',
                          style: AppTypography.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => _jumpToDate(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.calendar_month_outlined, 
                          color: Theme.of(context).colorScheme.primary, 
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Horizontal Date Picker
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                  itemCount: _dateList.length,
                  itemBuilder: (context, index) {
                    final date = _dateList[index];
                    final isSelected = date.year == _selectedDate.year &&
                        date.month == _selectedDate.month &&
                        date.day == _selectedDate.day;
                    final dayStr = DateFormat('EEE', 'id_ID').format(date);
                    final dateStr = DateFormat('d').format(date);

                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: _DateCard(
                        day: dayStr,
                        date: dateStr,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedDate = date;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Timeline List or Empty State
              _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : schedules.isEmpty
                      ? _buildEmptyState(context)
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: schedules.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final item = schedules[index];
                              return _TimelineCard(
                                schedule: item,
                                onToggle: () => _toggleCompletion(item.id),
                                onDelete: () => _deleteSchedule(item.id),
                                onReschedule: () => _navigateToAddOrEdit(item),
                              );
                            },
                          ),
                        ),
              const SizedBox(height: 120), // Bottom padding for shell FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding, vertical: 24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(isDark ? 0.2 : 0.03),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today_outlined,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum Ada Jadwal',
              style: AppTypography.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tidak ada agenda atau aktivitas bisnis untuk tanggal ini.',
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _navigateToAddOrEdit(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Buat Jadwal Baru'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateCard extends StatelessWidget {
  final String day;
  final String date;
  final bool isSelected;
  final VoidCallback onTap;

  const _DateCard({
    required this.day,
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary 
              : (isDark ? Theme.of(context).colorScheme.surfaceContainerHighest : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day,
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: isSelected ? Colors.white.withOpacity(0.8) : Theme.of(context).colorScheme.outline,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date,
              style: AppTypography.textTheme.headlineSmall?.copyWith(
                color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final ScheduleModel schedule;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onReschedule;

  const _TimelineCard({
    required this.schedule,
    required this.onToggle,
    required this.onDelete,
    required this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final isCompleted = schedule.isCompleted;
    final isMissed = !isCompleted && schedule.dateTime.isBefore(now);

    String statusText = 'Upcoming';
    Color statusBg = const Color(0xFFE3F2FD);
    Color statusTextCol = Theme.of(context).colorScheme.primary;
    Color borderCol = Theme.of(context).colorScheme.primary;
    bool isStrikethrough = false;

    if (isCompleted) {
      statusText = 'Completed';
      statusBg = isDark 
          ? Theme.of(context).colorScheme.surfaceContainerHighest 
          : Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3);
      statusTextCol = Theme.of(context).colorScheme.outline;
      borderCol = Theme.of(context).colorScheme.outlineVariant;
      isStrikethrough = true;
    } else if (isMissed) {
      statusText = 'Missed';
      statusBg = const Color(0xFFFED7D7);
      statusTextCol = const Color(0xFFC53030);
      borderCol = const Color(0xFFC53030);
    }

    final timeStr = DateFormat('hh:mm\na').format(schedule.dateTime);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Colored left border edge
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: borderCol,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
              ),
            ),
            // Time column
            Container(
              width: 75,
              padding: const EdgeInsets.symmetric(vertical: 20),
              alignment: Alignment.topCenter,
              child: Text(
                timeStr,
                textAlign: TextAlign.center,
                style: AppTypography.textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
            // Divider
            VerticalDivider(color: Theme.of(context).colorScheme.outlineVariant, width: 1, thickness: 1),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            schedule.title,
                            style: AppTypography.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isStrikethrough ? Theme.of(context).colorScheme.outline : Theme.of(context).colorScheme.onSurface,
                              decoration: isStrikethrough ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: onToggle,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  statusText,
                                  style: AppTypography.textTheme.labelSmall?.copyWith(
                                    color: statusTextCol,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18),
                              color: Theme.of(context).colorScheme.error.withOpacity(0.8),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: onDelete,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      schedule.note.isNotEmpty ? schedule.note : 'Tidak ada catatan tambahan.',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    if (isMissed) ...[
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Theme.of(context).colorScheme.primary,
                          elevation: 0,
                          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('Reschedule'),
                        onPressed: onReschedule,
                      ),
                    ] else if (!isCompleted) ...[
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Theme.of(context).colorScheme.primary,
                          elevation: 0,
                          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Ubah'),
                        onPressed: onReschedule,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}