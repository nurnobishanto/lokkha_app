import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/contest_history_item_model.dart';

class ContestHistoryCard extends StatelessWidget {
  final ContestHistoryItemModel item;
  final VoidCallback onViewRanking;
  final VoidCallback onViewResult;

  const ContestHistoryCard({
    super.key,
    required this.item,
    required this.onViewRanking,
    required this.onViewResult,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
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
          // 1. Header Row (Trophy Chip, Date, Duration Pill)
          Row(
            children: [
              // Trophy Chip
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.emoji_events_rounded,
                      size: 13.sp,
                      color: const Color(0xFFD97706),
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      "#${item.id}",
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
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
                color: const Color(0xFF64748B),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  item.date,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Duration Pill (if available)
              if (item.duration != null) ...[
                SizedBox(width: 6.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 11.sp,
                        color: const Color(0xFF64748B),
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        item.duration!,
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          color: const Color(0xFF475569),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),

          SizedBox(height: 12.h),

          // 2. Middle Content (Medal Icon + Title + Metrics)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Gold Medal Icon Container
              Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.military_tech_rounded,
                  size: 22.sp,
                  color: const Color(0xFFD97706),
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
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 13.sp,
                          color: const Color(0xFF10B981),
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          "${item.correctCount} সঠিক",
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF059669),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text("•", style: TextStyle(color: const Color(0xFF94A3B8), fontSize: 11.sp)),
                        SizedBox(width: 6.w),
                        Icon(
                          Icons.cancel_rounded,
                          size: 13.sp,
                          color: const Color(0xFFEF4444),
                        ),
                        SizedBox(width: 3.w),
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

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          SizedBox(height: 10.h),

          // 3. Bottom Row (Action Buttons)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // র‍্যাঙ্কিং Button
              InkWell(
                onTap: onViewRanking,
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.military_tech_rounded,
                        size: 14.sp,
                        color: const Color(0xFFD97706),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        "র‍্যাঙ্কিং",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: 8.w),

              // ফলাফল দেখুন Button
              InkWell(
                onTap: onViewResult,
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: const Color(0xFF059669),
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    "ফলাফল দেখুন",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF059669),
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
