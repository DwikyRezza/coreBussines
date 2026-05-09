// ============================================================
// FEATURE: Schedule — Add Schedule Page
// lib/features/schedule/presentation/pages/add_schedule_page.dart
// ============================================================

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class AddSchedulePage extends StatefulWidget {
  const AddSchedulePage({super.key});

  @override
  State<AddSchedulePage> createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  int _selectedReminderIndex = 1; // 10 Menit default based on screenshot

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        titleSpacing: AppSpacing.pagePadding,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=11'),
              backgroundColor: AppColors.surfaceContainer,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'CoreFit',
              style: AppTypography.textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.primary),
            onPressed: () {},
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
            Text(
              'Buat Jadwal Baru',
              style: AppTypography.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A202C),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Rencanakan aktivitas kebugaran Anda hari ini.',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF4A5568),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Form Fields Container
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Aktivitas Field
                  Text('Aktivitas', style: AppTypography.textTheme.labelMedium?.copyWith(color: const Color(0xFF1A202C), fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Misal: Lari Pagi, Yoga',
                      hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(color: const Color(0xFFA0AEC0)),
                      prefixIcon: const Icon(Icons.directions_run_rounded, color: Color(0xFFA0AEC0)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF0D47A1)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Waktu Mulai Field
                  Text('Waktu Mulai', style: AppTypography.textTheme.labelMedium?.copyWith(color: const Color(0xFF1A202C), fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      hintText: '06:30 AM',
                      hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(color: const Color(0xFF1A202C)), // Mock active state
                      prefixIcon: const Icon(Icons.access_time_rounded, color: Color(0xFFA0AEC0)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Pengingat Sebelum Aktivitas
                  Text('Pengingat Sebelum Aktivitas', style: AppTypography.textTheme.labelMedium?.copyWith(color: const Color(0xFF1A202C), fontWeight: FontWeight.w600)),
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
                  Text('Catatan Tambahan', style: AppTypography.textTheme.labelMedium?.copyWith(color: const Color(0xFF1A202C), fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Target kalori, rute lari, atau fokus latihan...',
                      hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(color: const Color(0xFFA0AEC0)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      backgroundColor: const Color(0xFF0D47A1), // Deep Blue
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.save_outlined, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text('Simpan Jadwal', style: AppTypography.textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2962FF) : Colors.white, // Bright blue if active
          border: Border.all(color: isSelected ? const Color(0xFF2962FF) : const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: isSelected ? Colors.white : const Color(0xFF4A5568),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
