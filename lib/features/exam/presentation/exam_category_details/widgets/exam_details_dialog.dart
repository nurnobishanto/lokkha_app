import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:lokkha/app/router/router.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/shared/models/exam.dart';
import 'package:lokkha/shared/widgets/web_exam_view.dart';
import 'package:lokkha/features/exam/presentation/providers/exam_taking_notifier.dart';
import 'package:lokkha/features/exam/data/models/exam_lifecycle_models.dart';

const Color primaryColor = Color(0xFF006A4E);

class ExamDetailsDialog extends ConsumerStatefulWidget {
  final Exam? exam;
  final int? examId;
  final String? title;

  const ExamDetailsDialog({
    super.key,
    this.exam,
    this.examId,
    this.title,
  });

  @override
  ConsumerState<ExamDetailsDialog> createState() => _ExamDetailsDialogState();
}

class _ExamDetailsDialogState extends ConsumerState<ExamDetailsDialog> {
  int get effectiveExamId => widget.exam?.id ?? widget.examId ?? 0;
  String get effectiveTitle => widget.exam?.name ?? widget.title ?? 'পরীক্ষা';

  @override
  void initState() {
    super.initState();
    if (effectiveExamId > 0) {
      Future.microtask(() {
        ref.read(examTakingNotifierProvider.notifier).loadInstructions(effectiveExamId);
      });
    }
  }

