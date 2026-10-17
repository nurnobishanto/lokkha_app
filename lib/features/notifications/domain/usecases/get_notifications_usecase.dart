import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository repository;

  GetNotificationsUseCase(this.repository);

  Future<NotificationListEntity> call({String? deviceId}) {
    return repository.getNotifications(deviceId: deviceId);
  }
}
