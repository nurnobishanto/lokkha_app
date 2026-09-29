import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lokkha/shared/models/start_exam_model.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/core/network/api_call_status.dart';
import 'package:lokkha/shared/models/mock_subject_select_model.dart';
import 'package:lokkha/shared/shared.dart';

class MockTestSetTimeController extends GetxController {
  RxBool isNegativeMarkChecked = false.obs;
  RxBool isStartExam = false.obs;
  RxBool isSetTime = false.obs;
  RxBool isChecked = false.obs;
  final RxBool isLoading = false.obs;
  final TextEditingController setTimeCon = TextEditingController();
  final TextEditingController dayController = TextEditingController(text: '15');

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

  ///
  Future<void> testExamStart() async {
    String? token = MySharedPref.getUserToken();
    if (token == '' || token.isEmpty) return;

    final bool isSetTimeValue = isSetTime.value;
    final int durationValue = int.tryParse(setTimeCon.text) ?? 0;
    final int finalDuration =
        isSetTimeValue ? (durationValue < 1 ? 1 : durationValue) : 0;

    Map<String, dynamic> data = {
      'exam_name': 'Mock Test',
      'negative_mark': isNegativeMarkChecked.value ? 0.25 : 0,
      'is_negative_mark': isNegativeMarkChecked.value,
      'is_set_time': isSetTime.value,
      'type': selectedKey.value,
      'duration': finalDuration,
      'is_exam': true,
      'previous_day_count':
          (dayController.text == '' || dayController.text.isEmpty)
              ? 0
              : dayController.text,
      'subjects': selectedSubjects
          .map((subject) => subject.toMap())
          .toList(), // Convert each subject to map
    };

    Get.to(() => WebExamView(
        title: "Subject Wise Exam",
        url: AppConstants.webTestExamStart,
        body: data));
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
