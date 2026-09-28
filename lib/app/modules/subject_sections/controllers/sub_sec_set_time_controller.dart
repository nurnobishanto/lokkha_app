import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lokkha/app/models/start_exam_model.dart';
import 'package:lokkha/app/modules/subject_sections/models/sub_sec_select_model.dart';
import '../../../../../utils/constants.dart';
import '../../../data/local/my_shared_pref.dart';
import '../../../services/api_call_status.dart';
import '../../../views/widgets/web_exam_view.dart';

class SubSecSetTimeController extends GetxController {
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
  RxList<SubjectSectionSelect> selectedSubjects = <SubjectSectionSelect>[].obs;
  //
  Future<void> getSubjects() async {
    List<SubjectSectionSelect> fetchedSubjects =
        await MySharedPref.getSubjectSection();
    selectedSubjects.assignAll(fetchedSubjects);
  }

  final TextEditingController passwordController = TextEditingController();
  ApiCallStatus apiCallStatus = ApiCallStatus.holding;
  RxObjectMixin model = StartExamModel().obs;

  ///  method
  Future<void> testExamStart({bool isExam = true}) async {
    try {
      isLoading.value = true;
      String? token = MySharedPref.getUserToken();
      if (token == '' || token.isEmpty) return;

      final bool isSetTimeValue = isSetTime.value;
      final int durationValue = int.tryParse(setTimeCon.text) ?? 0;
      final int finalDuration =
          isSetTimeValue ? (durationValue < 1 ? 1 : durationValue) : 0;

      Map<String, dynamic> data = {
        'exam_name': 'Question Bank Exam',
        'is_negative_mark': isNegativeMarkChecked.value,
        'negative_mark': isNegativeMarkChecked.value ? 0.25 : 0,
        "is_exam": isExam,
        'is_set_time': isSetTime.value,
        'duration': finalDuration,
        'type': selectedKey.value,

        'subjects': selectedSubjects
            .map((subject) => subject.toMap())
            .toList(), // Convert each subject to map
      };

      Get.to(() => WebExamView(
          title: "Exam", url: AppConstants.webTestExamStart, body: data));
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    getSubjects();
  }
}
