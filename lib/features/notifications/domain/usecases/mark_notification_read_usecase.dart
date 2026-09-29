import '../repositories/notification_repository.dart';

class MarkNotificationReadUseCase {
  final NotificationRepository repository;

  MarkNotificationReadUseCase(this.repository);

  Future<bool> call({
    required int notificationId,
    required String? deviceId,
    required bool isRead,
  }) {
    return repository.markAsRead(
      notificationId: notificationId,
      deviceId: deviceId,
      isRead: isRead,
    );
  }
}
