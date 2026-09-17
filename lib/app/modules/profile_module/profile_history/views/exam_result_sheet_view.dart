import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../components/custom_app_bar.dart';
import '../../../../components/custom_snackbar.dart';
import '../models/exam_history_model.dart';
import '../models/exam_question_result_model.dart';
import '../widgets/result_question_card.dart';

class ExamResultSheetView extends StatelessWidget {
  final ExamHistoryModel exam;

  const ExamResultSheetView({
    super.key,
    required this.exam,
  });

  @override
  Widget build(BuildContext context) {
    // Sample questions matching the screenshots
    final List<ExamQuestionResultModel> questionList = [
      const ExamQuestionResultModel(
        questionNumber: 1,
        questionText: "গণতন্ত্রের প্রাণ হলো-",
        options: [
          "সরকার",
          "রাষ্ট্র",
          "সংবিধান",
          "নির্বাচন",
        ],
        correctOptionIndex: 3,
        userSelectedOptionIndex: null,
      ),
      const ExamQuestionResultModel(
        questionNumber: 4,
        questionText: "গণতন্ত্রের সর্বাপেক্ষা গুরুত্বপূর্ণ উপাদান কোনটি?",
        options: [
          "নির্বাচন",
          "সরকারের জবাবদিহিতা",
          "বহুদলীয় ব্যবস্থা",
          "আইনের শাসন",
        ],
        correctOptionIndex: 0,
        userSelectedOptionIndex: null,
      ),
      const ExamQuestionResultModel(
        questionNumber: 5,
        questionText: "স্থানীয় সরকার নয় কোনটি?",
        options: [
          "জেলা পরিষদ",
          "উপজেলা প্রশাসন",
          "ইউনিয়ন পরিষদ",
          "সিটি কর্পোরেশন",
        ],
        correctOptionIndex: 1,
        userSelectedOptionIndex: null,
        explanation:
            "দেশে স্থানীয় সরকার ব্যবস্থা গ্রামভিত্তিক ও শহরভিত্তিক এ দুইভাগে বিভক্ত। গ্রামভিত্তিক তিনস্তর (ইউনিয়ন পরিষদ, উপজেলা পরিষদ ও জেলা পরিষদ) এবং শহরভিত্তিক দুই স্তর (পৌরসভা ও সিটি কর্পোরেশন)।",
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomAppBar(
        title: 'ফলাফল ও সমাধান',
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 30.h),
        children: [
          // 1. Dark Navy Top Banner Card (Matching Screenshot)
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
                  "${exam.title} | ২০২৬",
                  textAlign: TextAlign.center,
                  maxLines: 1,
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

          // 2. Score Summary Card (Matching Screenshot)
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
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
                    color: const Color(0xFFEFF6FF),
                    border: Border.all(
                      color: const Color(0xFFDBEAFE),
                      width: 3.5,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          exam.obtainedMark,
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF2563EB),
                            height: 1,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          "0",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10.h),

                // Name & Rank
                Text(
                  "sadman",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  "Rank: #",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: 14.h),

                // Metrics List (সঠিক, ভুল, সময়)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
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
                                    color: const Color(0xFF334155),
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
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                "${exam.correctCount}",
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
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),

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
                                    color: const Color(0xFF334155),
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
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                "${exam.wrongCount}",
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
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),

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
                                    color: const Color(0xFF334155),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              "০ মিনিট ০ সেকেন্ড",
                              style: TextStyle(
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
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
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: questionList.length,
            separatorBuilder: (_, __) => SizedBox(height: 14.h),
            itemBuilder: (context, index) {
              return ResultQuestionCard(item: questionList[index]);
            },
          ),
        ],
      ),
    );
  }
}
