import 'package:lokkha/core/compat/get_compat.dart';

import '../controllers/exam_controller.dart';

class ExamBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExamController>(
      () => ExamController(),
    );
  }
}
