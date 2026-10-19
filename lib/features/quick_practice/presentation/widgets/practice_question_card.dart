import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/quick_practice/data/models/quick_practice_models.dart';

class PracticeQuestionCard extends StatelessWidget {
  final PracticeQuestion question;
  final int index;
  final dynamic selectedOptionKey;
  final bool isExplanationExpanded;
  final bool isBookmarked;
  final void Function(dynamic optionKey) onSelectOption;
  final VoidCallback onToggleExplanation;
  final VoidCallback onToggleBookmark;

  const PracticeQuestionCard({
    super.key,
    required this.question,
    required this.index,
    required this.selectedOptionKey,
    required this.isExplanationExpanded,
    required this.isBookmarked,
    required this.onSelectOption,
    required this.onToggleExplanation,
    required this.onToggleBookmark,
  });

  static String _toBengaliNumber(int number) {
    const bengaliDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    final s = number.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final code = s.codeUnitAt(i);
      if (code >= 48 && code <= 57) {
        buffer.write(bengaliDigits[code - 48]);
      } else {
        buffer.write(s[i]);
      }
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final isAnswered = selectedOptionKey != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasExplanation = question.explanation != null &&
        question.explanation!.trim().isNotEmpty;

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: context.borderColor.withValues(alpha: isDark ? 0.7 : 0.8),
          width: 0.9,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isDark ? 0.25 : 0.03,
            ),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Question number & Bookmark button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 9.w,
                    vertical: 3.h,
                  ),
                  decoration: BoxDecoration(
                    color: context.primaryColor.withValues(
                      alpha: isDark ? 0.2 : 0.09,
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.quiz_outlined,
                        size: 13.sp,
                        color: context.primaryColor,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'প্রশ্ন ${_toBengaliNumber(index + 1)}',
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w700,
                          color: context.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onToggleBookmark,
                  icon: Icon(
                    isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    size: 20.sp,
                    color: isBookmarked
                        ? context.primaryColor
                        : context.textMuted,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            SizedBox(height: 10.h),

            // Question Title with HtmlWidget (supports Wirisformula MathML / SVG / text)
            HtmlWidget(
              question.title,
              textStyle: TextStyle(
                fontSize: 14.5.sp,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
                height: 1.4,
              ),
            ),

            if (question.description != null &&
                question.description!.trim().isNotEmpty) ...[
              SizedBox(height: 6.h),
              HtmlWidget(
                question.description!,
                textStyle: TextStyle(
                  fontSize: 12.5.sp,
                  color: context.textSecondary,
                  height: 1.35,
                ),
              ),
            ],

            SizedBox(height: 12.h),

            // MCQ Options
            ...question.options.map((option) {
              final isSelected = selectedOptionKey != null &&
                  (selectedOptionKey == option.key ||
                      selectedOptionKey.toString() == option.key.toString());
              final isCorrect = option.isCorrect;

              // Color state
              Color bgColor = context.surfaceSubtle;
              Color borderColor = context.borderColor;
              Color textColor = context.textPrimary;
              Color letterBgColor = context.borderColor.withValues(alpha: 0.5);
              Color letterTextColor = context.textSecondary;
              Widget? statusIcon;

              if (isAnswered) {
                if (isSelected) {
                  if (isCorrect) {
                    bgColor = isDark
                        ? const Color(0xFF064E3B)
                        : const Color(0xFFECFDF5);
                    borderColor = const Color(0xFF10B981);
                    letterBgColor = const Color(0xFF10B981);
                    letterTextColor = Colors.white;
                    textColor = const Color(0xFF065F46);
                    statusIcon = Icon(
                      Icons.check_circle_rounded,
                      size: 18.sp,
                      color: const Color(0xFF10B981),
                    );
                  } else {
                    bgColor = isDark
                        ? const Color(0xFF4C0519)
                        : const Color(0xFFFFF1F2);
                    borderColor = const Color(0xFFF43F5E);
                    letterBgColor = const Color(0xFFF43F5E);
                    letterTextColor = Colors.white;
                    textColor = const Color(0xFF9F1239);
                    statusIcon = Icon(
                      Icons.cancel_rounded,
                      size: 18.sp,
                      color: const Color(0xFFF43F5E),
                    );
                  }
                } else if (isCorrect) {
                  // Reveal correct answer
                  bgColor = isDark
                      ? const Color(0xFF064E3B).withValues(alpha: 0.6)
                      : const Color(0xFFECFDF5);
                  borderColor = const Color(0xFF10B981).withValues(alpha: 0.8);
                  letterBgColor = const Color(0xFF10B981);
                  letterTextColor = Colors.white;
                  textColor = const Color(0xFF065F46);
                  statusIcon = Icon(
                    Icons.check_circle_outline_rounded,
                    size: 18.sp,
                    color: const Color(0xFF10B981),
                  );
                } else {
                  textColor = context.textMuted;
                }
              }

              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isAnswered ? null : () => onSelectOption(option.key),
                    borderRadius: BorderRadius.circular(10.r),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 9.h,
                      ),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: borderColor,
                          width: isSelected || (isAnswered && isCorrect) ? 1.4 : 0.8,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 26.r,
                            height: 26.r,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: letterBgColor,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              option.bengaliLetter,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: letterTextColor,
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: HtmlWidget(
                              option.value,
                              textStyle: TextStyle(
                                fontSize: 13.5.sp,
                                fontWeight: isSelected || (isAnswered && isCorrect)
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                          ),
                          if (statusIcon != null) ...[
                            SizedBox(width: 8.w),
                            statusIcon,
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),

            // Explanation / Answer Reveal Section
            if (isAnswered) ...[
              SizedBox(height: 6.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'সঠিক উত্তর: ${question.bengaliCorrectLetter}',
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF059669),
                    ),
                  ),
                  if (hasExplanation)
                    InkWell(
                      onTap: onToggleExplanation,
                      borderRadius: BorderRadius.circular(6.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline_rounded,
                              size: 14.sp,
                              color: const Color(0xFFD97706),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              isExplanationExpanded
                                  ? 'ব্যাখ্যা লুকান'
                                  : 'ব্যাখ্যা দেখুন',
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFD97706),
                              ),
                            ),
                            Icon(
                              isExplanationExpanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              size: 16.sp,
                              color: const Color(0xFFD97706),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              if (hasExplanation && isExplanationExpanded) ...[
                SizedBox(height: 8.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(11.r),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: const Color(0xFFFDE68A),
                      width: 0.8,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.menu_book_rounded,
                            size: 13.sp,
                            color: const Color(0xFFB45309),
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            'বিস্তারিত ব্যাখ্যা:',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFB45309),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5.h),
                      HtmlWidget(
                        question.explanation!,
                        textStyle: TextStyle(
                          fontSize: 12.5.sp,
                          color: isDark ? Colors.white70 : const Color(0xFF334155),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
