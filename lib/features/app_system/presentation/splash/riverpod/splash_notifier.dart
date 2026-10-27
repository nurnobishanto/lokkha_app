import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/core/services/app_update_service.dart';
import 'package:lokkha/core/services/premium_entitlement_service.dart';
import 'package:lokkha/core/services/storage/my_shared_pref.dart';
import 'package:lokkha/features/course/course.dart';
import 'package:lokkha/features/home/presentation/home/riverpod/home_feed_notifier.dart';

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
    final token = MySharedPref.getUserToken();

    // Pre-fetch Home Feed & Courses in background during splash so Home opens instantly
    if (token.isNotEmpty) {
      unawaited(ref.read(homeFeedNotifierProvider.notifier).fetchHomeFeed());
      // Trigger courses notifier initialization early
      ref.read(coursesNotifierProvider(null));
    }

    await Future.wait([
      () async {
        try {
          await PremiumEntitlementService.to.validateEntitlement();
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
      Future.delayed(const Duration(milliseconds: 500)),
    ]);

    if (!context.mounted) return;

    if (appUpdateService.maintenanceMode) {
      context.go(Routes.maintenanceMode);
    } else if (appUpdateService.updateRequired) {
      context.go(Routes.appUpdate);
    } else {
      final isOnboardingSeen = MySharedPref.isOnboardingSeen();
      if (!isOnboardingSeen) {
        context.go(Routes.onBoarding);
      } else {
        final token = MySharedPref.getUserToken();
        if (token.isEmpty) {
          context.go(Routes.authGateway);
        } else {
          context.go(Routes.navbar);
        }
      }
    }
  }
}

final splashNotifierProvider =
    NotifierProvider<SplashNotifier, SplashState>(SplashNotifier.new);
