import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/quick_practice/data/models/quick_practice_models.dart';
import 'package:lokkha/features/quick_practice/presentation/providers/quick_practice_providers.dart';
import 'package:lokkha/features/quick_practice/presentation/widgets/subject_child_card.dart';
import 'package:lokkha/features/quick_practice/presentation/views/subject_exam_setup_view.dart';

class SubjectChildrenView extends ConsumerStatefulWidget {
  final QuickPracticeSubject subject;

  const SubjectChildrenView({
    super.key,
    required this.subject,
  });

  @override
  ConsumerState<SubjectChildrenView> createState() => _SubjectChildrenViewState();
}

class _SubjectChildrenViewState extends ConsumerState<SubjectChildrenView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref
          .read(subjectChildrenNotifierProvider(widget.subject.id).notifier)
          .loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state =
        ref.watch(subjectChildrenNotifierProvider(widget.subject.id));
    final notifier =
        ref.read(subjectChildrenNotifierProvider(widget.subject.id).notifier);

    final filtered = state.filteredChildren;

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: CustomAppBar(
        title: widget.subject.name,
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'সরাসরি পরীক্ষা শুরু করুন',
            icon: const Icon(Icons.play_circle_fill_rounded, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SubjectExamSetupView(
                    subjectId: widget.subject.id,
                    subjectTitle: widget.subject.name,
                    availableQuestions: widget.subject.totalQuestions,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Summary Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: context.cardColor,
              border: Border(
                bottom: BorderSide(
                  color: context.borderColor.withValues(alpha: 0.6),
                  width: 0.8,
                ),
              ),
            ),
            child: Column(
              children: [
                // Clean Search Bar
                Container(
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: context.surfaceSubtle,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: context.borderColor.withValues(alpha: 0.7),
                      width: 0.8,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: notifier.setSearchQuery,
                    style: TextStyle(fontSize: 13.sp, color: context.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'টপিক বা অধ্যায় খুঁজুন...',
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
                      contentPadding: EdgeInsets.symmetric(vertical: 9.h),
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'টপিকসমূহ',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                      ),
                    ),
                    Text(
                      'মোট ${state.meta.total > 0 ? state.meta.total : filtered.length}টি টপিক',
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w500,
                        color: context.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Children List
          Expanded(
            child: state.isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: context.primaryColor,
                    ),
                  )
                : state.hasError
                    ? _buildErrorView(context, notifier, state.errorMessage)
                    : filtered.isEmpty
                        ? _buildEmptyView(context)
                        : RefreshIndicator(
                            color: context.primaryColor,
                            onRefresh: () =>
                                notifier.fetchChildren(isRefresh: true),
                            child: ListView.builder(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 12.h,
                              ),
                              itemCount: filtered.length +
                                  (state.isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == filtered.length) {
                                  return Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 16.h),
                                    child: Center(
                                      child: SizedBox(
                                        width: 24.r,
                                        height: 24.r,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          color: context.primaryColor,
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                final item = filtered[index];
                                return SubjectChildCard(
                                  childItem: item,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => SubjectExamSetupView(
                                          subjectId: item.id,
                                          subjectTitle: item.name,
                                          availableQuestions:
                                              item.questionsCount,
                                        ),
                                      ),
                                    );
                                  },
                                  onPracticeTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => SubjectExamSetupView(
                                          subjectId: item.id,
                                          subjectTitle: item.name,
                                          availableQuestions:
                                              item.questionsCount,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(
    BuildContext context,
    SubjectChildrenNotifier notifier,
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
                Icons.folder_open_rounded,
                size: 32.sp,
                color: context.primaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'কোনো টপিক পাওয়া যায়নি',
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
                  'এই বিষয়ের অধ্যায়সমূহ শীঘ্রই যুক্ত করা হবে। অনুগ্রহ করে পুনরায় চেষ্টা করুন।',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5.sp,
                color: context.textMuted,
                height: 1.4,
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: () => notifier.fetchChildren(isRefresh: true),
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
              label: const Text('আবার চেষ্টা করুন'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open_rounded,
              size: 46.sp,
              color: context.textMuted,
            ),
            SizedBox(height: 12.h),
            Text(
              'কোনো টপিক বা অধ্যায় পাওয়া যায়নি',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.5.sp,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'আপনি সরাসরি এই প্রশ্নব্যাংকের পরীক্ষা শুরু করতে পারেন।',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: context.textMuted,
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SubjectExamSetupView(
                      subjectId: widget.subject.id,
                      subjectTitle: widget.subject.name,
                      availableQuestions: widget.subject.totalQuestions,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
              label: const Text('সরাসরি পরীক্ষা দিন'),
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
}
