// ============================================================
// FEATURE: Notifications — Local Datasource
// lib/features/notifications/data/datasources/notification_local_datasource.dart
// ============================================================

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';

abstract class NotificationLocalDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<void> saveNotification(NotificationModel notification);
  Future<void> markAllAsRead();
  Future<void> clearAllNotifications();
}

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _key = 'cached_notifications';

  NotificationLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final jsonString = sharedPreferences.getString(_key);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) =>
              NotificationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      // Seed initial data with core business notifications (no gym-related whey proteins!)
      final now = DateTime.now();
      final seedData = [
        NotificationModel(
          id: 'seed-1',
          title: 'Peringatan Stok Menipis',
          body:
              'Stok Kertas HVS A4 80gr menipis. Sisa 4 rim di gudang inventaris.',
          timestamp: now.subtract(const Duration(hours: 1)),
          type: 'alert',
          isRead: false,
        ),
        NotificationModel(
          id: 'seed-2',
          title: 'Laporan Keuangan Selesai',
          body:
              'Laporan Keuangan Bulanan (Laba Rugi & Neraca) berhasil diekspor ke format PDF.',
          timestamp: now.subtract(const Duration(hours: 3)),
          type: 'success',
          isRead: false,
        ),
        NotificationModel(
          id: 'seed-3',
          title: 'Agenda Rapat Tim',
          body:
              'Rapat koordinasi bulanan penyelarasan keuangan dan logistik bisnis akan dimulai dalam 30 menit.',
          timestamp: now.subtract(const Duration(hours: 5)),
          type: 'info',
          isRead: true,
        ),
        NotificationModel(
          id: 'seed-4',
          title: 'Analisis Kinerja Omzet',
          body:
              'Omzet penjualan kotor meningkat 4.2% minggu ini dibandingkan minggu sebelumnya.',
          timestamp: now.subtract(const Duration(days: 1)),
          type: 'success',
          isRead: true,
        ),
        NotificationModel(
          id: 'seed-5',
          title: 'Audit Mesin Kasir Selesai',
          body:
              'Pembersihan dan kalibrasi printer struk kasir utama telah berhasil diselesaikan.',
          timestamp: now.subtract(const Duration(days: 1, hours: 4)),
          type: 'info',
          isRead: true,
        ),
      ];
      await _saveList(seedData);
      return seedData;
    }
  }

  @override
  Future<void> saveNotification(NotificationModel notification) async {
    final list = await getNotifications();

    // Insert new notification at the top of the list
    final updatedList = [notification, ...list];
    await _saveList(updatedList);
  }

  @override
  Future<void> markAllAsRead() async {
    final list = await getNotifications();
    final updatedList =
        list.map((item) => item.copyWith(isRead: true)).toList();
    await _saveList(updatedList);
  }

  @override
  Future<void> clearAllNotifications() async {
    await sharedPreferences.remove(_key);
  }

  Future<void> _saveList(List<NotificationModel> list) async {
    final jsonList = list.map((item) => item.toJson()).toList();
    await sharedPreferences.setString(_key, jsonEncode(jsonList));
  }
}
