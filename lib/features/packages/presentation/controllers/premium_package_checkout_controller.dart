import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:lokkha/shared/shared.dart';
import 'package:lokkha/core/network/api_call_status.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/navigation/navigation.dart';
import 'package:lokkha/features/packages/packages.dart';

class PremiumPackageCheckoutController extends GetxController {
  final RxBool isChecked = false.obs;
  final TextEditingController couponController = TextEditingController();
  RxBool isCheckedCondition = false.obs;
  //************************** Text Field Area ******************************* */
  final Rx<TextEditingController> nameController = TextEditingController().obs;
  final Rx<TextEditingController> phoneController = TextEditingController().obs;
  final Rx<TextEditingController> mailController = TextEditingController().obs;
  RxBool isLoading = false.obs;

  //final otp = MySharedPref.getOTPNumber();

  RxObjectMixin<PackageCheckoutModel> dataModel = PackageCheckoutModel().obs;

  Future<void> makePayment(int id) async {
    String email = mailController.value.text.toString().trim();
    String? token = MySharedPref.getUserToken();
    String orderPlaceUrl = "${AppConstants.packageOrder}/$id";

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    // Create a map containing
    Map<String, dynamic> data = {
      'coupon_code': couponController.text,
      'email': email,
      'payment_method': selectedPaymentMethod.value,
    };

    BaseClient.safeApiCall(
      orderPlaceUrl,
      RequestType.post,
      data: data,
      headers: headers,
      onSuccess: (response) {
        if (response.data["status"]) {
          debugPrint("PAYMENT: ${response.data["status"]}");
          isLoading.value = false;
          PackageCheckoutModel data =
              PackageCheckoutModel.fromJson(response.data);
          dataModel.value = data;
          Get.to(PaymentWebView(url: data.paymentUrl.toString()));
        } else {
          isLoading.value = false;
          CustomSnackBar.showCustomToast(
              title: "Something Went Wrong!",
              message: response.data["message"].toString());
        }
      },
    );
  }

  //

  RxInt selectedPayment = 0.obs;
  RxString selectedPaymentMethod = RxString("bkash"); // Default selected index

  void setSelectedPayment(int index) {
    selectedPayment.value = index;
    switch (selectedPayment.value) {
      case 0:
        selectedPaymentMethod.value = "bkash";
        break;
      case 1:
        selectedPaymentMethod.value = "nagad";
        break;
      case 2:
        selectedPaymentMethod.value = "sslcommerz";
        break;
      default:
        selectedPaymentMethod.value = "bkash";
        break;
    }
  }

  /// Apply coupon Method...
  ApiCallStatus apiCallStatus = ApiCallStatus.holding;
  RxString appliedCouponMessage = "".obs;
  RxInt discountAmount = (-1).obs;
  RxInt totalAmount = (-1).obs;
  Future<void> couponApply(
      String couponCode, String price, BuildContext context) async {
    apiCallStatus = ApiCallStatus.loading;
    update();
    String? token = MySharedPref.getUserToken();
    String url = AppConstants.couponApply;
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final data = {
      'coupon_code': couponCode,
      'price': price,
    };

    await BaseClient.safeApiCall(
      url,
      headers: headers,
      RequestType.post,
      data: data,
      onSuccess: (response) {
        final status = response.data["status"];
        final message = response.data["message"];

        if (status == true) {
          apiCallStatus = ApiCallStatus.success;
          appliedCouponMessage.value = message; // Optional
          discountAmount.value =
              int.tryParse(response.data["discount"].toString()) ?? -1;
          totalAmount.value =
              int.tryParse(response.data["discount_price"].toString()) ?? -1;
          CustomSnackBar.showCustomToast(message: message);
        } else {
          apiCallStatus = ApiCallStatus.error;
          appliedCouponMessage.value = "";
          discountAmount.value = -1;
          totalAmount.value = -1;
          CustomSnackBar.showCustomErrorToast(message: message);
        }

        update();
      },
      onError: (error) {
        apiCallStatus = ApiCallStatus.error;
        update();
        debugPrint("Coupon API error: $error");
        CustomSnackBar.showCustomErrorToast(message: "সার্ভারে সমস্যা হয়েছে");
      },
    );
  }

  void updateCoupon() {
    if (!isChecked.value) {
      couponController.clear();
      // status reset
      apiCallStatus = ApiCallStatus.holding;
      // success message- reset
      appliedCouponMessage.value = "";
      discountAmount.value = -1;
      totalAmount.value = -1;
    }
  }

  @override
  void onInit() {
    final profile = Get.find<NavbarController>().profileDataModel.value;
    final user = profile?.user;
    nameController.value.text = user?.name ?? '';
    phoneController.value.text = user?.phone ?? '';
    mailController.value.text = user?.email ?? '';

    // Listen reactively if profile data is loaded later
    if (user == null) {
      once(Get.find<NavbarController>().profileDataModel, (profileData) {
        final u = profileData?.user;
        if (nameController.value.text.isEmpty) {
          nameController.value.text = u?.name ?? '';
        }
        if (phoneController.value.text.isEmpty) {
          phoneController.value.text = u?.phone ?? '';
        }
        if (mailController.value.text.isEmpty) {
          mailController.value.text = u?.email ?? '';
        }
      });
    }

    Get.find<NavbarController>().getMeProfileInfo();
    super.onInit();
  }
}
