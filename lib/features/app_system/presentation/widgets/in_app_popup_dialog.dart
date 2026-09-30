import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/core.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../data/models/app_info_model.dart';

class InAppPopupDialog extends StatelessWidget {
  final InAppPopupModel popup;

  const InAppPopupDialog({super.key, required this.popup});

  static void show(InAppPopupModel popup) {
    if (!popup.enabled) return;
    Get.dialog(
      InAppPopupDialog(popup: popup),
      barrierDismissible: true,
    );
  }

  void _handleAction() async {
    Get.back();
    final url = popup.targetUrl.trim();
    if (url.isEmpty) return;

    if (url.startsWith('/')) {
      // Internal GetX route
      try {
        Get.toNamed(url);
      } catch (e) {
        debugPrint('[InAppPopupDialog] Route navigation failed for $url: $e');
      }
    } else if (url.startsWith('http://') || url.startsWith('https://')) {
      try {
        await launchUrlString(url, mode: LaunchMode.externalApplication);
      } catch (e) {
        debugPrint('[InAppPopupDialog] URL launch failed for $url: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topRight,
        children: [
          Container(
            width: double.infinity,
            constraints: BoxConstraints(maxWidth: 360.w),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Popup Banner Image
                    if (popup.imageUrl.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: popup.imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 180.h,
                          color: context.dividerColor.withValues(alpha: 0.1),
                          child: const Center(
                            child: CircularProgressIndicator.adaptive(),
                          ),
                        ),
                        errorWidget: (context, url, error) => const SizedBox(),
                      ),

                    // Content Padding
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (popup.heading.isNotEmpty) ...[
                            Text(
                              popup.heading,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
                                height: 1.3,
                              ),
                            ),
                            SizedBox(height: 8.h),
                          ],
                          if (popup.details != null &&
                              popup.details!.trim().isNotEmpty) ...[
                            Text(
                              popup.details!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: context.textSecondary,
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: 16.h),
                          ],
                          if (popup.buttonText.isNotEmpty &&
                              popup.targetUrl.isNotEmpty) ...[
                            SizedBox(height: 8.h),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _handleAction,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: context.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding:
                                      EdgeInsets.symmetric(vertical: 12.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  popup.buttonText,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
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
            ),
          ),

          // Close button (X)
          Positioned(
            top: -12.h,
            right: -12.w,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: context.isDark ? const Color(0xFF1E293B) : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 20.sp,
                  color: context.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
