import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lokkha/app/router/router.dart';
import 'package:lokkha/core/network/endpoints.dart';
import 'package:lokkha/features/course/course.dart';
import 'package:lokkha/features/home/presentation/see_all_items/providers/see_all_items_notifier.dart';

class AllCourseView extends ConsumerWidget {
  const AllCourseView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(seeAllItemsNotifierProvider);

    if (state.isCourseLoading &&
        (state.allCourseModel.courses?.data ?? []).isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("All Courses"),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final courses = state.allCourseModel.courses?.data ?? [];
    if (courses.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("All Courses"),
          centerTitle: true,
        ),
        body: const Center(child: Text("Course not found")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Courses"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: courses.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      MediaQuery.sizeOf(context).width > 600 ? 3 : 2,
                  mainAxisSpacing: 10.h,
                  crossAxisSpacing: 10.w,
                  childAspectRatio:
                      MediaQuery.sizeOf(context).width > 600 ? 0.95 : 0.80,
                ),
                itemBuilder: (_, index) {
                  final course = courses[index];
                  return CustomCourseCard(
                    imageUrl:
                        Endpoints.storageUrl + course.image.toString(),
                    title: course.title ?? "",
                    regularPrice: course.regularPrice.toString(),
                    salePrice: course.salePrice.toString(),
                    rating: '5',
                    onPressed: () {
                      context.push(
                        Routes.courseDetails,
                        extra: {'course_id': course.id},
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
