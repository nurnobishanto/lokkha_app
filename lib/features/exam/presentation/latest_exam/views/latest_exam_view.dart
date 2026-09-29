import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lokkha/shared/widgets/custom_app_bar.dart';
import 'package:lokkha/core/services/storage/my_shared_pref.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/exam/presentation/latest_exam/views/latest_exam_start_view.dart';
import 'package:lokkha/core/theme/text_style.dart';
import 'package:lokkha/core/theme/light_theme_colors.dart';
import 'package:lokkha/shared/widgets/login_required_dialog.dart';
import '../controllers/latest_exam_controller.dart';

class LatestExamView extends GetView<LatestExamController> {
  const LatestExamView({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LatestExamController());
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: const CustomAppBar(title: 'সর্বশেষ নিয়োগ পরীক্ষা'),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.separated(
                itemCount: controller.model.value.latestExams!.data!.length + 1,
                itemBuilder: (c, index) {
                  if (index ==
                      controller.model.value.latestExams!.data!.length) {
                    return (controller.model.value.latestExams!.lastPage! >
                            controller.currentPage.value)
                        ? Column(
                            children: [
                              const SizedBox(height: 5.0),
                              GestureDetector(
                                onTap: () {
                                  controller.fetchLatestExam(
                                      page: controller.currentPage.value + 1);
                                },
                                child: Container(
                                  height: 30,
                                  width: Get.width / 2,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15.0),
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
                  final data = controller.model.value.latestExams?.data![index];
                  return LatestExamCard(
                    title: data?.title ?? '',
                    date: data!.date,
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
        }
      }),
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
