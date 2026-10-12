import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lokkha/app/router/router.dart';
import 'package:lokkha/features/profile/data/models/contest_history_item_model.dart';
import 'package:lokkha/features/profile/data/models/exam_history_model.dart';
import 'package:lokkha/features/profile/data/models/saved_question_item_model.dart';
import 'package:lokkha/features/profile/presentation/profile_history/views/exam_rank_view.dart';
import 'package:lokkha/features/profile/presentation/profile_history/views/exam_result_sheet_view.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';

class ContestHistoryState {
  final List<ContestHistoryItemModel> contestList;
  final List<SavedQuestionItemModel> savedQuestionList;
  final bool isLoading;

  const ContestHistoryState({
    this.contestList = const [],
    this.savedQuestionList = const [],
    this.isLoading = false,
  });

  ContestHistoryState copyWith({
    List<ContestHistoryItemModel>? contestList,
    List<SavedQuestionItemModel>? savedQuestionList,
    bool? isLoading,
  }) {
    return ContestHistoryState(
      contestList: contestList ?? this.contestList,
      savedQuestionList: savedQuestionList ?? this.savedQuestionList,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ContestHistoryNotifier extends Notifier<ContestHistoryState> {
  @override
  ContestHistoryState build() {
    final state = const ContestHistoryState(
      contestList: [
        ContestHistoryItemModel(
          id: "146",
          date: "21 Apr, 2026 • 07:00 PM",
          title: "লাইভ কনটেস্ট #43",
          correctCount: 0,
          wrongCount: 0,
        ),
        ContestHistoryItemModel(
          id: "31",
          date: "13 May, 2025 • 10:24 AM",
          duration: "70 সে.",
          title: "Quiz Contest 1",
          correctCount: 3,
          wrongCount: 7,
        ),
      ],
      savedQuestionList: [
        SavedQuestionItemModel(
          id: "62618",
          savedDate: "23 Dec, 2025",
        ),
        SavedQuestionItemModel(
          id: "62617",
          savedDate: "23 Dec, 2025",
        ),
        SavedQuestionItemModel(
          id: "62616",
          savedDate: "23 Dec, 2025",
        ),
      ],
    );
    return state;
  }

  void openLiveContests(BuildContext context) {
    context.push(Routes.allContest);
  }

  void viewRanking(BuildContext context, ContestHistoryItemModel item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExamRankView(
          exam: ExamHistoryModel(
            id: "#${item.id}",
            date: item.date,
            status: "Completed",
            isPassed: true,
            title: item.title,
            totalQuestions: item.correctCount + item.wrongCount,
            correctCount: item.correctCount,
            wrongCount: item.wrongCount,
            obtainedMark: "${item.correctCount}",
          ),
        ),
      ),
    );
  }

  void viewResult(BuildContext context, ContestHistoryItemModel item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExamResultSheetView(
          exam: ExamHistoryModel(
            id: "#${item.id}",
            date: item.date,
            status: "Completed",
            isPassed: true,
            title: item.title,
            totalQuestions: item.correctCount + item.wrongCount,
            correctCount: item.correctCount,
            wrongCount: item.wrongCount,
            obtainedMark: "${item.correctCount}",
          ),
        ),
      ),
    );
  }

  void viewSavedQuestion(SavedQuestionItemModel item) {
    CustomSnackBar.showCustomToast(
      message: "প্রশ্ন #${item.id} বিস্তারিত প্রস্তুত হচ্ছে...",
    );
  }

  void removeSavedQuestion(SavedQuestionItemModel item) {
    state = state.copyWith(
      savedQuestionList: state.savedQuestionList.where((q) => q.id != item.id).toList(),
    );
    CustomSnackBar.showCustomToast(
      message: "প্রশ্নটি সেভড লিস্ট থেকে অপসারণ করা হয়েছে",
    );
  }

  void practiceQuestion(SavedQuestionItemModel item) {
    CustomSnackBar.showCustomToast(
      message: "প্রশ্ন #${item.id} প্র্যাকটিস মোড চালু হচ্ছে...",
    );
  }
}

final contestHistoryNotifierProvider =
    NotifierProvider<ContestHistoryNotifier, ContestHistoryState>(ContestHistoryNotifier.new);
