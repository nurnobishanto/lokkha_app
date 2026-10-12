import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lokkha/app/router/router.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/core/enums/api_call_status.dart';
import 'package:lokkha/features/exam/presentation/providers/exam_notifier.dart';
import '../../exam_category/widgets/exam_category_card.dart';
import '../widgets/exam_card.dart';
import '../widgets/exam_details_dialog.dart';

class ExamCategoryDetailsView extends ConsumerStatefulWidget {
  final int? categoryId;
  final String? categoryName;

  const ExamCategoryDetailsView({
    super.key,
    this.categoryId,
    this.categoryName,
  });

  @override
  ConsumerState<ExamCategoryDetailsView> createState() =>
      _ExamCategoryDetailsViewState();
}

class _ExamCategoryDetailsViewState
    extends ConsumerState<ExamCategoryDetailsView> {
  int _categoryId = 0;
  String _categoryName = '';
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      if (widget.categoryId != null && widget.categoryId! > 0) {
        _categoryId = widget.categoryId!;
        _categoryName = widget.categoryName ?? '';
      } else {
        final extra = GoRouterState.of(context).extra;
        if (extra is Map) {
          _categoryId = extra['category_id'] as int? ??
              int.tryParse(extra['category_id']?.toString() ?? '') ??
              0;
          _categoryName = extra['category_name'] as String? ?? '';
        }
      }
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_categoryId <= 0) {
      return Scaffold(
        appBar: AppBar(title: const Text('পরীক্ষা')),
        body: const Center(child: Text("ক্যাটাগরি পাওয়া যায়নি")),
      );
    }

    final state = ref.watch(examCategoryDetailsNotifierProvider(_categoryId));
    final notifier =
        ref.read(examCategoryDetailsNotifierProvider(_categoryId).notifier);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(
          _categoryName,
          style: TextStyle(fontSize: 16.0.sp),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (state.apiCallStatus == ApiCallStatus.loading &&
                state.examCategoryDetailsModel == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final categories =
                state.categoriesWithParentID?.examCategories ?? [];
            final exams =
                state.examCategoryDetailsModel?.freeExams?.data ?? [];

            if (categories.isEmpty && exams.isEmpty) {
              return const Center(child: Text("Data not found"));
            }

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
                              context.push(
                                Routes.examCategoryDetails,
                                extra: {
                                  "category_id": category.id,
                                  "category_name": category.name,
                                },
                              );
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
                              builder: (context) =>
                                  ExamDetailsDialog(exam: exam),
                            );
                          },
                        );
                      },
                    ),
                  ),

                // bottom padding so last item isn't under the bar
                const SliverToBoxAdapter(
                  child: SizedBox(height: kBottomNavigationBarHeight),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: state.totalPages <= 1
          ? null
          : SafeArea(
              child: Container(
                color: context.cardColor,
                padding: const EdgeInsets.only(bottom: 20, left: 25),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // First Page
                      IconButton(
                        icon: Icon(Icons.first_page,
                            color: context.textPrimary),
                        onPressed:
                            state.currentPage > 1 ? notifier.firstPage : null,
                      ),

                      // Previous
                      IconButton(
                        icon: Icon(Icons.navigate_before,
                            color: context.textPrimary),
                        onPressed: state.currentPage > 1
                            ? notifier.previousPage
                            : null,
                      ),

                      // Page Numbers
                      ...List.generate(state.totalPages, (index) => index + 1)
                          .where((page) {
                        int current = state.currentPage;
                        return (page >= current - 2 && page <= current + 2) ||
                            page == 1 ||
                            page == state.totalPages;
                      }).map((page) {
                        bool isActive = page == state.currentPage;
                        return InkWell(
                          onTap: () => notifier.goToPage(page),
                          child: Container(
                            margin:
                                const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 10),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? LightThemeColors.primaryColor
                                  : (context.isDark
                                      ? context.surfaceColor
                                      : Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: isActive
                                      ? LightThemeColors.primaryColor
                                      : context.borderColor),
                            ),
                            child: Text(
                              page.toString(),
                              style: TextStyle(
                                color: isActive
                                    ? Colors.white
                                    : context.textPrimary,
                              ),
                            ),
                          ),
                        );
                      }),

                      // Next
                      IconButton(
                        icon: Icon(Icons.navigate_next,
                            color: context.textPrimary),
                        onPressed: state.currentPage < state.totalPages
                            ? notifier.nextPage
                            : null,
                      ),

                      // Last
                      IconButton(
                        icon: Icon(Icons.last_page,
                            color: context.textPrimary),
                        onPressed: state.currentPage < state.totalPages
                            ? notifier.lastPage
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
