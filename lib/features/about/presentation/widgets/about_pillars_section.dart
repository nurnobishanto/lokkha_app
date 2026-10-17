import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/theme/app_colors.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import '../../data/models/about_model.dart';

class AboutPillarsSection extends StatelessWidget {
  final AboutPillarsModel pillars;

  const AboutPillarsSection({super.key, required this.pillars});

  Color _getThemeColor(String theme) {
    switch (theme.toLowerCase()) {
      case 'emerald':
        return LightThemeColors.primaryColor;
      case 'amber':
        return const Color(0xFFF59E0B);
      case 'blue':
        return const Color(0xFF3B82F6);
      default:
        return LightThemeColors.primaryColor;
    }
  }

  IconData _getPillarIcon(String icon) {
    switch (icon.toLowerCase()) {
      case 'track_changes':
        return Icons.track_changes_rounded;
      case 'lightbulb':
        return Icons.lightbulb_outline_rounded;
      case 'verified_user':
        return Icons.verified_user_rounded;
      default:
        return Icons.stars_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (pillars.items.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pillars.sectionTitle.isNotEmpty)
          Text(
            pillars.sectionTitle,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: context.textPrimary,
              height: 1.3,
            ),
          ),
        if (pillars.sectionSubtitle.isNotEmpty) ...[
          SizedBox(height: 6.h),
          Text(
            pillars.sectionSubtitle,
            style: TextStyle(
              fontSize: 13.sp,
              color: context.textSecondary,
              height: 1.4,
            ),
          ),
        ],
        SizedBox(height: 14.h),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: pillars.items.length,
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            final item = pillars.items[index];
            final color = _getThemeColor(item.theme);
            final icon = _getPillarIcon(item.icon);

            return Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: color.withValues(alpha: isDark ? 0.3 : 0.2),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(icon, color: color, size: 24.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: context.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          item.description,
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            color: context.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
