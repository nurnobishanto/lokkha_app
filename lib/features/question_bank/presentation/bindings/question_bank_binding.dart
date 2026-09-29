import 'package:get/get.dart';

import '../controllers/question_bank_controller.dart';

class QuestionBankBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QuestionBankController>(
      () => QuestionBankController(),
    );
  }
}
