import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:lokkha/routes/routes.dart';
import 'package:lokkha/core/services/app_update_service.dart';
import 'package:lokkha/core/services/premium_entitlement_service.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    debugPrint("Splash called initial");
    _initAppAndNavigate();
  }

  Future<void> _initAppAndNavigate() async {
    final appUpdateService = AppUpdateService();

    // Run parallel initializations with timeout protection
    await Future.wait([
      // 1. Validate entitlement
      () async {
        try {
          await Get.find<PremiumEntitlementService>().validateEntitlement();
        } catch (e) {
          debugPrint("Error validating premium entitlement: $e");
        }
      }(),
      // 2. Fetch v1 dynamic app-info and evaluate version/maintenance
      () async {
        try {
          await appUpdateService.fetchAppInfoAndCheckVersion();
        } catch (e) {
          debugPrint("Error fetching v1 app-info: $e");
        }
      }(),
      // 3. Minimum 1.8 seconds splash branding duration
      Future.delayed(const Duration(milliseconds: 1800)),
    ]);

    // Handle maintenance and force update blocking
    final canProceed = appUpdateService.handleStartupFlow();
    if (canProceed) {
      Get.offAllNamed(Routes.NAVBAR);
      Future.delayed(const Duration(milliseconds: 700), () {
        appUpdateService.showInAppAnnouncementIfAvailable();
      });
    }
  }
}
