import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/profile/profile.dart';
import 'package:lokkha/shared/widgets/custom_app_bar.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';
import '../widgets/result_question_card.dart';

class ExamResultSheetView extends StatelessWidget {
  final ExamHistoryModel exam;

  const ExamResultSheetView({
    super.key,
    required this.exam,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      ExamResultSheetController(exam: exam),
      tag: exam.id,
    );

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: const CustomAppBar(
        title: 'ফলাফল ও সমাধান',
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                SizedBox(height: 12.h),
                Text(
                  "ফলাফল ও সমাধান লোড হচ্ছে...",
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.detail.value == null) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 48.r,
                    color: Colors.redAccent,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: context.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton.icon(
                    onPressed: controller.fetchReview,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text("আবার চেষ্টা করুন"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final detail = controller.detail.value;
        final questions = detail?.questions ?? [];

        final scoreDisplay = detail != null && detail.score != 0.0
            ? _formatNum(detail.score)
            : exam.obtainedMark;
        final totalMarksDisplay = detail != null && detail.totalMarks > 0
            ? _formatNum(detail.totalMarks)
            : (exam.totalMarks > 0 ? _formatNum(exam.totalMarks) : "0");
        final correctCountDisplay = detail?.correctAnswers ?? exam.correctCount;
        final wrongCountDisplay = detail?.incorrectAnswers ?? exam.wrongCount;
        final String candidateName =
            (myUser.name != null && myUser.name!.isNotEmpty)
                ? myUser.name!
                : "শিক্ষার্থী";
        final rankDisplay = detail?.rank != null
            ? "Rank: #${detail!.rank}"
            : "Rank: #";
        final timeDisplay = detail?.timeTaken ?? "০ মিনিট ০ সেকেন্ড";

        return ListView(
          padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 30.h),
          children: [
            // 1. Dark Navy Top Banner Card
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B), // Dark Navy
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.military_tech_rounded,
                        size: 22.sp,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "পরীক্ষার বিস্তারিত ফলাফল",
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    "${(detail != null && detail.examTitle.isNotEmpty) ? detail.examTitle : exam.title} | ২০২৬",
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // Action Buttons: কার্ড & উত্তরপত্র
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          CustomSnackBar.showCustomToast(
                            message: "রেজাল্ট কার্ড ডাউনলোড হচ্ছে...",
                          );
                        },
                        borderRadius: BorderRadius.circular(8.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 7.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.download_rounded,
                                size: 15.sp,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                "কার্ড",
                                style: TextStyle(
                                  fontSize: 12.5.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      InkWell(
                        onTap: () {
                          CustomSnackBar.showCustomToast(
                            message: "উত্তরপত্র প্রস্তুত হচ্ছে...",
                          );
                        },
                        borderRadius: BorderRadius.circular(8.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 7.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.description_outlined,
                                size: 15.sp,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                "উত্তরপত্র",
                                style: TextStyle(
                                  fontSize: 12.5.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // 2. Score Summary Card
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: context.borderColor, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Circular Score Badge
                  Container(
                    width: 86.r,
                    height: 86.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.isDark
                          ? const Color(0xFF1E3A8A).withValues(alpha: 0.3)
                          : const Color(0xFFEFF6FF),
                      border: Border.all(
                        color: context.isDark
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFFDBEAFE),
                        width: 3.5,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            scoreDisplay,
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF2563EB),
                              height: 1,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            totalMarksDisplay,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // Name & Rank
                  Text(
                    candidateName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: context.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    rankDisplay,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: context.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: 14.h),

                  // Metrics List (সঠিক, ভুল, সময়)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: context.borderColor),
                    ),
                    child: Column(
                      children: [
                        // 1. সঠিক
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 9.h,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 16.sp,
                                    color: const Color(0xFF10B981),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    "সঠিক",
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: context.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 9.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: context.isDark
                                      ? const Color(0xFF064E3B)
                                          .withValues(alpha: 0.3)
                                      : const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  "$correctCountDisplay",
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF059669),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(height: 1, color: context.borderColor),

                        // 2. ভুল
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 9.h,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.cancel_outlined,
                                    size: 16.sp,
                                    color: const Color(0xFFEF4444),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    "ভুল",
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: context.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 9.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: context.isDark
                                      ? const Color(0xFF7F1D1D)
                                          .withValues(alpha: 0.3)
                                      : const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  "$wrongCountDisplay",
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFDC2626),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(height: 1, color: context.borderColor),

                        // 3. সময়
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 9.h,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 16.sp,
                                    color: const Color(0xFF10B981),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    "সময়",
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: context.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                timeDisplay,
                                style: TextStyle(
                                  fontSize: 12.5.sp,
                                  fontWeight: FontWeight.bold,
                                  color: context.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 18.h),

            // 3. Detailed Questions List
            if (questions.isEmpty)
              Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: context.borderColor),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.quiz_outlined,
                        size: 36.r,
                        color: context.textMuted,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "প্রশ্ন ও উত্তরের সমাধান শীঘ্রই আপডেট হবে",
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: context.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: questions.length,
                separatorBuilder: (_, __) => SizedBox(height: 14.h),
                itemBuilder: (context, index) {
                  return ResultQuestionCard(item: questions[index]);
                },
              ),
          ],
        );
      }),
    );
  }

  static String _formatNum(num val) {
    if (val.truncateToDouble() == val) {
      return val.toInt().toString();
    }
    return val.toStringAsFixed(1);
  }
}
