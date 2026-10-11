import 'package:lokkha/core/compat/get_compat.dart';

import '../controllers/my_orders_controller.dart';

class MyOrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyOrdersController>(
      () => MyOrdersController(),
    );
  }
}
