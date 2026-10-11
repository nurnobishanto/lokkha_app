import 'package:lokkha/core/compat/get_compat.dart';
import '../controllers/accuracy_progress_controller.dart';

class AccuracyProgressBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AccuracyProgressController>(
      () => AccuracyProgressController(),
    );
  }
}
