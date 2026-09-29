import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/constants/app_constants.dart';
import 'package:lokkha/shared/models/tag.dart';
import 'package:lokkha/core/network/base_client.dart';
import 'package:lokkha/shared/shared.dart';
import 'package:lokkha/features/exam/exam.dart';
import 'package:lokkha/core/network/api_call_status.dart';

class LatestExamController extends GetxController {
  RxBool isLoading = true.obs;
  RxBool isLoadingQuestion = false.obs;
  RxInt currentPage = 1.obs;
  RxBool isFavourite = false.obs;
  RxString search = RxString("");
  RxObjectMixin<LatestExamModel> model = LatestExamModel().obs;

  ApiCallStatus apiCallStatus = ApiCallStatus.holding;

  Future<void> fetchLatestExam(
      {int page = 1, String date = '', String search = ''}) async {
    apiCallStatus = ApiCallStatus.loading;
    isLoading.value = true;
    String url =
        "${AppConstants.latestExam}?search=$search&page=$page&date=$date";

    BaseClient.safeApiCall(url, RequestType.get, onSuccess: (response) {
      if (response.data["status"]) {
        LatestExamModel modelData = LatestExamModel.fromJson(response.data);
        if (page > 1 && model.value.latestExams != null) {
          // Merge new data with existing data
          model.value.latestExams!.data!.addAll(modelData.latestExams!.data!);
          apiCallStatus = ApiCallStatus.success;
        } else {
          model.value = modelData;
        }
        currentPage.value = page;
        isLoading.value = false;
      } else {
        isLoading.value = false;
      }
    }, onError: (err) {
      apiCallStatus = ApiCallStatus.error;
    });
  }

  Future<void> fetchTagQuestions(Tag tag, bool isStartExam, int duration,
      String selectedNegativeMark, BuildContext context) async {
    Map<String, dynamic> data = {
      'exam_name': tag.name,
      'negative_mark': 0,
      'is_negative_mark': false,
      'is_set_time': true,
      'type': "random",
      'duration': duration,
      'previous_day_count': 10,
      'tag_id': tag.id,
      'is_exam': isStartExam
    };
    log('xaa: $data');

    Get.to(() => WebExamView(
        title: tag.name.toString(),
        url: AppConstants.webTestExamStart,
        body: data));
  }

  @override
  void onInit() {
    fetchLatestExam();
    super.onInit();
  }
}
