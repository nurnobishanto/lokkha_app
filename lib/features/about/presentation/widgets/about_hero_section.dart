import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/theme/app_colors.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/core/constants/app_images.dart';
import '../../data/models/about_model.dart';

class AboutHeroSection extends StatelessWidget {
  final AboutHeroModel hero;

  const AboutHeroSection({super.key, required this.hero});

  IconData _getBadgeIcon(String? icon) {
    switch (icon?.toLowerCase()) {
      case 'star':
        return Icons.star_rounded;
      case 'school':
        return Icons.school_rounded;
      case 'verified':
        return Icons.verified_rounded;
      default:
        return Icons.auto_awesome_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tagline Chip
          if (hero.tagline.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: LightThemeColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30.r),
                border: Border.all(
                  color: LightThemeColors.primaryColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.flag_rounded,
                    size: 14.sp,
                    color: LightThemeColors.primaryColor,
                  ),
                  Flexible(
                    child: Text(
                      hero.tagline,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: LightThemeColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: 12.h),

          // Main Heading
          if (hero.heading.isNotEmpty)
            Text(
              hero.heading,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: context.textPrimary,
                height: 1.3,
              ),
            ),

          // Subheading
          if (hero.subheading.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              hero.subheading,
              style: TextStyle(
                fontSize: 14.sp,
                color: LightThemeColors.primaryColor,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ],

          SizedBox(height: 16.h),

          // Hero Image with Floating Badges
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: hero.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: hero.imageUrl,
                        width: double.infinity,
                        height: 180.h,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 180.h,
                          color: isDark
                              ? Colors.grey[850]
                              : const Color(0xFFF1F5F9),
                          child: const Center(
                            child: CircularProgressIndicator.adaptive(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Image.asset(
                          AssetImagePaths.logo,
                          height: 180.h,
                          fit: BoxFit.contain,
                        ),
                      )
                    : Image.asset(
                        AssetImagePaths.logo,
                        height: 180.h,
                        fit: BoxFit.contain,
                      ),
              ),

              // Top Floating Badge
              if (hero.floatingBadges?.top != null)
                Positioned(
                  top: 12.h,
                  left: 12.w,
                  child: _FloatingBadgeWidget(
                    badge: hero.floatingBadges!.top!,
                    icon: _getBadgeIcon(hero.floatingBadges!.top!.icon),
                    accentColor: const Color(0xFFF59E0B),
                  ),
                ),

              // Bottom Floating Badge
              if (hero.floatingBadges?.bottom != null)
                Positioned(
                  bottom: 12.h,
                  right: 12.w,
                  child: _FloatingBadgeWidget(
                    badge: hero.floatingBadges!.bottom!,
                    icon: _getBadgeIcon(hero.floatingBadges!.bottom!.icon),
                    accentColor: LightThemeColors.primaryColor,
                  ),
                ),
            ],
          ),

          SizedBox(height: 16.h),

          // Paragraph 1
          if (hero.description1.isNotEmpty)
            Text(
              hero.description1,
              style: TextStyle(
                fontSize: 13.5.sp,
                color: context.textSecondary,
                height: 1.6,
              ),
            ),

          // Paragraph 2
          if (hero.description2.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Text(
              hero.description2,
              style: TextStyle(
                fontSize: 13.5.sp,
                color: context.textSecondary,
                height: 1.6,
              ),
            ),
          ],

          // Key Bullet Features
          if (hero.features.isNotEmpty) ...[
            SizedBox(height: 14.h),
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                children: hero.features.map((feature) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 2.h),
                          padding: EdgeInsets.all(3.r),
                          decoration: const BoxDecoration(
                            color: LightThemeColors.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            size: 11.sp,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            feature,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: context.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FloatingBadgeWidget extends StatelessWidget {
  final AboutFloatingBadgeItem badge;
  final IconData icon;
  final Color accentColor;

  const _FloatingBadgeWidget({
    required this.badge,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF0F172A) : Colors.white)
            .withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(4.r),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14.sp, color: accentColor),
          ),
          SizedBox(width: 6.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                badge.displayTitle,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
              if (badge.displaySubtitle.isNotEmpty)
                Text(
                  badge.displaySubtitle,
                  style: TextStyle(
                    fontSize: 9.5.sp,
                    color: context.textMuted,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
