import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lokkha/core/services/storage/app_storage_cache.dart';
import 'package:lokkha/core/services/storage/my_shared_pref.dart';
import 'package:lokkha/core/services/storage/secure_storage_service.dart';
import 'package:lokkha/features/auth/auth.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/core/utils/global.dart';
import 'package:lokkha/shared/models/user.dart';
import 'package:lokkha/app/router/router.dart';
import 'package:lokkha/core/constants/app_constants.dart';
import 'package:lokkha/core/network/rest_client.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

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

    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      _isSessionDialogShowing = false;
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bool isBanglaMessage =
          message != null && RegExp(r'[\u0980-\u09FF]').hasMatch(message);
      final String dialogMessage = isBanglaMessage
          ? message
          : "আপনার অ্যাকাউন্টের সুরক্ষার স্বার্থে সেশনের মেয়াদ শেষ হয়েছে। অ্যাপের সকল সুবিধা পেতে অনুগ্রহ করে পুনরায় লগইন করুন।";

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogCtx) => PopScope(
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
                            Navigator.of(dialogCtx).pop();
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
                            Navigator.of(dialogCtx).pop();
                            context.goNamed(Routes.authGateway);
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
      final context = rootNavigatorKey.currentContext;
      if (context != null) {
        context.goNamed(Routes.authGateway);
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
        isLoggedIn.value = true;
        havePackage.value = res.havePackage;

        // Check profile completion requirement
        if (!res.profileCompleted || res.rawData?['update_profile_required'] == true) {
          final context = rootNavigatorKey.currentContext;
          if (context != null) {
            context.pushNamed(Routes.profileUpdateRequired, extra: {
              "phoneNumber": res.user?.phone ?? res.rawData?["data"]?["phone"] ?? "",
            });
          }
        }
      } else {
        // Explicit invalid session response from server
        handleSessionExpired(message: res.message);
      }
    } else {
      // Network timeout / offline: keep offline cached session
      debugPrint("Auth Check: Network unavailable, keeping cached session");
      isLoggedIn.value = true;
    }
  }

  /// Logout the current user completely and reset state
  Future<void> logout() async {
    try {
      final token = await SecureStorageService.getToken();
      if (token != null && token.isNotEmpty) {
        try {
          await RestClient().post(AppConstants.v1AuthLogout);
        } catch (e) {
          debugPrint('[AuthService.logout] Remote API logout warning: $e');
        }
      }
    } catch (e) {
      debugPrint('[AuthService.logout] Pre-cleanup error: $e');
    } finally {
      // Always wipe local credentials regardless of API response
      await SecureStorageService.clearAuthData();
      await MySharedPref.removeUserToken();
      MyGetStorage.removeCache(MyGetStorage.meUser);
      isLoggedIn.value = false;
      havePackage.value = false;
      myUser = User();

      CustomSnackBar.showCustomToast(message: "লগআউট সফল হয়েছে");
      final context = rootNavigatorKey.currentContext;
      if (context != null) {
        context.goNamed(Routes.authGateway);
      }
    }
  }

  /// Show a standardized logout confirmation modal
  static void confirmAndLogout() {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          "লগ আউট",
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "আপনি কি নিশ্চিতভাবে আপনার অ্যাকাউন্ট থেকে লগ আউট করতে চান?",
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("বাতিল", style: TextStyle(color: Colors.black87)),
          ),
          TextButton(
            style: TextButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.of(ctx).pop();
              AuthService().logout();
            },
            child: const Text("হ্যাঁ, লগ আউট", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
