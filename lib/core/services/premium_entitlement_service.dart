import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lokkha/app/router/router.dart';
import 'package:lokkha/core/services/storage/secure_storage_service.dart';
import 'package:lokkha/core/utils/global.dart';
import 'package:lokkha/features/auth/auth.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// PremiumEntitlementService
///
/// SINGLE SOURCE OF TRUTH for premium package access.
///
/// Replaces the scattered `havePackage.value` reads across the app.
/// Every premium feature check must go through this service.
/// ─────────────────────────────────────────────────────────────────────────────
class PremiumEntitlementService {
  static final PremiumEntitlementService _instance =
      PremiumEntitlementService._internal();
  factory PremiumEntitlementService() => _instance;
  PremiumEntitlementService._internal();

  static PremiumEntitlementService get to => _instance;
  static PremiumEntitlementService get instance => _instance;

  // ── Public reactive state ────────────────────────────────────────────────
  final ValueNotifier<bool> isValidating = ValueNotifier<bool>(false);

  // ── Cache control ────────────────────────────────────────────────────────
  DateTime? _lastValidatedAt;
  static const Duration _cacheDuration = Duration(minutes: 5);

  // ── Public API ───────────────────────────────────────────────────────────

  /// Convenience getter — the authoritative premium check.
  bool get isPremiumValid => checkUserHasPackage();

  /// Asserts and validates premium entitlement, checking local cache first then network if needed.
  Future<bool> ensurePremiumAccess() async {
    if (checkUserHasPackage()) return true;
    try {
      await validateEntitlement();
    } catch (_) {}
    return checkUserHasPackage();
  }

  /// Full server-side validation.
  Future<void> validateEntitlement() async {
    // Skip if recently validated (unless forced)
    if (_isCacheValid()) {
      log('🔑 Entitlement cache valid — skipping network call');
      return;
    }
    await _fetchEntitlement();
  }

  /// Force refresh — always hits the server.
  Future<void> refreshAfterPurchase() async {
    log('🔑 Refreshing entitlement after purchase...');
    _lastValidatedAt = null; // Invalidate cache
    await _fetchEntitlement();
  }

  /// Asserts premium access. If not valid, calls [onDenied] or redirects.
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
      if (!checkUserHasPackage()) {
        _updateState(hasPremium: false);
      }
      return;
    }

    isValidating.value = true;

    try {
      final authRepo = AuthRepository();
      final res = await authRepo.getCurrentUser();
      if (res != null && res.status) {
        final bool hasPkg = res.havePackage ||
            (res.user?.isSubscribed ?? false) ||
            (res.user?.hasActiveSubscription ?? false) ||
            res.user?.activePackage != null;
        _updateState(hasPremium: hasPkg);
        log('✅ Entitlement validated: isPremium=$hasPkg');
        isValidating.value = false;
      } else {
        if (!checkUserHasPackage()) {
          _updateState(hasPremium: false);
        }
        log('⚠️ Entitlement check returned status=false');
        isValidating.value = false;
      }
    } catch (e) {
      isValidating.value = false;
      log('❌ Entitlement network error: $e — keeping cached state');
    }
  }

  void _updateState({required bool hasPremium}) {
    havePackage.value = hasPremium;
    _lastValidatedAt = DateTime.now();
  }

  void _defaultDenialAction() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      rootNavigatorKey.currentContext?.go(Routes.packages);
    });
  }
}
