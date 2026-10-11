import 'package:lokkha/core/compat/get_compat.dart';

import '../controllers/auth_gateway_controller.dart';

class AuthGatewayBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthGatewayController>(
      () => AuthGatewayController(),
    );
  }
}
