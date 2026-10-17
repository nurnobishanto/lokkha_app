import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/theme/app_colors.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import '../../data/models/about_model.dart';

class AboutMetricsSection extends StatelessWidget {
  final List<AboutMetricItem> metrics;

  const AboutMetricsSection({super.key, required this.metrics});

  IconData _getMetricIcon(String? icon) {
    switch (icon?.toLowerCase()) {
      case 'school':
        return Icons.school_rounded;
      case 'quiz':
        return Icons.quiz_rounded;
      case 'trending_up':
        return Icons.trending_up_rounded;
      case 'support_agent':
        return Icons.support_agent_rounded;
      case 'people':
        return Icons.people_alt_rounded;
      default:
        return Icons.auto_graph_rounded;
    }
  }

  Color _getMetricColor(int index) {
    switch (index % 4) {
      case 0:
        return LightThemeColors.primaryColor;
      case 1:
        return const Color(0xFF3B82F6); // Blue
      case 2:
        return const Color(0xFFF59E0B); // Amber
      case 3:
        return const Color(0xFF8B5CF6); // Purple
      default:
        return LightThemeColors.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (metrics.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4.w,
              height: 18.h,
              decoration: BoxDecoration(
                color: LightThemeColors.primaryColor,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'আমাদের অর্জন ও প্রভাব',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: metrics.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 1.35,
          ),
          itemBuilder: (context, index) {
            final item = metrics[index];
            final color = _getMetricColor(index);
            final icon = _getMetricIcon(item.icon);

            return Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: color.withValues(alpha: isDark ? 0.25 : 0.15),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: isDark ? 0.08 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(icon, color: color, size: 20.sp),
                      ),
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.value,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: context.textPrimary,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w600,
                          color: context.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.subtitle.isNotEmpty)
                        Text(
                          item.subtitle,
                          style: TextStyle(
                            fontSize: 9.5.sp,
                            color: context.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
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
