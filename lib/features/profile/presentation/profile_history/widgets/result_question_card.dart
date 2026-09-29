import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:lokkha/core/theme/theme_extensions.dart';
import 'package:lokkha/features/profile/profile.dart';

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
          // Left accent strip (Green if correct, Red if wrong, Amber if avoided)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4.5.w,
              color: item.isCorrect
                  ? const Color(0xFF10B981)
                  : (item.isWrong
                      ? const Color(0xFFEF4444)
                      : const Color(0xFFF59E0B)),
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

                    // Question Title with HtmlWidget (Dark/Light mode compliant)
                    Expanded(
                      child: _buildHtml(
                        context,
                        item.questionText.isNotEmpty
                            ? item.questionText
                            : "প্রশ্ন ${item.questionNumber}",
                        defaultColor: context.textPrimary,
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w800,
                        lineHeight: 1.35,
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
                    final isUserChoice = item.userSelectedOptionIndex == index;
                    final isUserWrong = isUserChoice && !isCorrect;

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
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: borderColor,
                          width: (isCorrect || isUserWrong) ? 1.2 : 0.8,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                            child: item.options[index].trim().isNotEmpty
                                ? _buildHtml(
                                    context,
                                    item.options[index],
                                    defaultColor: textColor,
                                    fontSize: 13.sp,
                                    fontWeight: isCorrect
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    lineHeight: 1.3,
                                  )
                                : const SizedBox.shrink(),
                          ),
                          if (isUserChoice) ...[
                            SizedBox(width: 6.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 3.h,
                              ),
                              decoration: BoxDecoration(
                                color: isCorrect
                                    ? (context.isDark
                                        ? const Color(0xFF064E3B)
                                        : const Color(0xFFE0F2FE))
                                    : (context.isDark
                                        ? const Color(0xFF7F1D1D)
                                            .withValues(alpha: 0.5)
                                        : const Color(0xFFEFF6FF)),
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(
                                  color: isCorrect
                                      ? const Color(0xFF10B981)
                                          .withValues(alpha: 0.4)
                                      : const Color(0xFF93C5FD)
                                          .withValues(alpha: 0.6),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                "Your Choice",
                                style: TextStyle(
                                  fontSize: 10.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: isCorrect
                                      ? const Color(0xFF059669)
                                      : const Color(0xFF2563EB),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                ),

                // 3. Explanation Box (rendered using HtmlWidget)
                if (item.explanation != null &&
                    item.explanation!.trim().isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: BorderRadius.circular(10.r),
                      border:
                          Border.all(color: context.borderColor, width: 0.8),
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
                              _buildHtml(
                                context,
                                item.explanation!,
                                defaultColor: context.textPrimary,
                                fontSize: 12.5.sp,
                                lineHeight: 1.5,
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

  /// Renders HTML content cleanly in both Light and Dark mode.
  /// Removes hardcoded dark text colors and blinding white backgrounds
  /// from the API inline CSS, ensuring high contrast and smooth readability.
  Widget _buildHtml(
    BuildContext context,
    String htmlContent, {
    required Color defaultColor,
    required double fontSize,
    FontWeight fontWeight = FontWeight.normal,
    double lineHeight = 1.4,
  }) {
    final trimmed = htmlContent.trim();
    if (trimmed.isEmpty) return const SizedBox.shrink();

    final isDark = context.isDark;
    final r = (defaultColor.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (defaultColor.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (defaultColor.b * 255).round().toRadixString(16).padLeft(2, '0');
    final colorHex = '#$r$g$b';

    // Sanitize inline styles so they don't override the theme text color in dark mode
    String cleaned = trimmed;
    if (isDark) {
      cleaned = cleaned.replaceAll(
        RegExp(r'color\s*:\s*[^;"]+;?', caseSensitive: false),
        '',
      );
    }
    // Remove white or hardcoded background colors from inline HTML
    cleaned = cleaned.replaceAll(
      RegExp(r'background-color\s*:\s*[^;"]+;?', caseSensitive: false),
      '',
    );

    return HtmlWidget(
      cleaned,
      textStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: defaultColor,
        height: lineHeight,
      ),
      customStylesBuilder: (element) {
        return {
          'color': colorHex,
          'background-color': 'transparent',
        };
      },
    );
  }
}
