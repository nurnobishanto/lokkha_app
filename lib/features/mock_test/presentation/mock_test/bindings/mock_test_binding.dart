import 'package:get/get.dart';

import '../controllers/mock_test_controller.dart';

class MockTestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MockTestController>(
      () => MockTestController(),
    );
  }
}
