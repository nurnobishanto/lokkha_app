import 'package:get/get.dart';

import '../controllers/exam_category_details_controller.dart';

class ExamCategoryDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExamCategoryDetailsController>(
      () => ExamCategoryDetailsController(),
    );
  }
}
