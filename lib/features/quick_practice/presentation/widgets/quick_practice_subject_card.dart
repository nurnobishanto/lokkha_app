import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/quick_practice/data/models/quick_practice_models.dart';

class QuickPracticeSubjectCard extends StatelessWidget {
  final QuickPracticeSubject subject;
  final VoidCallback onTap;

  const QuickPracticeSubjectCard({
    super.key,
    required this.subject,
    required this.onTap,
  });

  static String _toBengaliDigits(int number) {
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
    final hasChildren = subject.hasChildren;
    final qCount = subject.totalQuestions;

    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: context.borderColor.withValues(alpha: context.isDark ? 0.7 : 0.8),
          width: 0.9,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: context.isDark ? 0.25 : 0.03,
            ),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 9.5.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top row: Category icon & arrow indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: BoxDecoration(
                        color: context.primaryColor.withValues(
                          alpha: context.isDark ? 0.22 : 0.09,
                        ),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        hasChildren
                            ? Icons.folder_open_rounded
                            : Icons.auto_stories_rounded,
                        size: 16.5.sp,
                        color: context.primaryColor,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 11.5.sp,
                      color: context.textMuted.withValues(alpha: 0.55),
                    ),
                  ],
                ),

                SizedBox(height: 5.h),

                // Subject Name
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      subject.name,
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                SizedBox(height: 5.h),

                // Bottom: Badges row (Question Count + Children count)
                Row(
                  children: [
                    if (qCount > 0)
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 5.5.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: context.isDark
                                ? const Color(0xFF064E3B)
                                : const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                          child: Text(
                            '${subject.formattedQuestionsCount} প্রশ্ন',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9.8.sp,
                              fontWeight: FontWeight.w600,
                              color: context.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    if (qCount > 0 && hasChildren) SizedBox(width: 4.w),
                    if (hasChildren)
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 5.5.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: context.isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                          child: Text(
                            '${_toBengaliDigits(subject.childrenCount)}টি টপিক',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9.8.sp,
                              fontWeight: FontWeight.w600,
                              color: context.textSecondary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
