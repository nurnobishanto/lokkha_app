import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'premium_entitlement_service.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// AppLifecycleService
///
/// Listens to Flutter app lifecycle events and triggers background services
/// when the app returns to the foreground.
///
/// Responsibilities:
///  - Re-validate premium entitlement on app resume
///  - Trigger app-update/maintenance check on app resume
/// ─────────────────────────────────────────────────────────────────────────────
class AppLifecycleService extends GetxService with WidgetsBindingObserver {
  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    log('AppLifecycleService initialized');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      log('📱 App resumed — re-validating entitlement');
      // Re-validate premium entitlement when user returns to app.
      // This catches cases where the package expired while app was backgrounded.
      Get.find<PremiumEntitlementService>().validateEntitlement();
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}
