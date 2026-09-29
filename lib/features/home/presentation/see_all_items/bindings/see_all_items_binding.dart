import 'package:get/get.dart';

import '../controllers/see_all_items_controller.dart';

class SeeAllItemsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SeeAllItemsController>(
      () => SeeAllItemsController(),
    );
  }
}
