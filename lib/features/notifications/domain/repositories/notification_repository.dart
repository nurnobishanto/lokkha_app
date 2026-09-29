import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<NotificationListEntity> getNotifications({required String? deviceId});
  Future<bool> markAsRead({
    required int notificationId,
    required String? deviceId,
    required bool isRead,
  });
}
