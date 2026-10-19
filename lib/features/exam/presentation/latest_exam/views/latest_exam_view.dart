import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/exam/presentation/latest_exam/views/latest_exam_start_view.dart';
import 'package:lokkha/features/exam/presentation/providers/exam_notifier.dart';
import 'package:lokkha/shared/widgets/login_required_dialog.dart';

class LatestExamView extends ConsumerWidget {
  const LatestExamView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(latestExamNotifierProvider);
    final examsList = state.model?.latestExams?.data ?? [];
    final lastPage = state.model?.latestExams?.lastPage ?? 1;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: const CustomAppBar(title: 'সর্বশেষ নিয়োগ পরীক্ষা'),
      body: Builder(
        builder: (context) {
          if (state.isLoading && state.model == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.separated(
                itemCount: examsList.length + 1,
                itemBuilder: (c, index) {
                  if (index == examsList.length) {
                    return (lastPage > state.currentPage)
                        ? Column(
                            children: [
                              const SizedBox(height: 5.0),
                              GestureDetector(
                                onTap: () {
                                  ref
                                      .read(latestExamNotifierProvider.notifier)
                                      .fetchLatestExam(
                                          page: state.currentPage + 1);
                                },
                                child: Container(
                                  height: 30,
                                  width:
                                      MediaQuery.sizeOf(context).width / 2,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(15.0),
                                    border: Border.all(
                                      color: LightThemeColors.primaryColor,
                                      width: 1,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'আরও দেখুন',
                                      style: TextStyle(
                                        color: LightThemeColors.primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink();
                  }

                  final data = examsList[index];
                  return LatestExamCard(
                    title: data.title,
                    date: data.date,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) {
                          if (isLoggedIn.value &&
                              MySharedPref.getUserToken().isNotEmpty) {
                            return LatestExamStartDialog(latestExam: data);
                          } else {
                            return LoginRequiredDialog(
                              title: 'লগইন প্রয়োজন',
                              message:
                                  'সর্বশেষ পরীক্ষা অ্যাক্সেস করতে লগইন করুন।',
                              cancelText: 'বাতিল',
                              signInText: 'সাইন-ইন',
                            );
                          }
                        },
                      );
                    },
                  );
                },
                separatorBuilder: (x, index) => 8.h.height,
              ),
            ),
          );
        },
      ),
    );
  }
}

class LatestExamCard extends StatelessWidget {
  final String title;
  final DateTime date;
  final void Function()? onTap;

  const LatestExamCard({
    super.key,
    required this.title,
    required this.onTap,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: constraints.maxWidth,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: context.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ---- TITLE ----
                Text(
                  title,
                  style: AppTextStyles.heading5.copyWith(
                    fontSize: 14.sp,
                    color: context.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 6.h),

                /// ---- DATE + TYPE ROW ----
                Row(
                  children: [
                    _buildTag(context, DateFormatter.formatToDMY(date)),
                    SizedBox(width: 6.w),
                    _buildTag(context, "MCQ"),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Small reusable chip widget
  Widget _buildTag(BuildContext context, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: context.isDark ? const Color(0xFF1E293B) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: context.borderColor),
      ),
      child: Text(
        text,
        style: AppTextStyles.body1.copyWith(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: context.textSecondary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
