import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/network/rest_client.dart';
import 'package:lokkha/core/services/storage/my_shared_pref.dart';
import 'package:lokkha/features/packages/data/models/package_detail_response_model.dart';
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
  final RestClient _client;
  bool _disposed = false;

  PackageDetailsNotifier(this.packageId, {RestClient? client})
      : _client = client ?? RestClient();

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
    final token = MySharedPref.getUserToken();
    final url = Endpoints.packageDetail(id); // GET /api/v1/packages/{id}
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await _client.get(url, headers: headers);
      if (_disposed) return;

      final data = response.data;
      if (data != null && (data['success'] == true || data['status'] == true)) {
        final parsed = PackageDetailResponseModel.fromJson(data);
        if (parsed.package != null) {
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
      } else {
        final msg =
            data?['message']?.toString() ?? "প্যাকেজ লোড করতে সমস্যা হয়েছে";
        state = state.copyWith(
          isLoading: false,
          hasError: true,
          errorMessage: msg,
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
    final token = MySharedPref.getUserToken();
    final url = Endpoints.claimFreeTrial;
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await _client.post(
        url,
        data: {'package_id': id},
        headers: headers,
      );
      if (_disposed) return false;

      state = state.copyWith(isClaimingTrial: false);
      final data = response.data;
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
