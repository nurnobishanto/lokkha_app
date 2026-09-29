import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/core/network/api_call_status.dart';
import 'package:lokkha/features/course/course.dart';

class SheetDetailsController extends GetxController {
  final apiCallStatus = Rx<ApiCallStatus>(ApiCallStatus.holding);
  final model = Rx<LectureSheetDetailsModel?>(null);

  late final int id;

  @override
  void onInit() {
    super.onInit();
    id = Get.arguments as int;
    fetchSheetDetails(id);
  }

  Future<void> fetchSheetDetails(int id) async {
    apiCallStatus.value = ApiCallStatus.loading;
    final url = "${AppConstants.lectureSheet}/$id";
    await BaseClient.safeApiCall(
      url,
      RequestType.get,
      onSuccess: (dynamic response) {
        final data = response.data;
        if (data['status'] == true) {
          model.value = LectureSheetDetailsModel.fromJson(data);
          apiCallStatus.value = ApiCallStatus.success;
        } else {
          apiCallStatus.value = ApiCallStatus.error;
        }
      },
      onLoading: () {
        apiCallStatus.value = ApiCallStatus.loading;
      },
      onError: (error) {
        apiCallStatus.value = ApiCallStatus.error;
        debugPrint("Error: $error");
      },
    );
  }
}
