import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/features/study_material/data/models/current_affairs_v1_models.dart';
import 'package:lokkha/features/study_material/data/repositories/current_affairs_repository.dart';

final currentAffairsRepositoryProvider = Provider<CurrentAffairsRepository>((ref) {
  return CurrentAffairsRepositoryImpl();
});

class CurrentAffairsHubState {
  // Feed state
  final bool isFeedLoading;
  final bool isMoreLoading;
  final List<CurrentAffairsFeedItem> feedItems;
  final List<CurrentAffairsDateGroup> dateGroups;
  final CurrentAffairsPagination pagination;
  final String activeType; // 'all', 'bangladesh', 'international'
  final String searchQuery;
  final String? selectedDate; // YYYY-MM-DD
  final String? selectedMonth; // YYYY-MM
  final int? selectedSubjectId;
  final String sortBy;

  // Monthly Digest state
  final bool isDigestLoading;
  final CurrentAffairsMonthlyDigestResponse? monthlyDigest;
  final String digestFormat; // 'without_options' | 'with_options'
  final String? activeDigestMonth; // e.g. "2026-05"

  // Available archive months
  final bool isMonthsLoading;
  final List<CurrentAffairsMonthItem> availableMonths;

  // Categories & Topic Tree
  final bool isCategoriesLoading;
  final CurrentAffairsCategoriesResponse? categories;

  // Latest Highlights (Top 5 BD + Top 5 Intl)
  final bool isLatestLoading;
  final CurrentAffairsLatestResponse? latest;

  // Single Question Details
  final bool isDetailLoading;
  final CurrentAffairsDetailResponse? questionDetail;

  // Interactive Question Card state
  final Set<int> revealedAnswers;
  final Set<int> expandedExplanations;
  final Map<int, dynamic> userSelectedAnswers; // questionId -> optionKey

  const CurrentAffairsHubState({
    this.isFeedLoading = false,
    this.isMoreLoading = false,
    this.feedItems = const [],
    this.dateGroups = const [],
    this.pagination = const CurrentAffairsPagination(),
    this.activeType = 'bangladesh',
    this.searchQuery = '',
    this.selectedDate,
    this.selectedMonth,
    this.selectedSubjectId,
    this.sortBy = 'date_desc',
    this.isDigestLoading = false,
    this.monthlyDigest,
    this.digestFormat = 'without_options',
    this.activeDigestMonth,
    this.isMonthsLoading = false,
    this.availableMonths = const [],
    this.isCategoriesLoading = false,
    this.categories,
    this.isLatestLoading = false,
    this.latest,
    this.isDetailLoading = false,
    this.questionDetail,
    this.revealedAnswers = const {},
    this.expandedExplanations = const {},
    this.userSelectedAnswers = const {},
  });

  CurrentAffairsHubState copyWith({
    bool? isFeedLoading,
    bool? isMoreLoading,
    List<CurrentAffairsFeedItem>? feedItems,
    List<CurrentAffairsDateGroup>? dateGroups,
    CurrentAffairsPagination? pagination,
    String? activeType,
    String? searchQuery,
    String? selectedDate,
    bool clearSelectedDate = false,
    String? selectedMonth,
    bool clearSelectedMonth = false,
    int? selectedSubjectId,
    bool clearSelectedSubjectId = false,
    String? sortBy,
    bool? isDigestLoading,
    CurrentAffairsMonthlyDigestResponse? monthlyDigest,
    String? digestFormat,
    String? activeDigestMonth,
    bool? isMonthsLoading,
    List<CurrentAffairsMonthItem>? availableMonths,
    bool? isCategoriesLoading,
    CurrentAffairsCategoriesResponse? categories,
    bool? isLatestLoading,
    CurrentAffairsLatestResponse? latest,
    bool? isDetailLoading,
    CurrentAffairsDetailResponse? questionDetail,
    Set<int>? revealedAnswers,
    Set<int>? expandedExplanations,
    Map<int, dynamic>? userSelectedAnswers,
  }) {
    return CurrentAffairsHubState(
      isFeedLoading: isFeedLoading ?? this.isFeedLoading,
      isMoreLoading: isMoreLoading ?? this.isMoreLoading,
      feedItems: feedItems ?? this.feedItems,
      dateGroups: dateGroups ?? this.dateGroups,
      pagination: pagination ?? this.pagination,
      activeType: activeType ?? this.activeType,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedDate: clearSelectedDate
          ? null
          : (selectedDate != null
              ? (selectedDate.trim().isEmpty ? null : selectedDate.trim())
              : this.selectedDate),
      selectedMonth: clearSelectedMonth
          ? null
          : (selectedMonth != null
              ? (selectedMonth.trim().isEmpty ? null : selectedMonth.trim())
              : this.selectedMonth),
      selectedSubjectId: clearSelectedSubjectId
          ? null
          : (selectedSubjectId != null
              ? (selectedSubjectId <= 0 ? null : selectedSubjectId)
              : this.selectedSubjectId),
      sortBy: sortBy ?? this.sortBy,
      isDigestLoading: isDigestLoading ?? this.isDigestLoading,
      monthlyDigest: monthlyDigest ?? this.monthlyDigest,
      digestFormat: digestFormat ?? this.digestFormat,
      activeDigestMonth: activeDigestMonth ?? this.activeDigestMonth,
      isMonthsLoading: isMonthsLoading ?? this.isMonthsLoading,
      availableMonths: availableMonths ?? this.availableMonths,
      isCategoriesLoading: isCategoriesLoading ?? this.isCategoriesLoading,
      categories: categories ?? this.categories,
      isLatestLoading: isLatestLoading ?? this.isLatestLoading,
      latest: latest ?? this.latest,
      isDetailLoading: isDetailLoading ?? this.isDetailLoading,
      questionDetail: questionDetail ?? this.questionDetail,
      revealedAnswers: revealedAnswers ?? this.revealedAnswers,
      expandedExplanations: expandedExplanations ?? this.expandedExplanations,
      userSelectedAnswers: userSelectedAnswers ?? this.userSelectedAnswers,
    );
  }
}

