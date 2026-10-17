import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/di/about_provider.dart';
import '../../data/models/about_model.dart';
import '../../domain/usecases/get_about_content_usecase.dart';

class AboutState {
  final bool isLoading;
  final bool isRefreshing;
  final AboutDataModel? data;
  final String? errorMessage;

  const AboutState({
    this.isLoading = true,
    this.isRefreshing = false,
    this.data,
    this.errorMessage,
  });

  AboutState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    AboutDataModel? data,
    String? errorMessage,
  }) {
    return AboutState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      data: data ?? this.data,
      errorMessage: errorMessage,
    );
  }
}

class AboutNotifier extends Notifier<AboutState> {
  GetAboutContentUseCase? _getAboutContentUseCase;

  AboutNotifier({GetAboutContentUseCase? getAboutContentUseCase})
      : _getAboutContentUseCase = getAboutContentUseCase;

  @override
  AboutState build() {
    _getAboutContentUseCase ??= ref.watch(getAboutContentUseCaseProvider);
    // Automatically trigger initial fetch
    Future.microtask(() => fetchAboutData());
    return const AboutState(isLoading: true);
  }

  Future<void> fetchAboutData({bool isRefresh = false}) async {
    if (isRefresh) {
      state = state.copyWith(isRefreshing: true, errorMessage: null);
    } else {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }

    try {
      final GetAboutContentUseCase useCase =
          _getAboutContentUseCase ?? ref.read(getAboutContentUseCaseProvider);
      final result = await useCase.call();
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        data: result,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}

final aboutNotifierProvider =
    NotifierProvider<AboutNotifier, AboutState>(() => AboutNotifier());
