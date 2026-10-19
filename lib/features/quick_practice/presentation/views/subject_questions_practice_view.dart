import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/quick_practice/presentation/providers/quick_practice_providers.dart';
import 'package:lokkha/features/quick_practice/presentation/widgets/practice_question_card.dart';
import 'package:lokkha/features/quick_practice/presentation/widgets/subject_exam_setup_bottom_sheet.dart';

class SubjectQuestionsPracticeView extends ConsumerStatefulWidget {
  final int subjectId;
  final String title;

  const SubjectQuestionsPracticeView({
    super.key,
    required this.subjectId,
    required this.title,
  });

  @override
  ConsumerState<SubjectQuestionsPracticeView> createState() =>
      _SubjectQuestionsPracticeViewState();
}

class _SubjectQuestionsPracticeViewState
    extends ConsumerState<SubjectQuestionsPracticeView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref
          .read(subjectQuestionsNotifierProvider(widget.subjectId).notifier)
          .loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state =
        ref.watch(subjectQuestionsNotifierProvider(widget.subjectId));
    final notifier =
        ref.read(subjectQuestionsNotifierProvider(widget.subjectId).notifier);

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: CustomAppBar(
        title: widget.title,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.play_circle_filled_rounded,
              color: Colors.white,
              size: 22.sp,
            ),
            tooltip: 'পরীক্ষা দিন',
            onPressed: () {
              SubjectExamSetupBottomSheet.show(
                context,
                subjectId: widget.subjectId,
                subjectTitle: widget.title,
                availableQuestions: state.questions.length,
              );
            },
          ),
          if (state.questions.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(right: 14.w),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 3.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    '${state.userAnswers.length}/${state.questions.length}',
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: state.isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: context.primaryColor,
              ),
            )
          : state.hasError
              ? _buildErrorView(context, notifier, state.errorMessage)
              : state.questions.isEmpty
                  ? _buildEmptyView(context, notifier)
                  : RefreshIndicator(
                      color: context.primaryColor,
                      onRefresh: () => notifier.fetchQuestions(isRefresh: true),
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 12.h,
                        ),
                        itemCount: state.questions.length +
                            (state.isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == state.questions.length) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
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

                          final question = state.questions[index];
                          return PracticeQuestionCard(
                            question: question,
                            index: index,
                            selectedOptionKey: state.userAnswers[question.id],
                            isExplanationExpanded:
                                state.showExplanations[question.id] ?? false,
                            isBookmarked: state.bookmarkedQuestionIds
                                .contains(question.id),
                            onSelectOption: (optionKey) {
                              notifier.selectOption(question.id, optionKey);
                            },
                            onToggleExplanation: () {
                              notifier.toggleExplanation(question.id);
                            },
                            onToggleBookmark: () {
                              notifier.toggleBookmark(question.id);
                            },
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _buildErrorView(
    BuildContext context,
    SubjectQuestionsNotifier notifier,
    String? message,
  ) {
    return _buildEmptyOrUnavailableView(
      context,
      notifier,
      title: 'কোনো প্রশ্ন পাওয়া যায়নি',
      subtitle: message ??
          'এই বিষয়ের প্রশ্নসমূহ দ্রুত যুক্ত করা হবে। অনুগ্রহ করে অন্য কোনো বিষয় অনুশীলন করুন।',
    );
  }

  Widget _buildEmptyView(BuildContext context, SubjectQuestionsNotifier notifier) {
    return _buildEmptyOrUnavailableView(
      context,
      notifier,
      title: 'বর্তমানে কোনো প্রশ্ন নেই',
      subtitle:
          'এই বিষয়ের জন্য শীঘ্রই নতুন প্রশ্ন যুক্ত করা হবে। অনুগ্রহ করে অন্য কোনো বিষয় বা অধ্যায় অনুশীলন করুন।',
    );
  }

  Widget _buildEmptyOrUnavailableView(
    BuildContext context,
    SubjectQuestionsNotifier notifier, {
    required String title,
    required String subtitle,
  }) {
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
                Icons.quiz_outlined,
                size: 32.sp,
                color: context.primaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5.sp,
                color: context.textMuted,
                height: 1.4,
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: () => notifier.fetchQuestions(isRefresh: true),
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
}
