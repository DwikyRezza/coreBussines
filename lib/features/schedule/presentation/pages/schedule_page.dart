// ============================================================
// FEATURE: Schedule — Schedule Page
// lib/features/schedule/presentation/pages/schedule_page.dart
// ============================================================

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/core_app_bar.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CoreAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
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
                        'TODAY',
                        style: AppTypography.textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Schedule',
                        style: AppTypography.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.calendar_month_outlined, color: Theme.of(context).colorScheme.primary, size: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Horizontal Date Picker Mock
            SizedBox(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                children: [
                  _DateCard(day: 'Mon', date: '12', isSelected: false),
                  const SizedBox(width: 12),
                  _DateCard(day: 'Tue', date: '13', isSelected: false),
                  const SizedBox(width: 12),
                  _DateCard(day: 'Wed', date: '14', isSelected: true), // Active
                  const SizedBox(width: 12),
                  _DateCard(day: 'Thu', date: '15', isSelected: false),
                  const SizedBox(width: 12),
                  _DateCard(day: 'Fri', date: '16', isSelected: false),
                  const SizedBox(width: 12),
                  _DateCard(day: 'Sat', date: '17', isSelected: false),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Timeline List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
              child: Column(
                children: [
                  _TimelineCard(
                    time: '07:00\nAM',
                    title: 'Morning Yoga',
                    subtitle: 'Studio 2 • Sarah Jenkins',
                    statusPillText: 'Completed',
                    statusPillColor: Theme.of(context).colorScheme.outlineVariant,
                    statusPillTextColor: Theme.of(context).colorScheme.outline,
                    borderColor: Theme.of(context).colorScheme.outlineVariant,
                    isStrikethrough: true,
                  ),
                  const SizedBox(height: 16),
                  _TimelineCard(
                    time: '10:30\nAM',
                    title: 'Personal Training',
                    subtitle: 'Main Floor • Mike Davis',
                    statusPillText: 'Missed',
                    statusPillColor: const Color(0xFFFED7D7),
                    statusPillTextColor: const Color(0xFFC53030),
                    borderColor: const Color(0xFFC53030),
                    hasRescheduleButton: true,
                  ),
                  const SizedBox(height: 16),
                  _TimelineCard(
                    time: '02:00\nPM',
                    title: 'HIIT Core',
                    subtitle: 'Zone A • Elena R.',
                    statusPillText: 'Upcoming',
                    statusPillColor: const Color(0xFFE3F2FD),
                    statusPillTextColor: Theme.of(context).colorScheme.primary,
                    borderColor: Theme.of(context).colorScheme.primary,
                    hasAvatars: true,
                  ),
                  const SizedBox(height: 16),
                  _TimelineCard(
                    time: '06:15\nPM',
                    title: 'Recovery Stretch',
                    subtitle: 'Studio 1 • Video Guided',
                    statusPillText: 'Upcoming',
                    statusPillColor: const Color(0xFFE3F2FD),
                    statusPillTextColor: Theme.of(context).colorScheme.primary,
                    borderColor: const Color(0xFF63B3ED), // Light blue
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100), // Bottom padding for shell
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

  const _DateCard({required this.day, required this.date, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      decoration: BoxDecoration(
        color: isSelected ? Theme.of(context).colorScheme.primary : const Color(0xFFF1F5F9), // Deep blue or gray
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
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final String time;
  final String title;
  final String subtitle;
  final String statusPillText;
  final Color statusPillColor;
  final Color statusPillTextColor;
  final Color borderColor;
  final bool isStrikethrough;
  final bool hasRescheduleButton;
  final bool hasAvatars;

  const _TimelineCard({
    required this.time,
    required this.title,
    required this.subtitle,
    required this.statusPillText,
    required this.statusPillColor,
    required this.statusPillTextColor,
    required this.borderColor,
    this.isStrikethrough = false,
    this.hasRescheduleButton = false,
    this.hasAvatars = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
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
                color: borderColor,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
              ),
            ),
            // Time column
            Container(
              width: 70,
              padding: const EdgeInsets.symmetric(vertical: 20),
              alignment: Alignment.topCenter,
              child: Text(
                time,
                textAlign: TextAlign.center,
                style: AppTypography.textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                            title,
                            style: AppTypography.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isStrikethrough ? Theme.of(context).colorScheme.outline : Theme.of(context).colorScheme.onSurface,
                              decoration: isStrikethrough ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusPillColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusPillText,
                            style: AppTypography.textTheme.labelSmall?.copyWith(
                              color: statusPillTextColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    if (hasRescheduleButton) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Reschedule', style: AppTypography.textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
                      ),
                    ],
                    if (hasAvatars) ...[
                      const SizedBox(height: 16),
                      Divider(color: Theme.of(context).colorScheme.outlineVariant),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          SizedBox(
                            width: 80,
                            height: 30,
                            child: Stack(
                              children: [
                                Positioned(left: 0, child: CircleAvatar(radius: 15, backgroundColor: Theme.of(context).colorScheme.primary, child: Text('A', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)))),
                                Positioned(left: 20, child: CircleAvatar(radius: 15, backgroundColor: Theme.of(context).colorScheme.primary, child: Text('B', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)))),
                                Positioned(
                                  left: 40,
                                  child: CircleAvatar(
                                    radius: 15,
                                    backgroundColor: Theme.of(context).colorScheme.outlineVariant,
                                    child: Text('+8', style: AppTypography.textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text('attending', style: AppTypography.textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline)),
                        ],
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