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
  final String? createdAt;
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
    this.createdAt,
    this.timeHuman,
  });

  NotificationEntity copyWith({
    int? id,
    String? title,
    String? body,
    String? image,
    String? route,
    String? webLink,
    dynamic sound,
    dynamic arguments,
    dynamic scheduledAt,
    bool? sent,
    bool? isRead,
    String? createdAt,
    String? timeHuman,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      image: image ?? this.image,
      route: route ?? this.route,
      webLink: webLink ?? this.webLink,
      sound: sound ?? this.sound,
      arguments: arguments ?? this.arguments,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      sent: sent ?? this.sent,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      timeHuman: timeHuman ?? this.timeHuman,
    );
  }
}

class NotificationListEntity {
  final bool? status;
  final String? message;
  final int? unreadCount;
  final List<NotificationEntity> notifications;

  const NotificationListEntity({
    this.status,
    this.message,
    this.unreadCount,
    this.notifications = const [],
  });

  NotificationListEntity copyWith({
    bool? status,
    String? message,
    int? unreadCount,
    List<NotificationEntity>? notifications,
  }) {
    return NotificationListEntity(
      status: status ?? this.status,
      message: message ?? this.message,
      unreadCount: unreadCount ?? this.unreadCount,
      notifications: notifications ?? this.notifications,
    );
  }
}

