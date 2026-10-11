import 'package:lokkha/core/compat/get_compat.dart';

import '../controllers/courses_controller.dart';

class CoursesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CoursesController>(
      () => CoursesController(),
    );
  }
}
