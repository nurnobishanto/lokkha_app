import 'package:lokkha/core/compat/get_compat.dart';

import '../controllers/question_bank_controller.dart';

class QuestionBankBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QuestionBankController>(
      () => QuestionBankController(),
    );
  }
}
