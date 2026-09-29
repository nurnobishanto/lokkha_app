import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';
import 'package:lokkha/core/services/storage/my_shared_pref.dart';
import 'package:lokkha/core/network/api_call_status.dart';
import 'package:lokkha/core/network/base_client.dart';
import 'package:lokkha/features/profile/profile.dart';

class OrdersDetailsController extends GetxController {
  RxBool isLoading = true.obs;
  // Data Model
  Rx<OrderDetailsModel> model = OrderDetailsModel().obs;

  // API Call Status
  var apiCallStatus = ApiCallStatus.holding.obs;

  // Fetch Order from API
  Future<void> fetchOrdersDetails({required String url}) async {
    isLoading.value = true;
    apiCallStatus.value = ApiCallStatus.loading;
    String? token = MySharedPref.getUserToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    await BaseClient.safeApiCall(
      url,
      headers: headers,
      RequestType.get,
      onSuccess: (response) {
        if (response.data['status'] == true) {
          model.value = OrderDetailsModel.fromJson(response.data);
          apiCallStatus.value = ApiCallStatus.success;
        } else {
          apiCallStatus.value = ApiCallStatus.error;
          CustomSnackBar.showCustomErrorToast(
              message:
                  response.data['message'] ?? "অর্ডার তথ্য লোড করতে ব্যর্থ");
        }
        isLoading.value = false;
      },
      onError: (error) {
        isLoading.value = false;
        apiCallStatus.value = ApiCallStatus.error;
        debugPrint("MyOrdersDetails API Error: $error");
        CustomSnackBar.showCustomErrorToast(
            message: "সার্ভার সংযোগে সমস্যা হয়েছে");
      },
    );
  }
}
