import 'package:flutter/foundation.dart';
import '../../../../utils/constants.dart';
import '../models/device_session_model.dart';
import '../network/api_client.dart';

class DeviceSessionRepository {
  /// Fetch all active devices for the authenticated student
  Future<List<DeviceSessionModel>> getActiveDevices() async {
    try {
      final response = await ApiClient.get(AppConstants.v1UserDevices);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final list = (data is Map && data['data'] is List)
            ? data['data'] as List
            : (data is List ? data : []);

        return list
            .map((item) => DeviceSessionModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('[DeviceSessionRepository] Failed to fetch devices: $e');
    }
    return [];
  }

  /// Terminate a specific device session
  Future<bool> logoutDevice(int deviceId) async {
    try {
      final response = await ApiClient.post(
        AppConstants.v1UserDevicesLogout,
        data: {'device_id': deviceId},
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[DeviceSessionRepository] Logout device error: $e');
      return false;
    }
  }

  /// Logout all devices except the current one
  Future<bool> logoutOtherDevices() async {
    try {
      final response = await ApiClient.post(
        AppConstants.v1UserDevicesLogout,
        data: {'all_except_current': true},
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[DeviceSessionRepository] Logout other devices error: $e');
      return false;
    }
  }
}
