class NotificationEntity {
  final int? id;
  final String? title;
  final String? body;
  final String? image;
  final String? route;
  final String? webLink;
  final dynamic sound;
  final dynamic arguments;
  final dynamic scheduledAt;
  final bool? sent;
  final bool? isRead;
  final String? timeHuman;

  const NotificationEntity({
    this.id,
    this.title,
    this.body,
    this.image,
    this.route,
    this.webLink,
    this.sound,
    this.arguments,
    this.scheduledAt,
    this.sent,
    this.isRead,
    this.timeHuman,
  });
}

class NotificationListEntity {
  final bool? status;
  final int? unreadCount;
  final List<NotificationEntity> notifications;

  const NotificationListEntity({
    this.status,
    this.unreadCount,
    this.notifications = const [],
  });
}
