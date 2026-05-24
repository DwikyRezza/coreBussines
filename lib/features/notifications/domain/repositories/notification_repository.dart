import '../../data/models/notification_model.dart';

abstract class NotificationRepository {
  Stream<List<NotificationModel>> watchNotifications();
  Stream<int> watchUnreadCount();
  Future<void> saveNotification(NotificationModel notification);
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String id);
  Future<void> deleteNotifications(List<String> ids);
  Future<void> deleteAllNotifications();
}
