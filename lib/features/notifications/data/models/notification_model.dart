import 'dart:convert';
import '../../domain/entities/notification_entity.dart';

NotificationModel notificationModelFromJson(String str) =>
    NotificationModel.fromJson(json.decode(str));

String notificationModelToJson(NotificationModel data) =>
    json.encode(data.toJson());

class NotificationModel extends NotificationListEntity {
  const NotificationModel({
    super.status,
    super.message,
    super.unreadCount,
    super.notifications,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final bool isSuccess = json["success"] == true || json["status"] == true;
    final String? message = json["message"]?.toString();

    // Support both wrapped v1 envelope {"success": true, "data": {...}} and raw data map
    final Map<String, dynamic> data = json["data"] is Map<String, dynamic>
        ? json["data"] as Map<String, dynamic>
        : json;

    final dynamic rawUnreadCount = data["unread_count"] ?? json["unread_count"];
    final int unreadCount = rawUnreadCount is num
        ? rawUnreadCount.toInt()
        : int.tryParse(rawUnreadCount?.toString() ?? '') ?? 0;

    final dynamic rawNotifications =
        data["notifications"] ?? json["notifications"];
    final List<NotificationItemModel> notificationList = [];

    if (rawNotifications is List) {
      for (final item in rawNotifications) {
        if (item is Map<String, dynamic>) {
          notificationList.add(NotificationItemModel.fromJson(item));
        }
      }
    }

    return NotificationModel(
      status: isSuccess,
      message: message,
      unreadCount: unreadCount,
      notifications: notificationList,
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "unread_count": unreadCount,
        "notifications": notifications.isEmpty
            ? []
            : notifications.map((x) {
                if (x is NotificationItemModel) return x.toJson();
                return NotificationItemModel(
                  id: x.id,
                  title: x.title,
                  body: x.body,
                  image: x.image,
                  route: x.route,
                  webLink: x.webLink,
                  sound: x.sound,
                  arguments: x.arguments,
                  scheduledAt: x.scheduledAt,
                  sent: x.sent,
                  isRead: x.isRead,
                  createdAt: x.createdAt,
                  timeHuman: x.timeHuman,
                ).toJson();
              }).toList(),
      };

  @override
  NotificationModel copyWith({
    bool? status,
    String? message,
    int? unreadCount,
    List<NotificationEntity>? notifications,
  }) {
    return NotificationModel(
      status: status ?? this.status,
      message: message ?? this.message,
      unreadCount: unreadCount ?? this.unreadCount,
      notifications: notifications ?? this.notifications,
    );
  }
}

class NotificationItemModel extends NotificationEntity {
  const NotificationItemModel({
    super.id,
    super.title,
    super.body,
    super.image,
    super.route,
    super.webLink,
    super.sound,
    super.arguments,
    super.scheduledAt,
    super.sent,
    super.isRead,
    super.createdAt,
    super.timeHuman,
  });

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawId = json["id"];
    final int? id = rawId is num
        ? rawId.toInt()
        : int.tryParse(rawId?.toString() ?? '');

    final dynamic rawIsRead = json["is_read"];
    final bool isRead = rawIsRead is bool
        ? rawIsRead
        : (rawIsRead == 1 || rawIsRead == '1' || rawIsRead == 'true');

    final dynamic rawSent = json["sent"];
    final bool? sent = rawSent is bool
        ? rawSent
        : (rawSent != null
            ? (rawSent == 1 || rawSent == '1' || rawSent == 'true')
            : null);

    return NotificationItemModel(
      id: id,
      title: json["title"]?.toString(),
      body: json["body"]?.toString(),
      image: json["image"]?.toString(),
      route: json["route"]?.toString(),
      webLink: json["web_link"]?.toString() ?? json["weblink"]?.toString(),
      sound: json["sound"],
      arguments: json["arguments"],
      scheduledAt: json["scheduled_at"]?.toString(),
      sent: sent,
      isRead: isRead,
      createdAt: json["created_at"]?.toString(),
      timeHuman: json["time_human"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "body": body,
        "image": image,
        "route": route,
        "web_link": webLink,
        "sound": sound,
        "arguments": arguments,
        "scheduled_at": scheduledAt,
        "sent": sent,
        "is_read": isRead,
        "created_at": createdAt,
        "time_human": timeHuman,
      };
}

class MarkReadResponseModel {
  final bool markedRead;
  final int? notificationId;

  const MarkReadResponseModel({
    required this.markedRead,
    this.notificationId,
  });

  factory MarkReadResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json["data"] is Map<String, dynamic>
        ? json["data"] as Map<String, dynamic>
        : json;
    final dynamic rawId = data["notification_id"];
    final int? notifId = rawId is num
        ? rawId.toInt()
        : int.tryParse(rawId?.toString() ?? '');

    return MarkReadResponseModel(
      markedRead: data["marked_read"] == true || json["success"] == true,
      notificationId: notifId,
    );
  }
}

class MarkAllReadResponseModel {
  final bool allMarkedRead;

  const MarkAllReadResponseModel({
    required this.allMarkedRead,
  });

  factory MarkAllReadResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json["data"] is Map<String, dynamic>
        ? json["data"] as Map<String, dynamic>
        : json;
    return MarkAllReadResponseModel(
      allMarkedRead: data["all_marked_read"] == true || json["success"] == true,
    );
  }
}
