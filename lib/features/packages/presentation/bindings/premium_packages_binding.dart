import 'package:get/get.dart';

import '../controllers/premium_packages_controller.dart';

class PremiumPackagesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PremiumPackagesController>(
      () => PremiumPackagesController(),
    );
  }
}
