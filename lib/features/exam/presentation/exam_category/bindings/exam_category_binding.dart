import 'package:lokkha/core/compat/get_compat.dart';

import '../controllers/exam_category_controller.dart';

class ExamCategoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExamCategoryController>(
      () => ExamCategoryController(),
    );
  }
}
