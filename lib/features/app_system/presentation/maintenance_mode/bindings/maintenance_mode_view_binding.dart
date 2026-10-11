import 'package:lokkha/core/compat/get_compat.dart';

import '../controllers/maintenance_mode_view_controller.dart';

class MaintenanceModeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MaintenanceModeController>(
      () => MaintenanceModeController(),
    );
  }
}
