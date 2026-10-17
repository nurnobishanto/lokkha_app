import '../repositories/notification_repository.dart';

class MarkAllNotificationsReadUseCase {
  final NotificationRepository repository;

  MarkAllNotificationsReadUseCase(this.repository);

  Future<bool> call({String? deviceId}) {
    return repository.markAllAsRead(deviceId: deviceId);
  }
}
