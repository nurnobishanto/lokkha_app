import 'dart:convert';
import '../../domain/entities/notification_entity.dart';

NotificationModel notificationModelFromJson(String str) =>
    NotificationModel.fromJson(json.decode(str));

String notificationModelToJson(NotificationModel data) =>
    json.encode(data.toJson());

class NotificationModel extends NotificationListEntity {
  const NotificationModel({
    super.status,
    super.unreadCount,
    super.notifications,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        status: json["status"],
        unreadCount: json["unread_count"],
        notifications: json["notifications"] == null
            ? []
            : List<NotificationItemModel>.from(
                json["notifications"]!.map((x) => NotificationItemModel.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
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
                  timeHuman: x.timeHuman,
                ).toJson();
              }).toList(),
      };
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
    super.timeHuman,
  });

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) =>
      NotificationItemModel(
        id: json["id"],
        title: json["title"],
        body: json["body"],
        image: json["image"],
        route: json["route"],
        webLink: json["web_link"],
        sound: json["sound"],
        arguments: json["arguments"],
        scheduledAt: json["scheduled_at"],
        sent: json["sent"],
        isRead: json["is_read"],
        timeHuman: json["time_human"],
      );

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
        "time_human": timeHuman,
      };
}
