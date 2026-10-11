import 'package:lokkha/core/compat/get_compat.dart';

import '../controllers/premium_packages_controller.dart';

class PremiumPackagesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PremiumPackagesController>(
      () => PremiumPackagesController(),
    );
  }
}
