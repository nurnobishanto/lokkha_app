import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/shared/widgets/custom_app_bar.dart';
import 'package:lokkha/features/profile/presentation/profile_history/widgets/exam_history_pagination.dart';
import '../riverpod/accuracy_progress_notifier.dart';
import '../widgets/accuracy_exam_card.dart';
import '../widgets/accuracy_stat_card.dart';
import '../widgets/accuracy_trend_chart.dart';

class AccuracyProgressView extends ConsumerWidget {
  const AccuracyProgressView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(accuracyProgressNotifierProvider);
    final notifier = ref.read(accuracyProgressNotifierProvider.notifier);
    final m = state.metrics;

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: const CustomAppBar(
        title: 'গড় নির্ভুলতা ও অগ্রগতি',
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: notifier.refresh,
        color: const Color(0xFF059669),
        child: Builder(
          builder: (context) {
            // Initial loading state
            if (state.isLoading && state.responseData == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF059669)),
                    SizedBox(height: 12.h),
                    Text(
                      "নির্ভুলতা অ্যানালিটিক্স লোড হচ্ছে...",
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: context.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Error state
            if (state.errorMessage != null && state.responseData == null) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 48.sp,
                        color: Colors.redAccent,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        "তথ্য লোড করতে সমস্যা হয়েছে",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        state.errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: context.textSecondary,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton.icon(
                        onPressed: () => notifier.loadAccuracyAnalytics(page: 1),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF059669),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text("আবার চেষ্টা করুন"),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 24.h),
              children: [
                // -------------------------------------------------------------
                // 1. 2x2 Summary Stat Cards
                // -------------------------------------------------------------
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
                          m.avgAccuracyStr,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w900,
                            color: context.textPrimary,
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
                          m.highestAccuracyStr,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w900,
                            color: context.textPrimary,
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
                            color: context.textPrimary,
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
                                text: "${m.totalCorrectAnswers}",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF059669),
                                ),
                              ),
                              TextSpan(
                                text: " / ${m.totalIncorrectAnswers} ভুল",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: context.textSecondary,
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

                // -------------------------------------------------------------
                // 2. Performance Trend Graph (fl_chart)
                // -------------------------------------------------------------
                AccuracyTrendChart(
                  chart: state.chart,
                  avgAccuracy: m.avgAccuracyStr,
                  highestAccuracy: m.highestAccuracyStr,
                ),

                SizedBox(height: 22.h),

                // -------------------------------------------------------------
                // 3. Exam Accuracy Breakdown List
                // -------------------------------------------------------------
                Row(
                  children: [
                    Icon(
                      Icons.format_list_bulleted_rounded,
                      size: 20.sp,
                      color: const Color(0xFF059669),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        "প্রতিটি পরীক্ষার নির্ভুলতা বিবরণী",
                        style: TextStyle(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w800,
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      "হিস্ট্রি ও ফলাফল",
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w600,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                // Pagination Loading Overlay / Indicator
                if (state.isPaginating)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: const Center(
                      child: LinearProgressIndicator(color: Color(0xFF059669)),
                    ),
                  ),

                // Empty state or Exam Cards
                if (state.examList.isEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 36.h),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: context.cardColor,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: context.borderColor, width: 1),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.assignment_late_outlined,
                          size: 40.sp,
                          color: context.textSecondary.withValues(alpha: 0.3),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "কোনো পরীক্ষার রেকর্ড পাওয়া যায়নি",
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: context.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.examList.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final item = state.examList[index];
                      return AccuracyExamCard(
                        item: item,
                        onViewRanking: () => notifier.viewRanking(context, item),
                        onViewResult: () => notifier.viewResult(context, item),
                      );
                    },
                  ),

                // -------------------------------------------------------------
                // 4. Pagination Footer (When multiple pages exist)
                // -------------------------------------------------------------
                if (state.meta.lastPage > 1) ...[
                  SizedBox(height: 20.h),
                  ExamHistoryPagination(
                    currentPage: state.currentPage,
                    totalPages: state.meta.lastPage,
                    totalRecords: state.meta.total,
                    onPageChanged: (newPage) => notifier.changePage(newPage),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
