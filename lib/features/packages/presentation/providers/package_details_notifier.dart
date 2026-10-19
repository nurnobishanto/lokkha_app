import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/di/packages_provider.dart';
import 'package:lokkha/shared/models/package.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';

class PackageDetailsState {
  final Package? package;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final bool isClaimingTrial;

  const PackageDetailsState({
    this.package,
    this.isLoading = true,
    this.hasError = false,
    this.errorMessage,
    this.isClaimingTrial = false,
  });

  PackageDetailsState copyWith({
    Package? package,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    bool? isClaimingTrial,
  }) {
    return PackageDetailsState(
      package: package ?? this.package,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      isClaimingTrial: isClaimingTrial ?? this.isClaimingTrial,
    );
  }
}

class PackageDetailsNotifier extends Notifier<PackageDetailsState> {
  final int packageId;
  final PackagesRepository? _injectedRepository;
  bool _disposed = false;

  PackageDetailsNotifier(this.packageId, {PackagesRepository? repository})
      : _injectedRepository = repository;


  PackagesRepository get _repo =>
      _injectedRepository ?? ref.read(packagesRepositoryProvider);

  @override
  PackageDetailsState build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    if (packageId > 0) {
      Future.microtask(() => fetchPackageDetails(packageId));
    }
    return const PackageDetailsState(isLoading: true, hasError: false);
  }

  void setInitialPackage(Package? pkg) {
    if (pkg != null && (state.package == null || state.package?.regularPrice == null)) {
      state = state.copyWith(
        package: pkg,
        isLoading: true, // Keep loading true until full details are fetched
        hasError: false,
      );
    }
  }

  Future<void> fetchPackageDetails(int id, {bool isRefresh = false}) async {
    if (!isRefresh) {
      state = state.copyWith(
        isLoading: true,
        hasError: false,
        errorMessage: null,
      );
    }

    try {
      final parsed = await _repo.getPackageDetails(id);
      if (_disposed) return;

      if (parsed != null && parsed.package != null) {
        state = state.copyWith(
          package: parsed.package,
          isLoading: false,
          hasError: false,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          hasError: true,
          errorMessage: "প্যাকেজের তথ্য পাওয়া যায়নি",
        );
      }
    } catch (e) {
      if (_disposed) return;
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: "সার্ভার সংযোগে সমস্যা হয়েছে",
      );
      if (kDebugMode) debugPrint("PackageDetails V1 API Error: $e");
    }
  }

  Future<bool> claimFreeTrial(int id) async {
    state = state.copyWith(isClaimingTrial: true);

    try {
      final data = await _repo.claimFreeTrial(id);
      if (_disposed) return false;

      state = state.copyWith(isClaimingTrial: false);
      if (data != null && (data['success'] == true || data['status'] == true)) {
        CustomSnackBar.showCustomToast(
          message:
              data['message']?.toString() ?? "ফ্রি ট্রায়াল সক্রিয় হয়েছে!",
        );
        fetchPackageDetails(id, isRefresh: true);
        return true;
      } else {
        CustomSnackBar.showCustomErrorToast(
          message:
              data?['message']?.toString() ?? "ট্রায়াল সক্রিয় করতে ব্যর্থ",
        );
        return false;
      }
    } catch (e) {
      if (_disposed) return false;
      state = state.copyWith(isClaimingTrial: false);
      CustomSnackBar.showCustomErrorToast(
        message: "সার্ভার সংযোগে সমস্যা হয়েছে",
      );
      return false;
    }
  }
}

final packageDetailsNotifierProvider = NotifierProvider.autoDispose
    .family<PackageDetailsNotifier, PackageDetailsState, int>(
  (arg) => PackageDetailsNotifier(arg),
);
