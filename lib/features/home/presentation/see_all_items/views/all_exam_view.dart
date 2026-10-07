import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/exam/exam.dart';
import 'package:lokkha/features/home/home.dart';
import 'package:lokkha/shared/models/exam.dart';

class AllExamView extends GetView<SeeAllItemsController> {
  const AllExamView({super.key});

  void _handleExamTap(BuildContext context, Exam exam) {
    if (isLoggedIn.value) {
      showDialog(
        context: context,
        builder: (context) => ExamDetailsDialog(exam: exam),
      );
    } else {
      showLoginPopup(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SeeAllItemsController>();

    return Scaffold(
      backgroundColor: AppColors.scaffold(context),
      appBar: AppBar(
        title: Text(
          "All Free Exams",
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: context.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18.sp,
            color: Colors.white,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 8.h),

            // Modern Segmented Filter Bar
            _buildModernFilterBar(context, controller),

            SizedBox(height: 8.h),

            // Exam List
            Expanded(
              child: Obx(() {
                final status = controller.examApiCallStatus.value;
                final exams = controller.examsList.isNotEmpty
                    ? controller.examsList
                    : (controller.allExamModel.value.exams?.data ?? []);

                if (status == ApiCallStatus.loading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: context.primaryColor,
                    ),
                  );
                }

                if (status == ApiCallStatus.error) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(14.r),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.error_outline_rounded,
                              size: 36.sp,
                              color: Colors.redAccent,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            "পরীক্ষা লোড করতে সমস্যা হয়েছে",
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: context.textPrimary,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            "ইন্টারনেট সংযোগ চেক করে পুনরায় চেষ্টা করুন",
                            style: TextStyle(
                              fontSize: 12.5.sp,
                              color: context.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16.h),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.primaryColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 18.w,
                                vertical: 9.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: const Text("পুনরায় চেষ্টা করুন"),
                            onPressed: () => controller.fetchAllExams(
                              page: controller.currentExamPage.value,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (exams.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(18.r),
                            decoration: BoxDecoration(
                              color: context.surfaceSubtle,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.assignment_outlined,
                              size: 42.sp,
                              color:
                                  context.textSecondary.withValues(alpha: 0.6),
                            ),
                          ),
                          SizedBox(height: 14.h),
                          Text(
                            controller.selectedFilter.value == 'attempted'
                                ? "আপনি এখনো কোনো পরীক্ষা দেননি"
                                : "কোনো পরীক্ষা পাওয়া যায়নি",
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: context.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            controller.selectedFilter.value == 'attempted'
                                ? "পরীক্ষায় অংশ নিয়ে আপনার মেধা যাচাই করুন"
                                : "নতুন পরীক্ষা যুক্ত হলে এখানে দেখতে পাবেন",
                            style: TextStyle(
                              fontSize: 12.5.sp,
                              color: context.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (controller.selectedFilter.value != 'all') ...[
                            SizedBox(height: 14.h),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: context.primaryColor),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                              onPressed: () => controller.setFilter('all'),
                              child: Text(
                                "সব পরীক্ষা দেখুন",
                                style: TextStyle(
                                  color: context.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: context.primaryColor,
                  backgroundColor: context.cardColor,
                  onRefresh: () async {
                    await controller.fetchAllExams(
                      page: controller.currentExamPage.value,
                    );
                  },
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 4.h,
                    ),
                    itemCount: exams.length,
                    separatorBuilder: (_, __) => SizedBox(height: 8.h),
                    itemBuilder: (context, index) {
                      final exam = exams[index];
                      return _buildCompactExamCard(
                        context: context,
                        exam: exam,
                        onTap: () => _handleExamTap(context, exam),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),

      // Theme-Adaptive Bottom Pagination Bar
      bottomNavigationBar: Obx(() {
        final totalPages = controller.totalExamPages.value;
        final currentPage = controller.currentExamPage.value;

        if (totalPages <= 1) {
          return const SizedBox.shrink();
        }

        return Container(
          decoration: BoxDecoration(
            color: context.cardColor,
            border: Border(
              top: BorderSide(
                color: context.borderColor.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 10.w),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // First Page (|<)
                  _buildNavArrowButton(
                    context: context,
                    icon: Icons.first_page_rounded,
                    isEnabled: currentPage > 1,
                    onTap: controller.firstExamPage,
                  ),

                  // Previous Page (<)
                  _buildNavArrowButton(
                    context: context,
                    icon: Icons.chevron_left_rounded,
                    isEnabled: currentPage > 1,
                    onTap: controller.previousExamPage,
                  ),

                  SizedBox(width: 3.w),

                  // Page Numbers
                  ..._buildPaginationNumbers(
                    context: context,
                    currentPage: currentPage,
                    totalPages: totalPages,
                    onPageSelected: (page) => controller.goToExamPage(page),
                  ),

                  SizedBox(width: 3.w),

                  // Next Page (>)
                  _buildNavArrowButton(
                    context: context,
                    icon: Icons.chevron_right_rounded,
                    isEnabled: currentPage < totalPages,
                    onTap: controller.nextExamPage,
                  ),

                  // Last Page (>|)
                  _buildNavArrowButton(
                    context: context,
                    icon: Icons.last_page_rounded,
                    isEnabled: currentPage < totalPages,
                    onTap: controller.lastExamPage,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // Modern Segmented Filter Pills (All / Attempted / Not Attempted)
  Widget _buildModernFilterBar(
    BuildContext context,
    SeeAllItemsController controller,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Obx(() {
        final currentFilter = controller.selectedFilter.value;

        return Container(
          padding: EdgeInsets.all(3.r),
          decoration: BoxDecoration(
            color: context.surfaceSubtle,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: context.borderColor.withValues(alpha: 0.6),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildFilterTab(
                  context: context,
                  label: "সব পরীক্ষা",
                  isSelected: currentFilter == 'all',
                  onTap: () => controller.setFilter('all'),
                ),
              ),
              Expanded(
                child: _buildFilterTab(
                  context: context,
                  label: "দেওয়া হয়েছে",
                  isSelected: currentFilter == 'attempted',
                  onTap: () {
                    if (isLoggedIn.value) {
                      controller.setFilter('attempted');
                    } else {
                      showLoginPopup(context);
                    }
                  },
                ),
              ),
              Expanded(
                child: _buildFilterTab(
                  context: context,
                  label: "দেওয়া হয়নি",
                  isSelected: currentFilter == 'not_attempted',
                  onTap: () {
                    if (isLoggedIn.value) {
                      controller.setFilter('not_attempted');
                    } else {
                      showLoginPopup(context);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFilterTab({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(vertical: 7.h),
        decoration: BoxDecoration(
          color: isSelected ? context.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(9.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: context.primaryColor.withValues(alpha: 0.25),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5.sp,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : context.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  // Compact, Sleek, Professional Exam Card
  Widget _buildCompactExamCard({
    required BuildContext context,
    required Exam exam,
    required VoidCallback onTap,
  }) {
    final isAttempted = exam.attempted == true;
    final categoryName = exam.examCategory?.name;
    final hasCategory = categoryName != null && categoryName.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isAttempted
              ? context.primaryColor.withValues(alpha: 0.35)
              : context.borderColor.withValues(alpha: 0.7),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.2 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          splashColor: context.primaryColor.withValues(alpha: 0.08),
          highlightColor: context.primaryColor.withValues(alpha: 0.04),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header: Title (Left) + Attempts Badge (Right)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        exam.name ?? '',
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    // Compact Status / Participants Pill
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 7.w,
                        vertical: 2.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: isAttempted
                            ? context.primaryColor.withValues(alpha: 0.12)
                            : context.surfaceSubtle,
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(
                          color: isAttempted
                              ? context.primaryColor.withValues(alpha: 0.35)
                              : context.borderColor.withValues(alpha: 0.6),
                          width: 0.7,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isAttempted
                                ? Icons.check_circle_outline_rounded
                                : Icons.people_outline_rounded,
                            size: 11.5.sp,
                            color: isAttempted
                                ? context.primaryColor
                                : context.textSecondary,
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            isAttempted
                                ? "সম্পন্ন"
                                : "${exam.examResultsCount ?? 0} জন",
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: isAttempted
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isAttempted
                                  ? context.primaryColor
                                  : context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 7.h),

                // Slim Compact Stats Row
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: context.surfaceSubtle,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      // Question Count
                      Expanded(
                        child: _buildMetricItem(
                          context: context,
                          icon: Icons.quiz_outlined,
                          iconColor: const Color(0xFF0284C7),
                          value: '${exam.questionsCount ?? 0}',
                          label: 'প্রশ্ন',
                        ),
                      ),
                      _buildVerticalDivider(context),
                      // Duration
                      Expanded(
                        child: _buildMetricItem(
                          context: context,
                          icon: Icons.timer_outlined,
                          iconColor: const Color(0xFF9333EA),
                          value: '${exam.duration ?? 0}',
                          label: 'মিনিট',
                        ),
                      ),
                      _buildVerticalDivider(context),
                      // Marks
                      Expanded(
                        child: _buildMetricItem(
                          context: context,
                          icon: Icons.emoji_events_outlined,
                          iconColor: const Color(0xFFD97706),
                          value: '${exam.possibleMark ?? 0}',
                          label: 'নম্বর',
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 7.h),

                // Footer Row: Date & Category (Left) + Compact Action Button (Right)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Published Date / Category
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 11.5.sp,
                          color: context.textMuted,
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          exam.publishedAt != null
                              ? 'প্রকাশিত: ${DateFormatter.formatToReadable(exam.publishedAt)}'
                              : 'প্রকাশিত',
                          style: TextStyle(
                            fontSize: 10.5.sp,
                            color: context.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (hasCategory) ...[
                          Text(
                            ' • ',
                            style: TextStyle(
                              color: context.textMuted,
                              fontSize: 10.sp,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              categoryName,
                              style: TextStyle(
                                fontSize: 10.5.sp,
                                color: context.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Compact Action Button
                    InkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.5.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isAttempted
                                ? [
                                    const Color(0xFF1E293B),
                                    const Color(0xFF334155),
                                  ]
                                : [
                                    context.primaryColor,
                                    const Color(0xFF047857),
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                          boxShadow: isAttempted
                              ? null
                              : [
                                  BoxShadow(
                                    color: context.primaryColor
                                        .withValues(alpha: 0.25),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isAttempted
                                  ? Icons.visibility_outlined
                                  : Icons.play_arrow_rounded,
                              size: 13.sp,
                              color: Colors.white,
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              isAttempted ? "ফলাফল দেখুন" : "পরীক্ষা দিন",
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 12.5.sp, color: iconColor),
        SizedBox(width: 4.w),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$value ',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  color: context.textPrimary,
                ),
              ),
              TextSpan(
                text: label,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider(BuildContext context) {
    return Container(
      height: 14.h,
      width: 1,
      color: context.borderColor.withValues(alpha: 0.6),
    );
  }

  // Navigation arrow buttons (|<<, <, >, >>|)
  Widget _buildNavArrowButton({
    required BuildContext context,
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      icon: Icon(
        icon,
        size: 18.sp,
        color: isEnabled
            ? context.primaryColor
            : context.textMuted.withValues(alpha: 0.3),
      ),
      onPressed: isEnabled ? onTap : null,
    );
  }

  // Smart Pagination page buttons
  List<Widget> _buildPaginationNumbers({
    required BuildContext context,
    required int currentPage,
    required int totalPages,
    required ValueChanged<int> onPageSelected,
  }) {
    final List<Widget> widgets = [];
    final List<int> pages = [];

    // Always include page 1
    pages.add(1);

    // Nearby pages (1 before, current, 1 after)
    for (int p = currentPage - 1; p <= currentPage + 1; p++) {
      if (p > 1 && p < totalPages && !pages.contains(p)) {
        pages.add(p);
      }
    }

    // Always include last page
    if (totalPages > 1 && !pages.contains(totalPages)) {
      pages.add(totalPages);
    }

    pages.sort();

    int lastRendered = 0;
    for (final page in pages) {
      if (lastRendered != 0 && page - lastRendered > 1) {
        widgets.add(
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            child: Text(
              "...",
              style: TextStyle(
                color: context.textMuted,
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
              ),
            ),
          ),
        );
      }

      final isActive = page == currentPage;
      widgets.add(
        InkWell(
          onTap: () => onPageSelected(page),
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 2.5.w),
            padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 9.w),
            decoration: BoxDecoration(
              color: isActive ? context.primaryColor : context.surfaceSubtle,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: isActive
                    ? context.primaryColor
                    : context.borderColor.withValues(alpha: 0.8),
                width: 1,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: context.primaryColor.withValues(alpha: 0.25),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              page.toString(),
              style: TextStyle(
                color: isActive ? Colors.white : context.textPrimary,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
          ),
        ),
      );

      lastRendered = page;
    }

    return widgets;
  }
}
