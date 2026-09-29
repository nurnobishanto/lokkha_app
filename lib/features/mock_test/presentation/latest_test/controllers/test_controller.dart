import 'package:get/get.dart';
import 'package:lokkha/shared/models/subject_model.dart';
import 'package:lokkha/core/network/api_call_status.dart';

class TestController extends GetxController {
  final Rx<ApiCallStatus> apiCallStatus = ApiCallStatus.holding.obs;
  final Rx<SubjectModel> model = SubjectModel().obs;

  // Future<void> getSubjects() async {
  //   apiCallStatus.value = ApiCallStatus.loading;
  //   debugPrint("Fetching subjects...");
  //   await BaseClient.safeApiCall(
  //     AppConstants.subjects,
  //     RequestType.get,
  //     onSuccess: (response) {
  //       model.value = SubjectModel.fromJson(response.data);
  //       apiCallStatus.value = ApiCallStatus.success;
  //     },
  //     onError: (error) {
  //       apiCallStatus.value = ApiCallStatus.error;
  //       debugPrint("Error fetching subjects: ${error.message}");
  //     },
  //   );
  // }

  @override
  void onReady() {
    //getSubjects();
    super.onReady();
  }
}
