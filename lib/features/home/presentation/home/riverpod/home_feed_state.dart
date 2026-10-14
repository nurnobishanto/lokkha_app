import 'package:lokkha/features/home/data/models/home_feed_model.dart';

class HomeFeedState {
  final bool isLoading;
  final bool isRefreshing;
  final String? errorMessage;
  final HomeFeedModel? feed;
  final int contestCountdownSeconds;
  final int currentSliderIndex;

  const HomeFeedState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.errorMessage,
    this.feed,
    this.contestCountdownSeconds = 0,
    this.currentSliderIndex = 0,
  });

  bool get hasData => feed?.data != null;
  HomeFeedData? get data => feed?.data;

  /// Returns days, hours, minutes, seconds formatted tuple
  ({int days, int hours, int minutes, int seconds}) get contestCountdownParts {
    final totalSeconds = contestCountdownSeconds > 0 ? contestCountdownSeconds : 0;
    final days = totalSeconds ~/ 86400;
    final hours = (totalSeconds % 86400) ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return (days: days, hours: hours, minutes: minutes, seconds: seconds);
  }

  HomeFeedState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    String? Function()? errorMessage,
    HomeFeedModel? Function()? feed,
    int? contestCountdownSeconds,
    int? currentSliderIndex,
  }) {
    return HomeFeedState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      feed: feed != null ? feed() : this.feed,
      contestCountdownSeconds:
          contestCountdownSeconds ?? this.contestCountdownSeconds,
      currentSliderIndex: currentSliderIndex ?? this.currentSliderIndex,
    );
  }
}
