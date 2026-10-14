import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/home/data/models/home_feed_model.dart';

class HomeStatsSection extends StatelessWidget {
  final HomeStatsModel stats;

  const HomeStatsSection({
    super.key,
    required this.stats,
  });

  IconData _getIconData(String iconKey) {
    switch (iconKey.toLowerCase()) {
      case 'users':
      case 'students':
        return Icons.people_alt_rounded;
      case 'teacher':
      case 'mentors':
        return Icons.co_present_rounded;
      case 'graduation-cap':
      case 'learners':
        return Icons.school_rounded;
      case 'book':
      case 'materials':
        return Icons.menu_book_rounded;
      case 'star':
      case 'rating':
        return Icons.star_rounded;
      default:
        return Icons.insights_rounded;
    }
  }

  Color _getAccentColor(int index) {
    const colors = [
      Color(0xFF0D9488), // Teal
      Color(0xFF2563EB), // Blue
      Color(0xFFD97706), // Amber
      Color(0xFF7C3AED), // Purple
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    if (stats.highlights.isEmpty) return const SizedBox.shrink();

    final items = stats.highlights.take(4).toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 10.h,
          childAspectRatio: 2.3,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          final accentColor = _getAccentColor(index);
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: context.borderColor.withOpacity(0.5),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    _getIconData(item.icon),
                    size: 20.sp,
                    color: accentColor,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.countFormatted,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          color: context.textSecondary,
                          fontWeight: FontWeight.w500,
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
    );
  }
}
