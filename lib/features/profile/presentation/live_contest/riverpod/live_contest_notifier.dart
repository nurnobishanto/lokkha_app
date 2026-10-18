import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/features/profile/data/models/content_history_model.dart';
import 'package:lokkha/features/profile/data/models/exam_history_model.dart';
import 'package:lokkha/features/profile/domain/usecases/get_content_history_usecase.dart';
import 'package:lokkha/features/profile/domain/usecases/toggle_save_question_usecase.dart';
import 'package:lokkha/features/profile/presentation/profile_history/views/exam_rank_view.dart';
import 'package:lokkha/features/profile/presentation/profile_history/views/exam_result_sheet_view.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';

class LiveContestState {
  final bool isLoading;
  final String? errorMessage;
  final ContentHistoryResponseModel? contentHistory;
  final String activeFilter; // 'all', 'contests', 'saved'
  final Set<int> togglingQuestionIds;

  const LiveContestState({
    this.isLoading = false,
    this.errorMessage,
    this.contentHistory,
    this.activeFilter = 'all',
    this.togglingQuestionIds = const {},
  });

  ContentHistorySummaryModel get summary =>
      contentHistory?.summary ?? const ContentHistorySummaryModel();

  List<UserContestItemModel> get recentContests =>
      contentHistory?.recentContests ?? const [];

  List<UserSavedQuestionModel> get recentSavedQuestions =>
      contentHistory?.recentSavedQuestions ?? const [];

  int get totalContests => summary.totalContests > 0
      ? summary.totalContests
      : recentContests.length;

  int get totalSavedQuestions => summary.totalSavedQuestions > 0
      ? summary.totalSavedQuestions
      : recentSavedQuestions.length;

  LiveContestState copyWith({
    bool? isLoading,
    String? errorMessage,
    ContentHistoryResponseModel? contentHistory,
    String? activeFilter,
    Set<int>? togglingQuestionIds,
  }) {
    return LiveContestState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      contentHistory: contentHistory ?? this.contentHistory,
      activeFilter: activeFilter ?? this.activeFilter,
      togglingQuestionIds: togglingQuestionIds ?? this.togglingQuestionIds,
    );
  }
}

class LiveContestNotifier extends Notifier<LiveContestState> {
  final LiveContestState? _initialState;
  final GetContentHistoryUseCase? _customGetContentHistoryUseCase;
  final ToggleSaveQuestionUseCase? _customToggleSaveQuestionUseCase;

  LiveContestNotifier({
    LiveContestState? initialState,
    GetContentHistoryUseCase? getContentHistoryUseCase,
    ToggleSaveQuestionUseCase? toggleSaveQuestionUseCase,
  })  : _initialState = initialState,
        _customGetContentHistoryUseCase = getContentHistoryUseCase,
        _customToggleSaveQuestionUseCase = toggleSaveQuestionUseCase;

  late final GetContentHistoryUseCase _getContentHistoryUseCase;
  late final ToggleSaveQuestionUseCase _toggleSaveQuestionUseCase;

  @override
  LiveContestState build() {
    _getContentHistoryUseCase =
        _customGetContentHistoryUseCase ?? GetContentHistoryUseCase();
    _toggleSaveQuestionUseCase =
        _customToggleSaveQuestionUseCase ?? ToggleSaveQuestionUseCase();

    if (_initialState != null) {
      return _initialState!;
    }

    // Trigger initial load
    Future.microtask(() => loadContentHistory());

    return const LiveContestState(isLoading: true);
  }

  Future<void> loadContentHistory({bool refresh = false}) async {
    if (state.contentHistory != null && !refresh && !state.isLoading) {
      return;
    }
    if (!refresh) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }

    try {
      final result = await _getContentHistoryUseCase();
      state = state.copyWith(
        isLoading: false,
        errorMessage: null,
        contentHistory: result,
      );
    } catch (e) {
      debugPrint('[LiveContestNotifier] loadContentHistory error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'কনটেন্ট হিস্ট্রি লোড করতে ব্যর্থ হয়েছে। পুনরায় চেষ্টা করুন।',
      );
    }
  }

  void setFilter(String filter) {
    if (state.activeFilter == filter) return;
    state = state.copyWith(activeFilter: filter);
  }

  void openLiveContests(BuildContext context) {
    context.push(Routes.allContest);
  }

  void viewContestRanking(BuildContext context, UserContestItemModel item) {
    final examModel = ExamHistoryModel(
      id: "#${item.id}",
      date: item.formattedDate,
      status: item.isCompleted ? "Completed" : "Participated",
      isPassed: item.score > 0,
      title: item.contestTitle,
      totalQuestions: item.totalQuestions > 0
          ? item.totalQuestions
          : (item.correctAnswers + item.incorrectAnswers),
      correctCount: item.correctAnswers,
      wrongCount: item.incorrectAnswers,
      obtainedMark: item.formattedScore,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExamRankView(exam: examModel),
      ),
    );
  }

  void viewContestResult(BuildContext context, UserContestItemModel item) {
    final examModel = ExamHistoryModel(
      id: "#${item.id}",
      date: item.formattedDate,
      status: item.isCompleted ? "Completed" : "Participated",
      isPassed: item.score > 0,
      title: item.contestTitle,
      totalQuestions: item.totalQuestions > 0
          ? item.totalQuestions
          : (item.correctAnswers + item.incorrectAnswers),
      correctCount: item.correctAnswers,
      wrongCount: item.incorrectAnswers,
      obtainedMark: item.formattedScore,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExamResultSheetView(exam: examModel),
      ),
    );
  }

  Future<void> removeSavedQuestion(
    BuildContext context,
    UserSavedQuestionModel item,
  ) async {
    final currentHistory = state.contentHistory;
    if (currentHistory == null) return;

    // Track toggling state
    final nextToggling = Set<int>.from(state.togglingQuestionIds)..add(item.questionId);
    state = state.copyWith(togglingQuestionIds: nextToggling);

    // Optimistically remove from list and decrement summary count
    final updatedList = currentHistory.recentSavedQuestions
        .where((q) => q.savedId != item.savedId && q.questionId != item.questionId)
        .toList();
    final updatedSummary = currentHistory.summary.copyWith(
      totalSavedQuestions: (currentHistory.summary.totalSavedQuestions - 1).clamp(0, 999999),
    );

    final optimisticHistory = currentHistory.copyWith(
      recentSavedQuestions: updatedList,
      summary: updatedSummary,
    );

    state = state.copyWith(contentHistory: optimisticHistory);

    try {
      final success = await _toggleSaveQuestionUseCase(item.questionId);
      if (context.mounted) {
        CustomSnackBar.showCustomToast(
          message: success
              ? "প্রশ্নটি সেভড লিস্ট থেকে অপসারণ করা হয়েছে"
              : "প্রশ্নটির অবস্থা হালনাগাদ করা হয়েছে",
        );
      }
    } catch (e) {
      debugPrint('[LiveContestNotifier] removeSavedQuestion error: $e');
      // Revert if error
      state = state.copyWith(contentHistory: currentHistory);
      if (context.mounted) {
        CustomSnackBar.showCustomToast(
          message: "বুকমার্ক মুছতে সমস্যা হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।",
        );
      }
    } finally {
      final finishedToggling = Set<int>.from(state.togglingQuestionIds)
        ..remove(item.questionId);
      state = state.copyWith(togglingQuestionIds: finishedToggling);
    }
  }
}

final liveContestNotifierProvider =
    NotifierProvider<LiveContestNotifier, LiveContestState>(LiveContestNotifier.new);
