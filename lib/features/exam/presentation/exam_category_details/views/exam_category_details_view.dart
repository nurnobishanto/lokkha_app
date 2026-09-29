import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/theme/light_theme_colors.dart';
import 'package:lokkha/core/theme/theme_extensions.dart';
import 'package:lokkha/core/network/api_call_status.dart';
import '../../exam_category/widgets/exam_category_card.dart';
import '../controllers/exam_category_details_controller.dart';
import '../widgets/exam_card.dart';
import '../widgets/exam_details_dialog.dart';

class ExamCategoryDetailsView extends GetView<ExamCategoryDetailsController> {
  const ExamCategoryDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    // read the argument once into a local variable
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final categoryName = args['category_name'] as String? ?? '';
    final controller = Get.put(ExamCategoryDetailsController());
    print("addd:$categoryName");
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(
          categoryName,
          style: TextStyle(fontSize: 16.0.sp),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.apiCallStatus.value == ApiCallStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if ((controller.examCategoriesModel.value.examCategories?.isEmpty ??
                  true) &&
              (controller.model.value.freeExams?.data?.isEmpty ?? true)) {
            return const Center(child: Text("Data not found"));
          }

          final categories =
              controller.examCategoriesModel.value.examCategories ?? [];
          final exams = controller.model.value.freeExams?.data ?? [];

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(height: 6.h),
              ),
              // categories grid
              if (categories.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.all(8),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final category = categories[index];
                        return ExamCategoryCard(
                          title: category.name ?? "",
                          onTap: () {
                            controller
                                .fetchExamCategoryDetails(category.id!.toInt());
                            controller.fetchExamCategoriesWithParentID(
                                category.id!.toInt());
                          },
                        );
                      },
                      childCount: categories.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 5,
                      crossAxisSpacing: 5,
                      childAspectRatio: 2.5,
                    ),
                  ),
                ),

              // exams list
              if (exams.isNotEmpty)
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
                          showDialog(
                            context: context,
                            builder: (context) => ExamDetailsDialog(exam: exam),
                          );
                        },
                      );
                    },
                  ),
                ),

              //bottom padding so last item isn’t under the bar
              const SliverToBoxAdapter(
                child: SizedBox(height: kBottomNavigationBarHeight),
              ),
            ],
          );
        }),
      ),
      bottomNavigationBar: Obx(() {
        if (controller.totalPages.value <= 1) return const SizedBox.shrink();
        return SafeArea(
          child: Container(
            color: context.cardColor,
            padding: const EdgeInsets.only(bottom: 20, left: 25),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // First Page
                  IconButton(
                    icon: Icon(Icons.first_page, color: context.textPrimary),
                    onPressed: controller.currentPage.value > 1
                        ? controller.firstPage
                        : null,
                  ),

                  // Previous
                  IconButton(
                    icon: Icon(Icons.navigate_before, color: context.textPrimary),
                    onPressed: controller.currentPage.value > 1
                        ? controller.previousPage
                        : null,
                  ),

                  // Page Numbers
                  ...List.generate(
                          controller.totalPages.value, (index) => index + 1)
                      .where((page) {
                    int current = controller.currentPage.value;
                    return (page >= current - 2 && page <= current + 2) ||
                        page == 1 ||
                        page == controller.totalPages.value;
                  }).map((page) {
                    bool isActive = page == controller.currentPage.value;
                    return InkWell(
                      onTap: () => controller.goToPage(page),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 10),
                        decoration: BoxDecoration(
                          color: isActive
                              ? LightThemeColors.primaryColor
                              : (context.isDark ? context.surfaceColor : Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: isActive ? LightThemeColors.primaryColor : context.borderColor),
                        ),
                        child: Text(
                          page.toString(),
                          style: TextStyle(
                            color: isActive ? Colors.white : context.textPrimary,
                          ),
                        ),
                      ),
                    );
                  }),

                  // Next
                  IconButton(
                    icon: Icon(Icons.navigate_next, color: context.textPrimary),
                    onPressed: controller.currentPage.value <
                            controller.totalPages.value
                        ? controller.nextPage
                        : null,
                  ),

                  // Last
                  IconButton(
                    icon: Icon(Icons.last_page, color: context.textPrimary),
                    onPressed: controller.currentPage.value <
                            controller.totalPages.value
                        ? controller.lastPage
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
