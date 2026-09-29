import 'package:get/get.dart';
import '../controllers/accuracy_progress_controller.dart';

class AccuracyProgressBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AccuracyProgressController>(
      () => AccuracyProgressController(),
    );
  }
}
