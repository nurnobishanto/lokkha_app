import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../components/custom_app_bar.dart';
import '../controllers/contest_history_controller.dart';
import '../widgets/contest_history_card.dart';
import '../widgets/saved_question_card.dart';

class ContestHistoryView extends GetView<ContestHistoryController> {
  const ContestHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomAppBar(
        title: 'আমার কনটেস্ট ও সেভড প্রশ্ন',
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 24.h),
        children: [
          // -------------------------------------------------------------------
          // 1. SECTION 1: লাইভ কনটেস্ট হিস্ট্রি
          // -------------------------------------------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.emoji_events_rounded,
                    size: 20.sp,
                    color: const Color(0xFFD97706), // Gold
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    "লাইভ কনটেস্ট হিস্ট্রি",
                    style: TextStyle(
                      fontSize: 15.5.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),

              // চলমান কনটেস্ট Button
              InkWell(
                onTap: controller.openLiveContests,
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: const Color(0xFFD97706),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    "চলমান কনটেস্ট",
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFB45309),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Contest Cards List
          Obx(() {
            if (controller.contestList.isEmpty) {
              return Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Center(
                  child: Text(
                    "কোনো কনটেস্ট হিস্ট্রি পাওয়া যায়নি",
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.contestList.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final item = controller.contestList[index];
                return ContestHistoryCard(
                  item: item,
                  onViewRanking: () => controller.viewRanking(item),
                  onViewResult: () => controller.viewResult(item),
                );
              },
            );
          }),

          SizedBox(height: 22.h),

          // -------------------------------------------------------------------
          // 2. SECTION 2: সংরক্ষিত প্রশ্নসমূহ
          // -------------------------------------------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.bookmark_rounded,
                    size: 20.sp,
                    color: const Color(0xFF059669), // Emerald Green
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    "সংরক্ষিত প্রশ্নসমূহ",
                    style: TextStyle(
                      fontSize: 15.5.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),

              Obx(
                () => Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    "${controller.savedQuestionList.length} টি",
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF059669),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Saved Questions List
          Obx(() {
            if (controller.savedQuestionList.isEmpty) {
              return Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Center(
                  child: Text(
                    "কোনো সংরক্ষিত প্রশ্ন পাওয়া যায়নি",
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.savedQuestionList.length,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (context, index) {
                final item = controller.savedQuestionList[index];
                return SavedQuestionCard(
                  item: item,
                  onTap: () => controller.viewSavedQuestion(item),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
