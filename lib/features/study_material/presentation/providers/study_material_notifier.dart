import 'package:flutter/material.dart';
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
  final bool isDetailLoading;
  final String search;
  final String selectedAlphabet;
  final List<Vocabulary> rawVocab;
  final List<Vocabulary> filteredVocab;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final bool isLastPage;
  final Category? selectedType;
  final Category? selectedCategory;
  final VocabularyModel? model;
  final List<String> alphabets;
  final List<Category> types;
  final List<Category> categories;
  final Vocabulary? selectedVocabularyDetail;

  VocabularyState({
    this.isLoading = true,
    this.isDetailLoading = false,
    this.search = '',
    this.selectedAlphabet = '',
    this.rawVocab = const [],
    this.filteredVocab = const [],
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalCount = 0,
    this.isLastPage = false,
    this.selectedType,
    this.selectedCategory,
    this.model,
    this.alphabets = const [],
    this.types = const [],
    this.categories = const [],
    this.selectedVocabularyDetail,
  });

  VocabularyState copyWith({
    bool? isLoading,
    bool? isDetailLoading,
    String? search,
    String? selectedAlphabet,
    List<Vocabulary>? rawVocab,
    List<Vocabulary>? filteredVocab,
    int? currentPage,
    int? totalPages,
    int? totalCount,
    bool? isLastPage,
    Category? selectedType,
    Category? selectedCategory,
    VocabularyModel? model,
    List<String>? alphabets,
    List<Category>? types,
    List<Category>? categories,
    Vocabulary? selectedVocabularyDetail,
    bool clearType = false,
    bool clearCategory = false,
    bool clearDetail = false,
  }) {
    return VocabularyState(
      isLoading: isLoading ?? this.isLoading,
      isDetailLoading: isDetailLoading ?? this.isDetailLoading,
      search: search ?? this.search,
      selectedAlphabet: selectedAlphabet ?? this.selectedAlphabet,
      rawVocab: rawVocab ?? this.rawVocab,
      filteredVocab: filteredVocab ?? this.filteredVocab,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
      isLastPage: isLastPage ?? this.isLastPage,
      selectedType: clearType ? null : (selectedType ?? this.selectedType),
      selectedCategory:
          clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      model: model ?? this.model,
      alphabets: alphabets ?? this.alphabets,
      types: types ?? this.types,
      categories: categories ?? this.categories,
      selectedVocabularyDetail: clearDetail
          ? null
          : (selectedVocabularyDetail ?? this.selectedVocabularyDetail),
    );
  }
}

class VocabularyNotifier extends Notifier<VocabularyState> {
  final VocabularyRepository? _injectedRepository;

  VocabularyNotifier({VocabularyRepository? repository})
      : _injectedRepository = repository;

  VocabularyRepository get _repo =>
      _injectedRepository ?? ref.read(vocabularyRepositoryProvider);

  @override
  VocabularyState build() {
    Future.microtask(() => init());
    return VocabularyState();
  }

