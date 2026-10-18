import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/network/rest_client.dart';
import 'package:lokkha/core/services/storage/my_shared_pref.dart';
import 'package:lokkha/features/profile/data/models/my_packages_model.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';

class MyPackagesState {
  final MyPackagesModel model;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;

  const MyPackagesState({
    required this.model,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
  });

  MyPackagesState.initial()
      : model = MyPackagesModel(),
        isLoading = false,
        hasError = false,
        errorMessage = null;

  MyPackagesState copyWith({
    MyPackagesModel? model,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
  }) {
    return MyPackagesState(
      model: model ?? this.model,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class MyPackagesNotifier extends Notifier<MyPackagesState> {
  final RestClient _client;
  bool _disposed = false;

  MyPackagesNotifier({RestClient? client}) : _client = client ?? RestClient();

  @override
  MyPackagesState build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    Future.microtask(() => fetchMyPackages());
    return MyPackagesState(
      model: MyPackagesModel(),
      isLoading: true,
      hasError: false,
    );
  }

  Future<void> fetchMyPackages({bool isRefresh = false}) async {
    if (!isRefresh) {
      state = state.copyWith(isLoading: true, hasError: false, errorMessage: null);
    }
    final token = MySharedPref.getUserToken();
    final url = Endpoints.userPackages; // GET /api/v1/user/packages

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await _client.get(
        url,
        headers: headers,
      );

      if (_disposed) return;

      final data = response.data;
      if (data != null && (data['success'] == true || data['status'] == true)) {
        state = state.copyWith(
          model: MyPackagesModel.fromJson(data),
          isLoading: false,
          hasError: false,
          errorMessage: null,
        );
      } else {
        final message =
            data?['message']?.toString() ?? "প্যাকেজ লোড করতে ব্যর্থ";
        state = state.copyWith(
          isLoading: false,
          hasError: true,
          errorMessage: message,
        );
        CustomSnackBar.showCustomErrorToast(message: message);
      }
    } catch (error) {
      if (_disposed) return;
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: "সার্ভার সংযোগে সমস্যা হয়েছে",
      );
      debugPrint("MyPackages V1 API Error: $error");
      CustomSnackBar.showCustomErrorToast(
        message: "সার্ভার সংযোগে সমস্যা হয়েছে",
      );
    }
  }
}

final myPackagesNotifierProvider =
    NotifierProvider<MyPackagesNotifier, MyPackagesState>(MyPackagesNotifier.new);
