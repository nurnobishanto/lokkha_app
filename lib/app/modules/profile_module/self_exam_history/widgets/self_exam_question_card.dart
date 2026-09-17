import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/self_exam_question_model.dart';

class SelfExamQuestionCard extends StatelessWidget {
  final SelfExamQuestionModel item;

  const SelfExamQuestionCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = item.isCorrect
        ? const Color(0xFF86EFAC)
        : const Color(0xFFFCA5A5);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: borderColor, width: 1.2),
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
          // 1. Question Title
          Text(
            "${item.questionNumber}) ${item.questionText}",
            style: TextStyle(
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              height: 1.3,
            ),
          ),

          SizedBox(height: 12.h),

          // 2. Options List
          Column(
            children: List.generate(item.options.length, (index) {
              final optionText = item.options[index];

              return Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: const Color(0xFF99F6E4), // Mint/teal border matching screenshot
                    width: 1.2,
                  ),
                ),
                child: Text(
                  optionText,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F766E),
                  ),
                ),
              );
            }),
          ),

          SizedBox(height: 6.h),

          // 3. Your Answer Row
          Row(
            children: [
              Text(
                "Your Answer: ",
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFDC2626),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  item.yourAnswer ?? "N/A",
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 6.h),

          // 4. Correct Answer Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Correct Answer: ",
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF059669),
                ),
              ),
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    item.correctAnswer,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 5. Explanation Box (if present)
          if (item.explanation != null && item.explanation!.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                "ব্যাখ্যা: ${item.explanation!}",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF475569),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
