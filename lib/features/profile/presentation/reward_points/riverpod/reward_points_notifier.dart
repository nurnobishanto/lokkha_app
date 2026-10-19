import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/features/profile/data/repositories/reward_points_repository.dart';
import 'package:lokkha/features/quick_practice/data/models/quick_practice_models.dart';

export 'package:lokkha/features/profile/data/models/reward_points_model.dart';

final rewardPointsRepositoryProvider = Provider<RewardPointsRepository>((ref) {
  return RewardPointsRepository();
});

class RewardPointsState {
  final RewardPointsBalance balance;
  final List<RewardTransactionItem> transactions;
  final String currentTab; // 'all', 'earned', 'used'
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasError;
  final String? errorMessage;
  final PaginationMeta meta;

  const RewardPointsState({
    this.balance = const RewardPointsBalance(),
    this.transactions = const [],
    this.currentTab = 'all',
    this.isLoading = true,
    this.isLoadingMore = false,
    this.hasError = false,
    this.errorMessage,
    this.meta = const PaginationMeta(),
  });

  RewardPointsState copyWith({
    RewardPointsBalance? balance,
    List<RewardTransactionItem>? transactions,
    String? currentTab,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasError,
    String? errorMessage,
    PaginationMeta? meta,
  }) {
    return RewardPointsState(
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      currentTab: currentTab ?? this.currentTab,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      meta: meta ?? this.meta,
    );
  }
}

class RewardPointsNotifier extends Notifier<RewardPointsState> {
  final RewardPointsRepository? _repoOverride;

  RewardPointsNotifier({RewardPointsRepository? repository})
      : _repoOverride = repository;

  RewardPointsRepository get _repository =>
      _repoOverride ?? ref.read(rewardPointsRepositoryProvider);

  @override
  RewardPointsState build() {
    Future.microtask(() => loadInitial());
    return const RewardPointsState();
  }

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, hasError: false);
    try {
      final results = await Future.wait([
        _repository.getRewardPoints(),
        _repository.getRewardTransactions(tab: state.currentTab, page: 1),
      ]);

      final balance = results[0] as RewardPointsBalance?;
      final txResponse = results[1] as RewardTransactionsResponse;

      state = state.copyWith(
        isLoading: false,
        hasError: false,
        balance: balance ?? state.balance,
        transactions: txResponse.items,
        meta: txResponse.meta,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'রিওয়ার্ড পয়েন্ট লোড করা সম্ভব হয়নি',
      );
    }
  }

  Future<void> setTab(String tab) async {
    if (state.currentTab == tab && !state.hasError) return;

    state = state.copyWith(
      currentTab: tab,
      isLoading: true,
      hasError: false,
    );

    try {
      final response = await _repository.getRewardTransactions(tab: tab, page: 1);
      state = state.copyWith(
        isLoading: false,
        transactions: response.items,
        meta: response.meta,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refresh() async {
    await loadInitial();
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.meta.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.meta.currentPage + 1;

    try {
      final response = await _repository.getRewardTransactions(
        tab: state.currentTab,
        page: nextPage,
      );

      state = state.copyWith(
        isLoadingMore: false,
        transactions: [...state.transactions, ...response.items],
        meta: response.meta,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }
}

final rewardPointsNotifierProvider =
    NotifierProvider<RewardPointsNotifier, RewardPointsState>(
  RewardPointsNotifier.new,
);
