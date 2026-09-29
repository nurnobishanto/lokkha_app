import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/home/home.dart';
import 'package:lokkha/core/network/api_call_status.dart';
import 'package:lokkha/features/exam/exam.dart';
import '../controllers/see_all_items_controller.dart';

class AllExamView extends GetView<SeeAllItemsController> {
  const AllExamView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SeeAllItemsController>();

    return Scaffold(
      appBar: AppBar(
        title: Text("All Free Exams", style: TextStyle(fontSize: 16.0.sp)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(() {
          final status = controller.examApiCallStatus.value;
          final exams = controller.allExamModel.value.exams?.data ?? [];

          if (status == ApiCallStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (exams.isEmpty) {
            return const Center(child: Text("Data not found"));
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: 6.h)),

              ///  SECTION — Removed Expanded
              SliverToBoxAdapter(
                child: Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RadioMenuButton<String>(
                        value: 'attempted',
                        groupValue: controller.selectedFilter?.value,
                        onChanged: (String? v) {
                          if (isLoggedIn.value) {
                            controller.selectedFilter?.value = v!;
                            controller.fetchAllExams();
                          } else {
                            showLoginPopup(context);
                          }
                        },
                        child: const Text("পরীক্ষা দেওয়া হয়েছে"),
                      ),
                      RadioMenuButton<String>(
                        value: "not_attempted",
                        groupValue: controller.selectedFilter?.value,
                        onChanged: (String? v) {
                          if (isLoggedIn.value) {
                            controller.selectedFilter?.value = v!;
                            controller.fetchAllExams();
                          } else {
                            showLoginPopup(context);
                          }
                        },
                        child: const Text("পরীক্ষা দেওয়া হয়নি"),
                      ),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                sliver: SliverList.separated(
                  itemCount: exams.length,
                  separatorBuilder: (_, __) => SizedBox(height: 5.h),
                  itemBuilder: (context, index) {
                    final exam = exams[index];

                    return ExamCard(
                      exam: exam,
                      onTap: () {
                        if (isLoggedIn.value) {
                          showDialog(
                            context: context,
                            builder: (context) => ExamDetailsDialog(exam: exam),
                          );
                        } else {
                          showLoginPopup(context);
                        }
                      },
                    );
                  },
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: kBottomNavigationBarHeight),
              ),
            ],
          );
        }),
      ),

      /// Pagination Bottom Bar
      bottomNavigationBar: Obx(() {
        if (controller.totalExamPages.value <= 1) {
          return const SizedBox.shrink();
        }

        return SafeArea(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 20, left: 25),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.first_page),
                    onPressed: controller.currentExamPage.value > 1
                        ? controller.firstExamPage
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.navigate_before),
                    onPressed: controller.currentExamPage.value > 1
                        ? controller.previousExamPage
                        : null,
                  ),
                  ...List.generate(
                    controller.totalExamPages.value,
                    (index) => index + 1,
                  ).where((page) {
                    int current = controller.currentExamPage.value;
                    return (page >= current - 2 && page <= current + 2) ||
                        page == 1 ||
                        page == controller.totalExamPages.value;
                  }).map((page) {
                    bool isActive = page == controller.currentExamPage.value;
                    return InkWell(
                      onTap: () => controller.goToExamPage(page),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 10),
                        decoration: BoxDecoration(
                          color: isActive
                              ? LightThemeColors.primaryColor
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: LightThemeColors.primaryColor),
                        ),
                        child: Text(
                          page.toString(),
                          style: TextStyle(
                            color: isActive ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  }),
                  IconButton(
                    icon: const Icon(Icons.navigate_next),
                    onPressed: controller.currentExamPage.value <
                            controller.totalExamPages.value
                        ? controller.nextExamPage
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.last_page),
                    onPressed: controller.currentExamPage.value <
                            controller.totalExamPages.value
                        ? controller.lastExamPage
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
