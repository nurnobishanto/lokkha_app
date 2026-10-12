import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lokkha/core/services/auth_service.dart';
import 'package:lokkha/core/services/storage/my_shared_pref.dart';
import 'package:lokkha/core/services/storage/secure_storage_service.dart';

/// Central Token & Session Manager Interceptor
class TokenManager extends Interceptor {
  /// Fetch auth token from secure storage with shared prefs fallback
  static Future<String?> getToken() async {
    try {
      var token = await SecureStorageService.getToken();
      if (token == null || token.isEmpty) {
        final prefToken = MySharedPref.getUserToken();
        if (prefToken.isNotEmpty) {
          token = prefToken;
        }
      }
      return token;
    } catch (_) {
      return null;
    }
  }

  /// Clear token from storage on logout
  static Future<void> clearToken() async {
    try {
      await SecureStorageService.clearAuthData();
      await MySharedPref.removeUserToken();
    } catch (_) {}
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Inject Bearer token if not already manually provided
    if (!options.headers.containsKey('Authorization')) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    // Standard API Headers
    options.headers['Accept'] ??= 'application/json';
    try {
      options.headers['X-Platform'] ??=
          Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'other');
      options.headers['X-Device-Name'] ??= Platform.isAndroid
          ? 'Android Device'
          : (Platform.isIOS ? 'iOS Device' : 'Desktop/Web');
    } catch (_) {
      options.headers['X-Platform'] ??= 'unknown';
      options.headers['X-Device-Name'] ??= 'Device';
    }
    options.headers['X-App-Version'] ??= '1.0.0';

    if (options.data is! FormData) {
      options.headers['Content-Type'] ??= 'application/json';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;
    final url = err.requestOptions.uri.toString();

    // 401 Unauthorized handling
    if (statusCode == 401) {
      final isAuthEndpoint = url.contains('/auth/') ||
          url.contains('login') ||
          url.contains('send-otp') ||
          url.contains('check-phone');

      if (!isAuthEndpoint) {
        if (kDebugMode) {
          debugPrint('[TokenManager] 401 Unauthorized on $url. Expiring session.');
        }
        String? serverMsg;
        if (err.response?.data is Map) {
          serverMsg = err.response?.data['message']?.toString();
        }
        AuthService().handleSessionExpired(message: serverMsg);
      }
    }

    return handler.next(err);
  }
}
