import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/packages/data/models/premium_package_model.dart';
import 'package:lokkha/shared/models/package.dart';

class PremiumPackagesState {
  final bool isLoading;
  final List<Package> packages;
  final String? errorMessage;

  const PremiumPackagesState({
    this.isLoading = true,
    this.packages = const [],
    this.errorMessage,
  });

  PremiumPackagesState copyWith({
    bool? isLoading,
    List<Package>? packages,
    String? errorMessage,
  }) {
    return PremiumPackagesState(
      isLoading: isLoading ?? this.isLoading,
      packages: packages ?? this.packages,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class PremiumPackagesNotifier extends Notifier<PremiumPackagesState> {
  @override
  PremiumPackagesState build() {
    Future.microtask(fetchPremiumPackages);
    return const PremiumPackagesState();
  }

  Future<void> fetchPremiumPackages() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await BaseClient.safeApiCall(
      AppConstants.premiumPackage,
      RequestType.get,
      onSuccess: (response) {
        if (response.data['status'] == true) {
          final model = PremiumPackageModel.fromJson(response.data);
          state = state.copyWith(
            isLoading: false,
            packages: model.packages ?? [],
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            errorMessage: response.data['message']?.toString(),
          );
        }
      },
      onError: (error) {
        debugPrint("Error fetching packages: $error");
        state = state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
        );
      },
    );
  }
}

final premiumPackagesNotifierProvider =
    NotifierProvider<PremiumPackagesNotifier, PremiumPackagesState>(
  PremiumPackagesNotifier.new,
);
