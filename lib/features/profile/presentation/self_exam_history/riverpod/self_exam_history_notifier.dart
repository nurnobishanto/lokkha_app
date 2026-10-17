import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/features/profile/data/models/self_exam_model.dart';
import 'package:lokkha/features/profile/presentation/self_exam_history/views/self_exam_result_view.dart';

class SelfExamHistoryState {
  final int currentPage;
  final int totalPages;
  final int totalRecords;
  final bool isLoading;
  final List<SelfExamModel> examList;

  const SelfExamHistoryState({
    this.currentPage = 1,
    this.totalPages = 3,
    this.totalRecords = 25,
    this.isLoading = false,
    this.examList = const [],
  });

  SelfExamHistoryState copyWith({
    int? currentPage,
    int? totalPages,
    int? totalRecords,
    bool? isLoading,
    List<SelfExamModel>? examList,
  }) {
    return SelfExamHistoryState(
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalRecords: totalRecords ?? this.totalRecords,
      isLoading: isLoading ?? this.isLoading,
      examList: examList ?? this.examList,
    );
  }
}

class SelfExamHistoryNotifier extends Notifier<SelfExamHistoryState> {
  @override
  SelfExamHistoryState build() {
    return SelfExamHistoryState(
      currentPage: 1,
      totalPages: 3,
      totalRecords: 25,
      isLoading: false,
      examList: _getItemsForPage(1),
    );
  }

  List<SelfExamModel> _getItemsForPage(int page) {
    List<SelfExamModel> items = [];
    if (page == 1) {
      items = const [
        SelfExamModel(
          id: "9560",
          date: "30 Aug, 2026 • 06:34 PM",
          duration: "10 সে.",
          status: "Failed (0%)",
          isPassed: false,
          title: "সেলফ একাডেমি টেস্ট",
          totalQuestions: 100,
          correctCount: 0,
          wrongCount: 2,
          obtainedMark: "0",
        ),
        SelfExamModel(
          id: "9559",
          date: "30 Aug, 2026 • 06:34 PM",
          status: "Failed (0%)",
          isPassed: false,
          title: "সেলফ একাডেমি টেস্ট",
          totalQuestions: 100,
          correctCount: 0,
          wrongCount: 0,
          obtainedMark: "0",
        ),
        SelfExamModel(
          id: "9558",
          date: "30 Aug, 2026 • 06:34 PM",
          status: "Failed (0%)",
          isPassed: false,
          title: "সেলফ একাডেমি টেস্ট",
          totalQuestions: 97,
          correctCount: 0,
          wrongCount: 0,
          obtainedMark: "0",
        ),
        SelfExamModel(
          id: "9557",
          date: "30 Aug, 2026 • 06:32 PM",
          status: "Failed (0%)",
          isPassed: false,
          title: "সেলফ একাডেমি টেস্ট",
          totalQuestions: 97,
          correctCount: 0,
          wrongCount: 0,
          obtainedMark: "0",
        ),
      ];
    } else if (page == 2) {
      items = const [
        SelfExamModel(
          id: "9556",
          date: "28 Aug, 2026 • 11:20 AM",
          duration: "15 সে.",
          status: "Passed (85%)",
          isPassed: true,
          title: "সেলফ একাডেমি টেস্ট - সাধারণ জ্ঞান",
          totalQuestions: 50,
          correctCount: 42,
          wrongCount: 4,
          obtainedMark: "41.0",
        ),
        SelfExamModel(
          id: "9555",
          date: "25 Aug, 2026 • 04:10 PM",
          status: "Passed (70%)",
          isPassed: true,
          title: "সেলফ একাডেমি টেস্ট - বাংলা ব্যাকরণ",
          totalQuestions: 50,
          correctCount: 35,
          wrongCount: 5,
          obtainedMark: "33.75",
        ),
      ];
    } else {
      items = const [
        SelfExamModel(
          id: "9550",
          date: "20 Aug, 2026 • 02:15 PM",
          status: "Failed (0%)",
          isPassed: false,
          title: "সেলফ একাডেমি টেস্ট",
          totalQuestions: 30,
          correctCount: 0,
          wrongCount: 0,
          obtainedMark: "0",
        ),
      ];
    }
    return items;
  }

  void loadExamHistory({required int page}) {
    final items = _getItemsForPage(page);
    state = state.copyWith(
      currentPage: page,
      examList: items,
      isLoading: false,
    );
  }

  void onPageChanged(int newPage) {
    if (newPage >= 1 && newPage <= state.totalPages) {
      loadExamHistory(page: newPage);
    }
  }

  void viewResult(BuildContext context, SelfExamModel item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SelfExamResultView(exam: item),
      ),
    );
  }
}

final selfExamHistoryNotifierProvider =
    NotifierProvider<SelfExamHistoryNotifier, SelfExamHistoryState>(SelfExamHistoryNotifier.new);
