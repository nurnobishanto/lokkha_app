import 'package:get/get.dart';

import '../controllers/terms_condition_controller.dart';

class TermsConditionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TermsConditionController>(
      () => TermsConditionController(),
    );
  }
}
