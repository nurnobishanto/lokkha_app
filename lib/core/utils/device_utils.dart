import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Utility class for detecting device model, name, and platform in a safe, testable way.
class DeviceUtils {
  DeviceUtils._();

  static String? _cachedDeviceName;

  /// Retrieves human-readable device name (e.g. 'Google Pixel 8', 'iPhone 15 Pro')
  static Future<String> getDeviceName({DeviceInfoPlugin? plugin}) async {
    if (_cachedDeviceName != null && _cachedDeviceName!.isNotEmpty) {
      return _cachedDeviceName!;
    }

    try {
      final deviceInfo = plugin ?? DeviceInfoPlugin();
      if (kIsWeb) {
        _cachedDeviceName = 'Web Browser';
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        final brand = androidInfo.brand;
        final model = androidInfo.model;
        if (brand.isNotEmpty && !model.toLowerCase().startsWith(brand.toLowerCase())) {
          _cachedDeviceName = '$brand $model';
        } else {
          _cachedDeviceName = model.isNotEmpty ? model : 'Android Device';
        }
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _cachedDeviceName = iosInfo.name.isNotEmpty
            ? iosInfo.name
            : (iosInfo.utsname.machine.isNotEmpty ? iosInfo.utsname.machine : 'iPhone');
      } else {
        _cachedDeviceName = Platform.operatingSystem;
      }
    } catch (e) {
      debugPrint('[DeviceUtils] Error getting device name: $e');
      _cachedDeviceName = Platform.isAndroid
          ? 'Android Device'
          : (Platform.isIOS ? 'iPhone' : 'Mobile Device');
    }

    return _cachedDeviceName ?? 'Mobile Device';
  }

  /// Returns canonical platform identifier ('android' or 'ios')
  static String getPlatform() {
    if (kIsWeb) return 'web';
    try {
      if (Platform.isAndroid) return 'android';
      if (Platform.isIOS) return 'ios';
      return Platform.operatingSystem.toLowerCase();
    } catch (_) {
      return 'android';
    }
  }

  @visibleForTesting
  static void setMockDeviceName(String? name) {
    _cachedDeviceName = name;
  }

  @visibleForTesting
  static void reset() {
    _cachedDeviceName = null;
  }
}
