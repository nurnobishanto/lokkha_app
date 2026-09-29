import 'package:get/get.dart';

import '../controllers/my_packages_controller.dart';

class MyPackagesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyPackagesController>(
      () => MyPackagesController(),
    );
  }
}
