import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../components/custom_app_bar.dart';
import '../controllers/profile_history_controller.dart';
import '../widgets/exam_history_card.dart';
import '../widgets/exam_history_pagination.dart';

class ProfileHistoryView extends GetView<ProfileHistoryController> {
  const ProfileHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is registered
    final controller = Get.put(ProfileHistoryController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomAppBar(
        title: 'My Exam History',
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
                  Icons.history_edu_rounded,
                  size: 48.r,
                  color: const Color(0xFF94A3B8),
                ),
                SizedBox(height: 8.h),
                Text(
                  "কোনো পরীক্ষার রেকর্ড পাওয়া যায়নি",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
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
        );
      }),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(
              top: BorderSide(
                color: Color(0xFFE2E8F0),
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
        ),
      ),
    );
  }
}
