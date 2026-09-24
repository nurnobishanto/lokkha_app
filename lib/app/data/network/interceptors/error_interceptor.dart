import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:lokkha/app/data/local/secure_storage_service.dart';
import 'package:lokkha/app/data/local/my_shared_pref.dart';
import 'package:lokkha/app/routes/app_pages.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;

    if (statusCode == 401) {
      debugPrint('[ErrorInterceptor] 401 Unauthorized detected. Clearing session.');
      // Clear token & auth data
      await SecureStorageService.clearAuthData();
      await MySharedPref.removeUserToken();

      // If user is not already on Auth screens, route to auth gateway
      if (Get.currentRoute != Routes.AUTH_GATEWAY &&
          Get.currentRoute != Routes.SIGNIN &&
          Get.currentRoute != Routes.SPLASH) {
        Get.offAllNamed(Routes.AUTH_GATEWAY);
      }
    }

    return handler.next(err);
  }
}
