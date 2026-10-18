import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lokkha/app/theme/app_theme.dart';

class LiveContestSummaryHeader extends StatelessWidget {
  final int totalContests;
  final int totalSavedQuestions;
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback onBrowseContests;

  const LiveContestSummaryHeader({
    super.key,
    required this.totalContests,
    required this.totalSavedQuestions,
    required this.activeFilter,
    required this.onFilterChanged,
    required this.onBrowseContests,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------------------------------------------------------------------
        // 1. Two Summary Metric Cards
        // ---------------------------------------------------------------------
        Row(
          children: [
            // Card 1: লাইভ কনটেস্ট (Gold / Amber)
            Expanded(
              child: _buildMetricCard(
                context: context,
                title: "লাইভ কনটেস্ট",
                count: "$totalContests",
                unit: "টি অংশ নিয়েছেন",
                icon: const FaIcon(
                  FontAwesomeIcons.trophy,
                  color: Color(0xFFD97706),
                  size: 18,
                ),
                iconBg: const Color(0xFFFFFBEB),
                borderColor: const Color(0xFFFDE68A),
                isSelected: activeFilter == 'contests',
                onTap: () => onFilterChanged(
                  activeFilter == 'contests' ? 'all' : 'contests',
                ),
              ),
            ),
            SizedBox(width: 12.w),
            // Card 2: সংরক্ষিত প্রশ্ন (Emerald)
            Expanded(
              child: _buildMetricCard(
                context: context,
                title: "সংরক্ষিত প্রশ্ন",
                count: "$totalSavedQuestions",
                unit: "টি বুকমার্ক করা",
                icon: const Icon(
                  Icons.bookmark_rounded,
                  color: Color(0xFF059669),
                  size: 22,
                ),
                iconBg: const Color(0xFFECFDF5),
                borderColor: const Color(0xFFA7F3D0),
                isSelected: activeFilter == 'saved',
                onTap: () => onFilterChanged(
                  activeFilter == 'saved' ? 'all' : 'saved',
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 14.h),

        // ---------------------------------------------------------------------
        // 2. Banner: চলমান কনটেস্টে যোগ দিন
        // ---------------------------------------------------------------------
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            gradient: LinearGradient(
              colors: context.isDark
                  ? [
                      const Color(0xFF1E293B),
                      const Color(0xFF0F172A),
                    ]
                  : [
                      const Color(0xFFFFFBEB),
                      const Color(0xFFFEF3C7),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: context.isDark
                  ? const Color(0xFFD97706).withValues(alpha: 0.3)
                  : const Color(0xFFFDE68A),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.fire,
                    color: Color(0xFFD97706),
                    size: 18,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "লাইভ কনটেস্টে অংশ নিন",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: context.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "চলমান ও আসন্ন কনটেস্টে অংশ নিয়ে মেধা যাচাই করুন",
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: context.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              ElevatedButton(
                onPressed: onBrowseContests,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD97706),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  elevation: 0,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "চলমান কনটেস্ট",
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    const Icon(Icons.arrow_forward_rounded, size: 13),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 16.h),

        // ---------------------------------------------------------------------
        // 3. Filter Chips (সবগুলো, লাইভ কনটেস্ট, সংরক্ষিত প্রশ্ন)
        // ---------------------------------------------------------------------
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(
                context: context,
                label: "সবগুলো",
                count: totalContests + totalSavedQuestions,
                isSelected: activeFilter == 'all',
                onTap: () => onFilterChanged('all'),
              ),
              SizedBox(width: 8.w),
              _buildFilterChip(
                context: context,
                label: "লাইভ কনটেস্ট",
                count: totalContests,
                isSelected: activeFilter == 'contests',
                activeColor: const Color(0xFFD97706),
                onTap: () => onFilterChanged('contests'),
              ),
              SizedBox(width: 8.w),
              _buildFilterChip(
                context: context,
                label: "সংরক্ষিত প্রশ্ন",
                count: totalSavedQuestions,
                isSelected: activeFilter == 'saved',
                activeColor: const Color(0xFF059669),
                onTap: () => onFilterChanged('saved'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required String count,
    required String unit,
    required Widget icon,
    required Color iconBg,
    required Color borderColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: context.cardColor,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isSelected ? context.primaryColor : context.borderColor,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: context.isDark
                      ? iconBg.withValues(alpha: 0.15)
                      : iconBg,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(child: icon),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      count,
                      style: TextStyle(
                        fontSize: 19.sp,
                        fontWeight: FontWeight.w800,
                        color: context.textPrimary,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    Text(
                      unit,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9.5.sp,
                        color: context.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required int count,
    required bool isSelected,
    Color? activeColor,
    required VoidCallback onTap,
  }) {
    final effectiveColor = activeColor ?? context.primaryColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: isSelected
                ? effectiveColor
                : (context.isDark
                    ? context.cardColor
                    : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isSelected ? effectiveColor : context.borderColor,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : context.textPrimary,
                ),
              ),
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : context.borderColor,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  "$count",
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : context.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
