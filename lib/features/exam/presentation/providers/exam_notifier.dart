import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/exam/exam.dart';
import 'package:lokkha/shared/shared.dart';

// ============================================================================
// 1. Random Question
// ============================================================================

class RandomQuestionState {
  final RandomQuestionModel? randomQuestionModel;
  final bool isLoading;
  final bool randomQuestionPackage;
  final bool isAnswerSelected;

  RandomQuestionState({
    this.randomQuestionModel,
    this.isLoading = false,
    this.randomQuestionPackage = false,
    this.isAnswerSelected = false,
  });

  RandomQuestionState copyWith({
    RandomQuestionModel? randomQuestionModel,
    bool? isLoading,
    bool? randomQuestionPackage,
    bool? isAnswerSelected,
  }) {
    return RandomQuestionState(
      randomQuestionModel: randomQuestionModel ?? this.randomQuestionModel,
      isLoading: isLoading ?? this.isLoading,
      randomQuestionPackage:
          randomQuestionPackage ?? this.randomQuestionPackage,
      isAnswerSelected: isAnswerSelected ?? this.isAnswerSelected,
    );
  }
}

class RandomQuestionNotifier extends Notifier<RandomQuestionState> {
  final RestClient _client;

  RandomQuestionNotifier({RestClient? client})
      : _client = client ?? RestClient();

  @override
  RandomQuestionState build() {
    Future.microtask(() => getRandomQuestion());
    return RandomQuestionState();
  }

  void setAnswerSelected(bool value) {
    state = state.copyWith(isAnswerSelected: value);
  }

  void setIsAnswerSelected(bool value) {
    state = state.copyWith(isAnswerSelected: value);
  }

