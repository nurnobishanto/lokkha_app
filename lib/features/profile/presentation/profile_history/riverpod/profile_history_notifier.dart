import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/features/profile/data/models/exam_history_model.dart';
import 'package:lokkha/features/profile/domain/usecases/get_exam_history_usecase.dart';
import 'package:lokkha/features/profile/presentation/profile_history/views/exam_rank_view.dart';
import 'package:lokkha/features/profile/presentation/profile_history/views/exam_result_sheet_view.dart';

class ProfileHistoryState {
  final int currentPage;
  final int totalPages;
  final int totalRecords;
  final bool isLoading;
  final String errorMessage;
  final List<ExamHistoryModel> examList;

  const ProfileHistoryState({
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalRecords = 0,
    this.isLoading = false,
    this.errorMessage = '',
    this.examList = const [],
  });

  ProfileHistoryState copyWith({
    int? currentPage,
    int? totalPages,
    int? totalRecords,
    bool? isLoading,
    String? errorMessage,
    List<ExamHistoryModel>? examList,
  }) {
    return ProfileHistoryState(
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalRecords: totalRecords ?? this.totalRecords,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      examList: examList ?? this.examList,
    );
  }
}

class ProfileHistoryNotifier extends Notifier<ProfileHistoryState> {
  late final GetExamHistoryUseCase _getExamHistoryUseCase;

  @override
  ProfileHistoryState build() {
    _getExamHistoryUseCase = GetExamHistoryUseCase();
    Future.microtask(() => loadExamHistory(page: 1));
    return const ProfileHistoryState(isLoading: true);
  }

  Future<void> loadExamHistory({required int page}) async {
    try {
      state = state.copyWith(
        isLoading: true,
        errorMessage: '',
        currentPage: page,
      );

      final response = await _getExamHistoryUseCase(page: page);

      state = state.copyWith(
        isLoading: false,
        currentPage: response.currentPage,
        totalPages: response.lastPage > 0 ? response.lastPage : 1,
        totalRecords: response.total,
        examList: response.items,
      );
    } catch (e) {
      debugPrint('[ProfileHistoryNotifier] loadExamHistory error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'পরীক্ষার ইতিহাস লোড করতে সমস্যা হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।',
      );
    }
  }

  void onPageChanged(int newPage) {
    if (newPage >= 1 && newPage <= state.totalPages && newPage != state.currentPage) {
      loadExamHistory(page: newPage);
    }
  }

  Future<void> onRefresh() async {
    await loadExamHistory(page: state.currentPage);
  }

  void viewRank(BuildContext context, ExamHistoryModel item) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ExamRankView(exam: item)),
    );
  }

  void viewResultSheet(BuildContext context, ExamHistoryModel item) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ExamResultSheetView(exam: item)),
    );
  }
}

final profileHistoryNotifierProvider =
    NotifierProvider<ProfileHistoryNotifier, ProfileHistoryState>(ProfileHistoryNotifier.new);
