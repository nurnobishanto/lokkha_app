import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/app/router/router.dart';

class DeepLinkService {
  static final DeepLinkService instance = DeepLinkService._();
  DeepLinkService._();

  static void init() {
    instance._initializeApp();
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

  final context = rootNavigatorKey.currentContext;
  if (context == null) return;

  if (uri.pathSegments.isNotEmpty) {
    final firstSegment = uri.pathSegments[0]; // exam, course, login, profile
    final secondSegment = uri.pathSegments.length > 1 ? uri.pathSegments[1] : '';
    final queryParams = uri.queryParameters;

    switch (firstSegment) {
      case 'profile':
        context.pushNamed(Routes.profile);
        break;

      case 'login':
        context.pushNamed(Routes.authGateway);
        break;

      case 'course':
        final idOrSlug = secondSegment.isNotEmpty ? secondSegment : queryParams['id'] ?? '';
        if (idOrSlug.isNotEmpty) {
          context.push('/course/$idOrSlug');
        }
        break;

      case 'exam':
        final idOrSlug = secondSegment.isNotEmpty ? secondSegment : queryParams['id'] ?? '';
        if (idOrSlug.isNotEmpty) {
          context.push('/exam/$idOrSlug');
        }
        break;

      default:
        debugPrint("Unknown deep link path: $firstSegment");
    }
  }
}
