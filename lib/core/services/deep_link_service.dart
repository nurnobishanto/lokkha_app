import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/routes/routes.dart';

class DeepLinkService extends GetxController {
  RxString appVersion = ''.obs;

  @override
  void onReady() {
    super.onReady();
    debugPrint("DeepLinkService / MyAppController Called");
    _initializeApp();
  }

  void _initializeApp() async {
    await fetchAppVersion();

    final AppLinks appLinks = AppLinks();

    // Cold start
    try {
      final initialUri = await appLinks.getInitialLink();
      if (initialUri != null) {
        handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint("Failed to get initial app link: $e");
    }

    // Foreground listener
    appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        handleDeepLink(uri);
      }
    }, onError: (err) {
      debugPrint("Deep link stream error: $err");
    });
  }
}

/// Backward compatibility alias
typedef MyAppController = DeepLinkService;

void handleDeepLink(Uri uri) {
  debugPrint("Deep link received: $uri");

  // Path segments এবং query parameters
  if (uri.pathSegments.isNotEmpty) {
    final firstSegment = uri.pathSegments[0]; // exam, course, login, profile
    final secondSegment = uri.pathSegments.length > 1 ? uri.pathSegments[1] : '';
    final queryParams = uri.queryParameters;

    switch (firstSegment) {
      case 'profile':
        Get.toNamed(Routes.PROFILE);
        break;

      case 'login':
        Get.toNamed(Routes.AUTH_GATEWAY);
        break;

      case 'course':
        // slug/id support
        final idOrSlug = secondSegment.isNotEmpty ? secondSegment : queryParams['id'] ?? '';
        if (idOrSlug.isNotEmpty) {
          Get.toNamed('/course/$idOrSlug');
        }
        break;

      case 'exam':
        // slug/id support
        final idOrSlug = secondSegment.isNotEmpty ? secondSegment : queryParams['id'] ?? '';
        if (idOrSlug.isNotEmpty) {
          Get.toNamed('/exam/$idOrSlug');
        }
        break;

      default:
        debugPrint("Unknown deep link path: $firstSegment");
    }
  }
}
