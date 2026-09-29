import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lokkha/shared/shared.dart';
import 'package:lokkha/features/auth/auth.dart';
import 'package:lokkha/features/packages/packages.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/shared/models/package.dart';
import 'package:lokkha/core/network/api_call_status.dart';

class PremiumPackageCheckoutView
    extends GetView<PremiumPackageCheckoutController> {
  const PremiumPackageCheckoutView({super.key, required this.packagesModel});
  final Package packagesModel;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PremiumPackageCheckoutController());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "চেকআউট",
          style: AppTextStyles.heading4
              .copyWith(color: LightThemeColors.white, fontSize: 20.0),
        ),
        centerTitle: true,
        backgroundColor: LightThemeColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (isLoggedIn.value) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5.0),
                    Text(
                      "পূর্ণ নাম",
                      style: AppTextStyles.heading5,
                    ),
                    const SizedBox(height: 5.0),
                    CustomTextField(
                      controller: controller.nameController.value,
                      hintText: 'No update Name',
                      readOnly: true,
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      "ফোন নম্বর",
                      style: AppTextStyles.heading5,
                    ),
                    const SizedBox(height: 5.0),
                    CustomTextField(
                      controller: controller.phoneController.value,
                      hintText: 'No update Phone',
                      readOnly: true,
                    ),
                    SizedBox(height: 10.0.h),
                    Text(
                      'ইমেইল',
                      style: AppTextStyles.heading5,
                    ),
                    const SizedBox(height: 5.0),
                    CustomTextField(
                      controller: controller.mailController.value,
                      hintText: 'No update Mail',
                    ),
                    const SizedBox(height: 10.0),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "অর্ডার",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Divider(),
                            const SizedBox(height: 16.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    "${packagesModel.name.toString()}\n${convertDaysToHumanReadable(int.parse(packagesModel.duration.toString()))}"),
                                Text(
                                  '৳${packagesModel.regularPrice.toString()}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const Divider(),

                            /// coupon
                            Row(
                              children: [
                                const Text(
                                  "কুপন কোড",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Checkbox.adaptive(
                                  activeColor: LightThemeColors.primaryColor,
                                  value: controller.isChecked.value,
                                  onChanged: (value) {
                                    controller.isChecked.value = value!;
                                    controller.updateCoupon();
                                  },
                                ),
                              ],
                            ),
                            controller.isChecked.value
                                ? Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: CustomTextField(
                                              controller:
                                                  controller.couponController,
                                              hintText: "কুপন কোড",
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: controller.apiCallStatus ==
                                                    ApiCallStatus.loading
                                                ? const Center(
                                                    child:
                                                        CircularProgressIndicator())
                                                : CustomActionButton(
                                                    text: "প্রয়োগ করুন",
                                                    onPressed: () {
                                                      final code = controller
                                                          .couponController.text
                                                          .trim();
                                                      if (code.isNotEmpty) {
                                                        controller.couponApply(
                                                          code,
                                                          packagesModel
                                                              .regularPrice
                                                              .toString(),
                                                          context,
                                                        );
                                                      } else {
                                                        CustomSnackBar
                                                            .showCustomErrorToast(
                                                                message:
                                                                    "কুপন কোড লিখুন");
                                                      }
                                                    },
                                                  ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  )
                                : const SizedBox.shrink(),

                            const Divider(),
                            const SizedBox(height: 10.00),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "সাব টোটাল",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0),
                                ),
                                Text(
                                  "৳${packagesModel.regularPrice.toString()}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10.00),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "ডিসকাউন্ট",
                                      style: AppTextStyles.body1
                                          .copyWith(color: Colors.redAccent),
                                    ),
                                    Text(
                                      "৳${controller.discountAmount > -1 ? controller.discountAmount.toString() : packagesModel.discount.toString()}",
                                      style: AppTextStyles.body1
                                          .copyWith(color: Colors.redAccent),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10.00),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "মোট",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0),
                                    ),
                                    Text(
                                      "৳${controller.totalAmount > -1 ? controller.totalAmount.toString() : packagesModel.discountedPrice.toString()}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const Divider(),
                            const SizedBox(height: 10.0),
                            const CustomPaymentCardButton(
                                'https://lokkha.com/uploads/files/shares/app/bkash.png',
                                0),
                            const SizedBox(height: 10.0),
                            const CustomPaymentCardButton(
                                'https://lokkha.com/uploads/files/shares/app/nagad.png',
                                1),
                            const SizedBox(height: 10.0),
                            const CustomPaymentCardButton(
                                'https://lokkha.com/uploads/files/shares/app/master_visa_card.png',
                                2),
                            const SizedBox(height: 20.0),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Checkbox(
                                  value: controller.isCheckedCondition.value,
                                  onChanged: (value) {
                                    controller.isCheckedCondition.value =
                                        value!;
                                  },
                                ),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style:
                                          const TextStyle(color: Colors.black),
                                      children: [
                                        const TextSpan(
                                            text:
                                                "By proceeding, you agree to our "),
                                        TextSpan(
                                          text: "Privacy Policy",
                                          style: const TextStyle(
                                            color:
                                                LightThemeColors.primaryColor,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              Get.to(
                                                BaseWebView(
                                                  title: 'Privacy Policy',
                                                  url: AppConstants
                                                      .privacyPolicy,
                                                ),
                                              );
                                            },
                                        ),
                                        const TextSpan(text: ", "),
                                        TextSpan(
                                          text: "Terms & Conditions",
                                          style: const TextStyle(
                                            color:
                                                LightThemeColors.primaryColor,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              Get.to(
                                                BaseWebView(
                                                  title: 'Terms & Conditions',
                                                  url: AppConstants.termsPolicy,
                                                ),
                                              );
                                            },
                                        ),
                                        const TextSpan(text: ", and "),
                                        TextSpan(
                                          text: "Refund Policy",
                                          style: const TextStyle(
                                            color:
                                                LightThemeColors.primaryColor,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              Get.to(
                                                BaseWebView(
                                                  title: 'Refund Policy',
                                                  url:
                                                      AppConstants.refundPolicy,
                                                ),
                                              );
                                            },
                                        ),
                                        const TextSpan(text: "."),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20.0),
                            CustomActionButton(
                              onPressed: () {
                                if (controller.isCheckedCondition.value) {
                                  controller.makePayment(
                                      int.parse(packagesModel.id.toString()));
                                } else {
                                  CustomSnackBar.showCustomErrorToast(
                                      message:
                                          'Please accept the terms and conditions to proceed.');
                                }
                              },
                              text: "পেমেন্ট করুন",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return const AuthGatewayView();
        }
      }),
    );
  }
}

