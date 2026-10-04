import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/network/api_call_status.dart';
import 'package:lokkha/features/profile/data/models/order_v1_model.dart';
import 'package:lokkha/features/profile/domain/usecases/get_order_details_usecase.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';

class OrdersDetailsController extends GetxController {
  final GetOrderDetailsUseCase getOrderDetailsUseCase;

  OrdersDetailsController({GetOrderDetailsUseCase? getOrderDetailsUseCase})
      : getOrderDetailsUseCase =
            getOrderDetailsUseCase ?? GetOrderDetailsUseCase();

  final RxBool isLoading = true.obs;
  final Rx<OrderDetailV1Data?> orderDetail = Rx<OrderDetailV1Data?>(null);
  final Rx<ApiCallStatus> apiCallStatus = ApiCallStatus.holding.obs;

  /// Fetch order details by ID or URL
  Future<void> fetchOrdersDetails({dynamic id, String? url}) async {
    isLoading.value = true;
    apiCallStatus.value = ApiCallStatus.loading;

    try {
      dynamic orderId = id;
      if (orderId == null && url != null && url.isNotEmpty) {
        // Extract numeric ID from URL if provided (e.g. ".../105")
        final uri = Uri.tryParse(url);
        if (uri != null && uri.pathSegments.isNotEmpty) {
          orderId = uri.pathSegments.last;
        } else {
          final match = RegExp(r'\d+').allMatches(url).lastOrNull;
          if (match != null) {
            orderId = match.group(0);
          }
        }
      }

      if (orderId == null) {
        throw Exception('Order ID not provided');
      }

      final data = await getOrderDetailsUseCase(orderId);
      orderDetail.value = data;
      apiCallStatus.value = ApiCallStatus.success;
    } catch (e) {
      debugPrint('[OrdersDetailsController] fetchOrdersDetails error: $e');
      apiCallStatus.value = ApiCallStatus.error;
      CustomSnackBar.showCustomErrorToast(
        message: "অর্ডার তথ্য লোড করতে সমস্যা হয়েছে",
      );
    } finally {
      isLoading.value = false;
    }
  }
}
