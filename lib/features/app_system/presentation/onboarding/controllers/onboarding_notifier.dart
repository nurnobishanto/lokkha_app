import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/services/storage/my_shared_pref.dart';
import 'package:lokkha/features/app_system/domain/models/onboarding_item.dart';
import 'package:lokkha/features/app_system/domain/usecases/get_onboarding_items_usecase.dart';

class OnboardingState {
  final int currentPage;
  final List<OnboardingItem> items;
  final bool isCompleted;

  const OnboardingState({
    this.currentPage = 0,
    this.items = const [],
    this.isCompleted = false,
  });

  bool get isLastPage => currentPage == (items.isNotEmpty ? items.length - 1 : 2);

  OnboardingState copyWith({
    int? currentPage,
    List<OnboardingItem>? items,
    bool? isCompleted,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      items: items ?? this.items,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class OnboardingNotifier extends Notifier<OnboardingState> {
  late final GetOnboardingItemsUseCase _getItemsUseCase;

  @override
  OnboardingState build() {
    _getItemsUseCase = const GetOnboardingItemsUseCase();
    return OnboardingState(
      currentPage: 0,
      items: _getItemsUseCase(),
      isCompleted: MySharedPref.isOnboardingSeen(),
    );
  }

  void onPageChanged(int index) {
    state = state.copyWith(currentPage: index);
  }

  Future<void> completeOnboarding() async {
    await MySharedPref.setOnboardingSeen(true);
    state = state.copyWith(isCompleted: true);
  }
}

final onboardingNotifierProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
  OnboardingNotifier.new,
);
