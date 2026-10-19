import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/theme/app_colors.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/about_model.dart';

class AboutAppShowcaseSection extends StatelessWidget {
  final AboutAppShowcaseModel appShowcase;

  const AboutAppShowcaseSection({super.key, required this.appShowcase});

  IconData _getFeatureIcon(String icon) {
    switch (icon.toLowerCase()) {
      case 'notifications_active':
        return Icons.notifications_active_rounded;
      case 'bolt':
        return Icons.bolt_rounded;
      case 'trending_up':
        return Icons.trending_up_rounded;
      default:
        return Icons.check_circle_outline_rounded;
    }
  }

  Future<void> _launchDownloadUrl(BuildContext context) async {
    final url = appShowcase.downloadUrl;
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: LightThemeColors.primaryColor.withValues(alpha: isDark ? 0.3 : 0.2),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: LightThemeColors.primaryColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.smartphone_rounded,
                  color: LightThemeColors.primaryColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  appShowcase.heading.isNotEmpty
                      ? appShowcase.heading
                      : 'মোবাইলেই সেরা ক্যারিয়ার প্রস্তুতি',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          if (appShowcase.subheading.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text(
              appShowcase.subheading,
              style: TextStyle(
                fontSize: 12.5.sp,
                color: context.textSecondary,
                height: 1.4,
              ),
            ),
          ],
          SizedBox(height: 14.h),

          // Features List
          ...appShowcase.features.map((feature) {
            final icon = _getFeatureIcon(feature.icon);
            return Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 2.h),
                    padding: EdgeInsets.all(5.r),
                    decoration: BoxDecoration(
                      color: LightThemeColors.primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      icon,
                      color: LightThemeColors.primaryColor,
                      size: 16.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feature.title,
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w700,
                            color: context.textPrimary,
                          ),
                        ),
                        if (feature.description.isNotEmpty) ...[
                          SizedBox(height: 2.h),
                          Text(
                            feature.description,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: context.textSecondary,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),

          SizedBox(height: 8.h),

          // Download Play Store Button
          if (appShowcase.downloadUrl.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _launchDownloadUrl(context),
                icon: const Icon(Icons.shop_rounded, color: Colors.white),
                label: Text(
                  'গুগল প্লে স্টোর থেকে ডাউনলোড করুন',
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: LightThemeColors.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
