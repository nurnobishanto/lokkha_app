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
    try {
      await Get.find<PremiumEntitlementService>().validateEntitlement();
    } catch (e) {
      debugPrint("Error validating premium entitlement: $e");
    }

    Future.delayed(const Duration(seconds: 2), () {
      final AppUpdateService appUpdateService = AppUpdateService();
      appUpdateService.startUpdateService();
      Get.offAllNamed(Routes.NAVBAR);
    });
  }
}
