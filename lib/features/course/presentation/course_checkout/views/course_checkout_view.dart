import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/auth/auth.dart';
import 'package:lokkha/features/course/presentation/providers/course_notifier.dart';
import 'package:lokkha/features/packages/presentation/views/payment_webview.dart';
import 'package:lokkha/features/profile/presentation/profile/riverpod/profile_notifier.dart';
import 'package:lokkha/shared/models/course.dart';
import 'package:lokkha/shared/widgets/base_webview.dart';
import 'package:lokkha/shared/widgets/custom_action_button.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';
import 'package:lokkha/shared/widgets/custom_text_field.dart';

class CourseCheckoutView extends ConsumerStatefulWidget {
  final Course course;
  const CourseCheckoutView({super.key, required this.course});

  @override
  ConsumerState<CourseCheckoutView> createState() => _CourseCheckoutViewState();
}

class _CourseCheckoutViewState extends ConsumerState<CourseCheckoutView> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _mailController;
  final TextEditingController _couponController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final profileUser = ref.read(profileNotifierProvider).profileDataModel?.user;

    final name = profileUser?.name ?? '';
    final phone = profileUser?.phone ?? '';
    final email = profileUser?.email ?? '';

    _nameController = TextEditingController(text: name);
    _phoneController = TextEditingController(text: phone);
    _mailController = TextEditingController(text: email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _mailController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loggedIn = isLoggedIn.value;
    if (!loggedIn) {
      return const AuthGatewayView();
    }

    final state = ref.watch(courseCheckoutNotifierProvider);
    final notifier = ref.read(courseCheckoutNotifierProvider.notifier);

    final double regularPrice =
        double.tryParse(widget.course.regularPrice.toString()) ?? 0;
    final double salePrice =
        double.tryParse(widget.course.salePrice.toString()) ?? 0;

    final double discountAmount = state.discountAmount > -1
        ? state.discountAmount.toDouble()
        : (regularPrice - salePrice).clamp(0, double.infinity);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(
          "চেকআউট",
          style: AppTextStyles.heading4.copyWith(
            color: LightThemeColors.white,
            fontSize: 20.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: LightThemeColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5.0),
                Text(
                  "পূর্ণ নাম",
                  style: AppTextStyles.heading5.copyWith(color: context.textPrimary),
                ),
                const SizedBox(height: 5.0),
                CustomTextField(
                  controller: _nameController,
                  hintText: 'No update Name',
                  readOnly: true,
                ),
                const SizedBox(height: 10.0),
                Text(
                  "ফোন নম্বর",
                  style: AppTextStyles.heading5.copyWith(color: context.textPrimary),
                ),
                const SizedBox(height: 5.0),
                CustomTextField(
                  controller: _phoneController,
                  hintText: 'No update Phone',
                  readOnly: true,
                ),
                SizedBox(height: 10.0.h),
                Text(
                  'ইমেইল',
                  style: AppTextStyles.heading5.copyWith(color: context.textPrimary),
                ),
                const SizedBox(height: 5.0),
                CustomTextField(
                  controller: _mailController,
                  hintText: 'No update Mail',
                ),
                const SizedBox(height: 10.0),
                Card(
                  color: context.cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    side: BorderSide(color: context.borderColor),
                  ),
                  elevation: context.isDark ? 0 : 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "অর্ডার",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                        Divider(color: context.borderColor),
                        const SizedBox(height: 8.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "${widget.course.title ?? ''}\n${widget.course.duration ?? ""}",
                                style: TextStyle(color: context.textPrimary),
                              ),
                            ),
                            Text(
                              '৳${widget.course.regularPrice.toString()}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Divider(color: context.borderColor),

                        /// coupon
                        Row(
                          children: [
                            Text(
                              "কুপন কোড",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
                              ),
                            ),
                            Checkbox.adaptive(
                              activeColor: LightThemeColors.primaryColor,
                              value: state.isChecked,
                              onChanged: (value) {
                                final check = value ?? false;
                                notifier.setIsChecked(check);
                                if (!check) {
                                  _couponController.clear();
                                }
                              },
                            ),
                          ],
                        ),
                        if (state.isChecked) ...[
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: CustomTextField(
                                  controller: _couponController,
                                  hintText: "কুপন কোড",
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: state.isCouponLoading
                                    ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : CustomActionButton(
                                        text: "প্রয়োগ করুন",
                                        onPressed: () {
                                          final code =
                                              _couponController.text.trim();
                                          if (code.isNotEmpty) {
                                            notifier.couponApply(
                                              code,
                                              widget.course.regularPrice.toString(),
                                            );
                                          } else {
                                            CustomSnackBar.showCustomErrorToast(
                                              message: "কুপন কোড লিখুন",
                                            );
                                          }
                                        },
                                      ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],

                        Divider(color: context.borderColor),
                        const SizedBox(height: 8.00),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "সাব টোটাল",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                                color: context.textPrimary,
                              ),
                            ),
                            Text(
                              "৳${widget.course.regularPrice.toString()}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                                color: context.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10.00),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "ডিসকাউন্ট",
                                  style: AppTextStyles.body1.copyWith(
                                    color: Colors.redAccent,
                                  ),
                                ),
                                Text(
                                  "৳$discountAmount",
                                  style: AppTextStyles.body1.copyWith(
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10.00),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "মোট",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                    color: context.textPrimary,
                                  ),
                                ),
                                Text(
                                  "৳${state.totalAmount > -1 ? state.totalAmount.toString() : widget.course.salePrice.toString()}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                    color: context.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        Divider(color: context.borderColor),
                        const SizedBox(height: 8.0),
                        CustomPaymentCardButton(
                          assetName:
                              'https://lokkha.com/uploads/files/shares/app/bkash.png',
                          isSelected: state.selectedPayment == 0,
                          onTap: () => notifier.setSelectedPayment(0),
                        ),
                        const SizedBox(height: 8.0),
                        CustomPaymentCardButton(
                          assetName:
                              'https://lokkha.com/uploads/files/shares/app/nagad.png',
                          isSelected: state.selectedPayment == 1,
                          onTap: () => notifier.setSelectedPayment(1),
                        ),
                        const SizedBox(height: 8.0),
                        CustomPaymentCardButton(
                          assetName:
                              'https://lokkha.com/uploads/files/shares/app/master_visa_card.png',
                          isSelected: state.selectedPayment == 2,
                          onTap: () => notifier.setSelectedPayment(2),
                        ),
                        const SizedBox(height: 8.0),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: state.isCheckedCondition,
                              onChanged: (value) {
                                notifier.setIsCheckedCondition(value ?? false);
                              },
                            ),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(color: context.textPrimary),
                                  children: [
                                    const TextSpan(
                                      text: "By proceeding, you agree to our ",
                                    ),
                                    TextSpan(
                                      text: "Privacy Policy",
                                      style: TextStyle(
                                        color: LightThemeColors.primaryColor,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => BaseWebView(
                                                title: 'Privacy Policy',
                                                url: AppConstants.privacyPolicy,
                                              ),
                                            ),
                                          );
                                        },
                                    ),
                                    const TextSpan(text: ", "),
                                    TextSpan(
                                      text: "Terms & Conditions",
                                      style: TextStyle(
                                        color: LightThemeColors.primaryColor,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => BaseWebView(
                                                title: 'Terms & Conditions',
                                                url: AppConstants.termsPolicy,
                                              ),
                                            ),
                                          );
                                        },
                                    ),
                                    const TextSpan(text: ", and "),
                                    TextSpan(
                                      text: "Refund Policy",
                                      style: TextStyle(
                                        color: LightThemeColors.primaryColor,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => BaseWebView(
                                                title: 'Refund Policy',
                                                url: AppConstants.refundPolicy,
                                              ),
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

                        const SizedBox(height: 8.0),
                        state.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : CustomActionButton(
                                onPressed: () async {
                                  if (state.isCheckedCondition) {
                                    final courseId = int.tryParse(widget.course.id.toString()) ?? 0;
                                    final paymentUrl = await notifier.makePayment(
                                      id: courseId,
                                      couponCode: _couponController.text.trim(),
                                      email: _mailController.text.trim(),
                                    );
                                    if (paymentUrl != null && mounted) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PaymentWebView(url: paymentUrl),
                                        ),
                                      );
                                    }
                                  } else {
                                    CustomSnackBar.showCustomErrorToast(
                                      message:
                                          'Please accept the terms and conditions to proceed.',
                                    );
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
      ),
    );
  }
}

class CustomPaymentCardButton extends StatelessWidget {
  final String assetName;
  final bool isSelected;
  final VoidCallback onTap;

  const CustomPaymentCardButton({
    super.key,
    required this.assetName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        side: BorderSide(
          width: isSelected ? 2.0 : 0.5,
          color: isSelected ? Colors.green : Colors.blue.shade600,
        ),
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
          if (isSelected)
            Positioned(
              top: 5,
              bottom: 5,
              right: 5,
              child: CachedNetworkImage(
                imageUrl:
                    "https://lokkha.com/uploads/files/shares/app/tick-check.png",
                scale: 13,
              ),
            ),
        ],
      ),
    );
  }
}
