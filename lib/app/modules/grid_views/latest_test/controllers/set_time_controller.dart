import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lokkha/app/models/start_exam_model.dart';
import '../../../../../utils/constants.dart';
import '../../../../data/local/my_shared_pref.dart';
import '../../../../models/mock_subject_select_model.dart';
import '../../../../services/api_call_status.dart';
import '../../../../views/widgets/web_exam_view.dart';

class SetTimeController extends GetxController {
  RxBool isNegativeMarkChecked = false.obs;
  RxBool isStartExam = false.obs;
  RxBool isSetTime = false.obs;
  RxBool isChecked = false.obs;
  final RxBool isLoading = false.obs;
  final TextEditingController setTimeCon = TextEditingController();

  final RxMap<String, String> questionType = {
    "random": "রেনডম প্রশ্ন",
    "unanswered": "উত্তর না দেওয়া প্রশ্ন",
    "answered": "উত্তর দেওয়া প্রশ্ন",
    "wrong": 'ভুল উত্তর দেওয়া প্রশ্ন',
    "corrected": 'সঠিক উত্তর দেওয়া প্রশ্ন',
    "favorite": 'ফেভারিট প্রশ্ন',
  }.obs;

  // RxString to store the selected key (the key will be used for further logic)
  final RxString selectedKey = "random".obs;

  RxString dropdownValue = "random".obs;
  RxList<MockSubjectSelect> selectedSubjects = <MockSubjectSelect>[].obs;

  Future<void> getSubjects() async {
    List<MockSubjectSelect> fetchedSubjects =
        await MySharedPref.getMockSubjects();
    selectedSubjects.assignAll(fetchedSubjects);
  }

  final TextEditingController passwordController = TextEditingController();
  ApiCallStatus apiCallStatus = ApiCallStatus.holding;
  RxObjectMixin model = StartExamModel().obs;

  /// startExam method
  Future<void> startExam() async {
    Map<String, dynamic> data = {
      'negative_mark': 0.25,
      'exam_name': 'Mock Test',
      'is_negative_mark': isNegativeMarkChecked.value,
      'is_set_time': isSetTime.value,
      'type': selectedKey.value,
      'duration': int.tryParse(setTimeCon.text) ?? 0,
      'subjects': selectedSubjects
          .map((subject) => subject.toMap())
          .toList(), // Convert each subject to map
    };

    Get.to(() => WebExamView(
        title: "Exam", url: AppConstants.webTestExamStart, body: data));
  }

  @override
  void onInit() {
    super.onInit();

    getSubjects();
  }

  @override
  void onClose() {
    setTimeCon.dispose();
    super.onClose();
  }
}
