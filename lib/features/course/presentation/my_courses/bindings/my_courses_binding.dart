import 'package:get/get.dart';

import '../controllers/my_courses_controller.dart';

class MyCoursesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyCoursesController>(
      () => MyCoursesController(),
    );
  }
}
