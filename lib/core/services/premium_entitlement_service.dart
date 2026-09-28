import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lokkha/app/data/local/secure_storage_service.dart';
import 'package:lokkha/app/data/repositories/auth_repository.dart';

import 'package:lokkha/core/utils/global.dart';
import 'package:lokkha/core/network/api_call_status.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// PremiumEntitlementService
///
/// SINGLE SOURCE OF TRUTH for premium package access.
///
/// Replaces the scattered `havePackage.value` reads across the app.
/// Every premium feature check must go through this service.
///
/// Key guarantees:
///  - Entitlement is re-validated from the server on app start, app resume,
///    and immediately after any purchase completes.
///  - Local cache is invalidated after [_cacheDuration] minutes.
///  - The global `havePackage` Rx variable is always kept in sync so that
///    existing Obx() widgets continue to react without any changes.
///  - Controller lifecycle cannot accidentally grant access via stale state.
/// ─────────────────────────────────────────────────────────────────────────────
class PremiumEntitlementService extends GetxService {
  // ── Public reactive state ────────────────────────────────────────────────
  final Rx<ApiCallStatus> validationStatus = ApiCallStatus.holding.obs;

  // ── Cache control ────────────────────────────────────────────────────────
  DateTime? _lastValidatedAt;
  static const Duration _cacheDuration = Duration(minutes: 5);

  // ── Singleton accessor ───────────────────────────────────────────────────
  static PremiumEntitlementService get to =>
      Get.find<PremiumEntitlementService>();

  // ── Public API ───────────────────────────────────────────────────────────

  /// Convenience getter — the authoritative premium check.
  /// All premium guards must use this, never read [havePackage] directly.
  bool get isPremiumValid => havePackage.value;

  /// Full server-side validation.
  /// Call on: app start, app resume.
  Future<void> validateEntitlement() async {
    // Skip if recently validated (unless forced)
    if (_isCacheValid()) {
      log('🔑 Entitlement cache valid — skipping network call');
      return;
    }
    await _fetchEntitlement();
  }

  /// Force refresh — always hits the server.
  /// Call immediately after: PaymentWebView completes, IAP purchase delivers.
  Future<void> refreshAfterPurchase() async {
    log('🔑 Refreshing entitlement after purchase...');
    _lastValidatedAt = null; // Invalidate cache
    await _fetchEntitlement();
  }

  /// Asserts premium access. If not valid, calls [onDenied] or shows a
  /// navigate-to-packages bottom sheet by default.
  ///
  /// Usage in controller.onInit():
  /// ```dart
  /// PremiumEntitlementService.to.assertPremiumAccess(onDenied: () {
  ///   Get.back();
  ///   Get.toNamed(Routes.PREMIUM_PACKAGES);
  /// });
  /// ```
  void assertPremiumAccess({VoidCallback? onDenied}) {
    if (!isPremiumValid) {
      log('🔒 Premium access denied — redirecting');
      if (onDenied != null) {
        onDenied();
      } else {
        _defaultDenialAction();
      }
    }
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  bool _isCacheValid() {
    if (_lastValidatedAt == null) return false;
    return DateTime.now().difference(_lastValidatedAt!) < _cacheDuration;
  }

  Future<void> _fetchEntitlement() async {
    final token = await SecureStorageService.getToken();
    if (token == null || token.isEmpty) {
      // Not logged in → no entitlement
      _updateState(hasPremium: false);
      return;
    }

    validationStatus.value = ApiCallStatus.loading;

    try {
      final authRepo = AuthRepository();
      final res = await authRepo.getCurrentUser();
      if (res != null && res.status) {
        _updateState(hasPremium: res.havePackage);
        log('✅ Entitlement validated: isPremium=${res.havePackage}');
        validationStatus.value = ApiCallStatus.success;
      } else {
        _updateState(hasPremium: false);
        log('⚠️ Entitlement check returned status=false');
        validationStatus.value = ApiCallStatus.error;
      }
    } catch (e) {
      // On network error: keep the CURRENT cached value — do not revoke
      // access on transient failures to avoid locking out paying users.
      validationStatus.value = ApiCallStatus.error;
      log('❌ Entitlement network error: $e — keeping cached state');
    }
  }

  void _updateState({required bool hasPremium}) {
    havePackage.value = hasPremium; // Keeps global Rx in sync
    _lastValidatedAt = DateTime.now();
  }

  void _defaultDenialAction() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.toNamed('/packages');
    });
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    log('PremiumEntitlementService initialized');
  }
}
