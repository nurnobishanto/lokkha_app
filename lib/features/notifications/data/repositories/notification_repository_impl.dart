import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<NotificationListEntity> getNotifications({String? deviceId}) {
    return remoteDataSource.fetchNotifications(deviceId: deviceId);
  }

  @override
  Future<bool> markAsRead({
    required int notificationId,
    String? deviceId,
    bool isRead = true,
  }) {
    return remoteDataSource.markAsRead(
      notificationId: notificationId,
      deviceId: deviceId,
      isRead: isRead,
    );
  }

  @override
  Future<bool> markAllAsRead({String? deviceId}) {
    return remoteDataSource.markAllAsRead(deviceId: deviceId);
  }
}
