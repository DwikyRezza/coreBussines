// ============================================================
// FEATURE: Schedule — Local Data Source (SharedPreferences)
// lib/features/schedule/data/datasources/schedule_local_datasource.dart
// ============================================================

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/schedule_model.dart';

abstract class ScheduleLocalDataSource {
  Future<List<ScheduleModel>> getSchedules();
  Future<void> saveSchedule(ScheduleModel schedule);
  Future<void> deleteSchedule(String id);
  Future<void> toggleScheduleCompletion(String id);
}

class ScheduleLocalDataSourceImpl implements ScheduleLocalDataSource {
  final SharedPreferences prefs;

  static const String _kSchedulesKey = 'cached_schedules';

  ScheduleLocalDataSourceImpl({required this.prefs});

  @override
  Future<List<ScheduleModel>> getSchedules() async {
    final raw = prefs.getString(_kSchedulesKey);
    if (raw == null || raw.isEmpty) {
      return _loadSeeds();
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => ScheduleModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveSchedule(ScheduleModel schedule) async {
    final list = await getSchedules();
    final index = list.indexWhere((s) => s.id == schedule.id);
    if (index >= 0) {
      list[index] = schedule;
    } else {
      list.add(schedule);
    }
    await _writeAll(list);
  }

  @override
  Future<void> deleteSchedule(String id) async {
    final list = await getSchedules();
    list.removeWhere((s) => s.id == id);
    await _writeAll(list);
  }

  @override
  Future<void> toggleScheduleCompletion(String id) async {
    final list = await getSchedules();
    final index = list.indexWhere((s) => s.id == id);
    if (index >= 0) {
      final s = list[index];
      list[index] = s.copyWith(isCompleted: !s.isCompleted);
      await _writeAll(list);
    }
  }

  Future<void> _writeAll(List<ScheduleModel> list) async {
    final encoded = jsonEncode(list.map((e) => e.toJson()).toList());
    await prefs.setString(_kSchedulesKey, encoded);
  }

  List<ScheduleModel> _loadSeeds() {
    // Generate some default dummy data to populate first-time visits beautifully
    final now = DateTime.now();
    final seeds = [
      ScheduleModel(
        id: 'sch_seed_1',
        title: 'Review & Pembukuan Kas',
        dateTime: DateTime(now.year, now.month, now.day, 18, 15),
        reminderMinutes: 10,
        note: 'Kasir Cabang • Sistem Cloud',
        isCompleted: false,
      ),
      ScheduleModel(
        id: 'sch_seed_2',
        title: 'Rapat Tim Harian',
        dateTime: DateTime(now.year, now.month, now.day, 7, 0),
        reminderMinutes: 10,
        note: 'Ruang Kerja Utama • Tim Finansial',
        isCompleted: true,
      ),
      ScheduleModel(
        id: 'sch_seed_3',
        title: 'Stok Opname Inventaris',
        dateTime: DateTime(now.year, now.month, now.day, 10, 30),
        reminderMinutes: 5,
        note: 'Gudang Utama • Tim Logistik',
        isCompleted: false, // Let this represent missed if in the past
      ),
      ScheduleModel(
        id: 'sch_seed_4',
        title: 'Evaluasi Laporan Keuangan',
        dateTime: DateTime(now.year, now.month, now.day, 14, 0),
        reminderMinutes: 60,
        note: 'Ruang Rapat Utama • Direksi',
        isCompleted: false,
      ),
    ];
    return seeds;
  }
}
