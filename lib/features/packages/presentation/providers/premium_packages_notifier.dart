import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/di/packages_provider.dart';
import 'package:lokkha/features/packages/data/models/premium_package_model.dart';
import 'package:lokkha/shared/models/package.dart';

class PremiumPackagesState {
  final bool isLoading;
  final bool isLoadingMore;
  final List<Package> packages;
  final PremiumPackageModel? model;
  final String? errorMessage;
  final String? searchQuery;
  final bool? isFeaturedFilter;
  final bool? isTrialFilter;
  final String? sortBy;
  final int currentPage;
  final bool hasMore;

  const PremiumPackagesState({
    this.isLoading = true,
    this.isLoadingMore = false,
    this.packages = const [],
    this.model,
    this.errorMessage,
    this.searchQuery,
    this.isFeaturedFilter,
    this.isTrialFilter,
    this.sortBy,
    this.currentPage = 1,
    this.hasMore = false,
  });

  PremiumPackagesState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<Package>? packages,
    PremiumPackageModel? model,
    String? errorMessage,
    String? searchQuery,
    bool? isFeaturedFilter,
    bool? isTrialFilter,
    String? sortBy,
    int? currentPage,
    bool? hasMore,
  }) {
    return PremiumPackagesState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      packages: packages ?? this.packages,
      model: model ?? this.model,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      isFeaturedFilter: isFeaturedFilter ?? this.isFeaturedFilter,
      isTrialFilter: isTrialFilter ?? this.isTrialFilter,
      sortBy: sortBy ?? this.sortBy,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class PremiumPackagesNotifier extends Notifier<PremiumPackagesState> {
  final PackagesRepository? _repository;
  bool _disposed = false;

  PremiumPackagesNotifier({PackagesRepository? repository})
      : _repository = repository;

  PackagesRepository get _repo =>
      _repository ?? ref.read(packagesRepositoryProvider);

  @override
  PremiumPackagesState build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    Future.microtask(() => fetchPremiumPackages());
    return const PremiumPackagesState();
  }

  Future<void> fetchPremiumPackages({
    String? search,
    bool? isFeatured,
    bool? isTrial,
    String? sortBy,
    bool isRefresh = false,
  }) async {
    if (!isRefresh) {
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        searchQuery: search,
        isFeaturedFilter: isFeatured,
        isTrialFilter: isTrial,
        sortBy: sortBy,
      );
    }

    try {
      final model = await _repo.getPremiumPackages(
        page: 1,
        perPage: 15,
        search: search,
        isFeatured: isFeatured,
        isTrial: isTrial,
        sortBy: sortBy,
      );

      if (_disposed) return;

      if (model != null) {
        final meta = model.meta;
        final hasMore = meta != null && meta.currentPage < meta.lastPage;

        state = state.copyWith(
          isLoading: false,
          packages: model.packages,
          model: model,
          currentPage: 1,
          hasMore: hasMore,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'প্যাকেজ লোড করতে ব্যর্থ',
        );
      }
    } catch (error) {
      if (_disposed) return;
      debugPrint("Error fetching V1 packages: $error");
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'সার্ভার সংযোগে সমস্যা হয়েছে',
      );
    }
  }

  Future<void> loadMore() async {
    if (_disposed || state.isLoading || state.isLoadingMore || !state.hasMore) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.currentPage + 1;

    try {
      final model = await _repo.getPremiumPackages(
        page: nextPage,
        perPage: 15,
        search: state.searchQuery,
        isFeatured: state.isFeaturedFilter,
        isTrial: state.isTrialFilter,
        sortBy: state.sortBy,
      );

      if (_disposed) return;

      if (model != null) {
        final meta = model.meta;
        final hasMore = meta != null && meta.currentPage < meta.lastPage;

        final combined = [
          ...state.packages,
          ...model.packages,
        ];

        state = state.copyWith(
          isLoadingMore: false,
          packages: combined,
          currentPage: nextPage,
          hasMore: hasMore,
        );
      } else {
        state = state.copyWith(isLoadingMore: false);
      }
    } catch (error) {
      if (_disposed) return;
      debugPrint("Error loading more V1 packages: $error");
      state = state.copyWith(isLoadingMore: false);
    }
  }
}

final premiumPackagesNotifierProvider =
    NotifierProvider<PremiumPackagesNotifier, PremiumPackagesState>(
  PremiumPackagesNotifier.new,
);
