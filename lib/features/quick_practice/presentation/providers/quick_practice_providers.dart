import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/features/quick_practice/data/models/quick_practice_models.dart';
import 'package:lokkha/features/quick_practice/data/repositories/quick_practice_repository_impl.dart';
import 'package:lokkha/features/quick_practice/domain/repositories/quick_practice_repository.dart';

// ─── Repository Provider ───────────────────────────────────────────────────
final quickPracticeRepositoryProvider = Provider<QuickPracticeRepository>((ref) {
  return QuickPracticeRepositoryImpl();
});

// ─── 1. Top-Level Subjects Notifier ────────────────────────────────────────
class QuickPracticeSubjectsState {
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final List<QuickPracticeSubject> subjects;
  final String searchQuery;

  const QuickPracticeSubjectsState({
    this.isLoading = true,
    this.hasError = false,
    this.errorMessage,
    this.subjects = const [],
    this.searchQuery = '',
  });

  List<QuickPracticeSubject> get filteredSubjects {
    // Only display subjects marked show_app != false and status != false
    var list = subjects.where((s) => s.showApp && s.status).toList();
    if (searchQuery.trim().isEmpty) return list;

    final q = searchQuery.trim().toLowerCase();
    return list.where((s) {
      final name = s.name.toLowerCase();
      final slug = (s.slug ?? '').toLowerCase();
      return name.contains(q) || slug.contains(q);
    }).toList();
  }

