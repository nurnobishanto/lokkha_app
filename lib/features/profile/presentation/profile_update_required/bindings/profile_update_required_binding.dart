import 'package:get/get.dart';

import '../controllers/profile_update_required_controller.dart';

class ProfileUpdateRequiredBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileUpdateRequiredController>(
      () => ProfileUpdateRequiredController(),
    );
  }
}
