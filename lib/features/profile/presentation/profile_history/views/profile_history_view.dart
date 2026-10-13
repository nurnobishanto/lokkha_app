import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/shared/widgets/custom_app_bar.dart';
import '../riverpod/profile_history_notifier.dart';
import '../widgets/exam_history_card.dart';
import '../widgets/exam_history_pagination.dart';

class ProfileHistoryView extends ConsumerWidget {
  const ProfileHistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileHistoryNotifierProvider);
    final notifier = ref.read(profileHistoryNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: const CustomAppBar(
        title: 'My Exam History',
        centerTitle: true,
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading && state.examList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage.isNotEmpty && state.examList.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48.r,
                      color: Colors.redAccent,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      state.errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: context.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton.icon(
                      onPressed: () => notifier.loadExamHistory(
                        page: state.currentPage,
                      ),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text("আবার চেষ্টা করুন"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state.examList.isEmpty) {
            return RefreshIndicator(
              onRefresh: notifier.onRefresh,
              child: ListView(
                children: [
                  SizedBox(height: 180.h),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_edu_rounded,
                          size: 48.r,
                          color: context.textMuted,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "কোনো পরীক্ষার রেকর্ড পাওয়া যায়নি",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: context.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: notifier.onRefresh,
            child: Stack(
              children: [
                ListView.separated(
                  padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
                  itemCount: state.examList.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final item = state.examList[index];
                    return ExamHistoryCard(
                      item: item,
                      onRankTap: () => notifier.viewRank(context, item),
                      onResultSheetTap: () => notifier.viewResultSheet(context, item),
                    );
                  },
                ),
                if (state.isLoading)
                  Positioned(
                    top: 8.h,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: context.cardColor,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 14.r,
                              height: 14.r,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: context.primaryColor,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              "লোড হচ্ছে...",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: context.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Builder(
        builder: (context) {
          if (state.examList.isEmpty && state.totalRecords == 0) {
            return const SizedBox.shrink();
          }

          return Container(
            decoration: BoxDecoration(
              color: context.cardColor,
              border: Border(
                top: BorderSide(
                  color: context.borderColor,
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
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                child: ExamHistoryPagination(
                  currentPage: state.currentPage,
                  totalPages: state.totalPages,
                  totalRecords: state.totalRecords,
                  onPageChanged: notifier.onPageChanged,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
