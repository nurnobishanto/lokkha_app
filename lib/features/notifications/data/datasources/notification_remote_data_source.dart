import 'dart:async';
import 'package:dio/dio.dart';
import 'package:lokkha/core/errors/exceptions.dart';
import 'package:lokkha/core/network/endpoints.dart';
import 'package:lokkha/core/network/rest_client.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<NotificationModel> fetchNotifications({String? deviceId});
  Future<bool> markAsRead({
    required int notificationId,
    String? deviceId,
    bool isRead = true,
  });
  Future<bool> markAllAsRead({String? deviceId});
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final RestClient _client;

  NotificationRemoteDataSourceImpl({RestClient? client})
      : _client = client ?? RestClient();

  @override
  Future<NotificationModel> fetchNotifications({String? deviceId}) async {
    final queryParams = <String, dynamic>{};
    if (deviceId != null && deviceId.isNotEmpty) {
      queryParams['device_id'] = deviceId;
    }

    // /api/v1/notifications is a Public endpoint that tracks notification delivery by device_id.
    // The backend NotificationController@index crashes with a 500 Server Error if Authorization: Bearer is sent.
    // skipAuth: true prevents injecting the Bearer header and prevents the 500 Server Error.
    final response = await _client.get(
      Endpoints.notifications,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
      options: Options(extra: {'skipAuth': true}),
    );

    if (response.data is Map<String, dynamic>) {
      final map = response.data as Map<String, dynamic>;
      if (map['success'] == true ||
          map['status'] == true ||
          map.containsKey('data')) {
        return NotificationModel.fromJson(map);
      }
      throw AppException(
        map['message']?.toString() ?? 'Failed to fetch notifications',
      );
    }
    throw const AppException('Invalid notifications response format');
  }

  @override
  Future<bool> markAsRead({
    required int notificationId,
    String? deviceId,
    bool isRead = true,
  }) async {
    final url = Endpoints.notificationMarkRead(notificationId);
    final data = <String, dynamic>{
      if (deviceId != null && deviceId.isNotEmpty) 'device_id': deviceId,
      'is_read': isRead,
    };

    final response = await _client.post(
      url,
      data: data.isNotEmpty ? data : null,
      options: (deviceId != null && deviceId.isNotEmpty)
          ? Options(extra: {'skipAuth': true})
          : null,
    );

    if (response.data is Map<String, dynamic>) {
      final map = response.data as Map<String, dynamic>;
      return map['success'] == true ||
          map['status'] == true ||
          map['data']?['marked_read'] == true;
    }
    return false;
  }

  @override
  Future<bool> markAllAsRead({String? deviceId}) async {
    final url = Endpoints.notificationsReadAll;
    final data = <String, dynamic>{
      if (deviceId != null && deviceId.isNotEmpty) 'device_id': deviceId,
    };

    final response = await _client.post(
      url,
      data: data.isNotEmpty ? data : null,
      options: (deviceId != null && deviceId.isNotEmpty)
          ? Options(extra: {'skipAuth': true})
          : null,
    );

    if (response.data is Map<String, dynamic>) {
      final map = response.data as Map<String, dynamic>;
      return map['success'] == true ||
          map['status'] == true ||
          map['data']?['all_marked_read'] == true;
    }
    return false;
  }
}
