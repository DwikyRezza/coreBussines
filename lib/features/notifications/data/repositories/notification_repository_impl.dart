import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;

  const NotificationRepositoryImpl(this._remoteDataSource);

  @override
  Stream<List<NotificationModel>> watchNotifications() {
    return _remoteDataSource.watchNotifications();
  }

  @override
  Stream<int> watchUnreadCount() {
    return _remoteDataSource.watchUnreadCount();
  }

  @override
  Future<void> saveNotification(NotificationModel notification) {
    return _remoteDataSource.saveNotification(notification);
  }

  @override
  Future<void> markAsRead(String id) {
    return _remoteDataSource.markAsRead(id);
  }

  @override
  Future<void> markAllAsRead() {
    return _remoteDataSource.markAllAsRead();
  }

  @override
  Future<void> deleteNotification(String id) {
    return _remoteDataSource.deleteNotification(id);
  }

  @override
  Future<void> deleteNotifications(List<String> ids) {
    return _remoteDataSource.deleteNotifications(ids);
  }

  @override
  Future<void> deleteAllNotifications() {
    return _remoteDataSource.deleteAllNotifications();
  }
}
