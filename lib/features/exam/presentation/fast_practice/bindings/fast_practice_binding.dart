import 'package:get/get.dart';

import '../controllers/fast_practice_controller.dart';

class FastPracticeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FastPracticeController>(
      () => FastPracticeController(),
    );
  }
}
