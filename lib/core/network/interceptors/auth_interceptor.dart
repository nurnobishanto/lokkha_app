import 'dart:io';
import 'package:dio/dio.dart';
import 'package:lokkha/core/services/storage/secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Read JWT token directly from encrypted storage
    final token = await SecureStorageService.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Standard V1 API Headers
    options.headers['Accept'] = 'application/json';
    options.headers['X-Platform'] =
        Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'other');
    options.headers['X-Device-Name'] = Platform.isAndroid
        ? 'Android Device'
        : (Platform.isIOS ? 'iOS Device' : 'Desktop/Web');
    options.headers['X-App-Version'] = '1.0.0';

    if (options.data is! FormData) {
      options.headers['Content-Type'] = 'application/json';
    }

    return handler.next(options);
  }
}
