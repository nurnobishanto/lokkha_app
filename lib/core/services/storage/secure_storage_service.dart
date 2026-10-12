import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  const SecureStorageService();

  Future<String?> getAuthToken() async => getToken();
  Future<void> saveAuthToken(String token) async => saveToken(token);

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static const String _keyToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyDeviceId = 'device_id';

  /// Save Auth Token
  static Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _keyToken, value: token);
    } catch (e) {
      debugPrint('[SecureStorageService] Error saving token: $e');
    }
  }

  /// Get Auth Token
  static Future<String?> getToken() async {
    try {
      return await _storage.read(key: _keyToken);
    } catch (e) {
      return null;
    }
  }

  /// Save Refresh Token
  static Future<void> saveRefreshToken(String refreshToken) async {
    try {
      await _storage.write(key: _keyRefreshToken, value: refreshToken);
    } catch (e) {
      debugPrint('[SecureStorageService] Error saving refresh token: $e');
    }
  }

  /// Get Refresh Token
  static Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _keyRefreshToken);
    } catch (e) {
      return null;
    }
  }

  /// Save Device ID
  static Future<void> saveDeviceId(String deviceId) async {
    try {
      await _storage.write(key: _keyDeviceId, value: deviceId);
    } catch (e) {
      debugPrint('[SecureStorageService] Error saving device id: $e');
    }
  }

  /// Get Device ID
  static Future<String?> getDeviceId() async {
    try {
      return await _storage.read(key: _keyDeviceId);
    } catch (e) {
      return null;
    }
  }

  /// Save User ID
  static Future<void> saveUserId(String userId) async {
    try {
      await _storage.write(key: _keyUserId, value: userId);
    } catch (e) {
      debugPrint('[SecureStorageService] Error saving user id: $e');
    }
  }

  /// Get User ID
  static Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _keyUserId);
    } catch (e) {
      return null;
    }
  }

  /// Delete All Auth Credentials (Logout)
  static Future<void> clearAuthData() async {
    try {
      await _storage.delete(key: _keyToken);
      await _storage.delete(key: _keyRefreshToken);
      await _storage.delete(key: _keyUserId);
    } catch (e) {
      debugPrint('[SecureStorageService] Error clearing auth data: $e');
    }
  }

  /// Clear everything in secure storage
  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      debugPrint('[SecureStorageService] Error clearing all secure storage: $e');
    }
  }
}
