import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/config/theme/theme_extensions.dart';
import '../models/self_exam_model.dart';

class SelfExamCard extends StatelessWidget {
  final SelfExamModel item;
  final VoidCallback onViewResult;

  const SelfExamCard({
    super.key,
    required this.item,
    required this.onViewResult,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(14.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Row (ID Chip, Date, Duration Pill, Status Badge)
          Row(
            children: [
              // ID Chip
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: context.isDark
                      ? const Color(0xFF0369A1).withValues(alpha: 0.25)
                      : const Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: context.isDark
                        ? const Color(0xFF0284C7)
                        : const Color(0xFFBAE6FD),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "#",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w900,
                        color: context.isDark
                            ? const Color(0xFF38BDF8)
                            : const Color(0xFF0284C7),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      item.id,
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.bold,
                        color: context.isDark
                            ? const Color(0xFF38BDF8)
                            : const Color(0xFF0284C7),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 8.w),

              // Date
              Icon(
                Icons.calendar_today_outlined,
                size: 13.sp,
                color: context.textSecondary,
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  item.date,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: context.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Duration Chip (if available)
              if (item.duration != null) ...[
                SizedBox(width: 6.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(color: context.borderColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 11.sp,
                        color: context.textSecondary,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        item.duration!,
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          color: context.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(width: 6.w),

              // Status Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: item.isPassed
                      ? (context.isDark
                          ? const Color(0xFF064E3B).withValues(alpha: 0.4)
                          : const Color(0xFFECFDF5))
                      : (context.isDark
                          ? const Color(0xFF7F1D1D).withValues(alpha: 0.4)
                          : const Color(0xFFFEF2F2)),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: item.isPassed
                        ? (context.isDark
                            ? const Color(0xFF059669)
                            : const Color(0xFFA7F3D0))
                        : (context.isDark
                            ? const Color(0xFFDC2626)
                            : const Color(0xFFFECACA)),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  item.status,
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.bold,
                    color: item.isPassed
                        ? (context.isDark
                            ? const Color(0xFF34D399)
                            : const Color(0xFF059669))
                        : (context.isDark
                            ? const Color(0xFFF87171)
                            : const Color(0xFFDC2626)),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // 2. Middle Content (Icon + Title + Stats)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Cyan Pencil Icon Container
              Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  color: context.isDark
                      ? const Color(0xFF0284C7).withValues(alpha: 0.2)
                      : const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.edit_outlined,
                  size: 20.sp,
                  color: context.isDark
                      ? const Color(0xFF38BDF8)
                      : const Color(0xFF0284C7),
                ),
              ),

              SizedBox(width: 12.w),

              // Title and Metrics
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w800,
                        color: context.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Text(
                          "মোট প্রশ্ন: ${item.totalQuestions}",
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            color: context.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text("•", style: TextStyle(color: context.textMuted, fontSize: 11.sp)),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.check_circle_rounded,
                          size: 13.sp,
                          color: const Color(0xFF10B981),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          "${item.correctCount} সঠিক",
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF059669),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text("•", style: TextStyle(color: context.textMuted, fontSize: 11.sp)),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.cancel_rounded,
                          size: 13.sp,
                          color: const Color(0xFFEF4444),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          "${item.wrongCount} ভুল",
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          Divider(height: 1, color: context.dividerColor),

          SizedBox(height: 10.h),

          // 3. Bottom Row (Mark & Action Button)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "অর্জিত মার্ক: ",
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      color: context.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    item.obtainedMark,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF059669),
                    ),
                  ),
                ],
              ),

              // ফলাফল দেখুন Button
              InkWell(
                onTap: onViewResult,
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: context.isDark
                        ? const Color(0xFF0284C7).withValues(alpha: 0.15)
                        : const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: context.isDark
                          ? const Color(0xFF0284C7)
                          : const Color(0xFF0284C7),
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    "ফলাফল দেখুন",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: context.isDark
                          ? const Color(0xFF38BDF8)
                          : const Color(0xFF0284C7),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
