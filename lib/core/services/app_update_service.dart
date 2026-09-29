import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lokkha/features/navigation/navigation.dart';
import 'package:lokkha/core/network/base_client.dart';
import 'package:lokkha/core/constants/app_images.dart';
import 'package:lokkha/core/theme/light_theme_colors.dart';
import 'package:lokkha/core/constants/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lokkha/core/utils/global.dart';
import 'package:lokkha/features/app_system/app_system.dart';
import 'package:lokkha/routes/routes.dart';

class AppUpdateService {
  static final AppUpdateService _instance = AppUpdateService._internal();
  factory AppUpdateService() => _instance;
  AppUpdateService._internal();
  // RxString appVersionCode = ''.obs;
  RxBool updateRequiredCheck = false.obs;
  RxBool firstAppUpdateCalled = false.obs;
  bool updateRequired = false;
  bool maintenanceMode = false;

  Timer? _firstTimer;
  Timer? _timer;

  void startUpdateService() {
    // Cancel previous timers if any
    stopUpdateService();
    // Run version check once on service startup
    appVersionCheck();
  }

  void stopUpdateService() {
    _firstTimer?.cancel();
    _firstTimer = null;
    _timer?.cancel();
    _timer = null;
  }

  Future<void> appVersionCheck() async {
    String platform = 'android';

    if (Platform.isAndroid) {
      platform = 'android';
    } else if (Platform.isIOS) {
      platform = 'ios';
    }
    log("My Platform:$platform");
    String authCheckUrl =
        "${AppConstants.appVersionCheck}?platform=$platform&version_code=$appVersionCode";

    BaseClient.safeApiCall(authCheckUrl, RequestType.get,
        onSuccess: (response) {
      if (response.data['status'] == true) {
        updateRequired = response.data['update_required'] == true;
        maintenanceMode = response.data['maintenance_mode'] == true;
        bool hasAppUrl = response.data['app_url'] != null;
        Uri url = Uri.parse(response.data['app_url'].toString());
        if (updateRequired) {
          // updateRequiredCheck.value = true;
          log("Called Update screen");
          Get.offAll(AppUpdateView(url: url));
        } else if (maintenanceMode) {
          log("Called Maintenance Mode screen");
          Get.offAll(const MaintenanceModeView());
        } else if (hasAppUrl) {
          Get.defaultDialog(
            title: "New Version Available",
            titlePadding: const EdgeInsets.only(top: 10.0),
            buttonColor: LightThemeColors.primaryColor,
            cancelTextColor: LightThemeColors.black,
            confirmTextColor: LightThemeColors.white,
            contentPadding: const EdgeInsets.all(10),
            content: Container(
              padding: const EdgeInsets.all(0.0),
              child: Column(
                children: [
                  Image.asset(AssetImagePaths.appIcon, width: 100),
                  const SizedBox(height: 4.0),
                  Text(
                    response.data['message'].toString(),
                  ),
                ],
              ),
            ),
            onConfirm: () async {
              if (!await launchUrl(url)) {
                throw Exception('Could not launch $url');
              }
            },
            onCancel: () => Get.back(),
            textConfirm: "Update Now",
            textCancel: "Later",
          );
        }
      } else {
        log("App update check: ${response.data['message']}");
        if (Get.currentRoute == Routes.MAINTENANCE_MODE_VIEW ||
            Get.currentRoute == Routes.APP_UPDATE_VIEW) {
          Get.offAll(const NavbarView());
        }
      }
    });
  }
}
