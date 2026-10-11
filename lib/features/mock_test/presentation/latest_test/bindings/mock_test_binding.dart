import 'package:lokkha/core/compat/get_compat.dart';
import 'package:lokkha/features/mock_test/mock_test.dart';

class MockTestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MockTestController>(
      () => MockTestController(),
    );
  }
}
