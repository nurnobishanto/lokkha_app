import 'package:get/get.dart';

import '../controllers/profile_history_controller.dart';

class ProfileHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileHistoryController>(
      () => ProfileHistoryController(),
    );
  }
}
