import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/shared/shared.dart';
import 'package:lokkha/features/auth/auth.dart';
import 'package:lokkha/features/packages/packages.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/di/network_provider.dart';
import 'package:lokkha/shared/models/package.dart';

class PremiumPackageCheckoutView extends ConsumerStatefulWidget {
  const PremiumPackageCheckoutView({super.key, required this.packagesModel});
  final Package packagesModel;

  @override
  ConsumerState<PremiumPackageCheckoutView> createState() =>
      _PremiumPackageCheckoutViewState();
}

class _PremiumPackageCheckoutViewState
    extends ConsumerState<PremiumPackageCheckoutView> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _mailController;
  late final TextEditingController _couponController;

  bool _isCouponEnabled = false;
  bool _isTermsAccepted = false;
  bool _isApplyingCoupon = false;
  bool _isLoadingPayment = false;

  int _selectedPayment = 0; // 0: bkash, 1: nagad, 2: sslcommerz
  int _discountAmount = -1;
  int _totalAmount = -1;

  @override
  void initState() {
    super.initState();
    final user = myUser;

    _nameController = TextEditingController(text: user.name ?? '');
    _phoneController = TextEditingController(text: user.phone ?? '');
    _mailController = TextEditingController(text: user.email ?? '');
    _couponController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _mailController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  String get _selectedPaymentMethod {
    switch (_selectedPayment) {
      case 0:
        return 'bkash';
      case 1:
        return 'nagad';
      case 2:
        return 'sslcommerz';
      default:
        return 'bkash';
    }
  }

  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) {
      CustomSnackBar.showCustomErrorToast(message: "কুপন কোড লিখুন");
      return;
    }

    setState(() => _isApplyingCoupon = true);
    final token = MySharedPref.getUserToken();
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final data = {
      'coupon_code': code,
      'price': widget.packagesModel.regularPrice.toString(),
    };

    try {
      final response = await ref.read(restClientProvider).post(
        AppConstants.couponApply,
        headers: headers,
        data: data,
      );
      if (!mounted) return;
      final status = response.data["status"];
      final message = response.data["message"]?.toString() ?? '';

      if (status == true) {
        setState(() {
          _isApplyingCoupon = false;
          _discountAmount =
              int.tryParse(response.data["discount"].toString()) ?? -1;
          _totalAmount =
              int.tryParse(response.data["discount_price"].toString()) ?? -1;
        });
        CustomSnackBar.showCustomToast(message: message);
      } else {
        setState(() {
          _isApplyingCoupon = false;
          _discountAmount = -1;
          _totalAmount = -1;
        });
        CustomSnackBar.showCustomErrorToast(message: message);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isApplyingCoupon = false;
        _discountAmount = -1;
        _totalAmount = -1;
      });
      debugPrint("Coupon API error: $error");
      CustomSnackBar.showCustomErrorToast(message: "সার্ভারে সমস্যা হয়েছে");
    }
  }

  void _onToggleCoupon(bool? value) {
    setState(() {
      _isCouponEnabled = value ?? false;
      if (!_isCouponEnabled) {
        _couponController.clear();
        _discountAmount = -1;
        _totalAmount = -1;
      }
    });
  }

  Future<void> _makePayment() async {
    if (!_isTermsAccepted) {
      CustomSnackBar.showCustomErrorToast(
        message: 'Please accept the terms and conditions to proceed.',
      );
      return;
    }

    setState(() => _isLoadingPayment = true);

    final email = _mailController.text.trim();
    final token = MySharedPref.getUserToken();
    final orderPlaceUrl =
        "${AppConstants.packageOrder}/${widget.packagesModel.id}";

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final data = {
      'coupon_code': _couponController.text.trim(),
      'email': email,
      'payment_method': _selectedPaymentMethod,
    };

    try {
      final response = await ref.read(restClientProvider).post(
        orderPlaceUrl,
        data: data,
        headers: headers,
      );
      if (!mounted) return;
      setState(() => _isLoadingPayment = false);

      if (response.data["status"] == true) {
        final checkoutData = PackageCheckoutModel.fromJson(response.data);
        final paymentUrl = checkoutData.paymentUrl.toString();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PaymentWebView(url: paymentUrl),
          ),
        );
      } else {
        CustomSnackBar.showCustomToast(
          title: "Something Went Wrong!",
          message: response.data["message"]?.toString() ?? '',
        );
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoadingPayment = false);
      CustomSnackBar.showCustomErrorToast(
        message: 'পেমেন্ট প্রক্রিয়া সম্পন্ন করা যায়নি।',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuth = isLoggedIn.value;

    if (!isAuth) {
      return const Scaffold(body: AuthGatewayView());
    }

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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5.0),
                Text("পূর্ণ নাম", style: AppTextStyles.heading5),
                const SizedBox(height: 5.0),
                CustomTextField(
                  controller: _nameController,
                  hintText: 'No update Name',
                  readOnly: true,
                ),
                const SizedBox(height: 10.0),
                Text("ফোন নম্বর", style: AppTextStyles.heading5),
                const SizedBox(height: 5.0),
                CustomTextField(
                  controller: _phoneController,
                  hintText: 'No update Phone',
                  readOnly: true,
                ),
                SizedBox(height: 10.0.h),
                Text('ইমেইল', style: AppTextStyles.heading5),
                const SizedBox(height: 5.0),
                CustomTextField(
                  controller: _mailController,
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
                              "${widget.packagesModel.name.toString()}\n${convertDaysToHumanReadable(int.tryParse(widget.packagesModel.duration.toString()) ?? 0)}",
                            ),
                            Text(
                              '৳${widget.packagesModel.regularPrice.toString()}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(),

                        /// Coupon Section
                        Row(
                          children: [
                            const Text(
                              "কুপন কোড",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Checkbox.adaptive(
                              activeColor: LightThemeColors.primaryColor,
                              value: _isCouponEnabled,
                              onChanged: _onToggleCoupon,
                            ),
                          ],
                        ),
                        if (_isCouponEnabled)
                          Column(
                            children: [
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
                                    child: _isApplyingCoupon
                                        ? const Center(
                                            child:
                                                CircularProgressIndicator())
                                        : CustomActionButton(
                                            text: "প্রয়োগ করুন",
                                            onPressed: _applyCoupon,
                                          ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),

                        const Divider(),
                        const SizedBox(height: 10.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "সাব টোটাল",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16.0),
                            ),
                            Text(
                              "৳${widget.packagesModel.regularPrice.toString()}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16.0),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "ডিসকাউন্ট",
                                  style: AppTextStyles.body1
                                      .copyWith(color: Colors.redAccent),
                                ),
                                Text(
                                  "৳${_discountAmount > -1 ? _discountAmount.toString() : widget.packagesModel.discount.toString()}",
                                  style: AppTextStyles.body1
                                      .copyWith(color: Colors.redAccent),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "মোট",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0),
                                ),
                                Text(
                                  "৳${_totalAmount > -1 ? _totalAmount.toString() : widget.packagesModel.discountedPrice.toString()}",
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
                        _buildPaymentMethodCard(
                          assetName:
                              'https://lokkha.com/uploads/files/shares/app/bkash.png',
                          index: 0,
                        ),
                        const SizedBox(height: 10.0),
                        _buildPaymentMethodCard(
                          assetName:
                              'https://lokkha.com/uploads/files/shares/app/nagad.png',
                          index: 1,
                        ),
                        const SizedBox(height: 10.0),
                        _buildPaymentMethodCard(
                          assetName:
                              'https://lokkha.com/uploads/files/shares/app/master_visa_card.png',
                          index: 2,
                        ),
                        const SizedBox(height: 20.0),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: _isTermsAccepted,
                              onChanged: (value) {
                                setState(() {
                                  _isTermsAccepted = value ?? false;
                                });
                              },
                            ),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(color: Colors.black),
                                  children: [
                                    const TextSpan(
                                        text:
                                            "By proceeding, you agree to our "),
                                    TextSpan(
                                      text: "Privacy Policy",
                                      style: const TextStyle(
                                        color: LightThemeColors.primaryColor,
                                        decoration:
                                            TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => BaseWebView(
                                                title: 'Privacy Policy',
                                                url:
                                                    AppConstants.privacyPolicy,
                                              ),
                                            ),
                                          );
                                        },
                                    ),
                                    const TextSpan(text: ", "),
                                    TextSpan(
                                      text: "Terms & Conditions",
                                      style: const TextStyle(
                                        color: LightThemeColors.primaryColor,
                                        decoration:
                                            TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => BaseWebView(
                                                title: 'Terms & Conditions',
                                                url:
                                                    AppConstants.termsPolicy,
                                              ),
                                            ),
                                          );
                                        },
                                    ),
                                    const TextSpan(text: ", and "),
                                    TextSpan(
                                      text: "Refund Policy",
                                      style: const TextStyle(
                                        color: LightThemeColors.primaryColor,
                                        decoration:
                                            TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => BaseWebView(
                                                title: 'Refund Policy',
                                                url: AppConstants
                                                    .refundPolicy,
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

                        const SizedBox(height: 20.0),
                        _isLoadingPayment
                            ? const Center(child: CircularProgressIndicator())
                            : CustomActionButton(
                                onPressed: _makePayment,
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

  Widget _buildPaymentMethodCard({
    required String assetName,
    required int index,
  }) {
    final isSelected = _selectedPayment == index;

    return OutlinedButton(
      onPressed: () {
        setState(() => _selectedPayment = index);
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
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
