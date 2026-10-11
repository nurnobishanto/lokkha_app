import 'package:lokkha/core/compat/get_compat.dart';

import '../controllers/terms_condition_controller.dart';

class TermsConditionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TermsConditionController>(
      () => TermsConditionController(),
    );
  }
}
