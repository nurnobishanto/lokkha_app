import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/auth/auth.dart';
import 'package:lokkha/features/quick_practice/data/models/quick_practice_models.dart';
import 'package:lokkha/features/quick_practice/presentation/providers/quick_practice_providers.dart';
import 'package:lokkha/shared/widgets/web_exam_view.dart';

class SubjectExamSetupBottomSheet extends ConsumerStatefulWidget {
  final int subjectId;
  final String subjectTitle;
  final int? availableQuestions;

  const SubjectExamSetupBottomSheet({
    super.key,
    required this.subjectId,
    required this.subjectTitle,
    this.availableQuestions,
  });

  static Future<void> show(
    BuildContext context, {
    required int subjectId,
    required String subjectTitle,
    int? availableQuestions,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SubjectExamSetupBottomSheet(
        subjectId: subjectId,
        subjectTitle: subjectTitle,
        availableQuestions: availableQuestions,
      ),
    );
  }

  @override
  ConsumerState<SubjectExamSetupBottomSheet> createState() =>
      _SubjectExamSetupBottomSheetState();
}

class _SubjectExamSetupBottomSheetState
    extends ConsumerState<SubjectExamSetupBottomSheet> {
  int _questionCount = 10;
  bool _enableTimer = true;
  int _durationMinutes = 15;
  bool _enableNegativeMark = true;
  double _negativeMark = 0.25;
  String _questionOption = 'random'; // random, latest, unanswered

  Future<void> _handleStartExam() async {
    if (!isLoggedIn.value) {
      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AuthGatewayView()),
      );
      return;
    }

    final request = SubjectStartExamRequest(
      questionCount: _questionCount,
      enableTimer: _enableTimer,
      time: _enableTimer ? _durationMinutes : 0,
      enableNegativeMark: _enableNegativeMark,
      negativeMark: _enableNegativeMark ? _negativeMark : 0.0,
      questionOption: _questionOption,
    );

    final session =
        await ref.read(subjectExamSetupNotifierProvider.notifier).startExam(
              subjectId: widget.subjectId,
              request: request,
            );

    if (session != null && mounted) {
      final startUrl = session.startUrl;
      if (startUrl != null && startUrl.isNotEmpty) {
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WebExamView(
              title: widget.subjectTitle,
              url: startUrl,
              examId: session.examId,
              mode: ExamWebViewMode.start,
              isExamRunning: true,
            ),
          ),
        );
      } else {
        CustomSnackBar.showCustomErrorSnackBar(
          title: 'ত্রুটি',
          message: 'পরীক্ষার লিংক পাওয়া যায়নি। পুনরায় চেষ্টা করুন।',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final setupState = ref.watch(subjectExamSetupNotifierProvider);

    return Container(
      padding: EdgeInsets.fromLTRB(
        16.w,
        12.h,
        16.w,
        MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 44.w,
                height: 4.5.h,
                decoration: BoxDecoration(
                  color: context.borderColor,
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            ),
            SizedBox(height: 14.h),

            // Header Title + Subject
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(7.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFF006A4E).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.quiz_rounded,
                    color: const Color(0xFF006A4E),
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'অনুশীলন পরীক্ষা সেটআপ',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        widget.subjectTitle,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: context.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, size: 20.sp),
                  color: context.textMuted,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            Divider(height: 20.h, color: context.borderColor),

            // 1. Question Count Selection
            Text(
              'প্রশ্ন সংখ্যা',
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [10, 15, 20, 30].map((count) {
                final isSelected = _questionCount == count;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.w),
                    child: _buildChoiceChip(
                      label: '$countটি',
                      isSelected: isSelected,
                      onTap: () => setState(() => _questionCount = count),
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 14.h),

            // 2. Timer & Duration
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'পরীক্ষার সময়সীমা',
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                Switch(
                  value: _enableTimer,
                  activeThumbColor: const Color(0xFF006A4E),
                  onChanged: (val) => setState(() => _enableTimer = val),
                ),
              ],
            ),
            if (_enableTimer) ...[
              SizedBox(height: 6.h),
              Row(
                children: [10, 15, 20, 30].map((mins) {
                  final isSelected = _durationMinutes == mins;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                      child: _buildChoiceChip(
                        label: '$mins মিনিট',
                        isSelected: isSelected,
                        onTap: () => setState(() => _durationMinutes = mins),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            SizedBox(height: 14.h),

            // 3. Negative Marking
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'নেগেটিভ মার্কিং',
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                Switch(
                  value: _enableNegativeMark,
                  activeThumbColor: const Color(0xFF006A4E),
                  onChanged: (val) => setState(() => _enableNegativeMark = val),
                ),
              ],
            ),
            if (_enableNegativeMark) ...[
              SizedBox(height: 6.h),
              Row(
                children: [
                  {'label': '০.২৫', 'value': 0.25},
                  {'label': '০.৫০', 'value': 0.50},
                ].map((item) {
                  final val = item['value'] as double;
                  final label = item['label'] as String;
                  final isSelected = _negativeMark == val;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                      child: _buildChoiceChip(
                        label: '$label নম্বর',
                        isSelected: isSelected,
                        onTap: () => setState(() => _negativeMark = val),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            SizedBox(height: 14.h),

            // 4. Question Filter Mode
            Text(
              'প্রশ্ন বাছাইয়ের নিয়ম',
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                {'label': 'র‍্যান্ডম', 'value': 'random'},
                {'label': 'সর্বশেষ', 'value': 'latest'},
                {'label': 'নতুন প্রশ্ন', 'value': 'unanswered'},
              ].map((item) {
                final val = item['value'] as String;
                final label = item['label'] as String;
                final isSelected = _questionOption == val;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.w),
                    child: _buildChoiceChip(
                      label: label,
                      isSelected: isSelected,
                      onTap: () => setState(() => _questionOption = val),
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 18.h),

            // Error notice if any
            if (setupState.errorMessage != null) ...[
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: const Color(0xFFFECDD3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: const Color(0xFFE11D48),
                      size: 16.sp,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        setupState.errorMessage!,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: const Color(0xFFBE123C),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
            ],

            // Start Exam CTA Button
            Container(
              width: double.infinity,
              height: 48.h,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF006A4E),
                    Color(0xFF059669),
                  ],
                ),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF006A4E).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: setupState.isStarting ? null : _handleStartExam,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: setupState.isStarting
                    ? SizedBox(
                        width: 20.r,
                        height: 20.r,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'পরীক্ষা শুরু করুন',
                            style: TextStyle(
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF006A4E).withValues(
                  alpha: context.isDark ? 0.25 : 0.1,
                )
              : (context.isDark
                  ? context.surfaceColor
                  : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF006A4E) : context.borderColor,
            width: isSelected ? 1.4 : 1.0,
          ),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color:
                    isSelected ? const Color(0xFF006A4E) : context.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
