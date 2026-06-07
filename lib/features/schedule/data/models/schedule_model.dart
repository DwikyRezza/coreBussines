// ============================================================
// FEATURE: Schedule — Model
// lib/features/schedule/data/models/schedule_model.dart
// ============================================================

import 'package:equatable/equatable.dart';

class ScheduleModel extends Equatable {
  final String id;
  final String title;
  final DateTime dateTime;
  final int reminderMinutes;
  final String note;
  final bool isCompleted;

  const ScheduleModel({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.reminderMinutes,
    required this.note,
    this.isCompleted = false,
  });

  ScheduleModel copyWith({
    String? id,
    String? title,
    DateTime? dateTime,
    int? reminderMinutes,
    String? note,
    bool? isCompleted,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      note: note ?? this.note,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] as String,
      title: json['title'] as String,
      dateTime: DateTime.parse(json['date_time'] as String),
      reminderMinutes: json['reminder_minutes'] as int? ?? 10,
      note: json['note'] as String? ?? '',
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date_time': dateTime.toIso8601String(),
      'reminder_minutes': reminderMinutes,
      'note': note,
      'is_completed': isCompleted,
    };
  }

  @override
  List<Object?> get props =>
      [id, title, dateTime, reminderMinutes, note, isCompleted];
}
