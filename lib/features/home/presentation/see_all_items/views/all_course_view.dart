import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lokkha/features/home/home.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/routes/routes.dart';
import 'package:lokkha/core/network/api_call_status.dart';
import 'package:lokkha/features/course/course.dart';

class AllCourseView extends GetView<SeeAllItemsController> {
  const AllCourseView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SeeAllItemsController>();
    return Scaffold(
      appBar: AppBar(
        title: Text("All Courses"),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.courseApiCallStatus.value == ApiCallStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if ((controller.allCourseModel.value.courses?.data ?? []).isEmpty) {
          return const Center(child: Text("Course not found"));
        }

        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Obx(() {
                  final courses =
                      controller.allCourseModel.value.courses?.data ?? [];
                  if (controller.courseApiCallStatus.value ==
                      ApiCallStatus.loading) {
                    return const CircularProgressIndicator();
                  }

                  return GridView.builder(
                    padding: EdgeInsets.all(8.w),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: courses.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8.w,
                      crossAxisSpacing: 8.w,
                      childAspectRatio:
                          MediaQuery.sizeOf(context).width > 600 ? 1.5 : 1.1,
                    ),
                    itemBuilder: (_, index) {
                      final course = courses[index];
                      return CustomCourseCard(
                        imageUrl:
                            AppConstants.storageUrl + course.image.toString(),
                        title: course.title ?? "",
                        regularPrice: course.regularPrice.toString(),
                        salePrice: course.salePrice.toString(),
                        rating: '5',
                        onPressed: () {
                          // Handle buy button tap
                          Get.toNamed(Routes.COURSE_DETAILS,
                              arguments: {'course_id': course.id});
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
