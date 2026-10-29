import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lokkha/core/services/auth_service.dart';
import 'package:lokkha/core/services/storage/my_shared_pref.dart';
import 'package:lokkha/core/services/storage/secure_storage_service.dart';
import 'package:lokkha/core/utils/global.dart';

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
      if (token == null || token.isEmpty) {
        final cachedToken = myUser.jwtToken;
        if (cachedToken != null && cachedToken.isNotEmpty) {
          token = cachedToken;
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
    // If skipAuth is requested or Authorization header is explicitly set to empty/null, do not inject token
    if (options.extra['skipAuth'] == true ||
        (options.headers.containsKey('Authorization') &&
            (options.headers['Authorization'] == null ||
                options.headers['Authorization'] == ''))) {
      options.headers.remove('Authorization');
    } else if (!options.headers.containsKey('Authorization')) {
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
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _checkSessionExpiration(response.data, response.requestOptions.uri.toString());
    return handler.next(response);
  }

  void _checkSessionExpiration(dynamic data, String url) {
    if (data is! Map) return;

    final isAuthEndpoint = url.contains('/auth/') ||
        url.contains('login') ||
        url.contains('send-otp') ||
        url.contains('check-phone') ||
        url.contains('register');

    if (isAuthEndpoint) return;

    final status = data['status'];
    final success = data['success'];
    final message = data['message']?.toString();

    // Check if status is explicitly false and session expired message is returned
    if ((status == false || success == false) && message != null) {
      final lowerMsg = message.toLowerCase();
      final isSessionExpired = lowerMsg.contains('session expired') ||
          lowerMsg.contains('maximum limit') ||
          lowerMsg.contains('logged-in device') ||
          lowerMsg.contains('device limit') ||
          lowerMsg.contains('unauthenticated') ||
          lowerMsg.contains('token expired') ||
          lowerMsg.contains('invalid token');

      if (isSessionExpired) {
        if (kDebugMode) {
          debugPrint('[TokenManager] Session expired in response ($url): $message');
        }
        AuthService().handleSessionExpired(message: message);
      }
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;
    final url = err.requestOptions.uri.toString();

    // 401 Unauthorized or 403/419 handling
    if (statusCode == 401 || statusCode == 403 || statusCode == 419) {
      final isAuthEndpoint = url.contains('/auth/') ||
          url.contains('login') ||
          url.contains('send-otp') ||
          url.contains('check-phone') ||
          url.contains('register');

      if (!isAuthEndpoint) {
        if (kDebugMode) {
          debugPrint('[TokenManager] $statusCode Unauthorized on $url. Expiring session.');
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
