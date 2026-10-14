import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/home/data/models/home_feed_model.dart';
import 'package:lokkha/features/question_bank/presentation/views/question_bank_exam_view.dart';

class QuestionBankExamSheet extends StatefulWidget {
  final HomeQuestionBankItem bankItem;

  const QuestionBankExamSheet({
    super.key,
    required this.bankItem,
  });

  static Future<void> show(BuildContext context, HomeQuestionBankItem item) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QuestionBankExamSheet(bankItem: item),
    );
  }

  @override
  State<QuestionBankExamSheet> createState() => _QuestionBankExamSheetState();
}

class _QuestionBankExamSheetState extends State<QuestionBankExamSheet> {
  int _selectedDuration = 15;
  double _selectedNegative = 0.25;

  Color _getThemeColor(String? colorName) {
    switch (colorName) {
      case 'sky':
        return const Color(0xFF0284C7);
      case 'rose':
        return const Color(0xFFE11D48);
      case 'amber':
        return const Color(0xFFD97706);
      case 'emerald':
      default:
        return const Color(0xFF006A4E);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _getThemeColor(widget.bankItem.themeColor);

    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Drag Handle
          Center(
            child: Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: context.borderColor,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Header Row: Theme Icon + Title & Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  Icons.auto_stories_rounded,
                  color: themeColor,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.bankItem.badge != null &&
                        widget.bankItem.badge!.isNotEmpty) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: themeColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          widget.bankItem.badge!,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: themeColor,
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                    ],
                    Text(
                      widget.bankItem.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (widget.bankItem.subtitle != null &&
              widget.bankItem.subtitle!.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Text(
              widget.bankItem.subtitle!,
              style: TextStyle(
                fontSize: 12.sp,
                color: context.textSecondary,
                height: 1.35,
              ),
            ),
          ],

          SizedBox(height: 16.h),

          // Time Duration Selector
          Text(
            'পরীক্ষার সময় নির্বাচন করুন',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            children: [10, 15, 30, 60].map((mins) {
              final isSelected = _selectedDuration == mins;
              return ChoiceChip(
                label: Text('$mins মিনিট'),
                selected: isSelected,
                selectedColor: themeColor,
                backgroundColor: context.scaffoldBg,
                labelStyle: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : context.textPrimary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  side: BorderSide(
                    color: isSelected ? themeColor : context.borderColor,
                  ),
                ),
                onSelected: (val) {
                  if (val) setState(() => _selectedDuration = mins);
                },
              );
            }).toList(),
          ),

          SizedBox(height: 14.h),

          // Negative Marking Selector
          Text(
            'নেগেটিভ মার্কিং',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            children: [0.0, 0.25, 0.50].map((neg) {
              final isSelected = _selectedNegative == neg;
              return ChoiceChip(
                label: Text(neg == 0.0 ? 'নেই' : '-$neg'),
                selected: isSelected,
                selectedColor: themeColor,
                backgroundColor: context.scaffoldBg,
                labelStyle: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : context.textPrimary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  side: BorderSide(
                    color: isSelected ? themeColor : context.borderColor,
                  ),
                ),
                onSelected: (val) {
                  if (val) setState(() => _selectedNegative = neg);
                },
              );
            }).toList(),
          ),

          SizedBox(height: 20.h),

          // Primary Start Exam Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => QuestionBankExamView(
                      bankItem: widget.bankItem,
                      durationMinutes: _selectedDuration,
                      negativeMark: _selectedNegative,
                      isPracticeMode: false,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.play_circle_outline_rounded, size: 20),
              label: const Text('লাইভ পরীক্ষা শুরু করুন'),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 13.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
            ),
          ),

          SizedBox(height: 10.h),

          // Secondary Practice & Past Exams Row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => QuestionBankExamView(
                          bankItem: widget.bankItem,
                          isPracticeMode: true,
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.menu_book_rounded,
                      size: 18, color: themeColor),
                  label: Text('অনুশীলন মোড',
                      style: TextStyle(color: themeColor, fontSize: 12.5.sp)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: themeColor.withOpacity(0.5)),
                    padding: EdgeInsets.symmetric(vertical: 11.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    if (GoRouter.maybeOf(context) != null) {
                      context.push(Routes.allExam);
                    }
                  },
                  icon: Icon(Icons.history_edu_rounded,
                      size: 18, color: context.textPrimary),
                  label: Text('বিগত প্রশ্নসমূহ',
                      style: TextStyle(
                          color: context.textPrimary, fontSize: 12.5.sp)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: context.borderColor.withOpacity(0.7)),
                    padding: EdgeInsets.symmetric(vertical: 11.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}
