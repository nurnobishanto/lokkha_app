import 'package:get/get.dart';
import '../controllers/contest_history_controller.dart';

class ContestHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ContestHistoryController>(
      () => ContestHistoryController(),
    );
  }
}