  void _startExam(ExamInstructionsData? data) {
    Navigator.of(context).pop();

    final token = MySharedPref.getUserToken();
    if (token.isEmpty) {
      context.pushNamed(Routes.authGateway);
      return;
    }

    final webviewUrl = (data != null && data.webviewUrls.start.isNotEmpty)
        ? data.webviewUrls.start
        : Endpoints.v1ExamWebviewStart(effectiveExamId, token: token);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WebExamView(
          title: effectiveTitle,
          url: webviewUrl,
          examId: effectiveExamId,
          mode: ExamWebViewMode.start,
          isExamRunning: true,
        ),
      ),
    );
  }

  void _readExam(ExamInstructionsData? data) {
    Navigator.of(context).pop();

    final token = MySharedPref.getUserToken();
    final webviewUrl = (data != null && data.webviewUrls.read.isNotEmpty)
        ? data.webviewUrls.read
        : Endpoints.v1ExamWebviewRead(effectiveExamId, token: token);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WebExamView(
          title: '$effectiveTitle (প্রশ্ন পড়ুন)',
          url: webviewUrl,
          examId: effectiveExamId,
          mode: ExamWebViewMode.read,
          isExamRunning: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(examTakingNotifierProvider);
    final instructionsData = state.instructions;
    final isLoading = state.isLoading && instructionsData == null;

    final examMeta = instructionsData?.exam;
    final duration = examMeta?.duration ?? widget.exam?.duration ?? 60;
    final totalQ = examMeta?.totalQuestions ?? widget.exam?.questionsCount ?? 0;
    final posMark = examMeta?.positiveMark ?? (widget.exam?.positiveMark?.toDouble() ?? 1.0);
    final negMark = examMeta?.negativeMark ?? (widget.exam?.negativeMark ?? 0.0);
    final passMark = examMeta?.passMark ?? 0.0;
    final description = examMeta?.description ?? widget.exam?.description?.toString() ?? '';
    final eligibility = instructionsData?.eligibility ?? const UserEligibility();
    final instructionsList = instructionsData?.instructions ?? [];

    return Dialog(
      backgroundColor: context.cardColor,
      elevation: 10,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Header
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 15.h),
                  decoration: const BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.assignment_turned_in_rounded,
                            color: Colors.white, size: 20),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              effectiveTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (eligibility.hasActiveSession) ...[
                              SizedBox(height: 3.h),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade700,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  "চলমান পরীক্ষা (Active Session)",
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white70),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                if (isLoading)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: const Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    ),
                  )
                else
                  Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Description if present
                        if (description.isNotEmpty && description != 'null') ...[
                          HtmlWidget(
                            description,
                            textStyle: TextStyle(
                              fontSize: 12.5.sp,
                              color: context.textPrimary,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: 14.h),
                        ],

                        // 2. Metrics Grid
                        Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: context.isDark
                                ? context.surfaceColor
                                : primaryColor.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(color: context.borderColor),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildMetricTile(
                                      context: context,
                                      icon: Icons.timer_outlined,
                                      label: "সময়",
                                      value: "$duration মি.",
                                      color: primaryColor,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: _buildMetricTile(
                                      context: context,
                                      icon: Icons.help_outline_rounded,
                                      label: "প্রশ্ন",
                                      value: "$totalQ টি",
                                      color: const Color(0xFF2563EB),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildMetricTile(
                                      context: context,
                                      icon: Icons.add_circle_outline_rounded,
                                      label: "সঠিক উত্তর",
                                      value: "+$posMark",
                                      color: const Color(0xFF16A34A),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: _buildMetricTile(
                                      context: context,
                                      icon: Icons.remove_circle_outline_rounded,
                                      label: "ভুল উত্তর",
                                      value: "-$negMark",
                                      color: const Color(0xFFDC2626),
                                    ),
                                  ),
                                  if (passMark > 0) ...[
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: _buildMetricTile(
                                        context: context,
                                        icon: Icons.verified_outlined,
                                        label: "পাস মার্ক",
                                        value: "$passMark",
                                        color: const Color(0xFFD97706),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),

                        // 3. Official Instructions List
                        if (instructionsList.isNotEmpty) ...[
                          SizedBox(height: 14.h),
                          Text(
                            "পরীক্ষার নির্দেশনাবলী:",
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.bold,
                              color: context.textPrimary,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          ...instructionsList.map(
                            (inst) => Padding(
                              padding: EdgeInsets.only(bottom: 6.h),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.arrow_right_rounded,
                                    size: 18.sp,
                                    color: primaryColor,
                                  ),
                                  SizedBox(width: 4.w),
                                  Expanded(
                                    child: Text(
                                      inst,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: context.textSecondary,
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        // 4. Ineligibility Warning if cannot take exam
                        if (!eligibility.canTakeExam) ...[
                          SizedBox(height: 12.h),
                          Container(
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.amber.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.lock_outline_rounded,
                                    color: Colors.amber.shade900, size: 20.sp),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    eligibility.reason ??
                                        "এই পরীক্ষায় অংশ নিতে প্যাকেজ সাবস্ক্রিপশন প্রয়োজন।",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.amber.shade900,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        SizedBox(height: 18.h),

                        // 5. Action Buttons (Dual Webview Runners)
                        Row(
                          children: [
                            // Study Mode ("প্রশ্ন পড়ুন")
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: Icon(Icons.menu_book_rounded, size: 16.sp),
                                label: Text(
                                  'প্রশ্ন পড়ুন',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: primaryColor,
                                  side: const BorderSide(color: primaryColor, width: 1.2),
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                                onPressed: () => _readExam(instructionsData),
                              ),
                            ),
                            SizedBox(width: 10.w),

                            // Exam Mode ("পরীক্ষা দিন" / "পুনরায় শুরু করুন")
                            Expanded(
                              flex: 1,
                              child: ElevatedButton.icon(
                                icon: Icon(
                                  eligibility.hasActiveSession
                                      ? Icons.play_arrow_rounded
                                      : Icons.edit_note_rounded,
                                  size: 18.sp,
                                ),
                                label: Text(
                                  eligibility.hasActiveSession
                                      ? 'পুনরায় শুরু'
                                      : 'পরীক্ষা দিন',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: eligibility.hasActiveSession
                                      ? Colors.amber.shade700
                                      : primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  elevation: 2,
                                ),
                                onPressed: eligibility.canTakeExam
                                    ? () => _startExam(instructionsData)
                                    : () {
                                        Navigator.of(context).pop();
                                        context.push(Routes.packages);
                                      },
                              ),
                            ),
                          ],
                        ),

                        // Package upsell footer
                        if (eligibility.requiresPackage && !eligibility.canTakeExam) ...[
                          SizedBox(height: 10.h),
                          Center(
                            child: TextButton.icon(
                              onPressed: () {
                                Navigator.of(context).pop();
                                context.push(Routes.packages);
                              },
                              icon: const Icon(Icons.workspace_premium_rounded,
                                  color: Color(0xFFD97706), size: 16),
                              label: const Text(
                                "প্যাকেজ দেখতে এখানে ট্যাপ করুন",
                                style: TextStyle(
                                  color: Color(0xFFD97706),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: color),
          SizedBox(width: 6.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: context.textSecondary,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
