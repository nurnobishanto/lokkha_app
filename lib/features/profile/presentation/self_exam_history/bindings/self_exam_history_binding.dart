import 'package:get/get.dart';
import '../controllers/self_exam_history_controller.dart';

class SelfExamHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SelfExamHistoryController>(
      () => SelfExamHistoryController(),
    );
  }
}
