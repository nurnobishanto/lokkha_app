import 'dart:async';
import 'package:lokkha/core/network/endpoints.dart';
import 'package:lokkha/core/errors/exceptions.dart';
import 'package:lokkha/core/network/rest_client.dart';
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
  final RestClient _client;

  NotificationRemoteDataSourceImpl({RestClient? client})
      : _client = client ?? RestClient();

  @override
  Future<NotificationModel> fetchNotifications({required String? deviceId}) async {
    final token = MySharedPref.getUserToken();
    final headers = {
      'Authorization': 'Bearer $token',
    };
    final url = "${Endpoints.notifications}?device_id=$deviceId";

    final response = await _client.get(
      url,
      headers: headers,
    );

    if (response.data["status"] == true) {
      return NotificationModel.fromJson(response.data);
    } else {
      throw AppException(
        response.data["message"]?.toString() ?? "Failed to fetch notifications",
      );
    }
  }

  @override
  Future<bool> markAsRead({
    required int notificationId,
    required String? deviceId,
    required bool isRead,
  }) async {
    final token = MySharedPref.getUserToken();
    final headers = {
      'Authorization': 'Bearer $token',
    };
    final url = "${Endpoints.notifications}/$notificationId/read";
    final data = {'device_id': deviceId, 'is_read': isRead};

    final response = await _client.post(
      url,
      headers: headers,
      data: data,
    );

    return response.data['status'] == true;
  }
}
