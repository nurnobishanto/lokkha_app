import 'package:get/get.dart';

import '../controllers/maintenance_mode_view_controller.dart';

class MaintenanceModeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MaintenanceModeController>(
      () => MaintenanceModeController(),
    );
  }
}
