import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/features/course/presentation/providers/course_notifier.dart';
import '../widgets/custom_course_card.dart';

class CoursesView extends ConsumerWidget {
  final int? categoryId;
  final String? categoryName;

  const CoursesView({
    super.key,
    this.categoryId,
    this.categoryName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = (categoryName != null && categoryName!.trim().isNotEmpty)
        ? categoryName!
        : 'কোর্সসমূহ';

    final state = ref.watch(coursesNotifierProvider(categoryId));

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final courses = state.model.courses?.data ?? [];
          if (courses.isEmpty) {
            return Center(
              child: Text(
                'কোনো কোর্স পাওয়া যায়নি',
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
                        imageUrl: Endpoints.resolveUrl(course.image),
                        title: course.title ?? '',
                        regularPrice: course.regularPrice?.toString() ?? '0',
                        salePrice: course.salePrice?.toString() ?? '0',
                        rating: '5',
                        onPressed: () {
                          context.pushNamed(
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
          );
        },
      ),
    );
  }
}