class CurrentAffairsHubNotifier extends Notifier<CurrentAffairsHubState> {
  final CurrentAffairsRepository? _injectedRepository;
  Future<void>? _initFuture;

  CurrentAffairsHubNotifier({CurrentAffairsRepository? repository})
      : _injectedRepository = repository;

  CurrentAffairsRepository get _repository =>
      _injectedRepository ?? ref.read(currentAffairsRepositoryProvider);

  @override
  CurrentAffairsHubState build() {
    Future.microtask(() => init());
    return const CurrentAffairsHubState();
  }

  Future<void> init() {
    _initFuture ??= _doInit();
    return _initFuture!;
  }

  Future<void> _doInit() async {
    await Future.wait([
      fetchFeed(resetPage: true),
      fetchMonths(),
      fetchCategories(),
      fetchLatest(),
      fetchMonthlyDigest(),
    ]);
  }

  /// 1. Fetch paginated Feed
  Future<void> fetchFeed({
    bool resetPage = true,
    String? newType,
    String? newSearch,
    String? newDate,
    bool clearDate = false,
    String? newMonth,
    bool clearMonth = false,
    int? newSubjectId,
    bool clearSubjectId = false,
  }) async {
    final page = resetPage ? 1 : state.pagination.currentPage + 1;
    final type = newType ?? state.activeType;
    final search = newSearch ?? state.searchQuery;

    final String? resolvedDate = clearDate
        ? null
        : (newDate != null
            ? (newDate.trim().isEmpty ? null : newDate.trim())
            : state.selectedDate);

    final String? resolvedMonth = clearMonth
        ? null
        : (newMonth != null
            ? (newMonth.trim().isEmpty ? null : newMonth.trim())
            : state.selectedMonth);

    final int? resolvedSubjectId = clearSubjectId
        ? null
        : (newSubjectId != null
            ? (newSubjectId <= 0 ? null : newSubjectId)
            : state.selectedSubjectId);

    if (resetPage) {
      state = state.copyWith(
        isFeedLoading: true,
        activeType: type,
        searchQuery: search,
        selectedDate: resolvedDate,
        clearSelectedDate: clearDate || resolvedDate == null,
        selectedMonth: resolvedMonth,
        clearSelectedMonth: clearMonth || resolvedMonth == null,
        selectedSubjectId: resolvedSubjectId,
        clearSelectedSubjectId: clearSubjectId || resolvedSubjectId == null,
      );
    } else {
      if (state.isMoreLoading || !state.pagination.hasMore) return;
      state = state.copyWith(isMoreLoading: true);
    }

    try {
      final response = await _repository.getFeed(
        type: type,
        search: search,
        date: resolvedDate,
        month: resolvedMonth,
        subjectId: resolvedSubjectId,
        sortBy: state.sortBy,
        page: page,
        perPage: 20,
      );

      if (response.success || response.items.isNotEmpty || response.groupedByDate.isNotEmpty) {
        if (resetPage) {
          state = state.copyWith(
            isFeedLoading: false,
            feedItems: response.items,
            dateGroups: response.groupedByDate,
            pagination: response.pagination,
          );
        } else {
          // Merge items
          final mergedItems = [...state.feedItems, ...response.items];

          // Merge date groups
          final Map<String, CurrentAffairsDateGroup> groupMap = {};
          for (final g in state.dateGroups) {
            groupMap[g.date] = g;
          }
          for (final g in response.groupedByDate) {
            if (groupMap.containsKey(g.date)) {
              final existing = groupMap[g.date]!;
              final mergedQuestions = [...existing.questions, ...g.questions];
              groupMap[g.date] = existing.copyWith(questions: mergedQuestions);
            } else {
              groupMap[g.date] = g;
            }
          }

          state = state.copyWith(
            isMoreLoading: false,
            feedItems: mergedItems,
            dateGroups: groupMap.values.toList(),
            pagination: response.pagination,
          );
        }
      } else {
        state = state.copyWith(isFeedLoading: false, isMoreLoading: false);
      }
    } catch (e) {
      debugPrint('[CurrentAffairsHubNotifier] fetchFeed error: $e');
      state = state.copyWith(isFeedLoading: false, isMoreLoading: false);
    }
  }

