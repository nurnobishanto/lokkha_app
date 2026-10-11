import 'package:lokkha/core/compat/get_compat.dart';

import '../controllers/profile_update_required_controller.dart';

class ProfileUpdateRequiredBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileUpdateRequiredController>(
      () => ProfileUpdateRequiredController(),
    );
  }
}
