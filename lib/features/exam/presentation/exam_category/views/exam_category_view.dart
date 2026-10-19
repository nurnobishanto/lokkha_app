import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/router/router.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/exam/presentation/providers/exam_notifier.dart';
import 'package:lokkha/features/home/home.dart';
import '../widgets/exam_category_card.dart';

class ExamCategoryView extends ConsumerWidget {
  const ExamCategoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(examCategoriesNotifierProvider);

    if (state.isExamLoading || state.isCourseLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('পরীক্ষার ক্যাটাগরি'),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final courses = state.courseCategoriesModel?.courseCategories ?? [];
    final exams = state.examCategoriesModel?.examCategories ?? [];

    if (exams.isEmpty && courses.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('পরীক্ষার ক্যাটাগরি'),
          centerTitle: true,
        ),
        body: const Center(child: Text("Data not found")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('পরীক্ষার ক্যাটাগরি'),
        centerTitle: true,
      ),
      body: SafeArea(
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
                    context.push(Routes.allCourses);
                  },
                ),
              ),

              if (courses.isNotEmpty)
                GridView.builder(
                  padding: const EdgeInsets.all(8),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: courses.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8.00,
                    crossAxisSpacing: 8.00,
                    childAspectRatio: 3.0,
                  ),
                  itemBuilder: (_, x) {
                    final course = courses[x];
                    return ExamCategoryCard(
                      title: course.title ?? "",
                      slug: course.slug,
                      imageUrl: course.image,
                      onTap: () {
                        context.push(
                          Routes.courses,
                          extra: {
                            "course_category_id": course.id,
                            'category_name': course.title,
                          },
                        );
                      },
                    );
                  },
                ),

              /// Free Courses/Exams
              5.h.height,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0.w),
                child: SectionTitleWithSeeAll(
                  title: "ফ্রি পরীক্ষা সমূহ",
                  onSeeAllPressed: () {
                    context.push(Routes.allExam);
                  },
                ),
              ),

              if (exams.isNotEmpty)
                GridView.builder(
                  padding: const EdgeInsets.all(8),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: exams.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8.00,
                    crossAxisSpacing: 8.00,
                    childAspectRatio: 3.0,
                  ),
                  itemBuilder: (_, x) {
                    final exam = exams[x];
                    return ExamCategoryCard(
                      title: exam.name ?? "",
                      slug: exam.slug,
                      imageUrl: exam.image,
                      onTap: () {
                        if (exam.id != null) {
                          context.push(
                            Routes.examCategoryDetails,
                            extra: {
                              "category_id": exam.id,
                              "category_name": exam.name,
                            },
                          );
                        }
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
