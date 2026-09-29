import 'package:get/get.dart';

import '../controllers/auth_gateway_controller.dart';

class AuthGatewayBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthGatewayController>(
      () => AuthGatewayController(),
    );
  }
}
