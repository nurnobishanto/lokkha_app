import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../components/custom_app_bar.dart';
import '../controllers/accuracy_progress_controller.dart';
import '../widgets/accuracy_exam_card.dart';
import '../widgets/accuracy_stat_card.dart';
import '../widgets/accuracy_trend_chart.dart';

class AccuracyProgressView extends GetView<AccuracyProgressController> {
  const AccuracyProgressView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomAppBar(
        title: 'গড় নির্ভুলতা ও অগ্রগতি',
        centerTitle: true,
      ),
      body: Obx(() {
        final m = controller.metrics.value;

        return ListView(
          padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 24.h),
          children: [
            // -----------------------------------------------------------------
            // 1. 2x2 Summary Stat Cards (Matching media_1789642066293.png)
            // -----------------------------------------------------------------
            Row(
              children: [
                // 1. গড় নির্ভুলতা
                Expanded(
                  child: AccuracyStatCard(
                    iconBg: const Color(0xFFF3E8FF),
                    icon: Icon(
                      Icons.adjust_rounded,
                      size: 22.sp,
                      color: const Color(0xFF9333EA), // Purple
                    ),
                    valueWidget: Text(
                      m.avgAccuracy,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    label: "গড় নির্ভুলতা",
                  ),
                ),

                SizedBox(width: 10.w),

                // 2. সর্বোচ্চ নির্ভুলতা
                Expanded(
                  child: AccuracyStatCard(
                    iconBg: const Color(0xFFDBEAFE),
                    icon: Icon(
                      Icons.emoji_events_rounded,
                      size: 22.sp,
                      color: const Color(0xFF2563EB), // Blue
                    ),
                    valueWidget: Text(
                      m.highestAccuracy,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    label: "সর্বোচ্চ নির্ভুলতা",
                  ),
                ),
              ],
            ),

            SizedBox(height: 10.h),

            Row(
              children: [
                // 3. মোট প্রশ্ন উত্তর
                Expanded(
                  child: AccuracyStatCard(
                    iconBg: const Color(0xFFCCFBF1),
                    icon: Icon(
                      Icons.help_outline_rounded,
                      size: 22.sp,
                      color: const Color(0xFF0D9488), // Teal
                    ),
                    valueWidget: Text(
                      "${m.totalQuestionsAnswered}",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    label: "মোট প্রশ্ন উত্তর",
                  ),
                ),

                SizedBox(width: 10.w),

                // 4. সঠিক বনাম ভুল
                Expanded(
                  child: AccuracyStatCard(
                    iconBg: const Color(0xFFFFE4E6),
                    icon: Icon(
                      Icons.done_all_rounded,
                      size: 22.sp,
                      color: const Color(0xFFE11D48), // Rose
                    ),
                    valueWidget: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "${m.correctCount}",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF059669),
                            ),
                          ),
                          TextSpan(
                            text: " / ${m.wrongCount} ভুল",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    label: "সঠিক বনাম ভুল",
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // -----------------------------------------------------------------
            // 2. Performance Trend Graph (নির্ভুলতা ও পারফরম্যান্স ট্রেন্ড গ্রাফ)
            // -----------------------------------------------------------------
            AccuracyTrendChart(
              points: controller.trendPoints,
              avgAccuracy: m.avgAccuracy,
              highestAccuracy: m.highestAccuracy,
            ),

            SizedBox(height: 22.h),

            // -----------------------------------------------------------------
            // 3. Exam Accuracy Breakdown List (প্রতিটি পরীক্ষার নির্ভুলতা বিবরণী)
            // -----------------------------------------------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.format_list_bulleted_rounded,
                      size: 20.sp,
                      color: const Color(0xFF059669),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "প্রতিটি পরীক্ষার নির্ভুলতা বিবরণী",
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                Text(
                  "হিস্ট্রি ও ফলাফল",
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Exam Cards
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.examList.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final item = controller.examList[index];
                return AccuracyExamCard(
                  item: item,
                  onViewRanking: () => controller.viewRanking(item),
                  onViewResult: () => controller.viewResult(item),
                );
              },
            ),
          ],
        );
      }),
    );
  }
}
