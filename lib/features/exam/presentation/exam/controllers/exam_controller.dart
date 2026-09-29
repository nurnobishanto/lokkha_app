import 'package:get/get.dart';
import 'package:lokkha/core/constants/app_constants.dart';
import 'package:lokkha/shared/models/exam.dart';
import 'package:lokkha/core/network/api_call_status.dart';
import 'package:lokkha/shared/shared.dart';

class ExamController extends GetxController {
  final isReadLoading = false.obs;
  final isExamLoading = false.obs;

  // Read Exam
  final apiCallStatus = ApiCallStatus.holding.obs;
  Future<void> fetchExamDetails(Exam exam) async {
    Get.to(() => WebExamView(
          title: exam.name.toString(),
          url: "${AppConstants.webExamRead}/${exam.id}",
        ));
  }

  // Read Exam
  final apiExamCallStatus = ApiCallStatus.holding.obs;
  RxString errorMessage = "".obs;

  Future<void> startExam(Exam exam) async {
    Get.to(() => WebExamView(
          title: exam.name.toString(),
          url: "${AppConstants.webExamStart}/${exam.id}",
        ));
  }
}
