import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/theme/theme_extensions.dart';
import 'package:lokkha/shared/widgets/custom_app_bar.dart';
import '../controllers/profile_history_controller.dart';
import '../widgets/exam_history_card.dart';
import '../widgets/exam_history_pagination.dart';

class ProfileHistoryView extends StatelessWidget {
  const ProfileHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<ProfileHistoryController>()
        ? Get.find<ProfileHistoryController>()
        : Get.put(ProfileHistoryController());

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: const CustomAppBar(
        title: 'My Exam History',
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.examList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.examList.isEmpty) {
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
                    onPressed: () => controller.loadExamHistory(
                      page: controller.currentPage.value,
                    ),
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

        if (controller.examList.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.onRefresh,
            child: ListView(
              children: [
                SizedBox(height: 180.h),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history_edu_rounded,
                        size: 48.r,
                        color: context.textMuted,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "কোনো পরীক্ষার রেকর্ড পাওয়া যায়নি",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: context.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.onRefresh,
          child: Stack(
            children: [
              ListView.separated(
                padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
                itemCount: controller.examList.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final item = controller.examList[index];
                  return ExamHistoryCard(
                    item: item,
                    onRankTap: () => controller.viewRank(item),
                    onResultSheetTap: () => controller.viewResultSheet(item),
                  );
                },
              ),
              if (controller.isLoading.value)
                Positioned(
                  top: 8.h,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 14.r,
                            height: 14.r,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: context.primaryColor,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            "লোড হচ্ছে...",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: context.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(
        () {
          if (controller.examList.isEmpty &&
              controller.totalRecords.value == 0) {
            return const SizedBox.shrink();
          }

          return Container(
            decoration: BoxDecoration(
              color: context.cardColor,
              border: Border(
                top: BorderSide(
                  color: context.borderColor,
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                child: ExamHistoryPagination(
                  currentPage: controller.currentPage.value,
                  totalPages: controller.totalPages.value,
                  totalRecords: controller.totalRecords.value,
                  onPageChanged: controller.onPageChanged,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
