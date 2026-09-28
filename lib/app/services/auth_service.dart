import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lokkha/app/data/local/my_get_storage.dart';
import 'package:lokkha/app/data/local/my_shared_pref.dart';
import 'package:lokkha/app/data/local/secure_storage_service.dart';
import 'package:lokkha/app/data/repositories/auth_repository.dart';
import 'package:lokkha/config/theme/light_theme_colors.dart';

import '../helper/global.dart';
import '../models/user.dart';
import '../modules/navbar/controllers/navbar_controller.dart';
import '../routes/app_pages.dart';
import 'api_call_status.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  ApiCallStatus apiCallStatus = ApiCallStatus.holding;
  static bool _isSessionDialogShowing = false;

  /// Handle session expiration with a dialog
  void handleSessionExpired({String? message}) async {
    final token = await SecureStorageService.getToken();
    final prefToken = MySharedPref.getUserToken();
    if ((token == null || token.isEmpty) && prefToken.isEmpty && !isLoggedIn.value) {
      return;
    }

    if (_isSessionDialogShowing) return;
    _isSessionDialogShowing = true;

    // Clear user session state
    isLoggedIn.value = false;
    havePackage.value = false;
    await SecureStorageService.clearAuthData();
    await MySharedPref.removeUserToken();
    MyGetStorage.removeCache(MyGetStorage.meUser);
    myUser = User();

    if (Get.isRegistered<NavbarController>()) {
      Get.find<NavbarController>().clearProfileState();
    }

    // Do not show dialog if already on authentication screens
    if (Get.currentRoute == Routes.AUTH_GATEWAY ||
        Get.currentRoute == Routes.SIGNIN ||
        Get.currentRoute == Routes.VERIFY_OTP) {
      _isSessionDialogShowing = false;
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      final bool isBanglaMessage =
          message != null && RegExp(r'[\u0980-\u09FF]').hasMatch(message);
      final String dialogMessage = isBanglaMessage
          ? message
          : "আপনার অ্যাকাউন্টের সুরক্ষার স্বার্থে সেশনের মেয়াদ শেষ হয়েছে। অ্যাপের সকল সুবিধা পেতে অনুগ্রহ করে পুনরায় লগইন করুন।";

      Get.dialog(
        PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            _isSessionDialogShowing = false;
          },
          child: Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            elevation: 4,
            insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56.r,
                    height: 56.r,
                    decoration: BoxDecoration(
                      color: LightThemeColors.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_outline_rounded,
                      size: 30.r,
                      color: LightThemeColors.primaryColor,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    "সেশনের মেয়াদ শেষ",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    dialogMessage,
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      color: Colors.black54,
                      height: 1.45,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 22.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _isSessionDialogShowing = false;
                            Get.back();
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            "বাতিল",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _isSessionDialogShowing = false;
                            Get.back();
                            Get.offAllNamed(Routes.AUTH_GATEWAY);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: LightThemeColors.primaryColor,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: Text(
                            "লগইন করুন",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );
    });
  }

  /// Auth Check method (Pure V1 with offline session preservation)
  Future<void> authCheck() async {
    debugPrint("Auth Check Called..");
    var token = await SecureStorageService.getToken();

    // Fallback: If SecureStorage is empty but MySharedPref has token, sync to SecureStorage
    if ((token == null || token.isEmpty) && MySharedPref.getUserToken().isNotEmpty) {
      token = MySharedPref.getUserToken();
      await SecureStorageService.saveToken(token);
    }

    if (token == null || token.isEmpty) {
      isLoggedIn.value = false;
      await MySharedPref.removeUserToken();
      if (Get.currentRoute != Routes.AUTH_GATEWAY &&
          Get.currentRoute != Routes.SPLASH) {
        Get.offAllNamed(Routes.AUTH_GATEWAY);
      }
      return;
    }

    // Ensure MySharedPref has token synced
    if (MySharedPref.getUserToken().isEmpty) {
      await MySharedPref.setUserToken(token);
    }

    final authRepo = AuthRepository();
    final res = await authRepo.getCurrentUser();

    if (res != null) {
      if (res.status) {
        apiCallStatus = ApiCallStatus.success;
        isLoggedIn.value = true;
        havePackage.value = res.havePackage;

        // Check profile completion requirement
        if (!res.profileCompleted || res.rawData?['update_profile_required'] == true) {
          Get.toNamed(Routes.PROFILE_UPDATE_REQUIRED, arguments: {
            "phoneNumber": res.user?.phone ?? res.rawData?["data"]?["phone"] ?? "",
          });
        }

        if (Get.isRegistered<NavbarController>()) {
          Get.find<NavbarController>().getMeProfileInfo();
        }
      } else {
        // Explicit invalid session response from server
        apiCallStatus = ApiCallStatus.error;
        handleSessionExpired(message: res.message);
      }
    } else {
      // Network timeout / offline: keep offline cached session
      debugPrint("Auth Check: Network unavailable, keeping cached session");
      isLoggedIn.value = true;
    }
  }
}
