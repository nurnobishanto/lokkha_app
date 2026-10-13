import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/features/profile/data/models/exam_history_model.dart';
import 'package:lokkha/features/profile/data/models/exam_review_detail_model.dart';
import 'package:lokkha/features/profile/domain/usecases/get_exam_history_detail_usecase.dart';

class ExamResultSheetState {
  final bool isLoading;
  final String errorMessage;
  final ExamReviewDetailModel? detail;

  const ExamResultSheetState({
    this.isLoading = true,
    this.errorMessage = '',
    this.detail,
  });

  ExamResultSheetState copyWith({
    bool? isLoading,
    String? errorMessage,
    ExamReviewDetailModel? detail,
  }) {
    return ExamResultSheetState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      detail: detail ?? this.detail,
    );
  }
}

class ExamResultSheetNotifier extends Notifier<ExamResultSheetState> {
  final ExamHistoryModel exam;
  late final GetExamHistoryDetailUseCase _getExamHistoryDetailUseCase;

  ExamResultSheetNotifier(this.exam);

  @override
  ExamResultSheetState build() {
    _getExamHistoryDetailUseCase = GetExamHistoryDetailUseCase();
    Future.microtask(() => fetchReview());
    return const ExamResultSheetState(isLoading: true);
  }

  Future<void> fetchReview() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: '');
      final targetId = exam.numericId > 0 ? exam.numericId : exam.id;
      final result = await _getExamHistoryDetailUseCase(
        targetId,
        summaryExam: exam,
      );
      state = state.copyWith(isLoading: false, detail: result);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "পর্যালোচনা তথ্য লোড করা যায়নি।",
      );
    }
  }
}

final examResultSheetNotifierProvider = NotifierProvider.family<
    ExamResultSheetNotifier, ExamResultSheetState, ExamHistoryModel>(
  ExamResultSheetNotifier.new,
);
