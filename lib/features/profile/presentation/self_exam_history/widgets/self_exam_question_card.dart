import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/core/utils/html_sanitizer.dart';
import 'package:lokkha/features/profile/profile.dart';

class SelfExamQuestionCard extends StatelessWidget {
  final SelfExamQuestionModel item;

  const SelfExamQuestionCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = item.isCorrect
        ? (context.isDark ? const Color(0xFF059669) : const Color(0xFF86EFAC))
        : (context.isDark ? const Color(0xFFDC2626) : const Color(0xFFFCA5A5));

    final hasCorrectAnswer = item.correctAnswer.trim().isNotEmpty;
    final hasYourAnswer =
        item.yourAnswer != null && item.yourAnswer!.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: context.isDark
                ? Colors.transparent
                : Colors.black.withValues(alpha: 0.02),
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
          HtmlWidget(
            HtmlSanitizer.formatForDisplay(
              "${item.questionNumber}) ${item.questionText}",
              isDark: context.isDark,
            ),
            textStyle: TextStyle(
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w800,
              color: context.textPrimary,
              height: 1.3,
            ),
            customStylesBuilder: (element) {
              if (element.localName == 'p') {
                return {'margin': '0', 'padding': '0'};
              }
              return null;
            },
          ),

          if (item.options.isNotEmpty) ...[
            SizedBox(height: 12.h),

            // 2. Options List
            Column(
              children: List.generate(item.options.length, (index) {
                final optionText = item.options[index];

                final cleanOption = optionText
                    .replaceAll(RegExp(r'^[A-D]\)\s*'), '')
                    .trim()
                    .toLowerCase();
                final cleanCorrect = item.correctAnswer
                    .replaceAll(RegExp(r'^[A-D]\)\s*'), '')
                    .trim()
                    .toLowerCase();
                final cleanUser = item.yourAnswer
                    ?.replaceAll(RegExp(r'^[A-D]\)\s*'), '')
                    .trim()
                    .toLowerCase();

                final isCorrectOption = cleanCorrect.isNotEmpty &&
                    (cleanOption == cleanCorrect ||
                        optionText.toLowerCase().contains(cleanCorrect) ||
                        item.correctAnswer.toLowerCase().contains(cleanOption));

                final isUserChoice = cleanUser != null &&
                    cleanUser.isNotEmpty &&
                    (cleanOption == cleanUser ||
                        optionText.toLowerCase().contains(cleanUser) ||
                        item.yourAnswer!.toLowerCase().contains(cleanOption));

                final isUserWrong = isUserChoice && !isCorrectOption;

                Color bgColor = context.isDark
                    ? const Color(0xFF1E293B)
                    : Colors.white;
                Color optBorderColor = context.isDark
                    ? const Color(0xFF0F766E)
                    : const Color(0xFF99F6E4);
                Color textColor = context.isDark
                    ? const Color(0xFF5EEAD4)
                    : const Color(0xFF0F766E);

                if (isCorrectOption) {
                  bgColor = context.isDark
                      ? const Color(0xFF064E3B).withValues(alpha: 0.35)
                      : const Color(0xFFECFDF5);
                  optBorderColor = const Color(0xFF059669);
                  textColor = context.isDark
                      ? const Color(0xFF34D399)
                      : const Color(0xFF065F46);
                } else if (isUserWrong) {
                  bgColor = context.isDark
                      ? const Color(0xFF7F1D1D).withValues(alpha: 0.35)
                      : const Color(0xFFFEF2F2);
                  optBorderColor = const Color(0xFFDC2626);
                  textColor = context.isDark
                      ? const Color(0xFFF87171)
                      : const Color(0xFF991B1B);
                }

                return Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: optBorderColor,
                      width: (isCorrectOption || isUserWrong) ? 1.4 : 1.1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: HtmlWidget(
                          HtmlSanitizer.formatForDisplay(
                            optionText,
                            isDark: context.isDark,
                          ),
                          textStyle: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: isCorrectOption
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: textColor,
                          ),
                          customStylesBuilder: (element) {
                            if (element.localName == 'p') {
                              return {'margin': '0', 'padding': '0'};
                            }
                            return null;
                          },
                        ),
                      ),
                      if (isCorrectOption) ...[
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.check_circle_rounded,
                          size: 16.sp,
                          color: const Color(0xFF059669),
                        ),
                      ] else if (isUserWrong) ...[
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.cancel_rounded,
                          size: 16.sp,
                          color: const Color(0xFFDC2626),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ),
          ],

          if (hasYourAnswer) ...[
            SizedBox(height: 6.h),
            // 3. Your Answer Row
            Row(
              children: [
                Text(
                  "Your Answer: ",
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.bold,
                    color: item.isCorrect
                        ? (context.isDark
                            ? const Color(0xFF34D399)
                            : const Color(0xFF059669))
                        : (context.isDark
                            ? const Color(0xFFF87171)
                            : const Color(0xFFDC2626)),
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: item.isCorrect
                        ? const Color(0xFF059669)
                        : const Color(0xFFDC2626),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    item.yourAnswer!,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],

          if (hasCorrectAnswer) ...[
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
                    color: context.isDark
                        ? const Color(0xFF34D399)
                        : const Color(0xFF059669),
                  ),
                ),
                Flexible(
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
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
          ],

          // 5. Explanation Box (if present)
          if (item.explanation != null &&
              item.explanation!.trim().isNotEmpty) ...[
            SizedBox(height: 10.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: context.isDark
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: context.borderColor),
              ),
              child: HtmlWidget(
                HtmlSanitizer.formatForDisplay(
                  "ব্যাখ্যা: ${item.explanation!}",
                  isDark: context.isDark,
                ),
                textStyle: TextStyle(
                  fontSize: 12.sp,
                  color: context.textSecondary,
                  height: 1.4,
                ),
                customStylesBuilder: (element) {
                  if (element.localName == 'p') {
                    return {'margin': '0', 'padding': '0'};
                  }
                  return null;
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
