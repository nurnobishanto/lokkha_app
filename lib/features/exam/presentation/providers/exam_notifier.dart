import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/constants/app_constants.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/core/enums/api_call_status.dart';
import 'package:lokkha/core/network/rest_client.dart';
import 'package:lokkha/core/services/storage/my_get_storage.dart';
import 'package:lokkha/core/services/storage/my_shared_pref.dart';
import 'package:lokkha/core/utils/global.dart';
import 'package:lokkha/features/exam/exam.dart';
import 'package:lokkha/shared/models/tag.dart';
import 'package:lokkha/shared/widgets/web_exam_view.dart';

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
  @override
  RandomQuestionState build() {
    Future.microtask(() => getRandomQuestion());
    return RandomQuestionState();
  }

  Future<void> getRandomQuestion({bool forceNew = false}) async {
    state = state.copyWith(isLoading: true, isAnswerSelected: false);

    if (forceNew) {
      MyGetStorage.removeCache(MyGetStorage.randomQuestionKey);
    } else if (MyGetStorage.getStorage.hasData(MyGetStorage.randomQuestionKey)) {
      final cacheData =
          MyGetStorage.readCache(MyGetStorage.randomQuestionKey);
      if (cacheData != null) {
        final model = RandomQuestionModel.fromJson(cacheData);
        state = state.copyWith(
          randomQuestionModel: model,
          isLoading: false,
        );
        return;
      }
    }

    final deviceID = await getDeviceId();
    final url =
        "${AppConstants.randomQuestion}?forceNew=$forceNew&deviceID=$deviceID";

    await BaseClient.safeApiCall(
      url,
      RequestType.get,
      onSuccess: (response) {
        if (response.data['status'] == true) {
          final data = RandomQuestionModel.fromJson(response.data);
          MyGetStorage.writeCacheData(
              MyGetStorage.randomQuestionKey, response.data);
          state = state.copyWith(
            randomQuestionModel: data,
            isLoading: false,
            randomQuestionPackage: response.data['package_required'] == true,
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            randomQuestionPackage: response.data['package_required'] == true,
          );
        }
      },
      onError: (_) {
        state = state.copyWith(isLoading: false);
      },
    );
  }

  void setIsAnswerSelected(bool value) {
    state = state.copyWith(isAnswerSelected: value);
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
  final ApiCallStatus examApiStatus;
  final ApiCallStatus courseApiStatus;

  ExamCategoriesState({
    this.examCategoriesModel,
    this.courseCategoriesModel,
    this.examApiStatus = ApiCallStatus.holding,
    this.courseApiStatus = ApiCallStatus.holding,
  });

  ExamCategoriesState copyWith({
    ExamCategoriesModel? examCategoriesModel,
    CourseCategoriesModel? courseCategoriesModel,
    ApiCallStatus? examApiStatus,
    ApiCallStatus? courseApiStatus,
  }) {
    return ExamCategoriesState(
      examCategoriesModel: examCategoriesModel ?? this.examCategoriesModel,
      courseCategoriesModel:
          courseCategoriesModel ?? this.courseCategoriesModel,
      examApiStatus: examApiStatus ?? this.examApiStatus,
      courseApiStatus: courseApiStatus ?? this.courseApiStatus,
    );
  }
}

class ExamCategoriesNotifier extends Notifier<ExamCategoriesState> {
  @override
  ExamCategoriesState build() {
    Future.microtask(() {
      fetchExamCategories();
      fetchCourseCategories();
    });
    return ExamCategoriesState();
  }

  Future<void> fetchExamCategories() async {
    state = state.copyWith(examApiStatus: ApiCallStatus.loading);
    final url = AppConstants.examsCategories;
    await BaseClient.safeApiCall(
      url,
      RequestType.get,
      onSuccess: (response) {
        if (response.data['status'] == true) {
          state = state.copyWith(
            examCategoriesModel: ExamCategoriesModel.fromJson(response.data),
            examApiStatus: ApiCallStatus.success,
          );
        } else {
          state = state.copyWith(examApiStatus: ApiCallStatus.error);
        }
      },
      onError: (_) {
        state = state.copyWith(examApiStatus: ApiCallStatus.error);
      },
    );
  }

