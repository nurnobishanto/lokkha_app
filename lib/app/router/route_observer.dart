import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Clean, developer-friendly NavigatorObserver for logging routing events in the console.
class AppRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (!kDebugMode) return;
    final current = route.settings.name ?? route.settings.arguments?.toString() ?? route.toString();
    final prev = previousRoute?.settings.name ?? previousRoute?.settings.arguments?.toString() ?? 'None';
    debugPrint('🧭 [ROUTER] ➡️ PUSH: $current  (Previous: $prev)');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (!kDebugMode) return;
    final popped = route.settings.name ?? route.settings.arguments?.toString() ?? route.toString();
    final current = previousRoute?.settings.name ?? previousRoute?.settings.arguments?.toString() ?? 'None';
    debugPrint('🧭 [ROUTER] ⬅️ POP: $popped  (Current: $current)');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (!kDebugMode) return;
    final next = newRoute?.settings.name ?? newRoute?.settings.arguments?.toString() ?? 'None';
    final old = oldRoute?.settings.name ?? oldRoute?.settings.arguments?.toString() ?? 'None';
    debugPrint('🧭 [ROUTER] 🔄 REPLACE: $next  (Replaced: $old)');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    if (!kDebugMode) return;
    final removed = route.settings.name ?? route.settings.arguments?.toString() ?? route.toString();
    debugPrint('🧭 [ROUTER] 🗑️ REMOVE: $removed');
  }
}
