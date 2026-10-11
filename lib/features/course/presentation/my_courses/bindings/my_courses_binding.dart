import 'package:lokkha/core/compat/get_compat.dart';

import '../controllers/my_courses_controller.dart';

class MyCoursesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyCoursesController>(
      () => MyCoursesController(),
    );
  }
}
