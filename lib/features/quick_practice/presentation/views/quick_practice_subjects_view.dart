import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/quick_practice/presentation/providers/quick_practice_providers.dart';
import 'package:lokkha/features/quick_practice/presentation/views/subject_children_view.dart';
import 'package:lokkha/features/quick_practice/presentation/views/subject_questions_practice_view.dart';
import 'package:lokkha/features/quick_practice/presentation/widgets/quick_practice_subject_card.dart';

class QuickPracticeSubjectsView extends ConsumerStatefulWidget {
  const QuickPracticeSubjectsView({super.key});

  @override
  ConsumerState<QuickPracticeSubjectsView> createState() =>
      _QuickPracticeSubjectsViewState();
}

class _QuickPracticeSubjectsViewState
    extends ConsumerState<QuickPracticeSubjectsView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quickPracticeSubjectsNotifierProvider);
    final notifier = ref.read(quickPracticeSubjectsNotifierProvider.notifier);
    final filtered = state.filteredSubjects;

    if (state.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: context.primaryColor,
        ),
      );
    }

    if (state.hasError) {
      return _buildErrorState(context, notifier, state.errorMessage);
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final crossAxisCount = isTablet ? (screenWidth >= 900 ? 4 : 3) : 2;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final cardExtent =
        (122 + (textScale > 1.0 ? (textScale - 1.0) * 16 : 0)).h;

    return RefreshIndicator(
      color: context.primaryColor,
      onRefresh: () => notifier.fetchSubjects(isRefresh: true),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ─── Search & Header Section ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 6.h),
              child: Column(
                children: [
                  // Search Input
                  Container(
                    height: 42.h,
                    decoration: BoxDecoration(
                      color: context.cardColor,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: context.borderColor.withValues(alpha: 0.75),
                        width: 0.85,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: context.isDark ? 0.2 : 0.02,
                          ),
                          blurRadius: 6,
                          offset: const Offset(0, 1.5),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: notifier.setSearchQuery,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: context.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'বিষয় বা পরীক্ষার নাম খুঁজুন...',
                        hintStyle: TextStyle(
                          fontSize: 12.5.sp,
                          color: context.textMuted,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          size: 19.sp,
                          color: context.textMuted,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear_rounded, size: 16.sp),
                                color: context.textMuted,
                                onPressed: () {
                                   _searchController.clear();
                                  notifier.clearSearch();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                      ),
                    ),
                  ),

                  SizedBox(height: 10.h),

                  // Header status row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'সকল বিষয় ও সেকশন',
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w700,
                            color: context.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        'মোট ${filtered.length}টি বিষয়',
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w600,
                          color: context.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ─── Subjects Grid ───────────────────────────────────────────────
          if (filtered.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(context),
            )
          else
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 10.h,
                  mainAxisExtent: cardExtent,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final subject = filtered[index];
                    return QuickPracticeSubjectCard(
                      subject: subject,
                      onTap: () {
                        if (subject.hasChildren) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                   SubjectChildrenView(subject: subject),
                            ),
                          );
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SubjectQuestionsPracticeView(
                                subjectId: subject.id,
                                title: subject.name,
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                  childCount: filtered.length,
                ),
              ),
            ),

          SliverToBoxAdapter(
            child: SizedBox(height: 24.h),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    QuickPracticeSubjectsNotifier notifier,
    String? message,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 68.r,
              height: 68.r,
              decoration: BoxDecoration(
                color: context.primaryColor.withValues(
                  alpha: context.isDark ? 0.18 : 0.08,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.school_outlined,
                size: 32.sp,
                color: context.primaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'কোনো বিষয় পাওয়া যায়নি',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message ??
                  'অনুগ্রহ করে ইন্টারনেট সংযোগ পরীক্ষা করুন অথবা পুনরায় চেষ্টা করুন।',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5.sp,
                color: context.textMuted,
                height: 1.4,
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: () => notifier.fetchSubjects(isRefresh: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 9.5.h,
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('পুনরায় চেষ্টা করুন'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 46.sp,
              color: context.textMuted,
            ),
            SizedBox(height: 12.h),
            Text(
              'কোনো বিষয় খুঁজে পাওয়া যায়নি',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.5.sp,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
