import 'package:lokkha/core/compat/get_compat.dart';
import '../controllers/jobs_controller.dart';

class JobsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JobsController>(
      () => JobsController(),
    );
  }
}