  /// 2. Switch Category Filter (bangladesh, international)
  void setCategoryType(String type) {
    if (state.activeType == type) return;
    state = state.copyWith(
      activeType: type,
      isFeedLoading: true,
      feedItems: const [],
      dateGroups: const [],
      clearSelectedDate: true,
      clearSelectedMonth: true,
    );
    fetchFeed(
      resetPage: true,
      newType: type,
      clearDate: true,
      clearMonth: true,
    );
  }

  /// 3. Filter by exact Date (YYYY-MM-DD)
  void setDateFilter(String? date) {
    if (date == null || date.trim().isEmpty) {
      state = state.copyWith(clearSelectedDate: true);
      fetchFeed(resetPage: true, clearDate: true);
    } else {
      state = state.copyWith(selectedDate: date.trim(), clearSelectedMonth: true);
      fetchFeed(resetPage: true, newDate: date.trim(), clearMonth: true);
    }
  }

  /// 4. Search questions
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    fetchFeed(resetPage: true, newSearch: query);
  }

  /// 5. Filter by Month (YYYY-MM)
  void setMonthFilter(String? month) {
    if (month == null || month.trim().isEmpty) {
      state = state.copyWith(clearSelectedMonth: true);
      fetchFeed(resetPage: true, clearMonth: true);
    } else {
      state = state.copyWith(selectedMonth: month.trim(), clearSelectedDate: true);
      fetchFeed(resetPage: true, newMonth: month.trim(), clearDate: true);
    }
  }

  /// 6. Filter by Subject/Topic ID
  void setSubjectFilter(int? subjectId) {
    if (subjectId == null || subjectId <= 0) {
      state = state.copyWith(clearSelectedSubjectId: true);
      fetchFeed(resetPage: true, clearSubjectId: true);
    } else {
      state = state.copyWith(selectedSubjectId: subjectId);
      fetchFeed(resetPage: true, newSubjectId: subjectId);
    }
  }

  /// Clear all filters (Date, Month, Subject, Search)
  void clearAllFilters() {
    state = state.copyWith(
      clearSelectedDate: true,
      clearSelectedMonth: true,
      clearSelectedSubjectId: true,
      searchQuery: '',
    );
    fetchFeed(
      resetPage: true,
      clearDate: true,
      clearMonth: true,
      clearSubjectId: true,
      newSearch: '',
    );
  }

  /// 7. Fetch Available Archive Months
  Future<void> fetchMonths() async {
    state = state.copyWith(isMonthsLoading: true);
    try {
      final list = await _repository.getMonths();
      state = state.copyWith(
        isMonthsLoading: false,
        availableMonths: list,
      );
    } catch (e) {
      state = state.copyWith(isMonthsLoading: false);
    }
  }

  /// 8. Fetch Categories & Topic Tree
  Future<void> fetchCategories() async {
    state = state.copyWith(isCategoriesLoading: true);
    try {
      final cats = await _repository.getCategories();
      state = state.copyWith(
        isCategoriesLoading: false,
        categories: cats,
      );
    } catch (e) {
      state = state.copyWith(isCategoriesLoading: false);
    }
  }

  /// 9. Fetch Latest Top 5 Highlights
  Future<void> fetchLatest() async {
    state = state.copyWith(isLatestLoading: true);
    try {
      final latestRes = await _repository.getLatest();
      state = state.copyWith(
        isLatestLoading: false,
        latest: latestRes,
      );
    } catch (e) {
      state = state.copyWith(isLatestLoading: false);
    }
  }

  /// 10. Fetch Monthly Digest
  Future<void> fetchMonthlyDigest({
    String? month,
    String? format,
    int? subjectId,
  }) async {
    final activeMonth = month ?? state.activeDigestMonth ?? (state.availableMonths.isNotEmpty ? state.availableMonths.first.month : null);
    final activeFormat = format ?? state.digestFormat;

    state = state.copyWith(
      isDigestLoading: true,
      activeDigestMonth: activeMonth,
      digestFormat: activeFormat,
    );

    try {
      final digest = await _repository.getMonthlyDigest(
        month: activeMonth,
        format: activeFormat,
        subjectId: subjectId,
      );
      state = state.copyWith(
        isDigestLoading: false,
        monthlyDigest: digest,
      );
    } catch (e) {
      state = state.copyWith(isDigestLoading: false);
    }
  }

  /// 11. Fetch Single Question Detail
  Future<void> fetchQuestionDetail(dynamic id) async {
    state = state.copyWith(isDetailLoading: true);
    try {
      final detail = await _repository.getQuestionDetail(id);
      state = state.copyWith(
        isDetailLoading: false,
        questionDetail: detail,
      );
    } catch (e) {
      state = state.copyWith(isDetailLoading: false);
    }
  }

  /// 12. Toggle Bookmark with optimistic update across all views
  Future<bool> toggleBookmark(int questionId) async {
    // Determine new state
    bool currentVal = false;
    for (final item in state.feedItems) {
      if (item.id == questionId) {
        currentVal = item.isBookmarked;
        break;
      }
    }
    final nextVal = !currentVal;

    // Optimistic local update
    _applyBookmarkLocally(questionId, nextVal);

    try {
      final res = await _repository.toggleBookmark(questionId);
      if (res.success) {
        if (res.isBookmarked != nextVal) {
          _applyBookmarkLocally(questionId, res.isBookmarked);
        }
        return res.isBookmarked;
      } else {
        // Rollback
        _applyBookmarkLocally(questionId, currentVal);
        return currentVal;
      }
    } catch (e) {
      _applyBookmarkLocally(questionId, currentVal);
      return currentVal;
    }
  }

  void _applyBookmarkLocally(int questionId, bool isBookmarked) {
    // 1. Update feed items
    final updatedFeed = state.feedItems.map((item) {
      if (item.id == questionId) {
        return item.copyWith(isBookmarked: isBookmarked);
      }
      return item;
    }).toList();

    // 2. Update date groups
    final updatedDateGroups = state.dateGroups.map((group) {
      final updatedQuestions = group.questions.map((q) {
        if (q.id == questionId) {
          return q.copyWith(isBookmarked: isBookmarked);
        }
        return q;
      }).toList();
      return group.copyWith(questions: updatedQuestions);
    }).toList();

    // 3. Update question detail if matches
    CurrentAffairsDetailResponse? updatedDetail = state.questionDetail;
    if (updatedDetail != null && updatedDetail.question?.id == questionId) {
      updatedDetail = CurrentAffairsDetailResponse(
        success: updatedDetail.success,
        message: updatedDetail.message,
        question: updatedDetail.question!.copyWith(isBookmarked: isBookmarked),
        relatedQuestions: updatedDetail.relatedQuestions,
      );
    }

    state = state.copyWith(
      feedItems: updatedFeed,
      dateGroups: updatedDateGroups,
      questionDetail: updatedDetail,
    );
  }

  /// 13. Interactive Option Selection
  void selectOption(int questionId, dynamic key) {
    final updated = Map<int, dynamic>.from(state.userSelectedAnswers);
    updated[questionId] = key;

    final updatedRevealed = Set<int>.from(state.revealedAnswers)..add(questionId);
    state = state.copyWith(
      userSelectedAnswers: updated,
      revealedAnswers: updatedRevealed,
    );
  }

  /// 14. Toggle Reveal Answer
  void toggleRevealAnswer(int questionId) {
    final updated = Set<int>.from(state.revealedAnswers);
    if (updated.contains(questionId)) {
      updated.remove(questionId);
    } else {
      updated.add(questionId);
    }
    state = state.copyWith(revealedAnswers: updated);
  }

  /// 15. Toggle Explanation Expansion
  void toggleExplanation(int questionId) {
    final updated = Set<int>.from(state.expandedExplanations);
    if (updated.contains(questionId)) {
      updated.remove(questionId);
    } else {
      updated.add(questionId);
    }
    state = state.copyWith(expandedExplanations: updated);
  }
}

final currentAffairsHubNotifierProvider =
    NotifierProvider<CurrentAffairsHubNotifier, CurrentAffairsHubState>(
  CurrentAffairsHubNotifier.new,
);
