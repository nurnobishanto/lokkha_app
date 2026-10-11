import 'package:lokkha/core/compat/get_compat.dart';
import '../controllers/self_exam_history_controller.dart';

class SelfExamHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SelfExamHistoryController>(
      () => SelfExamHistoryController(),
    );
  }
}
