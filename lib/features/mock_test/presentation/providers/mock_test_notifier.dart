import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/network/endpoints.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/core/network/rest_client.dart';
import 'package:lokkha/core/services/storage/my_shared_pref.dart';
import 'package:lokkha/shared/models/get_subjects.dart';
import 'package:lokkha/shared/models/mock_subject_select_model.dart';
import 'package:lokkha/shared/widgets/web_exam_view.dart';

// ============================================================================
// 1. Mock Test Root Subjects
// ============================================================================

class MockTestState {
  final bool isLoading;
  final bool hasError;
  final GetSubjectsModel? model;

  MockTestState({
    this.isLoading = true,
    this.hasError = false,
    this.model,
  });

  MockTestState copyWith({
    bool? isLoading,
    bool? hasError,
    GetSubjectsModel? model,
  }) {
    return MockTestState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      model: model ?? this.model,
    );
  }
}

class MockTestNotifier extends Notifier<MockTestState> {
  final RestClient _client;

  MockTestNotifier({RestClient? client}) : _client = client ?? RestClient();

  @override
  MockTestState build() {
    Future.microtask(() => getRootSubjects());
    return MockTestState();
  }

  Future<void> getRootSubjects({bool isRefresh = false}) async {
    state = state.copyWith(
      isLoading: !isRefresh && (state.model?.subjects?.isEmpty ?? true),
      hasError: false,
    );

    // 1. First attempt: V1 Question Banks endpoint (/api/v1/home/question-banks)
    try {
      final response = await _client.get(Endpoints.homeQuestionBanks);
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final model = GetSubjectsModel.fromJson(data);
        if (model.subjects != null && model.subjects!.isNotEmpty) {
          state = state.copyWith(
            model: model,
            isLoading: false,
            hasError: false,
          );
          return;
        }
      }
    } catch (_) {
      // Fall through to fallback
    }

    // 2. Fallback: legacy getSubjects endpoint
    try {
      final response = await _client.get(Endpoints.getSubjects);
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final model = GetSubjectsModel.fromJson(data);
        if (model.status == true ||
            (model.subjects != null && model.subjects!.isNotEmpty)) {
          state = state.copyWith(
            model: model,
            isLoading: false,
            hasError: false,
          );
          return;
        }
      }
      state = state.copyWith(
        isLoading: false,
        hasError: true,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
      );
    }
  }
}

final mockTestNotifierProvider =
    NotifierProvider<MockTestNotifier, MockTestState>(
  MockTestNotifier.new,
);

// ============================================================================
// 2. Topic Selection
// ============================================================================

class TopicSelectionState {
  final bool isLoading;
  final GetSubjectsModel? topics;
  final List<MockSubjectSelect> selectedSubjects;

  TopicSelectionState({
    this.isLoading = true,
    this.topics,
    this.selectedSubjects = const [],
  });

  TopicSelectionState copyWith({
    bool? isLoading,
    GetSubjectsModel? topics,
    List<MockSubjectSelect>? selectedSubjects,
  }) {
    return TopicSelectionState(
      isLoading: isLoading ?? this.isLoading,
      topics: topics ?? this.topics,
      selectedSubjects: selectedSubjects ?? this.selectedSubjects,
    );
  }
}

class TopicSelectionNotifier extends Notifier<TopicSelectionState> {
  final int parentId;
  final RestClient _client;

  TopicSelectionNotifier(this.parentId, {RestClient? client})
      : _client = client ?? RestClient();

  @override
  TopicSelectionState build() {
    Future.microtask(() {
      getSubjectTopics();
      loadSelectedSubjects();
    });
    return TopicSelectionState();
  }

