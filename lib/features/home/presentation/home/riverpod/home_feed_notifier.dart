import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/services/storage/app_storage_cache.dart';
import 'package:lokkha/di/home_provider.dart';
import 'package:lokkha/features/home/data/models/home_feed_model.dart';
import 'package:lokkha/features/home/presentation/home/riverpod/home_feed_state.dart';

final homeFeedNotifierProvider =
    NotifierProvider<HomeFeedNotifier, HomeFeedState>(HomeFeedNotifier.new);

class HomeFeedNotifier extends Notifier<HomeFeedState> {
  Timer? _countdownTimer;
  DateTime? _lastFetchStartedAt;

  @override
  HomeFeedState build() {
    ref.onDispose(() {
      _countdownTimer?.cancel();
    });
    return const HomeFeedState();
  }

  void setSliderIndex(int index) {
    if (state.currentSliderIndex != index) {
      state = state.copyWith(currentSliderIndex: index);
    }
  }

  /// Primary fetch for home feed data (Module 23)
  Future<void> fetchHomeFeed({
    bool isRefresh = false,
    String sections = 'all',
    String sliderType = 'app',
  }) async {
    final now = DateTime.now();
    // Avoid duplicate network call if Splash already triggered fetch within last 4 seconds
    if (!isRefresh &&
        _lastFetchStartedAt != null &&
        now.difference(_lastFetchStartedAt!) < const Duration(seconds: 4) &&
        (state.isLoading || state.isRefreshing || state.hasData)) {
      return;
    }
    _lastFetchStartedAt = now;
    if (!state.hasData) {
      try {
        final cached = AppStorageCache.readCache(AppStorageCache.homeFeedCacheKey);
        if (cached is Map<String, dynamic>) {
          final cachedModel = HomeFeedModel.fromJson(cached);
          if (cachedModel.success && cachedModel.data != null) {
            final cachedSeconds =
                cachedModel.data?.contestHub?.activeContest?.countdownSeconds ?? 0;
            state = state.copyWith(
              isLoading: false,
              isRefreshing: true,
              feed: () => cachedModel,
              contestCountdownSeconds: cachedSeconds,
              errorMessage: () => null,
            );
            _startCountdownTimer(cachedSeconds);
          }
        }
      } catch (_) {}
    }

    if (isRefresh || state.hasData) {
      state = state.copyWith(isRefreshing: true, errorMessage: () => null);
    } else {
      state = state.copyWith(isLoading: true, errorMessage: () => null);
    }

    try {
      final useCase = ref.read(getHomeFeedUseCaseProvider);
      final result = await useCase(sections: sections, sliderType: sliderType);

      if (result.success && result.data != null) {
        final activeContest = result.data?.contestHub?.activeContest;
        final seconds = activeContest?.countdownSeconds ?? 0;

        state = state.copyWith(
          isLoading: false,
          isRefreshing: false,
          feed: () => result,
          contestCountdownSeconds: seconds,
          errorMessage: () => null,
        );

        _startCountdownTimer(seconds);
      } else {
        state = state.copyWith(
          isLoading: false,
          isRefreshing: false,
          errorMessage: () =>
              result.message ?? 'হোম ফিড লোড করতে সমস্যা হয়েছে।',
        );
      }
    } catch (e, st) {
      debugPrint('Error fetching home feed: $e\n$st');
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        errorMessage: () => 'সার্ভারের সাথে সংযোগ স্থাপন করা সম্ভব হয়নি।',
      );
    }
  }

  void _startCountdownTimer(int initialSeconds) {
    _countdownTimer?.cancel();
    if (initialSeconds <= 0) return;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.contestCountdownSeconds > 0) {
        state = state.copyWith(
          contestCountdownSeconds: state.contestCountdownSeconds - 1,
        );
      } else {
        timer.cancel();
      }
    });
  }
}
