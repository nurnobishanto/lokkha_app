import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/study_material/study_material.dart';
import 'package:lokkha/shared/models/category.dart';
import 'package:lokkha/shared/models/vocabulary.dart';
import 'package:lokkha/shared/widgets/web_exam_view.dart';

// ============================================================================
// 1. Current Affairs
// ============================================================================

class CurrentAffairsState {
  final bool isLoading;
  final CurrentAffairsModel? model;
  final int currentPage;
  final int totalPages;
  final String search;
  final String? selectedDate;

  CurrentAffairsState({
    this.isLoading = true,
    this.model,
    this.currentPage = 1,
    this.totalPages = 1,
    this.search = '',
    this.selectedDate,
  });

  CurrentAffairsState copyWith({
    bool? isLoading,
    CurrentAffairsModel? model,
    int? currentPage,
    int? totalPages,
    String? search,
    String? selectedDate,
  }) {
    return CurrentAffairsState(
      isLoading: isLoading ?? this.isLoading,
      model: model ?? this.model,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      search: search ?? this.search,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

class CurrentAffairsNotifier extends Notifier<CurrentAffairsState> {
  final bool isInternational;
  final RestClient _client;

  CurrentAffairsNotifier(this.isInternational, {RestClient? client})
      : _client = client ?? RestClient();

  @override
  CurrentAffairsState build() {
    Future.microtask(() => fetchCurrentAffairs(''));
    return CurrentAffairsState();
  }

  Future<void> fetchCurrentAffairs(
    String search, {
    int page = 1,
    bool refresh = false,
    String? date,
  }) async {
    state = state.copyWith(isLoading: true, search: search, selectedDate: date);
    final dateParam = (date != null && date.isNotEmpty) ? '&date=$date' : '';
    final baseUrl =
        isInternational ? Endpoints.internationalCA : Endpoints.nationalCA;
    final url = '$baseUrl?search=$search&page=$page$dateParam';

    final token = MySharedPref.getUserToken();
    final headers = {
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    try {
      final response = await _client.get(
        url,
        headers: headers,
      );
      if (response.data['status'] == true) {
        final model = CurrentAffairsModel.fromJson(response.data);
        state = state.copyWith(
          isLoading: false,
          model: model,
          currentPage: page,
          totalPages: model.currentAffairs?.lastPage ?? 1,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  void goToPage(int page) {
    if (page < 1 || page > state.totalPages) return;
    fetchCurrentAffairs('', page: page, date: state.selectedDate);
  }
}

final currentAffairsNotifierProvider =
    NotifierProvider.family<CurrentAffairsNotifier, CurrentAffairsState, bool>(
  CurrentAffairsNotifier.new,
);

// ============================================================================
// 2. Vocabulary
// ============================================================================

class VocabularyState {
  final bool isLoading;
  final String search;
  final String selectedAlphabet;
  final List<Vocabulary> filteredVocab;
  final int currentPage;
  final int totalPages;
  final bool isLastPage;
  final Category? selectedType;
  final Category? selectedCategory;
  final VocabularyModel? model;

  VocabularyState({
    this.isLoading = true,
    this.search = '',
    this.selectedAlphabet = '',
    this.filteredVocab = const [],
    this.currentPage = 1,
    this.totalPages = 1,
    this.isLastPage = false,
    this.selectedType,
    this.selectedCategory,
    this.model,
  });

  VocabularyState copyWith({
    bool? isLoading,
    String? search,
    String? selectedAlphabet,
    List<Vocabulary>? filteredVocab,
    int? currentPage,
    int? totalPages,
    bool? isLastPage,
    Category? selectedType,
    Category? selectedCategory,
    VocabularyModel? model,
    bool clearType = false,
    bool clearCategory = false,
  }) {
    return VocabularyState(
      isLoading: isLoading ?? this.isLoading,
      search: search ?? this.search,
      selectedAlphabet: selectedAlphabet ?? this.selectedAlphabet,
      filteredVocab: filteredVocab ?? this.filteredVocab,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isLastPage: isLastPage ?? this.isLastPage,
      selectedType: clearType ? null : (selectedType ?? this.selectedType),
      selectedCategory:
          clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      model: model ?? this.model,
    );
  }
}

class VocabularyNotifier extends Notifier<VocabularyState> {
  final RestClient _client;

  VocabularyNotifier({RestClient? client}) : _client = client ?? RestClient();

  @override
  VocabularyState build() {
    Future.microtask(() => fetchVocabulary());
    return VocabularyState();
  }

  void setType(Category? type) {
    state = state.copyWith(
      selectedType: type,
      clearType: type == null,
      currentPage: 1,
      selectedAlphabet: '',
    );
    fetchVocabulary();
  }

  void setCategory(Category? category) {
    state = state.copyWith(
      selectedCategory: category,
      clearCategory: category == null,
      currentPage: 1,
      selectedAlphabet: '',
    );
    fetchVocabulary();
  }

  void setAlphabet(String char) {
    state = state.copyWith(
      selectedAlphabet: char,
      currentPage: 1,
    );
    fetchVocabulary();
  }

  void setSearch(String query) {
    final allVocabs = state.model?.vocabularies?.data ?? [];
    List<Vocabulary> filtered;
    if (query.trim().isEmpty) {
      filtered = allVocabs;
    } else {
      final q = query.toLowerCase();
      filtered = allVocabs
          .where((v) => (v.word ?? '').toLowerCase().contains(q))
          .toList();
    }
    state = state.copyWith(search: query, filteredVocab: filtered);
  }

  Future<void> fetchVocabulary({bool refresh = false}) async {
    state = state.copyWith(isLoading: true);
    final url = Endpoints.vocabularies;

    final data = <String, dynamic>{
      'alphabet': state.selectedAlphabet.toUpperCase(),
      'page': state.currentPage,
      'search': state.search,
    };
    if (state.selectedType?.id != null) {
      data['type_ids[]'] = [state.selectedType!.id!];
    }
    if (state.selectedCategory?.id != null) {
      data['category_ids[]'] = [state.selectedCategory!.id!];
    }

    try {
      final response = await _client.get(
        url,
        queryParameters: data,
      );
      if (response.data['status'] == true) {
        final modelData = VocabularyModel.fromJson(response.data);
        final rawList = modelData.vocabularies?.data ?? [];
        final lastPage = modelData.vocabularies?.lastPage ?? 1;
        final curPage = modelData.vocabularies?.currentPage ?? 1;

        List<Vocabulary> filtered = rawList;
        if (state.search.trim().isNotEmpty) {
          final q = state.search.toLowerCase();
          filtered = rawList
              .where((v) => (v.word ?? '').toLowerCase().contains(q))
              .toList();
        }

        state = state.copyWith(
          isLoading: false,
          model: modelData,
          selectedAlphabet:
              modelData.selectedAlphabet?.toUpperCase() ?? state.selectedAlphabet,
          totalPages: lastPage,
          isLastPage: curPage >= lastPage,
          filteredVocab: filtered,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          filteredVocab: [],
        );
      }
    } catch (err) {
      state = state.copyWith(
        isLoading: false,
      );
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= state.totalPages) {
      state = state.copyWith(currentPage: page);
      fetchVocabulary();
    }
  }

  void nextPage() {
    if (state.currentPage < state.totalPages) {
      goToPage(state.currentPage + 1);
    }
  }

  void previousPage() {
    if (state.currentPage > 1) {
      goToPage(state.currentPage - 1);
    }
  }

  void firstPage() => goToPage(1);
  void lastPage() => goToPage(state.totalPages);
}

final vocabularyNotifierProvider =
    NotifierProvider<VocabularyNotifier, VocabularyState>(
  VocabularyNotifier.new,
);

// ============================================================================
// 3. SubSecSetTime
// ============================================================================

class SubSecSetTimeState {
  final bool isNegativeMarkChecked;
  final bool isSetTime;
  final bool isLoading;
  final String selectedKey;
  final List<SubjectSectionSelect> selectedSubjects;
  final Map<String, String> questionType;

  SubSecSetTimeState({
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

  SubSecSetTimeState copyWith({
    bool? isNegativeMarkChecked,
    bool? isSetTime,
    bool? isLoading,
    String? selectedKey,
    List<SubjectSectionSelect>? selectedSubjects,
    Map<String, String>? questionType,
  }) {
    return SubSecSetTimeState(
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

class SubSecSetTimeNotifier extends Notifier<SubSecSetTimeState> {
  @override
  SubSecSetTimeState build() {
    Future.microtask(() => getSubjects());
    return SubSecSetTimeState();
  }

  Future<void> getSubjects() async {
    final fetchedSubjects = await MySharedPref.getSubjectSection();
    state = state.copyWith(selectedSubjects: fetchedSubjects);
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

      final int durationValue = int.tryParse(setTimeText) ?? 0;
      final int finalDuration =
          state.isSetTime ? (durationValue < 1 ? 1 : durationValue) : 0;

      final data = <String, dynamic>{
        'exam_name': 'Question Bank Exam',
        'is_negative_mark': state.isNegativeMarkChecked,
        'negative_mark': state.isNegativeMarkChecked ? 0.25 : 0,
        'is_exam': isExam,
        'is_set_time': state.isSetTime,
        'duration': finalDuration,
        'type': state.selectedKey,
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

final subSecSetTimeNotifierProvider =
    NotifierProvider<SubSecSetTimeNotifier, SubSecSetTimeState>(
  SubSecSetTimeNotifier.new,
);
