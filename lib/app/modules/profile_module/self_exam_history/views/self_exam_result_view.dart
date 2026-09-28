import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/config/theme/theme_extensions.dart';
import '../../../../components/custom_app_bar.dart';
import '../../../../components/custom_snackbar.dart';
import '../models/self_exam_activity_model.dart';
import '../models/self_exam_model.dart';
import '../models/self_exam_question_model.dart';
import '../widgets/self_exam_question_card.dart';

class SelfExamResultView extends StatelessWidget {
  final SelfExamModel exam;

  const SelfExamResultView({
    super.key,
    required this.exam,
  });

  @override
  Widget build(BuildContext context) {
    // Activity details matching media_1789640748043.png
    final activity = SelfExamActivityModel(
      time: "০ মিনিট ১০ সেকেন্ড",
      totalQuestions: exam.totalQuestions,
      totalMark: "X 1 = 0",
      positiveMark: "1",
      studentName: "sadman",
      studentId: "250500049",
      fullMark: "${exam.totalQuestions}",
      yourMark: "${exam.obtainedMark} (0) / Failed",
      attempt: "${exam.correctCount + exam.wrongCount} (2%)",
      avoid: "${exam.totalQuestions - (exam.correctCount + exam.wrongCount)} (98%)",
      correct: "${exam.correctCount} (0%)",
      wrong: "${exam.wrongCount} (2%)",
    );

    // Questions list matching media_1789640759734.png
    final List<SelfExamQuestionModel> questionList = [
      const SelfExamQuestionModel(
        questionNumber: 1,
        questionText: "'ভালুকের জ্বর' বাগধারাটির অর্থ কী?",
        options: [
          "A) জ্বর জ্বর ভাব",
          "B) দীর্ঘস্থায়ী জ্বর",
          "C) ক্ষণস্থায়ী জ্বর",
          "D) তীব্র জ্বর",
        ],
        yourAnswer: "A",
        correctAnswer: "C) ক্ষণস্থায়ী জ্বর",
        isCorrect: false,
        explanation: "ভালুকের জ্বর বাগধারাটির সঠিক অর্থ হলো ক্ষণস্থায়ী জ্বর।",
      ),
      const SelfExamQuestionModel(
        questionNumber: 2,
        questionText: "কোনটি 'ঘোড়া' শব্দের সমার্থক শব্দ নয়?",
        options: [
          "A) বড়বা",
          "B) সপ্তি",
          "C) বাজী",
          "D) তোয়",
        ],
        yourAnswer: "A",
        correctAnswer: "D) তোয়",
        isCorrect: false,
        explanation: "'তোয়' শব্দের অর্থ জল বা পানি, এটি ঘোড়া শব্দের সমার্থক নয়।",
      ),
    ];

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: const CustomAppBar(
        title: 'ফলাফল ও বিশ্লেষণ',
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 24.h),
        children: [
          // 1. Header Title Row with green accent strip
          Row(
            children: [
              Container(
                width: 4.w,
                height: 20.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF059669),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  "Result With Activity",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          // 2. Summary Stat Cards (Time, Total Questions, Total Mark, Positive Mark)
          _buildSummaryBox(context, title: "Time", value: activity.time),
          SizedBox(height: 10.h),
          _buildSummaryBox(context, title: "Total Questions", value: "${activity.totalQuestions}"),
          SizedBox(height: 10.h),
          _buildSummaryBox(context, title: "Total Mark", value: activity.totalMark),
          SizedBox(height: 10.h),
          _buildSummaryBox(
            context,
            title: "Positive Mark",
            value: activity.positiveMark,
            titleColor: context.isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
            valueColor: context.isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
          ),

          SizedBox(height: 14.h),

          // 3. Student Performance Card & 2x3 Metric Grid
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: context.borderColor),
              boxShadow: [
                BoxShadow(
                  color: context.isDark ? Colors.transparent : Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header (Student Name & ID)
                Text(
                  "Name : ${activity.studentName}",
                  style: TextStyle(
                    fontSize: 15.5.sp,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  "ID : ${activity.studentId}",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: context.textMuted,
                  ),
                ),

                SizedBox(height: 12.h),
                Divider(height: 1, color: context.borderColor),
                SizedBox(height: 12.h),

                // 2x3 Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        context,
                        label: "Full Mark",
                        value: activity.fullMark,
                        valueColor: context.textPrimary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _buildMetricTile(
                        context,
                        label: "Your Mark",
                        value: activity.yourMark,
                        valueColor: context.isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        context,
                        label: "Attempt",
                        value: activity.attempt,
                        valueColor: context.isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _buildMetricTile(
                        context,
                        label: "Avoid",
                        value: activity.avoid,
                        valueColor: context.isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        context,
                        label: "Correct",
                        value: activity.correct,
                        valueColor: context.isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0D9488),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _buildMetricTile(
                        context,
                        label: "Wrong",
                        value: activity.wrong,
                        valueColor: context.isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // 4. Action Buttons (2x2 Grid matching screenshot)
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.download_rounded,
                  label: "ফলাফল কার্ড",
                  borderColor: context.isDark ? context.borderColor : const Color(0xFF334155),
                  textColor: context.isDark ? context.textPrimary : const Color(0xFF334155),
                  backgroundColor: context.cardColor,
                  onTap: () {
                    CustomSnackBar.showCustomToast(message: "ফলাফল কার্ড ডাউনলোড হচ্ছে...");
                  },
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.download_rounded,
                  label: "দাখিলকৃত উত্তরপত্র",
                  borderColor: context.isDark ? const Color(0xFFEF4444) : const Color(0xFFDC2626),
                  textColor: context.isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
                  backgroundColor: context.isDark
                      ? const Color(0xFF7F1D1D).withValues(alpha: 0.15)
                      : context.cardColor,
                  onTap: () {
                    CustomSnackBar.showCustomToast(message: "দাখিলকৃত উত্তরপত্র প্রস্তুত হচ্ছে...");
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.download_rounded,
                  label: "পরীক্ষার উত্তরপত্র",
                  borderColor: context.isDark ? const Color(0xFF14B8A6) : const Color(0xFF0D9488),
                  textColor: context.isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0D9488),
                  backgroundColor: context.isDark
                      ? const Color(0xFF134E4A).withValues(alpha: 0.15)
                      : context.cardColor,
                  onTap: () {
                    CustomSnackBar.showCustomToast(message: "পরীক্ষার উত্তরপত্র ডাউনলোড হচ্ছে...");
                  },
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.download_rounded,
                  label: "পরীক্ষার প্রশ্নপত্র",
                  borderColor: context.isDark ? const Color(0xFF10B981) : const Color(0xFF059669),
                  textColor: context.isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
                  backgroundColor: context.isDark
                      ? const Color(0xFF064E3B).withValues(alpha: 0.15)
                      : context.cardColor,
                  onTap: () {
                    CustomSnackBar.showCustomToast(message: "পরীক্ষার প্রশ্নপত্র ডাউনলোড হচ্ছে...");
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 18.h),

          // 5. Detailed Questions List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: questionList.length,
            separatorBuilder: (_, __) => SizedBox(height: 14.h),
            itemBuilder: (context, index) {
              return SelfExamQuestionCard(item: questionList[index]);
            },
          ),
        ],
      ),
    );
  }

  // Centered Summary Stat Box (Time, Total Questions, etc.)
  Widget _buildSummaryBox(
    BuildContext context, {
    required String title,
    required String value,
    Color? titleColor,
    Color? valueColor,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: context.isDark ? Colors.transparent : Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w800,
              color: titleColor ?? context.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: valueColor ?? context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // Metric Tile in 2x3 Grid
  Widget _buildMetricTile(
    BuildContext context, {
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: context.isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w600,
              color: context.textMuted,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  // 2x2 Action Button
  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color borderColor,
    required Color textColor,
    Color? backgroundColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 9.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: backgroundColor ?? context.cardColor,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14.sp, color: textColor),
            SizedBox(width: 4.w),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
