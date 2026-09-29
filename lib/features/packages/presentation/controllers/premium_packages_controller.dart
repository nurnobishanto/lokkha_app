import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lokkha/features/packages/packages.dart';
import 'package:lokkha/core/network/api_call_status.dart';
import 'package:lokkha/core/core.dart';

class PremiumPackagesController extends GetxController {
  RxObjectMixin<PremiumPackageModel> model = PremiumPackageModel().obs;
  ApiCallStatus apiCallStatus = ApiCallStatus.holding;
  final isLoading = true.obs;
  Future<void> fetchPremiumPackage() async {
    isLoading.value = true;
    var url = AppConstants.premiumPackage;
    BaseClient.safeApiCall(url, RequestType.get, onSuccess: (response) {
      apiCallStatus = ApiCallStatus.success;
      if (response.data['status']) {
        isLoading.value = false;
        model.value = PremiumPackageModel.fromJson(response.data);
      }
    }, onError: (error) {
      debugPrint(error.toString());
    });
  }

  @override
  void onInit() {
    fetchPremiumPackage();
    super.onInit();
  }
}