  Future<void> getSubjectTopics() async {
    state = state.copyWith(isLoading: true);
    final url = '${Endpoints.getSubjects}?parent_id=$parentId';

    try {
      final response = await _client.get(url);
      if (response.data['status'] == true) {
        final data = GetSubjectsModel.fromJson(response.data);
        state = state.copyWith(
          topics: data,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadSelectedSubjects() async {
    final list = await MySharedPref.getMockSubjects();
    state = state.copyWith(selectedSubjects: list);
  }
}

final topicSelectionNotifierProvider =
    NotifierProvider.family<TopicSelectionNotifier, TopicSelectionState, int>(
  TopicSelectionNotifier.new,
);

// ============================================================================
// 3. Mock Test Set Time
// ============================================================================

class MockTestSetTimeState {
  final bool isNegativeMarkChecked;
  final bool isSetTime;
  final bool isLoading;
  final String selectedKey;
  final List<MockSubjectSelect> selectedSubjects;
  final Map<String, String> questionType;

  MockTestSetTimeState({
    this.isNegativeMarkChecked = false,
    this.isSetTime = false,
    this.isLoading = false,
    this.selectedKey = 'random',
    this.selectedSubjects = const [],
    this.questionType = const {
      "random": "রেনডম প্রশ্ন",
      "unanswered": "উত্তর না দেওয়া প্রশ্ন",
      "answered": "উত্তর দেওয়া প্রশ্ন",
      "wrong": 'ভুল উত্তর দেওয়া প্রশ্ন',
      "corrected": 'সঠিক উত্তর দেওয়া প্রশ্ন',
      "favorite": 'ফেভারিট প্রশ্ন',
    },
  });

  MockTestSetTimeState copyWith({
    bool? isNegativeMarkChecked,
    bool? isSetTime,
    bool? isLoading,
    String? selectedKey,
    List<MockSubjectSelect>? selectedSubjects,
    Map<String, String>? questionType,
  }) {
    return MockTestSetTimeState(
      isNegativeMarkChecked:
          isNegativeMarkChecked ?? this.isNegativeMarkChecked,
      isSetTime: isSetTime ?? this.isSetTime,
      isLoading: isLoading ?? this.isLoading,
      selectedKey: selectedKey ?? this.selectedKey,
      selectedSubjects: selectedSubjects ?? this.selectedSubjects,
      questionType: questionType ?? this.questionType,
    );
  }
}

class MockTestSetTimeNotifier extends Notifier<MockTestSetTimeState> {
  @override
  MockTestSetTimeState build() {
    Future.microtask(() => getSubjects());
    return MockTestSetTimeState();
  }

  Future<void> getSubjects() async {
    final fetched = await MySharedPref.getMockSubjects();
    state = state.copyWith(selectedSubjects: fetched);
  }

  void setSetTime(bool value) {
    state = state.copyWith(isSetTime: value);
  }

  void setNegativeMarkChecked(bool value) {
    state = state.copyWith(isNegativeMarkChecked: value);
  }

  void setSelectedKey(String key) {
    state = state.copyWith(selectedKey: key);
  }

  Future<void> testExamStart({
    required BuildContext context,
    required String setTimeText,
    bool isExam = true,
  }) async {
    try {
      state = state.copyWith(isLoading: true);
      final token = MySharedPref.getUserToken();
      if (token.isEmpty) return;

      final durationValue = int.tryParse(setTimeText) ?? 0;
      final finalDuration =
          state.isSetTime ? (durationValue < 1 ? 1 : durationValue) : 0;

      final data = <String, dynamic>{
        'exam_name': 'Mock Test',
        'negative_mark': state.isNegativeMarkChecked ? 0.25 : 0,
        'is_negative_mark': state.isNegativeMarkChecked,
        'is_set_time': state.isSetTime,
        'type': state.selectedKey,
        'duration': finalDuration,
        'is_exam': isExam,
        'subjects': state.selectedSubjects
            .map((subject) => subject.toMap())
            .toList(),
      };

      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WebExamView(
              title: "Exam",
              url: Endpoints.webTestExamStart,
              body: data,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

final mockTestSetTimeNotifierProvider =
    NotifierProvider<MockTestSetTimeNotifier, MockTestSetTimeState>(
  MockTestSetTimeNotifier.new,
);
