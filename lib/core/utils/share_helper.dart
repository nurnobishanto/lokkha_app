import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// Centralized safe share utility for cross-platform sharing.
/// Handles iOS popover requirements (sharePositionOrigin) to prevent PlatformException.
class ShareHelper {
  ShareHelper._();

  /// Calculates a non-zero, safe share origin within the coordinate space of the screen.
  static Rect getSafeOrigin(BuildContext? context) {
    Size screenSize = const Size(375, 812);
    if (context != null && context.mounted) {
      screenSize = MediaQuery.sizeOf(context);
    } else {
      final view = WidgetsBinding.instance.platformDispatcher.views.firstOrNull;
      if (view != null) {
        final ratio = view.devicePixelRatio > 0 ? view.devicePixelRatio : 1.0;
        screenSize = view.physicalSize / ratio;
      }
    }

    if (context != null && context.mounted) {
      try {
        final box = context.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize && box.size.width > 0 && box.size.height > 0) {
          final pos = box.localToGlobal(Offset.zero);
          final rect = Rect.fromLTWH(
            pos.dx.clamp(0.0, (screenSize.width - 20).clamp(0.0, double.infinity)),
            pos.dy.clamp(0.0, (screenSize.height - 20).clamp(0.0, double.infinity)),
            box.size.width.clamp(1.0, screenSize.width),
            box.size.height.clamp(1.0, screenSize.height),
          );
          if (rect.width > 0 && rect.height > 0) {
            return rect;
          }
        }
      } catch (_) {}
    }

    final width = screenSize.width > 0 ? screenSize.width : 375.0;
    final height = screenSize.height > 0 ? screenSize.height : 812.0;
    return Rect.fromLTWH(0, 0, width, height / 2);
  }

  /// Safely shares text across Android & iOS without PlatformException on iPad/iOS
  static Future<ShareResult> share(
    String text, {
    BuildContext? context,
    String? subject,
    String? title,
    Rect? sharePositionOrigin,
  }) async {
    final origin = sharePositionOrigin ?? getSafeOrigin(context);
    return await SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: subject,
        title: title,
        sharePositionOrigin: origin,
      ),
    );
  }
}
