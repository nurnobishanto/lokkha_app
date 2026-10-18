import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/features/profile/data/models/self_exam_model.dart';
import 'package:lokkha/features/profile/data/models/self_exam_detail_model.dart';
import 'package:lokkha/features/profile/domain/usecases/get_self_academy_detail_usecase.dart';

class SelfExamResultState {
  final bool isLoading;
  final String errorMessage;
  final SelfExamDetailModel? detail;

  const SelfExamResultState({
    this.isLoading = true,
    this.errorMessage = '',
    this.detail,
  });

  SelfExamResultState copyWith({
    bool? isLoading,
    String? errorMessage,
    SelfExamDetailModel? detail,
  }) {
    return SelfExamResultState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      detail: detail ?? this.detail,
    );
  }
}

class SelfExamResultNotifier extends Notifier<SelfExamResultState> {
  final SelfExamModel exam;
  final GetSelfAcademyDetailUseCase? _injectedUseCase;
  late final GetSelfAcademyDetailUseCase _getSelfAcademyDetailUseCase;

  SelfExamResultNotifier(this.exam, [this._injectedUseCase]);

  @override
  SelfExamResultState build() {
    _getSelfAcademyDetailUseCase = _injectedUseCase ?? GetSelfAcademyDetailUseCase();
    Future.microtask(() => fetchDetail());
    return const SelfExamResultState(isLoading: true);
  }

  Future<void> fetchDetail() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: '');
      final targetId = exam.numericId > 0 ? exam.numericId : exam.id;
      final result = await _getSelfAcademyDetailUseCase(
        targetId,
        summaryExam: exam,
      );
      state = state.copyWith(isLoading: false, detail: result);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'পরীক্ষার বিস্তারিত তথ্য লোড করা যায়নি।',
      );
    }
  }
}

final selfExamResultNotifierProvider = NotifierProvider.family<
    SelfExamResultNotifier, SelfExamResultState, SelfExamModel>(
  SelfExamResultNotifier.new,
);
