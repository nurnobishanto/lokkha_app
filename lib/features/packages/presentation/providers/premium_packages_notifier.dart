import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/core.dart';
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
  final RestClient _client;
  bool _disposed = false;

  PremiumPackagesNotifier({RestClient? client})
      : _client = client ?? RestClient();

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

    final queryParams = <String, dynamic>{
      'page': 1,
      'per_page': 15,
      if (search != null && search.isNotEmpty) 'search': search,
      if (isFeatured != null) 'is_featured': isFeatured ? 1 : 0,
      if (isTrial != null) 'is_trial': isTrial ? 1 : 0,
      if (sortBy != null && sortBy.isNotEmpty) 'sort_by': sortBy,
    };

    final token = MySharedPref.getUserToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await _client.get(
        Endpoints.packages,
        queryParameters: queryParams,
        headers: headers,
      );

      if (_disposed) return;

      final data = response.data;
      if (data != null && (data['success'] == true || data['status'] == true)) {
        final model = PremiumPackageModel.fromJson(data);
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
          errorMessage: data?['message']?.toString() ?? 'প্যাকেজ লোড করতে ব্যর্থ',
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

    final queryParams = <String, dynamic>{
      'page': nextPage,
      'per_page': 15,
      if (state.searchQuery != null && state.searchQuery!.isNotEmpty)
        'search': state.searchQuery,
      if (state.isFeaturedFilter != null)
        'is_featured': state.isFeaturedFilter! ? 1 : 0,
      if (state.isTrialFilter != null)
        'is_trial': state.isTrialFilter! ? 1 : 0,
      if (state.sortBy != null && state.sortBy!.isNotEmpty)
        'sort_by': state.sortBy,
    };

    final token = MySharedPref.getUserToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await _client.get(
        Endpoints.packages,
        queryParameters: queryParams,
        headers: headers,
      );

      if (_disposed) return;

      final data = response.data;
      if (data != null && (data['success'] == true || data['status'] == true)) {
        final model = PremiumPackageModel.fromJson(data);
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
