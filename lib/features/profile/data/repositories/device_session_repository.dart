import 'package:flutter/foundation.dart';
import 'package:lokkha/core/constants/app_constants.dart';
import 'package:lokkha/features/profile/profile.dart';
import 'package:lokkha/core/network/api_client.dart';

class DeviceSessionRepository {
  /// Fetch all active devices for the authenticated student (GET /api/v1/user/devices)
  Future<List<DeviceSessionModel>> getActiveDevices() async {
    try {
      final response = await ApiClient.get(AppConstants.v1UserDevices);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final list = (data is Map && data['data'] != null && data['data']['active_devices'] is List)
            ? data['data']['active_devices'] as List
            : ((data is Map && data['data'] is List)
                ? data['data'] as List
                : (data is List ? data : []));

        return list
            .map((item) => DeviceSessionModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('[DeviceSessionRepository] Failed to fetch devices: $e');
    }
    return [];
  }

  /// Terminate a specific device session (DELETE /api/v1/user/devices/{id})
  Future<bool> logoutDevice(int deviceId) async {
    try {
      final response = await ApiClient.delete(
        '${AppConstants.v1UserDevices}/$deviceId',
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[DeviceSessionRepository] Logout device error: $e');
      return false;
    }
  }

  /// Logout all devices except the current one (POST /api/v1/user/devices/logout-others)
  Future<bool> logoutOtherDevices() async {
    try {
      final response = await ApiClient.post(
        AppConstants.v1UserDevicesLogoutOthers,
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[DeviceSessionRepository] Logout other devices error: $e');
      return false;
    }
  }
}
