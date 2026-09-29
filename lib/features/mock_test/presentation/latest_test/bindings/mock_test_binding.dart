import 'package:get/get.dart';
import 'package:lokkha/features/mock_test/mock_test.dart';

class MockTestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MockTestController>(
      () => MockTestController(),
    );
  }
}
