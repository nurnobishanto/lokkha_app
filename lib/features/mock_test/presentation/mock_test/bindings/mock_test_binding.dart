import 'package:lokkha/core/compat/get_compat.dart';

import '../controllers/mock_test_controller.dart';

class MockTestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MockTestController>(
      () => MockTestController(),
    );
  }
}
