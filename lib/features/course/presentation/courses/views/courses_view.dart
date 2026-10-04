import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/routes/routes.dart';
import '../controllers/courses_controller.dart';
import '../widgets/custom_course_card.dart';

class CoursesView extends GetView<CoursesController> {
  const CoursesView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    String categoryName = "";
    if (args is Map && args["category_name"] != null) {
      categoryName = args["category_name"].toString();
    } else if (Get.parameters["category_name"] != null) {
      categoryName = Get.parameters["category_name"]!;
    }
    if (categoryName.trim().isEmpty) {
      categoryName = "কোর্সসমূহ";
    }

    final controller = Get.isRegistered<CoursesController>()
        ? Get.find<CoursesController>()
        : Get.put(CoursesController());

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.apiCallCoursesStatus.value == ApiCallStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        final courses = controller.coursesModel.value.courses?.data ?? [];
        if (courses.isEmpty) {
          return Center(
            child: Text(
              "কোনো কোর্স পাওয়া যায়নি",
              style: TextStyle(
                fontSize: 14.sp,
                color: context.textMuted,
              ),
            ),
          );
        }

        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                GridView.builder(
                  padding: EdgeInsets.all(8.w),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: courses.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8.w,
                    crossAxisSpacing: 8.w,
                    childAspectRatio:
                        MediaQuery.sizeOf(context).width > 600 ? 1.5 : 1.0,
                  ),
                  itemBuilder: (_, index) {
                    final course = courses[index];
                    return CustomCourseCard(
                      imageUrl: AppConstants.resolveUrl(course.image),
                      title: course.title ?? "",
                      regularPrice: course.regularPrice?.toString() ?? "0",
                      salePrice: course.salePrice?.toString() ?? "0",
                      rating: '5',
                      onPressed: () {
                        Get.toNamed(
                          Routes.COURSE_DETAILS,
                          arguments: {'course_id': course.id},
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
