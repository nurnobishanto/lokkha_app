import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<NotificationListEntity> getNotifications({String? deviceId});
  Future<bool> markAsRead({
    required int notificationId,
    String? deviceId,
    bool isRead = true,
  });
  Future<bool> markAllAsRead({String? deviceId});
}