  Future<void> init() async {
    state = state.copyWith(isLoading: true);

    try {
      final results = await Future.wait([
        _repo.getAlphabets(),
        _repo.getCategories(),
        _repo.getTypes(),
        _repo.getVocabularies(
          page: 1,
          alphabet:
              state.selectedAlphabet.isNotEmpty ? state.selectedAlphabet : null,
          typeId: state.selectedType?.id,
          categoryId: state.selectedCategory?.id,
        ),
      ]);

      final alphabets = results[0] as List<String>;
      final categories = results[1] as List<Category>;
      final types = results[2] as List<Category>;
      final vocabModel = results[3] as VocabularyModel;

      final combinedModel = vocabModel.copyWith(
        alphabets: alphabets,
        categories: categories,
        types: types,
      );

      final rawList = combinedModel.vocabularies?.data ?? [];
      final lastPage = combinedModel.vocabularies?.lastPage ?? 1;
      final curPage = combinedModel.vocabularies?.currentPage ?? 1;
      final total = combinedModel.vocabularies?.total ?? rawList.length;

      final filtered = applyFilters(rawList);

      state = state.copyWith(
        isLoading: false,
        model: combinedModel,
        alphabets: alphabets,
        categories: categories,
        types: types,
        rawVocab: rawList,
        filteredVocab: filtered,
        currentPage: curPage,
        totalPages: lastPage,
        totalCount: total,
        isLastPage: curPage >= lastPage,
      );
    } catch (e) {
      debugPrint('[VocabularyNotifier.init] Error: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> setType(Category? type) async {
    final newType =
        (type != null && state.selectedType?.id == type.id) ? null : type;
    state = state.copyWith(
      selectedType: newType,
      clearType: newType == null,
      currentPage: 1,
    );
    state = state.copyWith(filteredVocab: applyFilters(state.rawVocab));
    await fetchVocabulary();
  }

  Future<void> setCategory(Category? category) async {
    final newCategory =
        (category != null && state.selectedCategory?.id == category.id)
            ? null
            : category;
    state = state.copyWith(
      selectedCategory: newCategory,
      clearCategory: newCategory == null,
      currentPage: 1,
    );
    state = state.copyWith(filteredVocab: applyFilters(state.rawVocab));
    await fetchVocabulary();
  }

  Future<void> setAlphabet(String char) async {
    final newChar =
        state.selectedAlphabet.toUpperCase() == char.toUpperCase() ? '' : char;
    state = state.copyWith(
      selectedAlphabet: newChar,
      currentPage: 1,
    );
    state = state.copyWith(filteredVocab: applyFilters(state.rawVocab));
    await fetchVocabulary();
  }

  void setSearch(String query) {
    state = state.copyWith(search: query);
    state = state.copyWith(filteredVocab: applyFilters(state.rawVocab));
  }

  List<Vocabulary> applyFilters(List<Vocabulary> rawList) {
    List<Vocabulary> filtered = rawList;

    // Filter by Alphabet
    if (state.selectedAlphabet.isNotEmpty) {
      final alpha = state.selectedAlphabet.toUpperCase();
      filtered = filtered
          .where((v) => (v.word ?? '').toUpperCase().startsWith(alpha))
          .toList();
    }

    // Filter by Type
    if (state.selectedType != null) {
      final tId = state.selectedType!.id;
      final tName = state.selectedType!.name?.toLowerCase();
      filtered = filtered.where((v) {
        if (tId != null &&
            v.types != null &&
            v.types!.any((t) => t.id == tId)) {
          return true;
        }
        if (tName != null) {
          if (v.typeName != null &&
              v.typeName!.toLowerCase().contains(tName)) {
            return true;
          }
          if (v.types != null &&
              v.types!.any((t) => t.name?.toLowerCase() == tName)) {
            return true;
          }
        }
        return false;
      }).toList();
    }

    // Filter by Category
    if (state.selectedCategory != null) {
      final cId = state.selectedCategory!.id;
      final cName = state.selectedCategory!.name?.toLowerCase();
      filtered = filtered.where((v) {
        if (cId != null &&
            v.categories != null &&
            v.categories!.any((c) => c.id == cId)) {
          return true;
        }
        if (cName != null) {
          if (v.categoryName != null &&
              v.categoryName!.toLowerCase().contains(cName)) {
            return true;
          }
          if (v.categories != null &&
              v.categories!.any((c) => c.name?.toLowerCase() == cName)) {
            return true;
          }
        }
        return false;
      }).toList();
    }

    // Filter by Search text
    if (state.search.trim().isNotEmpty) {
      final q = state.search.toLowerCase();
      filtered = filtered
          .where((v) =>
              (v.word ?? '').toLowerCase().contains(q) ||
              (v.displayMeaning ?? '').toLowerCase().contains(q) ||
              (v.details ?? '').toLowerCase().contains(q) ||
              (v.meaning ?? '').toLowerCase().contains(q) ||
              (v.banglaMeaning ?? '').toLowerCase().contains(q))
          .toList();
    }

    return filtered;
  }

  Future<void> fetchVocabulary({bool refresh = false}) async {
    state = state.copyWith(isLoading: true);

    try {
      final vocabModel = await _repo.getVocabularies(
        page: state.currentPage,
        alphabet:
            state.selectedAlphabet.isNotEmpty ? state.selectedAlphabet : null,
        typeId: state.selectedType?.id,
        categoryId: state.selectedCategory?.id,
      );

      final combinedModel = vocabModel.copyWith(
        alphabets: state.alphabets.isNotEmpty
            ? state.alphabets
            : vocabModel.alphabets,
        categories: state.categories.isNotEmpty
            ? state.categories
            : vocabModel.categories,
        types: state.types.isNotEmpty ? state.types : vocabModel.types,
      );

      final rawList = combinedModel.vocabularies?.data ?? [];
      final lastPage = combinedModel.vocabularies?.lastPage ?? 1;
      final curPage = combinedModel.vocabularies?.currentPage ?? 1;
      final total = combinedModel.vocabularies?.total ?? rawList.length;

      final filtered = applyFilters(rawList);

      state = state.copyWith(
        isLoading: false,
        model: combinedModel,
        rawVocab: rawList,
        filteredVocab: filtered,
        totalPages: lastPage,
        totalCount: total,
        isLastPage: curPage >= lastPage,
      );
    } catch (err) {
      debugPrint('[VocabularyNotifier.fetchVocabulary] Error: $err');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<Vocabulary?> getVocabularyDetail(int id) async {
    state = state.copyWith(isDetailLoading: true);
    final detail = await _repo.getVocabularyDetail(id);
    state = state.copyWith(
      isDetailLoading: false,
      selectedVocabularyDetail: detail,
    );
    return detail;
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