  Future<void> getRandomQuestion({bool forceNew = false}) async {
    state = state.copyWith(isLoading: true, isAnswerSelected: false);
    if (forceNew) {
      MyGetStorage.removeCache(MyGetStorage.randomQuestionKey);
    }
    if (!forceNew && MyGetStorage.hasData(MyGetStorage.randomQuestionKey)) {
      final cacheData = MyGetStorage.readCache(MyGetStorage.randomQuestionKey);
      if (cacheData != null) {
        state = state.copyWith(
          randomQuestionModel: RandomQuestionModel.fromJson(cacheData),
          isLoading: false,
        );
        return;
      }
    }

    final deviceID = await getDeviceId();
    final url =
        '${Endpoints.randomQuestion}?forceNew=$forceNew&deviceID=$deviceID';
    try {
      final response = await _client.get(url);
      if (response.data != null && response.data['status'] == true) {
        final data = RandomQuestionModel.fromJson(response.data);
        MyGetStorage.writeCacheData(
            MyGetStorage.randomQuestionKey, response.data);
        state = state.copyWith(
          randomQuestionModel: data,
          randomQuestionPackage: response.data['package_required'] == true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          randomQuestionPackage: response.data?['package_required'] == true,
        );
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> getRandomQuestionPackageCheck() async {
    state = state.copyWith(isLoading: true);
    final isPremium = checkUserHasPackage();
    if (isPremium) {
      state = state.copyWith(
        randomQuestionPackage: true,
        isLoading: false,
      );
      return;
    }

    final token = await SecureStorageService.getToken();
    final url = Endpoints.v1UserProfile;
    try {
      final response = await _client.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.data != null && response.data['user'] != null) {
        final havePkg = response.data['user']['have_package'] ?? false;
        havePackage.value = havePkg;
        state = state.copyWith(
          randomQuestionPackage: havePkg,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          randomQuestionPackage: isPremium,
          isLoading: false,
        );
      }
    } catch (_) {
      state = state.copyWith(
        randomQuestionPackage: isPremium,
        isLoading: false,
      );
    }
  }
}

final randomQuestionNotifierProvider =
    NotifierProvider<RandomQuestionNotifier, RandomQuestionState>(
  RandomQuestionNotifier.new,
);

// ============================================================================
// 2. Exam Categories & Course Categories
// ============================================================================

class ExamCategoriesState {
  final ExamCategoriesModel? examCategoriesModel;
  final CourseCategoriesModel? courseCategoriesModel;
  final bool isExamLoading;
  final bool isExamError;
  final bool isCourseLoading;
  final bool isCourseError;

  ExamCategoriesState({
    this.examCategoriesModel,
    this.courseCategoriesModel,
    this.isExamLoading = false,
    this.isExamError = false,
    this.isCourseLoading = false,
    this.isCourseError = false,
  });

  ExamCategoriesState copyWith({
    ExamCategoriesModel? examCategoriesModel,
    CourseCategoriesModel? courseCategoriesModel,
    bool? isExamLoading,
    bool? isExamError,
    bool? isCourseLoading,
    bool? isCourseError,
  }) {
    return ExamCategoriesState(
      examCategoriesModel: examCategoriesModel ?? this.examCategoriesModel,
      courseCategoriesModel:
          courseCategoriesModel ?? this.courseCategoriesModel,
      isExamLoading: isExamLoading ?? this.isExamLoading,
      isExamError: isExamError ?? this.isExamError,
      isCourseLoading: isCourseLoading ?? this.isCourseLoading,
      isCourseError: isCourseError ?? this.isCourseError,
    );
  }
}

class ExamCategoriesNotifier extends Notifier<ExamCategoriesState> {
  final RestClient _client;

  ExamCategoriesNotifier({RestClient? client})
      : _client = client ?? RestClient();

  @override
  ExamCategoriesState build() {
    Future.microtask(() {
      fetchExamCategories();
      fetchCourseCategories();
    });
    return ExamCategoriesState();
  }

  Future<void> fetchExamCategories() async {
    state = state.copyWith(isExamLoading: true, isExamError: false);
    final url = Endpoints.examsCategories;
    try {
      final response = await _client.get(url);
      if (response.data['status'] == true) {
        state = state.copyWith(
          examCategoriesModel: ExamCategoriesModel.fromJson(response.data),
          isExamLoading: false,
          isExamError: false,
        );
      } else {
        state = state.copyWith(isExamLoading: false, isExamError: true);
      }
    } catch (_) {
      state = state.copyWith(isExamLoading: false, isExamError: true);
    }
  }

  Future<void> fetchCourseCategories() async {
    state = state.copyWith(isCourseLoading: true, isCourseError: false);
    final url = Endpoints.courseCategories;
    try {
      final response = await _client.get(url);
      if (response.data['status'] == true) {
        state = state.copyWith(
          courseCategoriesModel:
              CourseCategoriesModel.fromJson(response.data),
          isCourseLoading: false,
          isCourseError: false,
        );
      } else {
        state = state.copyWith(isCourseLoading: false, isCourseError: true);
      }
    } catch (_) {
      state = state.copyWith(isCourseLoading: false, isCourseError: true);
    }
  }
}

final examCategoriesNotifierProvider =
    NotifierProvider<ExamCategoriesNotifier, ExamCategoriesState>(
  ExamCategoriesNotifier.new,
);

// ============================================================================
// 3. Latest Exam
// ============================================================================

class LatestExamState {
  final bool isLoading;
  final bool hasError;
  final bool isLoadingQuestion;
  final int currentPage;
  final LatestExamModel? model;

  LatestExamState({
    this.isLoading = true,
    this.hasError = false,
    this.isLoadingQuestion = false,
    this.currentPage = 1,
    this.model,
  });

  LatestExamState copyWith({
    bool? isLoading,
    bool? hasError,
    bool? isLoadingQuestion,
    int? currentPage,
    LatestExamModel? model,
  }) {
    return LatestExamState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      isLoadingQuestion: isLoadingQuestion ?? this.isLoadingQuestion,
      currentPage: currentPage ?? this.currentPage,
      model: model ?? this.model,
    );
  }
}

class LatestExamNotifier extends Notifier<LatestExamState> {
  final RestClient _client;

  LatestExamNotifier({RestClient? client}) : _client = client ?? RestClient();

  @override
  LatestExamState build() {
    Future.microtask(() => fetchLatestExam());
    return LatestExamState();
  }

  Future<void> fetchLatestExam({
    int page = 1,
    String date = '',
    String search = '',
  }) async {
    state = state.copyWith(
      isLoading: true,
      hasError: false,
    );
    final url =
        "${Endpoints.latestExam}?search=$search&page=$page&date=$date";

    try {
      final response = await _client.get(url);
      if (response.data['status'] == true) {
        final modelData = LatestExamModel.fromJson(response.data);
        if (page > 1 && state.model?.latestExams?.data != null) {
          state = state.copyWith(
            currentPage: page,
            isLoading: false,
            hasError: false,
          );
        } else {
          state = state.copyWith(
            model: modelData,
            currentPage: page,
            isLoading: false,
            hasError: false,
          );
        }
      } else {
        state = state.copyWith(isLoading: false, hasError: true);
      }
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
      );
    }
  }