class CustomPaymentCardButton extends StatelessWidget {
  final String assetName;
  final int index;

  const CustomPaymentCardButton(this.assetName, this.index, {super.key});

  @override
  Widget build(BuildContext context) {
    final paymentSelectionController =
        Get.find<PremiumPackageCheckoutController>();

    return Obx(() {
      return OutlinedButton(
        onPressed: () {
          paymentSelectionController.setSelectedPayment(index);
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          side: BorderSide(
              width: (paymentSelectionController.selectedPayment.value == index)
                  ? 2.0
                  : 0.5,
              color: (paymentSelectionController.selectedPayment.value == index)
                  ? Colors.green
                  : Colors.blue.shade600),
        ),
        child: Stack(
          children: [
            Center(
              child: Image.network(
                assetName,
                fit: BoxFit.contain,
                width: 160,
                height: 40,
              ),
            ),
            if (paymentSelectionController.selectedPayment.value == index)
              Positioned(
                  top: 5,
                  bottom: 5,
                  right: 5,
                  child: CachedNetworkImage(
                    imageUrl:
                        "https://lokkha.com/uploads/files/shares/app/tick-check.png",
                    scale: 13,
                  )

                  // Image.network(
                  //  "https://lokkha.com/uploads/files/shares/sadman/tick-check.png",
                  //   width: 20,
                  //   fit: BoxFit.cover,
                  // ),
                  ),
          ],
        ),
      );
    });
  }
}