  QuickPracticeSubjectsState copyWith({
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    List<QuickPracticeSubject>? subjects,
    String? searchQuery,
  }) {
    return QuickPracticeSubjectsState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      subjects: subjects ?? this.subjects,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class QuickPracticeSubjectsNotifier extends Notifier<QuickPracticeSubjectsState> {
  final QuickPracticeRepository? _repositoryOverride;

  QuickPracticeSubjectsNotifier({QuickPracticeRepository? repository})
      : _repositoryOverride = repository;

  QuickPracticeRepository get _repository =>
      _repositoryOverride ?? ref.read(quickPracticeRepositoryProvider);

  @override
  QuickPracticeSubjectsState build() {
    Future.microtask(() => fetchSubjects());
    return const QuickPracticeSubjectsState();
  }

  Future<void> fetchSubjects({bool isRefresh = false}) async {
    state = state.copyWith(
      isLoading: !isRefresh && state.subjects.isEmpty,
      hasError: false,
      errorMessage: null,
    );

    try {
      final list = await _repository.getTopLevelSubjects();
      state = state.copyWith(
        isLoading: false,
        hasError: false,
        subjects: list,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'বিষয়সমূহ লোড করা সম্ভব হয়নি। পুনরায় চেষ্টা করুন।',
      );
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }
}

final quickPracticeSubjectsNotifierProvider =
    NotifierProvider<QuickPracticeSubjectsNotifier, QuickPracticeSubjectsState>(
  QuickPracticeSubjectsNotifier.new,
);

// ─── 2. Subject Children Notifier ──────────────────────────────────────────
class SubjectChildrenState {
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasError;
  final String? errorMessage;
  final List<SubjectChild> children;
  final PaginationMeta meta;
  final String searchQuery;

  const SubjectChildrenState({
    this.isLoading = true,
    this.isLoadingMore = false,
    this.hasError = false,
    this.errorMessage,
    this.children = const [],
    this.meta = const PaginationMeta(),
    this.searchQuery = '',
  });

  List<SubjectChild> get filteredChildren {
    if (searchQuery.trim().isEmpty) return children;
    final q = searchQuery.trim().toLowerCase();
    return children.where((c) {
      final name = c.name.toLowerCase();
      final slug = (c.slug ?? '').toLowerCase();
      return name.contains(q) || slug.contains(q);
    }).toList();
  }

  SubjectChildrenState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasError,
    String? errorMessage,
    List<SubjectChild>? children,
    PaginationMeta? meta,
    String? searchQuery,
  }) {
    return SubjectChildrenState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      children: children ?? this.children,
      meta: meta ?? this.meta,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class SubjectChildrenNotifier extends Notifier<SubjectChildrenState> {
  final int subjectId;
  final QuickPracticeRepository? _repositoryOverride;

  SubjectChildrenNotifier(this.subjectId, {QuickPracticeRepository? repository})
      : _repositoryOverride = repository;

  QuickPracticeRepository get _repository =>
      _repositoryOverride ?? ref.read(quickPracticeRepositoryProvider);

  @override
  SubjectChildrenState build() {
    Future.microtask(() => fetchChildren());
    return const SubjectChildrenState();
  }

  Timer? _debounceTimer;

  Future<void> fetchChildren({bool isRefresh = false, String? search}) async {
    final query = search ?? state.searchQuery;
    state = state.copyWith(
      isLoading: !isRefresh && state.children.isEmpty,
      hasError: false,
      errorMessage: null,
    );

    try {
      final response = await _repository.getSubjectChildren(
        subjectId,
        page: 1,
        search: query.trim().isNotEmpty ? query.trim() : null,
      );
      state = state.copyWith(
        isLoading: false,
        hasError: false,
        children: response.items,
        meta: response.meta,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'টপিকগুলো লোড করা যায়নি। পুনরায় চেষ্টা করুন।',
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.meta.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.meta.currentPage + 1;
    final query = state.searchQuery.trim();

    try {
      final response = await _repository.getSubjectChildren(
        subjectId,
        page: nextPage,
        search: query.isNotEmpty ? query : null,
      );
      state = state.copyWith(
        isLoadingMore: false,
        children: [...state.children, ...response.items],
        meta: response.meta,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      fetchChildren(search: query);
    });
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    state = state.copyWith(searchQuery: '');
    fetchChildren(search: '');
  }
}

final subjectChildrenNotifierProvider =
    NotifierProvider.family<SubjectChildrenNotifier, SubjectChildrenState, int>(
  SubjectChildrenNotifier.new,
);

// ─── 3. Subject Questions Practice Notifier ────────────────────────────────
class SubjectQuestionsState {
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasError;
  final String? errorMessage;
  final List<PracticeQuestion> questions;
  final PaginationMeta meta;
  final Map<int, dynamic> userAnswers; // questionId -> optionKey
  final Map<int, bool> showExplanations; // questionId -> bool
  final Set<int> bookmarkedQuestionIds;

  const SubjectQuestionsState({
    this.isLoading = true,
    this.isLoadingMore = false,
    this.hasError = false,
    this.errorMessage,
    this.questions = const [],
    this.meta = const PaginationMeta(),
    this.userAnswers = const {},
    this.showExplanations = const {},
    this.bookmarkedQuestionIds = const {},
  });

  SubjectQuestionsState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasError,
    String? errorMessage,
    List<PracticeQuestion>? questions,
    PaginationMeta? meta,
    Map<int, dynamic>? userAnswers,
    Map<int, bool>? showExplanations,
    Set<int>? bookmarkedQuestionIds,
  }) {
    return SubjectQuestionsState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      questions: questions ?? this.questions,
      meta: meta ?? this.meta,
      userAnswers: userAnswers ?? this.userAnswers,
      showExplanations: showExplanations ?? this.showExplanations,
      bookmarkedQuestionIds:
          bookmarkedQuestionIds ?? this.bookmarkedQuestionIds,
    );
  }
}

class SubjectQuestionsNotifier extends Notifier<SubjectQuestionsState> {
  final int subjectId;
  final QuickPracticeRepository? _repositoryOverride;

  SubjectQuestionsNotifier(this.subjectId, {QuickPracticeRepository? repository})
      : _repositoryOverride = repository;

  QuickPracticeRepository get _repository =>
      _repositoryOverride ?? ref.read(quickPracticeRepositoryProvider);

  @override
  SubjectQuestionsState build() {
    Future.microtask(() => fetchQuestions());
    return const SubjectQuestionsState();
  }

  Future<void> fetchQuestions({bool isRefresh = false}) async {
    state = state.copyWith(
      isLoading: !isRefresh && state.questions.isEmpty,
      hasError: false,
      errorMessage: null,
    );

    try {
      final response = await _repository.getSubjectQuestions(subjectId, page: 1);
      state = state.copyWith(
        isLoading: false,
        hasError: false,
        questions: response.items,
        meta: response.meta,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'বর্তমানে কোনো প্রশ্ন পাওয়া যায়নি। শীঘ্রই নতুন প্রশ্ন যুক্ত করা হবে।',
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.meta.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.meta.currentPage + 1;

    try {
      final response =
          await _repository.getSubjectQuestions(subjectId, page: nextPage);
      state = state.copyWith(
        isLoadingMore: false,
        questions: [...state.questions, ...response.items],
        meta: response.meta,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void selectOption(int questionId, dynamic optionKey) {
    // Only allow selection once per question
    if (state.userAnswers.containsKey(questionId)) return;

    final updated = Map<int, dynamic>.from(state.userAnswers);
    updated[questionId] = optionKey;

    state = state.copyWith(userAnswers: updated);
  }

  void toggleExplanation(int questionId) {
    final updated = Map<int, bool>.from(state.showExplanations);
    updated[questionId] = !(updated[questionId] ?? false);
    state = state.copyWith(showExplanations: updated);
  }

  void toggleBookmark(int questionId) {
    final updated = Set<int>.from(state.bookmarkedQuestionIds);
    if (updated.contains(questionId)) {
      updated.remove(questionId);
    } else {
      updated.add(questionId);
    }
    state = state.copyWith(bookmarkedQuestionIds: updated);
  }

  void resetAnswers() {
    state = state.copyWith(
      userAnswers: {},
      showExplanations: {},
    );
  }
}

final subjectQuestionsNotifierProvider = NotifierProvider.family<
    SubjectQuestionsNotifier, SubjectQuestionsState, int>(
  SubjectQuestionsNotifier.new,
);

// ─── 4. Subject Exam Setup / Launch Notifier ───────────────────────────────
class SubjectExamSetupState {
  final bool isStarting;
  final String? errorMessage;
  final SubjectExamSession? session;

  const SubjectExamSetupState({
    this.isStarting = false,
    this.errorMessage,
    this.session,
  });

  SubjectExamSetupState copyWith({
    bool? isStarting,
    String? errorMessage,
    SubjectExamSession? session,
  }) {
    return SubjectExamSetupState(
      isStarting: isStarting ?? this.isStarting,
      errorMessage: errorMessage,
      session: session ?? this.session,
    );
  }
}

class SubjectExamSetupNotifier extends Notifier<SubjectExamSetupState> {
  @override
  SubjectExamSetupState build() => const SubjectExamSetupState();

  Future<SubjectExamSession?> startExam({
    required int subjectId,
    required SubjectStartExamRequest request,
  }) async {
    state = state.copyWith(isStarting: true, errorMessage: null);

    try {
      final repo = ref.read(quickPracticeRepositoryProvider);
      final session = await repo.startSubjectExam(subjectId, request);
      state = state.copyWith(isStarting: false, session: session);
      return session;
    } catch (e) {
      state = state.copyWith(
        isStarting: false,
        errorMessage: 'পরীক্ষা তৈরি করা সম্ভব হয়নি। অনুগ্রহ করে পুনরায় চেষ্টা করুন।',
      );
      return null;
    }
  }
}

final subjectExamSetupNotifierProvider =
    NotifierProvider<SubjectExamSetupNotifier, SubjectExamSetupState>(
  SubjectExamSetupNotifier.new,
);

