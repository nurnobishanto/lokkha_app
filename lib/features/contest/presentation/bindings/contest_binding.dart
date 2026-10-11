import 'package:lokkha/core/compat/get_compat.dart';

import '../controllers/contest_controller.dart';

class ContestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ContestController>(
      () => ContestController(),
    );
  }
}
