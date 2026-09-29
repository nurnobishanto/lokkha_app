import 'package:get/get.dart';
import 'package:lokkha/features/study_material/study_material.dart';
import 'package:lokkha/core/core.dart';

class SubjectSectionController extends GetxController {
  RxList<SubjectSectionSelect> selectedSubjects = <SubjectSectionSelect>[].obs;

  Future<void> getSubjects() async {
    List<SubjectSectionSelect> fetchedSubjects =
        await MySharedPref.getSubjectSection();
    selectedSubjects.assignAll(fetchedSubjects);
  }

  @override
  void onInit() {
    super.onInit();
    getSubjects();
  }
}
