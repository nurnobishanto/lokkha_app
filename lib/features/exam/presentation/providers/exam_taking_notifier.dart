import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/di/exam_provider.dart';
import 'package:lokkha/features/exam/domain/repositories/exam_repository.dart';
import 'package:lokkha/features/exam/data/models/exam_lifecycle_models.dart';

class ExamTakingState {
  final bool isLoading;
  final bool isStarting;
  final bool isSubmitting;
  final String? errorMessage;
  final ExamInstructionsData? instructions;
  final ExamStartResponse? startResponse;
  final ActiveExamSessionResponse? activeSession;
  final ExamSubmitResultData? submitResult;

  const ExamTakingState({
    this.isLoading = false,
    this.isStarting = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.instructions,
    this.startResponse,
    this.activeSession,
    this.submitResult,
  });

  ExamTakingState copyWith({
    bool? isLoading,
    bool? isStarting,
    bool? isSubmitting,
    String? errorMessage,
    ExamInstructionsData? instructions,
    ExamStartResponse? startResponse,
    ActiveExamSessionResponse? activeSession,
    ExamSubmitResultData? submitResult,
  }) {
    return ExamTakingState(
      isLoading: isLoading ?? this.isLoading,
      isStarting: isStarting ?? this.isStarting,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      instructions: instructions ?? this.instructions,
      startResponse: startResponse ?? this.startResponse,
      activeSession: activeSession ?? this.activeSession,
      submitResult: submitResult ?? this.submitResult,
    );
  }
}

class ExamTakingNotifier extends Notifier<ExamTakingState> {
  final ExamRepository? _repoOverride;

  ExamTakingNotifier({ExamRepository? repository}) : _repoOverride = repository;

  ExamRepository get _repo => _repoOverride ?? ref.read(examRepositoryProvider);

  @override
  ExamTakingState build() => const ExamTakingState();

  /// Step 1: Fetch Instructions, rules, candidate eligibility and WebView URLs
  Future<ExamInstructionsData?> loadInstructions(int examId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final res = await _repo.getExamInstructions(examId);
      if (res.success) {
        state = state.copyWith(
          isLoading: false,
          instructions: res.data,
        );
        return res.data;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: res.message.isNotEmpty
              ? res.message
              : 'নির্দেশনা লোড করা যায়নি',
        );
        return null;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'পরীক্ষার তথ্য পেতে সমস্যা হয়েছে',
      );
      return null;
    }
  }

  /// Step 2: Start / Recover Secure Exam Session
  Future<ExamStartResponse?> startExamSession(int examId) async {
    state = state.copyWith(isStarting: true, errorMessage: null);
    try {
      final res = await _repo.startExam(examId);
      if (res.success) {
        state = state.copyWith(
          isStarting: false,
          startResponse: res,
        );
        return res;
      } else {
        state = state.copyWith(
          isStarting: false,
          errorMessage: res.message.isNotEmpty ? res.message : 'পরীক্ষা শুরু করা যায়নি',
        );
        return null;
      }
    } catch (e) {
      state = state.copyWith(
        isStarting: false,
        errorMessage: 'পরীক্ষা সেশন শুরু করতে ব্যর্থ হয়েছে',
      );
      return null;
    }
  }

  /// Step 2b: Poll/Restore active in-progress attempt
  Future<ActiveExamSessionResponse?> checkActiveSession(int examId) async {
    try {
      final res = await _repo.getActiveSession(examId);
      state = state.copyWith(activeSession: res);
      return res;
    } catch (_) {
      return null;
    }
  }

  /// Step 3: Autosave answer
  Future<bool> saveAnswer({
    required int examId,
    required int questionId,
    required dynamic answer,
  }) async {
    try {
      final res = await _repo.saveAnswer(
        examId: examId,
        questionId: questionId,
        answer: answer,
      );
      return res.isSaved;
    } catch (_) {
      return false;
    }
  }

  /// Step 4: Submit Exam and calculate score/rank
  Future<ExamSubmitResultData?> submitExam({
    required int examId,
    required Map<String, dynamic> answers,
    required int totalDuration,
  }) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final res = await _repo.submitExam(
        examId: examId,
        answers: answers,
        totalDuration: totalDuration,
      );
      if (res.success) {
        state = state.copyWith(
          isSubmitting: false,
          submitResult: res.data,
        );
        return res.data;
      } else {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: res.message.isNotEmpty ? res.message : 'সাবমিট করা সম্ভব হয়নি',
        );
        return null;
      }
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'পরীক্ষা সাবমিট করতে ত্রুটি দেখা দিয়েছে',
      );
      return null;
    }
  }
}

final examTakingNotifierProvider =
    NotifierProvider<ExamTakingNotifier, ExamTakingState>(
  ExamTakingNotifier.new,
);
