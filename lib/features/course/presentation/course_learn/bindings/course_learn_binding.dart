import 'package:get/get.dart';

import '../controllers/course_learn_controller.dart';

class CourseLearnBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>?;

    Get.lazyPut(() => CourseLearnController(
          id: args?['id'] ?? 0,
          itemID: args?['item_id'],
        ));
  }
}
