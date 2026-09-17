import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/accuracy_exam_item_model.dart';

class AccuracyExamCard extends StatelessWidget {
  final AccuracyExamItemModel item;
  final VoidCallback onViewRanking;
  final VoidCallback onViewResult;

  const AccuracyExamCard({
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
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(14.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Row (ID Chip & Date)
          Row(
            children: [
              // Document ID Chip
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 13.sp,
                      color: const Color(0xFF059669),
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

              // Calendar Date/Time
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
            ],
          ),

          SizedBox(height: 8.h),

          // 2. Sub-Header Pills (Accuracy % and Status)
          Row(
            children: [
              // Accuracy Pill
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: const Color(0xFFA7F3D0), width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.adjust_rounded,
                      size: 12.sp,
                      color: const Color(0xFF059669),
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      "নির্ভুলতা: ${item.accuracy}",
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 6.w),

              // Status Pill
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: item.isPassed
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: item.isPassed
                        ? const Color(0xFFA7F3D0)
                        : const Color(0xFFFECACA),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  item.status,
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.bold,
                    color: item.isPassed
                        ? const Color(0xFF059669)
                        : const Color(0xFFDC2626),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // 3. Title & Metrics (Purple Trend Icon + Title + Question Stats)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Purple Trend Icon Container
              Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.show_chart_rounded,
                  size: 20.sp,
                  color: const Color(0xFF7C3AED),
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
                        Text(
                          "মোট প্রশ্ন: ${item.totalQuestions}",
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Text("•", style: TextStyle(color: const Color(0xFF94A3B8), fontSize: 11.sp)),
                        SizedBox(width: 5.w),
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
                        SizedBox(width: 5.w),
                        Text("•", style: TextStyle(color: const Color(0xFF94A3B8), fontSize: 11.sp)),
                        SizedBox(width: 5.w),
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

          SizedBox(height: 10.h),

          // 4. Accuracy Ratio Row
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "নির্ভুলতার অনুপাত:",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF475569),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  item.accuracyRatio,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 10.h),

          // 5. Bottom Action Row (প্রাপ্ত নম্বর + Buttons)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // প্রাপ্ত নম্বর
              Row(
                children: [
                  Text(
                    "প্রাপ্ত নম্বর: ",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF475569),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    item.obtainedMark,
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w900,
                      color: item.obtainedMark.startsWith("-")
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF059669),
                    ),
                  ),
                ],
              ),

              // Buttons
              Row(
                children: [
                  // 🏆 র‍্যাঙ্ক Button
                  InkWell(
                    onTap: onViewRanking,
                    borderRadius: BorderRadius.circular(20.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
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
                            Icons.emoji_events_rounded,
                            size: 13.sp,
                            color: const Color(0xFFD97706),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "র‍্যাঙ্ক",
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(width: 6.w),

                  // রেজাল্ট শিট Button
                  InkWell(
                    onTap: onViewResult,
                    borderRadius: BorderRadius.circular(20.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: const Color(0xFF059669),
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        "রেজাল্ট শিট",
                        style: TextStyle(
                          fontSize: 11.5.sp,
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
        ],
      ),
    );
  }
}
