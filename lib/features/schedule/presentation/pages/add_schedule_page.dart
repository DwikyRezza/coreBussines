// ============================================================
// FEATURE: Schedule — Add Schedule Page
// lib/features/schedule/presentation/pages/add_schedule_page.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/core_app_bar.dart';
import '../../../../core/di/service_locator.dart';
import '../../data/datasources/schedule_local_datasource.dart';
import '../../data/models/schedule_model.dart';
import '../../../notifications/data/models/notification_model.dart';
import '../../../notifications/data/datasources/notification_local_datasource.dart';
import '../../../notifications/data/services/notification_service.dart';

class AddSchedulePage extends StatefulWidget {
  final ScheduleModel? existingSchedule;
  const AddSchedulePage({super.key, this.existingSchedule});

  @override
  State<AddSchedulePage> createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  int _selectedReminderIndex = 1; // 10 Menit default

  @override
  void initState() {
    super.initState();
    if (widget.existingSchedule != null) {
      _titleController.text = widget.existingSchedule!.title;
      _noteController.text = widget.existingSchedule!.note;
      _selectedDate = widget.existingSchedule!.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(widget.existingSchedule!.dateTime);
      
      final rem = widget.existingSchedule!.reminderMinutes;
      if (rem == 5) {
        _selectedReminderIndex = 0;
      } else if (rem == 60) {
        _selectedReminderIndex = 2;
      } else {
        _selectedReminderIndex = 1;
      }
    } else {
      // Rounded to nearest future 30 minutes interval for elegance
      final now = DateTime.now();
      if (now.minute < 30) {
        _selectedTime = TimeOfDay(hour: now.hour, minute: 30);
      } else {
        _selectedTime = TimeOfDay(hour: (now.hour + 1) % 24, minute: 0);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)), // Past 1 year
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
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
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
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveSchedule() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Nama aktivitas tidak boleh kosong.',
            style: TextStyle(color: Theme.of(context).colorScheme.onError),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final scheduleDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    int reminderMinutes = 10;
    if (_selectedReminderIndex == 0) reminderMinutes = 5;
    if (_selectedReminderIndex == 2) reminderMinutes = 60;

    final schedule = ScheduleModel(
      id: widget.existingSchedule?.id ?? 'sch_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      dateTime: scheduleDateTime,
      reminderMinutes: reminderMinutes,
      note: _noteController.text.trim(),
      isCompleted: widget.existingSchedule?.isCompleted ?? false,
    );

    await sl<ScheduleLocalDataSource>().saveSchedule(schedule);

    // Trigger Native and Local Notifications
    final isUpdate = widget.existingSchedule != null;
    final notifTitle = isUpdate ? 'Jadwal Diperbarui' : 'Jadwal Baru Ditambahkan';
    final notifBody = isUpdate
        ? 'Jadwal "${title}" berhasil diperbarui untuk ${DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(scheduleDateTime)} pukul ${scheduleDateTime.hour.toString().padLeft(2, '0')}:${scheduleDateTime.minute.toString().padLeft(2, '0')}.'
        : 'Aktivitas "${title}" berhasil dijadwalkan pada ${DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(scheduleDateTime)} pukul ${scheduleDateTime.hour.toString().padLeft(2, '0')}:${scheduleDateTime.minute.toString().padLeft(2, '0')}.';

    await sl<NotificationLocalDataSource>().saveNotification(
      NotificationModel(
        id: 'sch_${DateTime.now().millisecondsSinceEpoch}',
        title: notifTitle,
        body: notifBody,
        timestamp: DateTime.now(),
        type: 'info',
        isRead: false,
      ),
    );

    await sl<NotificationService>().showInstantNotification(notifTitle, notifBody);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.existingSchedule != null 
                ? 'Jadwal berhasil diperbarui!' 
                : 'Jadwal baru berhasil disimpan!',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      Navigator.of(context).pop(true); // Pop and signal updates
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CoreAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
            Text(
              widget.existingSchedule != null ? 'Ubah Jadwal' : 'Buat Jadwal Baru',
              style: AppTypography.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Rencanakan jadwal dan aktivitas bisnis Anda secara presisi.',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Form Fields Container
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withOpacity(isDark ? 0.2 : 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Aktivitas Field
                  Text(
                    'Aktivitas',
                    style: AppTypography.textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Misal: Rapat Evaluasi, Stok Opname',
                      hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      prefixIcon: Icon(
                        Icons.business_center_rounded,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tanggal Field
                  Text(
                    'Tanggal Aktivitas',
                    style: AppTypography.textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(_selectedDate),
                      hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      prefixIcon: Icon(
                        Icons.calendar_today_rounded,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Waktu Mulai Field
                  Text(
                    'Waktu Mulai',
                    style: AppTypography.textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    readOnly: true,
                    onTap: () => _selectTime(context),
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: _selectedTime.format(context),
                      hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      prefixIcon: Icon(
                        Icons.access_time_rounded,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Pengingat Sebelum Aktivitas
                  Text(
                    'Pengingat Sebelum Aktivitas',
                    style: AppTypography.textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _ReminderToggle(
                          label: '5 Menit',
                          isSelected: _selectedReminderIndex == 0,
                          onTap: () => setState(() => _selectedReminderIndex = 0),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ReminderToggle(
                          label: '10 Menit',
                          isSelected: _selectedReminderIndex == 1,
                          onTap: () => setState(() => _selectedReminderIndex = 1),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ReminderToggle(
                          label: '1 Jam',
                          isSelected: _selectedReminderIndex == 2,
                          onTap: () => setState(() => _selectedReminderIndex = 2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Catatan Tambahan Field
                  Text(
                    'Catatan Tambahan',
                    style: AppTypography.textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    maxLines: 4,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Catatan target, lokasi, agenda rapat, atau detail aktivitas bisnis...',
                      hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  ElevatedButton(
                    onPressed: _saveSchedule,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      backgroundColor: Theme.of(context).colorScheme.primary, // Deep Blue
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.save_outlined, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          widget.existingSchedule != null ? 'Perbarui Jadwal' : 'Simpan Jadwal',
                          style: AppTypography.textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100), // Bottom navigation padding
          ],
        ),
      ),
    );
  }
}

class _ReminderToggle extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReminderToggle({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary 
              : (isDark ? Theme.of(context).colorScheme.surfaceContainerHighest : Colors.white),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary 
                : Theme.of(context).colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: isSelected 
                  ? Colors.white 
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}