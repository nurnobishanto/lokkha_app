import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/config/theme/theme_extensions.dart';
import '../models/exam_question_result_model.dart';

class ResultQuestionCard extends StatelessWidget {
  final ExamQuestionResultModel item;

  const ResultQuestionCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    const optionLetters = ['A', 'B', 'C', 'D'];

    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Left amber accent strip
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4.5.w,
              color: const Color(0xFFF59E0B),
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 14.w, 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          // 1. Question Header (Number badge + Title + Status icon)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question Number Badge
              Container(
                width: 28.r,
                height: 28.r,
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Text(
                    "${item.questionNumber}",
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                      color: context.textPrimary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),

              // Question Title
              Expanded(
                child: Text(
                  item.questionText,
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary,
                    height: 1.3,
                  ),
                ),
              ),
              SizedBox(width: 6.w),

              // Status Icon
              Icon(
                item.isCorrect
                    ? Icons.check_circle_rounded
                    : (item.isWrong
                        ? Icons.cancel_rounded
                        : Icons.remove_circle_rounded),
                color: item.isCorrect
                    ? const Color(0xFF10B981)
                    : (item.isWrong
                        ? const Color(0xFFEF4444)
                        : const Color(0xFFF59E0B)),
                size: 19.sp,
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // 2. Options List
          Column(
            children: List.generate(item.options.length, (index) {
              final isCorrect = index == item.correctOptionIndex;
              final isUserWrong = item.userSelectedOptionIndex == index && !isCorrect;

              Color bgColor = context.cardColor;
              Color borderColor = context.borderColor;
              Color letterColor = context.textSecondary;
              Color textColor = context.textPrimary;

              if (isCorrect) {
                bgColor = context.isDark
                    ? const Color(0xFF064E3B).withValues(alpha: 0.3)
                    : const Color(0xFFF0FDF4);
                borderColor = const Color(0xFF10B981);
                letterColor = const Color(0xFF10B981);
                textColor = context.isDark
                    ? const Color(0xFF6EE7B7)
                    : const Color(0xFF065F46);
              } else if (isUserWrong) {
                bgColor = context.isDark
                    ? const Color(0xFF7F1D1D).withValues(alpha: 0.3)
                    : const Color(0xFFFEF2F2);
                borderColor = const Color(0xFFEF4444);
                letterColor = const Color(0xFFEF4444);
                textColor = context.isDark
                    ? const Color(0xFFFCA5A5)
                    : const Color(0xFF991B1B);
              }

              return Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: borderColor,
                    width: (isCorrect || isUserWrong) ? 1.2 : 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      optionLetters[index],
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        color: letterColor,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        item.options[index],
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: isCorrect ? FontWeight.w700 : FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),

          // 3. Explanation Box (if available)
          if (item.explanation != null && item.explanation!.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: context.borderColor, width: 0.8),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 3.5.w,
                      color: const Color(0xFF059669),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(14.w, 12.h, 12.w, 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline_rounded,
                              size: 14.sp,
                              color: const Color(0xFF059669),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              "ব্যাখ্যা",
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF059669),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          item.explanation!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: context.textPrimary,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
