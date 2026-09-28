import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lokkha/config/theme/theme_extensions.dart';
import '../../../../components/custom_app_bar.dart';
import '../../profile_history/widgets/exam_history_pagination.dart';
import '../controllers/self_exam_history_controller.dart';
import '../widgets/self_exam_card.dart';

class SelfExamHistoryView extends GetView<SelfExamHistoryController> {
  const SelfExamHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: const CustomAppBar(
        title: 'আমার সেলফ টেস্ট',
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.examList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.edit_note_rounded,
                  size: 56.sp,
                  color: context.textMuted,
                ),
                SizedBox(height: 12.h),
                Text(
                  "কোনো সেলফ টেস্ট রেকর্ড পাওয়া যায়নি",
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 20.h),
          itemCount: controller.examList.length,
          separatorBuilder: (context, index) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            final item = controller.examList[index];
            return SelfExamCard(
              item: item,
              onViewResult: () => controller.viewResult(item),
            );
          },
        );
      }),

      // Docked Bottom Pagination with ZERO ghost gap
      bottomNavigationBar: Obx(
        () => Container(
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
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              child: ExamHistoryPagination(
                currentPage: controller.currentPage.value,
                totalPages: controller.totalPages.value,
                totalRecords: controller.totalRecords.value,
                onPageChanged: controller.onPageChanged,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
