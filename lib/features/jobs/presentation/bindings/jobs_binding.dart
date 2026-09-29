import 'package:get/get.dart';
import '../controllers/jobs_controller.dart';

class JobsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JobsController>(
      () => JobsController(),
    );
  }
}
