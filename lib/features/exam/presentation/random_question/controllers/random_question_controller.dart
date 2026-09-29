import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/constants/app_constants.dart';

import 'package:lokkha/core/services/storage/my_get_storage.dart';
import 'package:lokkha/core/utils/global.dart';
import 'package:lokkha/core/network/base_client.dart';
import 'package:lokkha/features/exam/exam.dart';

class RandomQuestionController extends GetxController {
  // instance of RandomQuestionModel
  RxObjectMixin<RandomQuestionModel> randomQuestionModel =
      RandomQuestionModel().obs;
  RxBool isLoading = false.obs;
  RxBool randomQuestionPackage = false.obs;
  RxBool isAnswerSelected = false.obs;

  Future<void> getRandomQuestion({bool? forceNew = false}) async {
    isLoading.value = true;
    if (forceNew == true) {
      MyGetStorage.removeCache(MyGetStorage.randomQuestionKey);
    }
    if (forceNew == false &&
        MyGetStorage.getStorage.hasData(MyGetStorage.randomQuestionKey)) {
      var cacheData = MyGetStorage.readCache(MyGetStorage.randomQuestionKey);
      if (cacheData != null) {
        randomQuestionModel.value = RandomQuestionModel.fromJson(cacheData);
        isLoading.value = false;
        return;
      }
    }
    String? deviceID = await getDeviceId();
    if (kDebugMode) {
      print("deviceID:;$deviceID");
    }

    // String? token = MySharedPref.getUserToken();
    // Map<String, String> headers = {
    //   'Authorization': 'Bearer $token',
    // };
    String url =
        "${AppConstants.randomQuestion}?forceNew=$forceNew&deviceID=$deviceID";
    BaseClient.safeApiCall(
      url,
      RequestType.get,
      onSuccess: (response) {
        if (response.data["status"]) {
          RandomQuestionModel data =
              RandomQuestionModel.fromJson(response.data);
          MyGetStorage.writeCacheData(
              MyGetStorage.randomQuestionKey, response.data);
          randomQuestionModel.value = data;
          isLoading.value = false;
          randomQuestionPackage.value = response.data["package_required"];
          debugPrint(
              "Successful load Random Question:${response.data['question']}");
        } else {
          isLoading.value = false;
          randomQuestionPackage.value = response.data["package_required"];
        }
      },
    );
  }

  @override
  void onInit() {
    getRandomQuestion();
    super.onInit();
  }
}
