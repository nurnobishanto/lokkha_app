import 'package:app_links/app_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/routes/routes.dart';

class MyAppController extends GetxController {
  // final AuthService _authService = AuthService();
  RxString appVersion = ''.obs;

  @override
  void onReady() {
    super.onReady();
    debugPrint("MyApp Controller Called");
    _initializeApp();
  }

  void _initializeApp() async {
    await fetchAppVersion();

    final AppLinks _appLinks = AppLinks();

    // Cold start
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        handleDeepLink(initialUri);
      }
    } catch (e) {
      print("Failed to get initial app link: $e");
    }

    // Foreground listener
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        handleDeepLink(uri);
      }
    }, onError: (err) {
      print("Deep link stream error: $err");
    });
  }
}




void handleDeepLink(Uri uri) {
  print("Deep link received: $uri");

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
        print("Unknown deep link path: $firstSegment");
    // Optional: fallback route
    // Get.toNamed(Routes.HOME);
    }
  }
}
