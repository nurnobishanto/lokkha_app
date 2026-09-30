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
      barrierColor: Colors.black.withValues(alpha: 0.65),
    );
  }

  void _handleAction() async {
    Get.back();
    final url = popup.targetUrl.trim();
    if (url.isEmpty) return;

    if (url.startsWith('/')) {
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
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Center(
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(maxWidth: 350.w),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 28,
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
                  // Poster Image Area with Floating Close Button
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      // Tappable Banner Image
                      if (popup.imageUrl.isNotEmpty)
                        GestureDetector(
                          onTap: _handleAction,
                          child: CachedNetworkImage(
                            imageUrl: AppConstants.resolveUrl(popup.imageUrl),
                            width: double.infinity,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => Container(
                              height: 320.h,
                              color: context.dividerColor.withValues(alpha: 0.1),
                              child: const Center(
                                child: CircularProgressIndicator.adaptive(),
                              ),
                            ),
                            errorWidget: (context, url, error) {
                              debugPrint(
                                  '[InAppPopupDialog] Image failed to load: $url, error: $error');
                              return Container(
                                height: 180.h,
                                color: context.cardColor,
                                padding: EdgeInsets.all(16.r),
                                child: Center(
                                  child: Text(
                                    popup.heading,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      // Close Button (Dark translucent circle with white outline & white 'X')
                      Positioned(
                        top: 10.h,
                        right: 10.w,
                        child: GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.85),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 18.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Optional CTA Button below image if buttonText is present
                  if (popup.buttonText.isNotEmpty && popup.targetUrl.isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 14.h),
                      child: SizedBox(
                        width: double.infinity,
                        height: 46.h,
                        child: ElevatedButton(
                          onPressed: _handleAction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.primaryColor,
                            foregroundColor: Colors.white,
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
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
