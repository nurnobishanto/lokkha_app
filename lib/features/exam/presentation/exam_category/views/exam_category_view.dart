import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:lokkha/core/network/api_call_status.dart';
import 'package:lokkha/core/core.dart';

import 'package:lokkha/routes/routes.dart';
import 'package:lokkha/features/home/home.dart';
import '../controllers/exam_category_controller.dart';
import '../widgets/exam_category_card.dart';

class ExamCategoryView extends GetView<ExamCategoryController> {
  const ExamCategoryView({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ExamCategoryController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('পরীক্ষার ক্যাটাগরি'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.apiCallStatus.value == ApiCallStatus.loading ||
            controller.apiCallCourseCategoriesStatus.value ==
                ApiCallStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.model.value.examCategories!.isEmpty &&
            controller.courseCategoriesModel.value.courseCategories!.isEmpty) {
          return const Center(child: Text("Data not found"));
        }

        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                /// Premium Courses/Exams
                5.h.height,
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0.w),
                  child: SectionTitleWithSeeAll(
                      title: "প্রিমিয়াম পরীক্ষা সমূহ",
                      onSeeAllPressed: () {
                        Get.toNamed(Routes.ALL_COURSES);
                      }),
                ),

                Obx(() {
                  final courses =
                      controller.courseCategoriesModel.value.courseCategories ??
                          [];
                  if (controller.apiCallCourseCategoriesStatus.value ==
                      ApiCallStatus.loading) {
                    return const CircularProgressIndicator();
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(8),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: courses.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8.00,
                      crossAxisSpacing: 8.00,
                      childAspectRatio: 3.0,
                    ),
                    itemBuilder: (_, x) {
                      final course = courses[x];
                      //courses.forEach((data)=> print(data.id));

                      return ExamCategoryCard(
                        title: course.title ?? "",
                        onTap: () {
                          Get.toNamed(
                            Routes.COURSES,
                            arguments: {
                              "course_category_id": course.id,
                              'category_name': course.title,
                            },
                          );
                        },
                      );
                    },
                  );
                }),

                /// Free Courses/Exams
                5.h.height,

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0.w),
                  child: SectionTitleWithSeeAll(
                      title: "ফ্রি পরীক্ষা সমূহ",
                      onSeeAllPressed: () {
                        Get.toNamed(Routes.ALL_EXAM);
                      }),
                ),
                Obx(() {
                  final exams = controller.model.value.examCategories ?? [];
                  if (controller.apiCallStatus.value == ApiCallStatus.loading) {
                    return const CircularProgressIndicator();
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(8),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: exams.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8.00,
                      crossAxisSpacing: 8.00,
                      childAspectRatio: 3.0,
                    ),
                    itemBuilder: (_, x) {
                      final exam = exams[x];
                      return ExamCategoryCard(
                        title: exam.name ?? "",
                        onTap: () {
                          if (exam.id != null) {
                            Get.toNamed(Routes.EXAM_CATEGORY_DETAILS,
                                arguments: {
                                  "category_id": exam.id,
                                  "category_name": exam.name
                                });
                          }
                        },
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        );
      }),
    );
  }
}
