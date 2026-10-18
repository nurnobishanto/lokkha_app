import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/features/profile/data/models/self_exam_model.dart';
import 'package:lokkha/features/profile/domain/usecases/get_self_academy_history_usecase.dart';
import 'package:lokkha/features/profile/presentation/self_exam_history/views/self_exam_result_view.dart';

class SelfExamHistoryState {
  final int currentPage;
  final int totalPages;
  final int totalRecords;
  final bool isLoading;
  final String errorMessage;
  final List<SelfExamModel> examList;

  const SelfExamHistoryState({
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalRecords = 0,
    this.isLoading = false,
    this.errorMessage = '',
    this.examList = const [],
  });

  SelfExamHistoryState copyWith({
    int? currentPage,
    int? totalPages,
    int? totalRecords,
    bool? isLoading,
    String? errorMessage,
    List<SelfExamModel>? examList,
  }) {
    return SelfExamHistoryState(
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalRecords: totalRecords ?? this.totalRecords,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      examList: examList ?? this.examList,
    );
  }
}

class SelfExamHistoryNotifier extends Notifier<SelfExamHistoryState> {
  final GetSelfAcademyHistoryUseCase? _injectedUseCase;
  late final GetSelfAcademyHistoryUseCase _getSelfAcademyHistoryUseCase;

  SelfExamHistoryNotifier([this._injectedUseCase]);

  @override
  SelfExamHistoryState build() {
    _getSelfAcademyHistoryUseCase =
        _injectedUseCase ?? GetSelfAcademyHistoryUseCase();
    Future.microtask(() => loadExamHistory(page: 1));
    return const SelfExamHistoryState(isLoading: true);
  }

  Future<void> loadExamHistory({required int page}) async {
    try {
      state = state.copyWith(
        isLoading: true,
        errorMessage: '',
        currentPage: page,
      );

      final response = await _getSelfAcademyHistoryUseCase(page: page);

      state = state.copyWith(
        isLoading: false,
        currentPage: response.currentPage,
        totalPages: response.lastPage > 0 ? response.lastPage : 1,
        totalRecords: response.total,
        examList: response.items,
      );
    } catch (e) {
      debugPrint('[SelfExamHistoryNotifier] loadExamHistory error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'সেলফ টেস্ট রেকর্ড লোড করতে সমস্যা হয়েছে।',
      );
    }
  }

  void onPageChanged(int newPage) {
    if (newPage >= 1 &&
        newPage <= state.totalPages &&
        newPage != state.currentPage) {
      loadExamHistory(page: newPage);
    }
  }

  Future<void> onRefresh() async {
    await loadExamHistory(page: state.currentPage);
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
    NotifierProvider<SelfExamHistoryNotifier, SelfExamHistoryState>(
  SelfExamHistoryNotifier.new,
);
