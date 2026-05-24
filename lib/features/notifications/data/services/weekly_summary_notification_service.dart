import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/services/business_context_service.dart';
import '../models/notification_model.dart';
import '../../domain/repositories/notification_repository.dart';

class WeeklySummaryNotificationService {
  final FirebaseFirestore _firestore;
  final BusinessContextService _businessContext;
  final NotificationRepository _notificationRepository;

  WeeklySummaryNotificationService({
    required FirebaseFirestore firestore,
    required BusinessContextService businessContext,
    required NotificationRepository notificationRepository,
  })  : _firestore = firestore,
        _businessContext = businessContext,
        _notificationRepository = notificationRepository;

  Future<void> ensureCurrentWeekSummary() async {
    final context = await _businessContext.getCurrentContext();
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final end = start.add(const Duration(days: 7));
    final weekKey =
        '${start.year}${start.month.toString().padLeft(2, '0')}${start.day.toString().padLeft(2, '0')}';
    final notificationId = 'weekly_${context.userId}_$weekKey';

    final existing = await _firestore
        .collection('businesses')
        .doc(context.businessId)
        .collection('notifications')
        .doc(notificationId)
        .get();
    if (existing.exists) return;

    Query<Map<String, dynamic>> query = _firestore
        .collection('businesses')
        .doc(context.businessId)
        .collection('transactions')
        .where('date_time', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date_time', isLessThan: Timestamp.fromDate(end));

    if (!context.isOwner) {
      query = query.where('createdByUserId', isEqualTo: context.userId);
    }

    final snapshot = await query.get();
    final staffCounts = <String, int>{};
    final categoryExpenses = <String, double>{};

    double income = 0;
    double expense = 0;
    double staffTotal = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final amount = (data['amount'] as num?)?.toDouble() ?? 0;
      final isIncome =
          data['is_income'] as bool? ?? (data['type'] as String?) == 'income';
      final staffName = data['createdByName'] as String? ??
          data['created_by_name'] as String? ??
          'Staff';
      final categoryName = data['category'] as String? ?? 'Lainnya';

      if (context.isOwner) {
        if (isIncome) {
          income += amount;
        } else {
          expense += amount;
          categoryExpenses[categoryName] =
              (categoryExpenses[categoryName] ?? 0) + amount;
        }
        staffCounts[staffName] = (staffCounts[staffName] ?? 0) + 1;
      } else {
        staffTotal += amount;
      }
    }

    final NotificationModel notification;
    if (context.isOwner) {
      String staffPalingAktif = 'Tidak ada';
      int maxStaffCount = 0;
      staffCounts.forEach((name, transactionCount) {
        if (transactionCount > maxStaffCount) {
          maxStaffCount = transactionCount;
          staffPalingAktif = name;
        }
      });

      String kategoriPengeluaranTerbesar = 'Tidak ada';
      double maxCategoryExpense = 0;
      categoryExpenses.forEach((cat, amt) {
        if (amt > maxCategoryExpense) {
          maxCategoryExpense = amt;
          kategoriPengeluaranTerbesar = cat;
        }
      });

      final profit = income - expense;
      final insight = expense > income
          ? 'Pengeluaran melebihi pemasukan minggu ini. Coba evaluasi biaya pengeluaran.'
          : 'Kondisi finansial sehat. Profit bersih mencapai Rp ${profit.toStringAsFixed(0)}.';

      final bodyText =
          'Pemasukan: Rp ${income.toStringAsFixed(0)} | Pengeluaran: Rp ${expense.toStringAsFixed(0)} | Profit: Rp ${profit.toStringAsFixed(0)} | Transaksi: ${snapshot.docs.length}.\n'
          '• Staff Teraktif: $staffPalingAktif ($maxStaffCount transaksi)\n'
          '• Kategori Terbesar: $kategoriPengeluaranTerbesar (Rp ${maxCategoryExpense.toStringAsFixed(0)})\n'
          '• Insight: $insight';

      notification = NotificationModel(
        id: notificationId,
        businessId: context.businessId,
        targetUserId: context.userId,
        title: 'Ringkasan Mingguan Bisnis (Owner)',
        body: bodyText,
        type: profit < 0 ? 'warning' : 'success',
        isRead: false,
        createdAt: now,
      );
    } else {
      notification = NotificationModel(
        id: notificationId,
        businessId: context.businessId,
        targetUserId: context.userId,
        title: 'Ringkasan Aktivitas Mingguan',
        body:
            'Anda mencatat ${snapshot.docs.length} transaksi minggu ini dengan total nominal Rp ${staffTotal.toStringAsFixed(0)}. Laporan lengkap hanya dapat dilihat owner.',
        type: 'info',
        isRead: false,
        createdAt: now,
      );
    }

    await _notificationRepository.saveNotification(notification);
  }
}
