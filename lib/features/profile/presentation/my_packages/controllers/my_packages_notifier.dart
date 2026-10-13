import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/constants/app_constants.dart';
import 'package:lokkha/core/network/rest_client.dart';
import 'package:lokkha/core/services/storage/my_shared_pref.dart';
import 'package:lokkha/features/profile/data/models/my_packages_model.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';

class MyPackagesState {
  final MyPackagesModel model;
  final bool isLoading;
  final bool hasError;

  const MyPackagesState({
    required this.model,
    this.isLoading = false,
    this.hasError = false,
  });

  MyPackagesState.initial()
      : model = MyPackagesModel(),
        isLoading = false,
        hasError = false;

  MyPackagesState copyWith({
    MyPackagesModel? model,
    bool? isLoading,
    bool? hasError,
  }) {
    return MyPackagesState(
      model: model ?? this.model,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
    );
  }
}

class MyPackagesNotifier extends Notifier<MyPackagesState> {
  final RestClient _client;

  MyPackagesNotifier({RestClient? client}) : _client = client ?? RestClient();

  @override
  MyPackagesState build() {
    Future.microtask(() => fetchMyPackages());
    return MyPackagesState(
      model: MyPackagesModel(),
      isLoading: true,
      hasError: false,
    );
  }

  Future<void> fetchMyPackages() async {
    state = state.copyWith(isLoading: true, hasError: false);
    String? token = MySharedPref.getUserToken();
    String url = AppConstants.myPackages;

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await _client.post(
        url,
        headers: headers,
      );
      if (response.data['status'] == true) {
        state = state.copyWith(
          model: MyPackagesModel.fromJson(response.data),
          isLoading: false,
          hasError: false,
        );
      } else {
        state = state.copyWith(isLoading: false, hasError: true);
        CustomSnackBar.showCustomErrorToast(
          message: response.data['message'] ?? "প্যাকেজ লোড করতে ব্যর্থ",
        );
      }
    } catch (error) {
      state = state.copyWith(isLoading: false, hasError: true);
      debugPrint("MyPackages API Error: $error");
      CustomSnackBar.showCustomErrorToast(
        message: "সার্ভার সংযোগে সমস্যা হয়েছে",
      );
    }
  }
}

final myPackagesNotifierProvider =
    NotifierProvider<MyPackagesNotifier, MyPackagesState>(MyPackagesNotifier.new);
