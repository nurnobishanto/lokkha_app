import 'dart:async';
import 'package:lokkha/core/constants/app_constants.dart';
import 'package:lokkha/core/network/base_client.dart';
import 'package:lokkha/core/services/storage/my_shared_pref.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<NotificationModel> fetchNotifications({required String? deviceId});
  Future<bool> markAsRead({
    required int notificationId,
    required String? deviceId,
    required bool isRead,
  });
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  @override
  Future<NotificationModel> fetchNotifications({required String? deviceId}) async {
    final completer = Completer<NotificationModel>();
    final token = MySharedPref.getUserToken();
    final headers = {
      'Authorization': 'Bearer $token',
    };
    final url = "${AppConstants.notifications}?device_id=$deviceId";

    BaseClient.safeApiCall(
      url,
      RequestType.get,
      headers: headers,
      onSuccess: (response) {
        if (response.data["status"] == true) {
          completer.complete(NotificationModel.fromJson(response.data));
        } else {
          completer.completeError(
            response.data["message"] ?? "Failed to fetch notifications",
          );
        }
      },
      onError: (err) {
        completer.completeError(err);
      },
    );

    return completer.future;
  }

  @override
  Future<bool> markAsRead({
    required int notificationId,
    required String? deviceId,
    required bool isRead,
  }) async {
    final completer = Completer<bool>();
    final token = MySharedPref.getUserToken();
    final headers = {
      'Authorization': 'Bearer $token',
    };
    final url = "${AppConstants.notifications}/$notificationId/read";
    final data = {'device_id': deviceId, 'is_read': isRead};

    BaseClient.safeApiCall(
      url,
      RequestType.post,
      headers: headers,
      data: data,
      onSuccess: (response) {
        if (response.data['status'] == true) {
          completer.complete(true);
        } else {
          completer.complete(false);
        }
      },
      onError: (err) {
        completer.completeError(err);
      },
    );

    return completer.future;
  }
}
