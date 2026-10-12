import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lokkha/app/router/router.dart';
import 'package:lokkha/core/core.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../data/models/app_info_model.dart';

class InAppPopupDialog extends StatelessWidget {
  final InAppPopupModel popup;
  static bool isShowing = false;

  const InAppPopupDialog({super.key, required this.popup});

  static void show(InAppPopupModel popup) {
    if (!popup.enabled || isShowing) return;
    isShowing = true;

    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      isShowing = false;
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => InAppPopupDialog(popup: popup),
    ).then((_) {
      isShowing = false;
    });
  }

  void _handleAction(BuildContext context) async {
    Navigator.of(context, rootNavigator: true).pop();
    final url = popup.targetUrl.trim();
    if (url.isEmpty) return;

    if (url.startsWith('/')) {
      try {
        context.push(url);
      } catch (e) {
        debugPrint('[InAppPopupDialog] Route navigation failed for $url: $e');
      }
    } else if (url.startsWith('http://') || url.startsWith('https://')) {
      final uri = Uri.tryParse(url);
      if (uri != null && uri.host.contains('lokkha.com')) {
        final pathWithQuery =
            uri.hasQuery ? '${uri.path}?${uri.query}' : uri.path;
        if (pathWithQuery.isNotEmpty && pathWithQuery.startsWith('/')) {
          try {
            context.push(pathWithQuery);
            return;
          } catch (e) {
            debugPrint(
                '[InAppPopupDialog] Internal route navigation failed: $e');
          }
        }
      }
      try {
        await launchUrlString(url, mode: LaunchMode.externalApplication);
      } catch (e) {
        debugPrint('[InAppPopupDialog] URL launch failed for $url: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context, rootNavigator: true)
          .pop(), // Tap outside anywhere to dismiss immediately
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Center(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {}, // Prevent taps inside dialog from closing it
            child: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: 380.w,
                    maxHeight: 520.h,
                  ),
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Scrollable content
                      SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Banner Image (if available)
                            if (popup.imageUrl.isNotEmpty)
                              GestureDetector(
                                onTap: () => _handleAction(context),
                                child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: CachedNetworkImage(
                                    imageUrl: popup.imageUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(
                                      color: context.isDark
                                          ? const Color(0xFF1E293B)
                                          : Colors.grey.shade100,
                                      child: const Center(
                                        child: SizedBox(
                                          width: 28,
                                          height: 28,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        ),
                                      ),
                                    ),
                                    errorWidget: (_, __, ___) =>
                                        const SizedBox.shrink(),
                                  ),
                                ),
                              ),

                            // Content Details
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                18.w,
                                popup.imageUrl.isNotEmpty ? 14.h : 28.h,
                                18.w,
                                18.h,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (popup.heading.isNotEmpty)
                                    Text(
                                      popup.heading,
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                        color: context.textPrimary,
                                        height: 1.3,
                                      ),
                                    ),
                                  if (popup.heading.isNotEmpty &&
                                      (popup.details?.isNotEmpty ?? false))
                                    SizedBox(height: 8.h),
                                  if (popup.details?.isNotEmpty ?? false)
                                    Text(
                                      popup.details!,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: context.textSecondary,
                                        height: 1.45,
                                      ),
                                    ),
                                  if (popup.buttonText.isNotEmpty) ...[
                                    SizedBox(height: 18.h),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 44.h,
                                      child: ElevatedButton(
                                        onPressed: () => _handleAction(context),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              context.primaryColor,
                                          foregroundColor: Colors.white,
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.r),
                                          ),
                                        ),
                                        child: Text(
                                          popup.buttonText,
                                          style: TextStyle(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Close Button with generous 48x48 hit target area
                      Positioned(
                        top: 6.h,
                        right: 6.w,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () =>
                              Navigator.of(context, rootNavigator: true).pop(),
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            color: Colors.transparent,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.75),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: 20.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
