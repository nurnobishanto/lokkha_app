import 'package:lokkha/core/compat/get_compat.dart';

import '../controllers/latest_exam_controller.dart';

class LatestExamBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LatestExamController>(
      () => LatestExamController(),
    );
  }
}