  Future<void> fetchCourseCategories() async {
    state = state.copyWith(courseApiStatus: ApiCallStatus.loading);
    final url = AppConstants.courseCategories;
    await BaseClient.safeApiCall(
      url,
      RequestType.get,
      onSuccess: (response) {
        if (response.data['status'] == true) {
          state = state.copyWith(
            courseCategoriesModel:
                CourseCategoriesModel.fromJson(response.data),
            courseApiStatus: ApiCallStatus.success,
          );
        } else {
          state = state.copyWith(courseApiStatus: ApiCallStatus.error);
        }
      },
      onError: (_) {
        state = state.copyWith(courseApiStatus: ApiCallStatus.error);
      },
    );
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
  final bool isLoadingQuestion;
  final int currentPage;
  final LatestExamModel? model;
  final ApiCallStatus apiCallStatus;

  LatestExamState({
    this.isLoading = true,
    this.isLoadingQuestion = false,
    this.currentPage = 1,
    this.model,
    this.apiCallStatus = ApiCallStatus.holding,
  });

  LatestExamState copyWith({
    bool? isLoading,
    bool? isLoadingQuestion,
    int? currentPage,
    LatestExamModel? model,
    ApiCallStatus? apiCallStatus,
  }) {
    return LatestExamState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingQuestion: isLoadingQuestion ?? this.isLoadingQuestion,
      currentPage: currentPage ?? this.currentPage,
      model: model ?? this.model,
      apiCallStatus: apiCallStatus ?? this.apiCallStatus,
    );
  }
}

class LatestExamNotifier extends Notifier<LatestExamState> {
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
      apiCallStatus: ApiCallStatus.loading,
      isLoading: true,
    );
    final url =
        "${AppConstants.latestExam}?search=$search&page=$page&date=$date";

    await BaseClient.safeApiCall(
      url,
      RequestType.get,
      onSuccess: (response) {
        if (response.data['status'] == true) {
          final modelData = LatestExamModel.fromJson(response.data);
          if (page > 1 && state.model?.latestExams?.data != null) {
            final combinedList = List.of(state.model!.latestExams!.data!)
              ..addAll(modelData.latestExams?.data ?? []);
            final updatedExams = state.model!.latestExams;
            // update existing data
            state = state.copyWith(
              currentPage: page,
              isLoading: false,
              apiCallStatus: ApiCallStatus.success,
            );
          } else {
            state = state.copyWith(
              model: modelData,
              currentPage: page,
              isLoading: false,
              apiCallStatus: ApiCallStatus.success,
            );
          }
        } else {
          state = state.copyWith(isLoading: false);
        }
      },
      onError: (_) {
        state = state.copyWith(
          apiCallStatus: ApiCallStatus.error,
          isLoading: false,
        );
      },
    );
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
            url: AppConstants.webTestExamStart,
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
  final ApiCallStatus apiCallStatus;
  final ExamCategoryDetailsModel? examCategoryDetailsModel;
  final ExamCategoriesModel? categoriesWithParentID;

  ExamCategoryDetailsState({
    required this.categoryId,
    this.currentPage = 1,
    this.totalPages = 1,
    this.isLastPage = false,
    this.apiCallStatus = ApiCallStatus.holding,
    this.examCategoryDetailsModel,
    this.categoriesWithParentID,
  });

  ExamCategoryDetailsState copyWith({
    int? currentPage,
    int? totalPages,
    bool? isLastPage,
    ApiCallStatus? apiCallStatus,
    ExamCategoryDetailsModel? examCategoryDetailsModel,
    ExamCategoriesModel? categoriesWithParentID,
  }) {
    return ExamCategoryDetailsState(
      categoryId: categoryId,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isLastPage: isLastPage ?? this.isLastPage,
      apiCallStatus: apiCallStatus ?? this.apiCallStatus,
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

  ExamCategoryDetailsNotifier(this.categoryId);

  @override
  ExamCategoryDetailsState build() {
    Future.microtask(() {
      fetchExamCategoryDetails(categoryId);
      fetchExamCategoriesWithParentID(categoryId);
    });
    return ExamCategoryDetailsState(categoryId: categoryId);
  }

  Future<void> fetchExamCategoryDetails(int id) async {
    state = state.copyWith(apiCallStatus: ApiCallStatus.loading);
    final url =
        '${AppConstants.examsCategory}/$id?page=${state.currentPage}';

    await BaseClient.safeApiCall(
      url,
      RequestType.get,
      onSuccess: (response) {
        if (response.data['status'] == true) {
          final modelData =
              ExamCategoryDetailsModel.fromJson(response.data);
          state = state.copyWith(
            examCategoryDetailsModel: modelData,
            totalPages: modelData.freeExams?.lastPage ?? 1,
            isLastPage: modelData.freeExams?.currentPage ==
                modelData.freeExams?.lastPage,
            apiCallStatus: ApiCallStatus.success,
          );
        } else {
          state = state.copyWith(apiCallStatus: ApiCallStatus.error);
        }
      },
      onError: (_) {
        state = state.copyWith(apiCallStatus: ApiCallStatus.error);
      },
    );
  }

  Future<void> fetchExamCategoriesWithParentID(int parentId) async {
    final url = '${AppConstants.examsCategories}?parent_id=$parentId';
    await BaseClient.safeApiCall(
      url,
      RequestType.get,
      onSuccess: (response) {
        if (response.data['status'] == true) {
          state = state.copyWith(
            categoriesWithParentID:
                ExamCategoriesModel.fromJson(response.data),
          );
        }
      },
      onError: (_) {},
    );
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
