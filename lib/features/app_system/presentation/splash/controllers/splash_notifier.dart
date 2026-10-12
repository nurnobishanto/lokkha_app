import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/compat/get_compat.dart';
import 'package:go_router/go_router.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/core/services/app_update_service.dart';
import 'package:lokkha/core/services/premium_entitlement_service.dart';

class SplashState {
  final bool isInitialized;
  const SplashState({this.isInitialized = false});
}

class SplashNotifier extends Notifier<SplashState> {
  @override
  SplashState build() {
    return const SplashState();
  }

  Future<void> initAppAndNavigate(BuildContext context) async {
    final appUpdateService = AppUpdateService();

    await Future.wait([
      () async {
        try {
          if (Get.isRegistered<PremiumEntitlementService>()) {
            await Get.find<PremiumEntitlementService>().validateEntitlement();
          }
        } catch (e) {
          debugPrint("Error validating premium entitlement: $e");
        }
      }(),
      () async {
        try {
          await appUpdateService.fetchAppInfoAndCheckVersion();
        } catch (e) {
          debugPrint("Error fetching v1 app-info: $e");
        }
      }(),
      Future.delayed(const Duration(milliseconds: 1800)),
    ]);

    final canProceed = appUpdateService.handleStartupFlow();
    if (canProceed && context.mounted) {
      context.go(Routes.navbar);
      Future.delayed(const Duration(milliseconds: 700), () {
        appUpdateService.showInAppAnnouncementIfAvailable();
      });
    }
    state = const SplashState(isInitialized: true);
  }
}

final splashNotifierProvider = NotifierProvider<SplashNotifier, SplashState>(SplashNotifier.new);
