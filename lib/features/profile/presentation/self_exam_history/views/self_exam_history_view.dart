import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/shared/widgets/custom_app_bar.dart';
import '../../profile_history/widgets/exam_history_pagination.dart';
import '../riverpod/self_exam_history_notifier.dart';
import '../widgets/self_exam_card.dart';

class SelfExamHistoryView extends ConsumerWidget {
  const SelfExamHistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(selfExamHistoryNotifierProvider);
    final notifier = ref.read(selfExamHistoryNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: const CustomAppBar(
        title: 'আমার সেলফ টেস্ট',
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
                      size: 56.sp,
                      color: const Color(0xFFEF4444),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      state.errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: context.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton.icon(
                      onPressed: () => notifier.loadExamHistory(page: state.currentPage),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('আবার চেষ্টা করুন'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
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
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 180.h),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.edit_note_rounded,
                          size: 56.sp,
                          color: context.textMuted,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          "কোনো সেলফ টেস্ট রেকর্ড পাওয়া যায়নি",
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: context.textSecondary,
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
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 20.h),
              itemCount: state.examList.length,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final item = state.examList[index];
                return SelfExamCard(
                  item: item,
                  onViewResult: () => notifier.viewResult(context, item),
                );
              },
            ),
          );
        },
      ),

      // Docked Bottom Pagination with ZERO ghost gap
      bottomNavigationBar: state.examList.isNotEmpty
          ? Container(
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
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  child: ExamHistoryPagination(
                    currentPage: state.currentPage,
                    totalPages: state.totalPages,
                    totalRecords: state.totalRecords,
                    onPageChanged: notifier.onPageChanged,
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
