import 'package:lokkha/core/compat/get_compat.dart';

import '../controllers/fast_practice_controller.dart';

class FastPracticeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FastPracticeController>(
      () => FastPracticeController(),
    );
  }
}