  Future<void> fetchTagQuestions({
    required Tag tag,
    required bool isStartExam,
    required int duration,
    required String selectedNegativeMark,
    required BuildContext context,
  }) async {
    final data = <String, dynamic>{
      'exam_name': tag.name,
      'negative_mark': 0,
      'is_negative_mark': false,
      'is_set_time': true,
      'type': "random",
      'duration': duration,
      'previous_day_count': 10,
      'tag_id': tag.id,
      'is_exam': isStartExam,
    };

    final token = MySharedPref.getUserToken();
    if (token.isEmpty) {
      return;
    }

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
  }
}

final latestExamNotifierProvider =
    NotifierProvider<LatestExamNotifier, LatestExamState>(
  LatestExamNotifier.new,
);

// ============================================================================
// 4. Exam Category Details
// ============================================================================

class ExamCategoryDetailsState {
  final int categoryId;
  final int currentPage;
  final int totalPages;
  final bool isLastPage;
  final bool isLoading;
  final bool hasError;
  final ExamCategoryDetailsModel? examCategoryDetailsModel;
  final ExamCategoriesModel? categoriesWithParentID;

  ExamCategoryDetailsState({
    required this.categoryId,
    this.currentPage = 1,
    this.totalPages = 1,
    this.isLastPage = false,
    this.isLoading = false,
    this.hasError = false,
    this.examCategoryDetailsModel,
    this.categoriesWithParentID,
  });

  ExamCategoryDetailsState copyWith({
    int? currentPage,
    int? totalPages,
    bool? isLastPage,
    bool? isLoading,
    bool? hasError,
    ExamCategoryDetailsModel? examCategoryDetailsModel,
    ExamCategoriesModel? categoriesWithParentID,
  }) {
    return ExamCategoryDetailsState(
      categoryId: categoryId,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isLastPage: isLastPage ?? this.isLastPage,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      examCategoryDetailsModel:
          examCategoryDetailsModel ?? this.examCategoryDetailsModel,
      categoriesWithParentID:
          categoriesWithParentID ?? this.categoriesWithParentID,
    );
  }
}

class ExamCategoryDetailsNotifier
    extends Notifier<ExamCategoryDetailsState> {
  final int categoryId;
  final RestClient _client;

  ExamCategoryDetailsNotifier(this.categoryId, {RestClient? client})
      : _client = client ?? RestClient();

  @override
  ExamCategoryDetailsState build() {
    Future.microtask(() {
      fetchExamCategoryDetails(categoryId);
      fetchExamCategoriesWithParentID(categoryId);
    });
    return ExamCategoryDetailsState(categoryId: categoryId);
  }

  Future<void> fetchExamCategoryDetails(int id) async {
    state = state.copyWith(isLoading: true, hasError: false);
    final url =
        '${Endpoints.examsCategory}/$id?page=${state.currentPage}';

    try {
      final response = await _client.get(url);
      if (response.data['status'] == true) {
        final modelData =
            ExamCategoryDetailsModel.fromJson(response.data);
        state = state.copyWith(
          examCategoryDetailsModel: modelData,
          totalPages: modelData.freeExams?.lastPage ?? 1,
          isLastPage: modelData.freeExams?.currentPage ==
              modelData.freeExams?.lastPage,
          isLoading: false,
          hasError: false,
        );
      } else {
        state = state.copyWith(isLoading: false, hasError: true);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false, hasError: true);
    }
  }

  Future<void> fetchExamCategoriesWithParentID(int parentId) async {
    final url = '${Endpoints.examsCategories}?parent_id=$parentId';
    try {
      final response = await _client.get(url);
      if (response.data['status'] == true) {
        state = state.copyWith(
          categoriesWithParentID:
              ExamCategoriesModel.fromJson(response.data),
        );
      }
    } catch (_) {}
  }

  void goToPage(int page) {
    if (page >= 1 && page <= state.totalPages) {
      state = state.copyWith(currentPage: page);
      fetchExamCategoryDetails(categoryId);
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

final examCategoryDetailsNotifierProvider = NotifierProvider.family<
    ExamCategoryDetailsNotifier, ExamCategoryDetailsState, int>(
  ExamCategoryDetailsNotifier.new,
);
