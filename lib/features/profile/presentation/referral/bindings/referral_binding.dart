import 'package:lokkha/core/compat/get_compat.dart';
import '../controllers/referral_controller.dart';

class ReferralBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReferralController>(() => ReferralController());
  }
}
