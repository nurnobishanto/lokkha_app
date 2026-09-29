import 'package:get/get.dart';

import '../controllers/exam_category_controller.dart';

class ExamCategoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExamCategoryController>(
      () => ExamCategoryController(),
    );
  }
}
