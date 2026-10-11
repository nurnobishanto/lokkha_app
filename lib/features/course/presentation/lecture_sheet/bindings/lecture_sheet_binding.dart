import 'package:lokkha/core/compat/get_compat.dart';

import '../controllers/lecture_sheet_list_controller.dart';

class LectureSheetBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LectureSheetListController>(
      () => LectureSheetListController(),
    );
  }
}
