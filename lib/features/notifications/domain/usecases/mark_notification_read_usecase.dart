import '../repositories/notification_repository.dart';

class MarkNotificationReadUseCase {
  final NotificationRepository repository;

  MarkNotificationReadUseCase(this.repository);

  Future<bool> call({
    required int notificationId,
    String? deviceId,
    bool isRead = true,
  }) {
    return repository.markAsRead(
      notificationId: notificationId,
      deviceId: deviceId,
      isRead: isRead,
    );
  }
}
