import 'package:lokkha/core/compat/get_compat.dart';
import '../controllers/all_contest_controller.dart';
import '../controllers/latest_contest_controller.dart';

class AllContestBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<LatestContestController>()) {
      Get.lazyPut<LatestContestController>(() => LatestContestController());
    }
    if (!Get.isRegistered<AllContestController>()) {
      Get.lazyPut<AllContestController>(() => AllContestController());
    }
  }
}
