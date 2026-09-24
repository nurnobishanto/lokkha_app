import 'package:dio/dio.dart';
import 'package:lokkha/app/data/local/secure_storage_service.dart';
import 'package:lokkha/app/data/local/my_shared_pref.dart';

class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Attempt to get token from SecureStorageService first, then fallback to MySharedPref
    String? token = await SecureStorageService.getToken();
    if (token == null || token.isEmpty) {
      token = MySharedPref.getUserToken();
    }

    if (token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    options.headers['Accept'] = 'application/json';
    if (options.data is! FormData) {
      options.headers['Content-Type'] = 'application/json';
    }

    return handler.next(options);
  }
}
