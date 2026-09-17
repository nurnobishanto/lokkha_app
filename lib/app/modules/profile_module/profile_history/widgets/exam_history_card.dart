import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/exam_history_model.dart';

class ExamHistoryCard extends StatelessWidget {
  final ExamHistoryModel item;
  final VoidCallback? onRankTap;
  final VoidCallback? onResultSheetTap;

  const ExamHistoryCard({
    super.key,
    required this.item,
    this.onRankTap,
    this.onResultSheetTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(12.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Row: Exam ID, Date, Status Chip
          Row(
            children: [
              // Code chip
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.description_rounded,
                      size: 13.sp,
                      color: const Color(0xFF10B981),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      item.id,
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

              // Calendar Icon & Date
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 12.sp,
                      color: const Color(0xFF64748B),
                    ),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        item.date,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Status Pill
              Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 2.5.h),
                decoration: BoxDecoration(
                  color: item.isPassed
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: item.isPassed
                        ? const Color(0xFFA7F3D0)
                        : const Color(0xFFFECDD3),
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
                        : const Color(0xFFE11D48),
                  ),
                ),
              ),
            ],
          ),

          // Divider
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: const Divider(
              color: Color(0xFFF1F5F9),
              height: 1,
              thickness: 1,
            ),
          ),

          // 2. Middle Row: Graduation Cap Icon + Exam Title + Statistics
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.graduationCap,
                    color: const Color(0xFF10B981),
                    size: 18.r,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Text(
                          "মোট প্রশ্ন: ",
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "${item.totalQuestions}",
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFF0F172A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                          child: const Text(
                            "•",
                            style: TextStyle(color: Color(0xFF94A3B8)),
                          ),
                        ),
                        Icon(
                          Icons.check_circle_rounded,
                          size: 13.sp,
                          color: const Color(0xFF10B981),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          "${item.correctCount} সঠিক",
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFF059669),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                          child: const Text(
                            "•",
                            style: TextStyle(color: Color(0xFF94A3B8)),
                          ),
                        ),
                        Icon(
                          Icons.cancel_rounded,
                          size: 13.sp,
                          color: const Color(0xFFEF4444),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          "${item.wrongCount} ভুল",
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFFDC2626),
                            fontWeight: FontWeight.bold,
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

          // 3. Bottom Row: Obtained Marks + Action Buttons (Rank & Result Sheet)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Obtained Marks
                Row(
                  children: [
                    Text(
                      "প্রাপ্ত নম্বর: ",
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      item.obtainedMark,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: item.obtainedMark.startsWith('-')
                            ? const Color(0xFF0D9488)
                            : (item.obtainedMark == "0"
                                ? const Color(0xFF059669)
                                : const Color(0xFF059669)),
                      ),
                    ),
                  ],
                ),

                // Actions: Rank & Result Sheet Buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Rank Button
                    InkWell(
                      onTap: onRankTap,
                      borderRadius: BorderRadius.circular(20.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 11.w,
                          vertical: 4.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: const Color(0xFFCBD5E1),
                            width: 0.9,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.emoji_events_rounded,
                              size: 13.sp,
                              color: const Color(0xFFF59E0B),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              "র‍্যাঙ্ক",
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),

                    // Result Sheet Button
                    InkWell(
                      onTap: onResultSheetTap,
                      borderRadius: BorderRadius.circular(20.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 11.w,
                          vertical: 4.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: const Color(0xFF059669),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF059669)
                                  .withValues(alpha: 0.06),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Center(
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
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
