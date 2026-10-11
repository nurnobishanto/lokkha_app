import 'package:lokkha/core/compat/get_compat.dart';

import '../controllers/exam_category_details_controller.dart';

class ExamCategoryDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExamCategoryDetailsController>(
      () => ExamCategoryDetailsController(),
    );
  }
}
