import 'dart:developer';
import 'package:flutter/material.dart';
import 'premium_entitlement_service.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// AppLifecycleService
///
/// Listens to Flutter app lifecycle events and triggers background services
/// when the app returns to the foreground.
///
/// Responsibilities:
///  - Re-validate premium entitlement on app resume
/// ─────────────────────────────────────────────────────────────────────────────
class AppLifecycleService with WidgetsBindingObserver {
  static final AppLifecycleService instance = AppLifecycleService._();
  AppLifecycleService._();

  static void init() {
    instance._init();
  }

  void _init() {
    WidgetsBinding.instance.addObserver(this);
    log('AppLifecycleService initialized');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      log('📱 App resumed — re-validating entitlement');
      PremiumEntitlementService.to.validateEntitlement();
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
