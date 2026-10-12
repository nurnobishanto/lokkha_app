import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/constants/app_constants.dart';
import 'package:lokkha/core/enums/api_call_status.dart';
import 'package:lokkha/core/network/rest_client.dart';
import 'package:lokkha/core/services/storage/my_shared_pref.dart';
import 'package:lokkha/features/profile/data/models/my_packages_model.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';

class MyPackagesState {
  final MyPackagesModel model;
  final ApiCallStatus apiCallStatus;

  const MyPackagesState({
    required this.model,
    this.apiCallStatus = ApiCallStatus.holding,
  });

  MyPackagesState.initial()
      : model = MyPackagesModel(),
        apiCallStatus = ApiCallStatus.holding;

  MyPackagesState copyWith({
    MyPackagesModel? model,
    ApiCallStatus? apiCallStatus,
  }) {
    return MyPackagesState(
      model: model ?? this.model,
      apiCallStatus: apiCallStatus ?? this.apiCallStatus,
    );
  }
}

class MyPackagesNotifier extends Notifier<MyPackagesState> {
  @override
  MyPackagesState build() {
    Future.microtask(() => fetchMyPackages());
    return MyPackagesState(
      model: MyPackagesModel(),
      apiCallStatus: ApiCallStatus.loading,
    );
  }

  Future<void> fetchMyPackages() async {
    state = state.copyWith(apiCallStatus: ApiCallStatus.loading);
    String? token = MySharedPref.getUserToken();
    String url = AppConstants.myPackages;

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    await BaseClient.safeApiCall(
      url,
      headers: headers,
      RequestType.post,
      onSuccess: (response) {
        if (response.data['status'] == true) {
          state = state.copyWith(
            model: MyPackagesModel.fromJson(response.data),
            apiCallStatus: ApiCallStatus.success,
          );
        } else {
          state = state.copyWith(apiCallStatus: ApiCallStatus.error);
          CustomSnackBar.showCustomErrorToast(
            message: response.data['message'] ?? "প্যাকেজ লোড করতে ব্যর্থ",
          );
        }
      },
      onError: (error) {
        state = state.copyWith(apiCallStatus: ApiCallStatus.error);
        debugPrint("MyPackages API Error: $error");
        CustomSnackBar.showCustomErrorToast(
          message: "সার্ভার সংযোগে সমস্যা হয়েছে",
        );
      },
    );
  }
}

final myPackagesNotifierProvider =
    NotifierProvider<MyPackagesNotifier, MyPackagesState>(MyPackagesNotifier.new);
