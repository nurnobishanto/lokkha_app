import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lokkha/features/home/home.dart';
import 'package:lokkha/core/network/api_call_status.dart';
import 'package:lokkha/core/core.dart';

class HomeApiService extends GetxController {
  // Make the models reactive
  final Rx<SliderModel> sliderModel = SliderModel().obs;
  final Rx<SubjectSectionModel> subjectSectionModel = SubjectSectionModel().obs;

  // API call status for both
  final Rx<ApiCallStatus> sliderApiStatus = ApiCallStatus.holding.obs;
  final Rx<ApiCallStatus> subjectSectionApiStatus = ApiCallStatus.holding.obs;

  // Fetch sliders data
  Future<void> fetchSliders() async {
    var url = AppConstants.sliders;
    sliderApiStatus.value = ApiCallStatus.loading;

    await BaseClient.safeApiCall(
      url,
      RequestType.get,
      onSuccess: (response) {
        if (response.data['status']) {
          // Update the slider model here
          sliderModel.value = SliderModel.fromJson(response.data);
          sliderApiStatus.value = ApiCallStatus.success;
        } else {
          sliderApiStatus.value = ApiCallStatus.error;
        }
        update();
      },
      onError: (error) {
        debugPrint("Error: $error");
        sliderApiStatus.value = ApiCallStatus.error;
        update(); // UI update using GetBuilder
      },
      onLoading: () {
        sliderApiStatus.value = ApiCallStatus.loading;
        update(); // UI update using GetBuilder
      },
    );
  }

  // Fetch subject sections data
  Future<void> fetchSubjectSection() async {
    var url = AppConstants.subjectSections;
    subjectSectionApiStatus.value = ApiCallStatus.loading;
    try {
      await BaseClient.safeApiCall(
        url,
        RequestType.get,
        onSuccess: (response) {
          if (response.data['status']) {
            subjectSectionModel.value =
                SubjectSectionModel.fromJson(response.data);
            subjectSectionApiStatus.value = ApiCallStatus.success;
          } else {
            subjectSectionApiStatus.value = ApiCallStatus.error;
          }
          update(); // UI update using GetBuilder
        },
        onError: (_) {
          subjectSectionApiStatus.value = ApiCallStatus.error;
          update(); // UI update using GetBuilder
        },
        onLoading: () {
          subjectSectionApiStatus.value = ApiCallStatus.loading;
          update(); // UI update using GetBuilder
        },
      );
    } catch (e) {
      print(e.toString());
    } finally {}
  }
}
