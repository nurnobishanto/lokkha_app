import 'package:get/get.dart';

import '../controllers/all_contest_controller.dart';

class AllContestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AllContestController>(
      () => AllContestController(),
    );
  }
}
