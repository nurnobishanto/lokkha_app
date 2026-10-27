import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/di/network_provider.dart';
import 'package:lokkha/features/auth/auth.dart';
import 'package:lokkha/features/packages/packages.dart';
import 'package:lokkha/shared/shared.dart';

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

  bool _isTermsAccepted = true; // default true for smoother checkout
  bool _isApplyingCoupon = false;
  bool _isLoadingPayment = false;

  int _selectedPayment = 0; // 0: bkash, 1: nagad, 2: sslcommerz
  int _discountAmount = -1;
  int _totalAmount = -1;

  @override
  void initState() {
    super.initState();
    final user = myUser;

    final initialEmail = (user.email == null ||
            user.email!.trim().toLowerCase() == 'no update mail' ||
            user.email!.trim().toLowerCase() == 'null')
        ? ''
        : user.email!.trim();

    _nameController = TextEditingController(text: user.name ?? '');
    _phoneController = TextEditingController(text: user.phone ?? '');
    _mailController = TextEditingController(text: initialEmail);
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
            Endpoints.couponApply,
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

  Future<void> _makePayment() async {
    if (!_isTermsAccepted) {
      CustomSnackBar.showCustomErrorToast(
        message: 'শর্তাবলী ও নীতিমালা মেনে নিয়ে এগিয়ে যান।',
      );
      return;
    }

    setState(() => _isLoadingPayment = true);

    final email = _mailController.text.trim();
    final token = MySharedPref.getUserToken();
    final orderPlaceUrl =
        "${Endpoints.packageOrder}/${widget.packagesModel.id}";

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
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (_) => PaymentWebView(url: paymentUrl),
          ),
        );
      } else {
        CustomSnackBar.showCustomToast(
          title: "সমস্যা দেখা দিয়েছে!",
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

  String _cleanPrice(dynamic price) {
    if (price == null) return '0';
    var p = price.toString().trim();
    if (p.contains('.')) {
      final val = double.tryParse(p);
      if (val != null) {
        p = val % 1 == 0 ? val.toInt().toString() : val.toStringAsFixed(2);
      }
    }
    return p.isEmpty ? '0' : p;
  }

  @override
  Widget build(BuildContext context) {
    final isAuth = isLoggedIn.value;
    if (!isAuth) {
      return const Scaffold(body: AuthGatewayView());
    }

    // Pricing calculations
    final regPriceStr = _cleanPrice(widget.packagesModel.regularPrice);
    final salePriceStr = _cleanPrice(
        widget.packagesModel.discountedPrice ?? widget.packagesModel.regularPrice);

    final double regVal = double.tryParse(regPriceStr) ?? 0;
    final double saleVal = double.tryParse(salePriceStr) ?? regVal;

    final double finalPayable = _totalAmount > -1
        ? _totalAmount.toDouble()
        : saleVal;

    final double totalDiscount = _totalAmount > -1 && _discountAmount > -1
        ? _discountAmount.toDouble()
        : (regVal > saleVal ? (regVal - saleVal) : 0);

    final finalPayableStr = _cleanPrice(finalPayable);
    final totalDiscountStr = _cleanPrice(totalDiscount);

    // Duration label
    final int durationDays =
        widget.packagesModel.duration ?? widget.packagesModel.durationDays ?? 0;
    final String durationLabel = durationDays > 0
        ? (durationDays == 365
            ? '৩৬৫ দিন (১ বছর)'
            : (durationDays == 180
                ? '১৮০ দিন (৬ মাস)'
                : (widget.packagesModel.formattedDuration ??
                    '$durationDays দিন')))
        : (widget.packagesModel.formattedDuration ?? 'মেয়াদ');

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: const CustomAppBar(
        title: "চেকআউট",
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── 1. Premium Customer Profile Card ────────────────────────
              _buildCompactCustomerStrip(context),

              SizedBox(height: 10.h),

              // ─── 2. Compact Order Summary Card with Intuitive Coupon ─────
              _buildCompactOrderSummary(
                context,
                durationLabel: durationLabel,
                regPriceStr: regPriceStr,
                totalDiscountStr: totalDiscountStr,
                finalPayableStr: finalPayableStr,
                hasDiscount: totalDiscount > 0,
              ),

              SizedBox(height: 10.h),

              // ─── 3. Compact Horizontal Payment Method Selector ───────────
              _buildCompactPaymentSelector(context),

              SizedBox(height: 10.h),

              // ─── 4. Terms and Policies Consent ───────────────────────────
              _buildCompactTerms(context),

              SizedBox(height: 14.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildStickyBottomBar(
        context,
        finalPayableStr: finalPayableStr,
      ),
    );
  }

  // ─── 1. Stylish & Premium Customer Profile Card ──────────────────────────
  Widget _buildUserAvatar(BuildContext context, User user) {
    final rawPath = user.photoUrl ?? user.avatar ?? user.image;
    final fullUrl = Endpoints.resolveUrl(rawPath);

    if (fullUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: fullUrl,
        imageBuilder: (context, imageProvider) => Container(
          width: 38.r,
          height: 38.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: context.primaryColor.withValues(alpha: 0.4),
              width: 1.2,
            ),
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        placeholder: (_, __) => _buildDefaultAvatar(context),
        errorWidget: (_, __, ___) => _buildDefaultAvatar(context),
      );
    }
    return _buildDefaultAvatar(context);
  }

  Widget _buildDefaultAvatar(BuildContext context) {
    return Container(
      width: 38.r,
      height: 38.r,
      decoration: BoxDecoration(
        color: context.primaryColor.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(
          color: context.primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Icon(
        Icons.person_rounded,
        size: 20.sp,
        color: context.primaryColor,
      ),
    );
  }

  Widget _buildCompactCustomerStrip(BuildContext context) {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: context.isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.6),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.25 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Profile Photo/Avatar, Name, Verification badge & Phone chip
          Row(
            children: [
              _buildUserAvatar(context, myUser),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name.isNotEmpty ? name : 'গ্রাহক',
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w800,
                              color: context.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.verified_rounded,
                          size: 13.sp,
                          color: context.primaryColor,
                        ),
                      ],
                    ),
                    SizedBox(height: 1.5.h),
                    Text(
                      'নিবন্ধিত ব্যবহারকারী',
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        color: context.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (phone.isNotEmpty)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.5.h),
                  decoration: BoxDecoration(
                    color: context.isDark
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: context.borderColor.withValues(alpha: 0.5),
                      width: 0.6,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.phone_android_rounded,
                        size: 11.5.sp,
                        color: context.primaryColor,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        phone,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          SizedBox(height: 10.h),
          Divider(
            height: 1,
            thickness: 0.6,
            color: context.borderColor.withValues(alpha: 0.5),
          ),
          SizedBox(height: 8.h),

          // Row 2: Clean full-width email field with hint text only (no outside label)
          Container(
            height: 35.h,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              color: context.isDark
                  ? const Color(0xFF0F172A)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: context.borderColor.withValues(alpha: 0.7),
                width: 0.7,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.email_outlined,
                  size: 13.5.sp,
                  color: context.textMuted,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: TextField(
                    controller: _mailController,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: context.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'ইমেইল এড্রেস লিখুন (ঐচ্ছিক)',
                      hintStyle: TextStyle(
                        fontSize: 11.5.sp,
                        color: context.textMuted,
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── 2. Compact Order Summary Card with Clear Intuitive Coupon ───────────
  Widget _buildCompactOrderSummary(
    BuildContext context, {
    required String durationLabel,
    required String regPriceStr,
    required String totalDiscountStr,
    required String finalPayableStr,
    required bool hasDiscount,
  }) {
    final pkgName = widget.packagesModel.name?.trim().isNotEmpty == true
        ? widget.packagesModel.name!.trim()
        : 'প্রিমিয়াম প্যাকেজ';

    final isCouponApplied = _discountAmount > -1;

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: context.isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.6),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.2 : 0.02),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Package title, duration, and price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        pkgName,
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 1.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: context.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        durationLabel,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: context.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '৳$regPriceStr',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // ─── Intuitive & Easily Understood Coupon Section ────────────────
          if (isCouponApplied)
            // Applied Coupon Success Pill with Cancel Option
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.4),
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 15.sp,
                    color: const Color(0xFF10B981),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'কুপন ছাড় প্রয়োগ হয়েছে (-৳$_discountAmount)',
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF059669),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _couponController.clear();
                        _discountAmount = -1;
                        _totalAmount = -1;
                      });
                    },
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      padding: EdgeInsets.all(2.5.r),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 13.sp,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            // Always-visible, Sleek & Understandable Promo Code Box
            Container(
              height: 38.h,
              padding: EdgeInsets.only(left: 10.w, right: 3.w),
              decoration: BoxDecoration(
                color: context.isDark
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: context.borderColor.withValues(alpha: 0.8),
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.local_offer_outlined,
                    size: 15.sp,
                    color: context.primaryColor,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextField(
                      controller: _couponController,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                      decoration: InputDecoration(
                        hintText: 'কুপন কোড লিখুন',
                        hintStyle: TextStyle(
                          fontSize: 11.5.sp,
                          color: context.textMuted,
                          letterSpacing: 0,
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  SizedBox(
                    height: 32.h,
                    child: ElevatedButton(
                      onPressed: _isApplyingCoupon ? null : _applyCoupon,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                      ),
                      child: _isApplyingCoupon
                          ? SizedBox(
                              width: 12.r,
                              height: 12.r,
                              child: const CircularProgressIndicator(
                                strokeWidth: 1.8,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'প্রয়োগ',
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: 10.h),
          Divider(
            height: 1,
            thickness: 0.6,
            color: context.borderColor.withValues(alpha: 0.5),
          ),
          SizedBox(height: 8.h),

          // Price Breakdown
          _buildSummaryRow(
            label: 'সাবটোটাল',
            value: '৳$regPriceStr',
          ),
          if (hasDiscount) ...[
            SizedBox(height: 4.h),
            _buildSummaryRow(
              label: _discountAmount > -1 ? 'কুপন ছাড়' : 'প্যাকেজ ছাড়',
              value: '-৳$totalDiscountStr',
              valueColor: const Color(0xFFE11D48),
            ),
          ],
          SizedBox(height: 6.h),
          Divider(
            height: 1,
            thickness: 0.6,
            color: context.borderColor.withValues(alpha: 0.5),
          ),
          SizedBox(height: 6.h),
          _buildSummaryRow(
            label: 'সর্বমোট প্রদেয়',
            value: '৳$finalPayableStr',
            valueColor: context.primaryColor,
            isBold: true,
            fontSize: 14.5.sp,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    Color? valueColor,
    bool isBold = false,
    double? fontSize,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize ?? 12.sp,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: isBold ? context.textPrimary : context.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize ?? 12.5.sp,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? context.textPrimary,
          ),
        ),
      ],
    );
  }

  // ─── 3. Clean Logo-Only Payment Method Tiles (No Redundant Text) ──────────
  Widget _buildCompactPaymentSelector(BuildContext context) {
    final methods = [
      {
        'id': 0,
        'logo': 'https://lokkha.com/uploads/files/shares/app/bkash.png',
      },
      {
        'id': 1,
        'logo': 'https://lokkha.com/uploads/files/shares/app/nagad.png',
      },
      {
        'id': 2,
        'logo':
            'https://lokkha.com/uploads/files/shares/app/master_visa_card.png',
      },
    ];

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: context.isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.6),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.2 : 0.02),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 14.sp,
                color: const Color(0xFF10B981),
              ),
              SizedBox(width: 6.w),
              Text(
                'পেমেন্ট মাধ্যম',
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: methods.map((method) {
              final id = method['id'] as int;
              final isSelected = _selectedPayment == id;

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedPayment = id),
                  child: Container(
                    height: 52.h,
                    margin: EdgeInsets.symmetric(horizontal: 3.5.w),
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.primaryColor.withValues(
                              alpha: context.isDark ? 0.16 : 0.06,
                            )
                          : (context.isDark
                              ? const Color(0xFF0F172A).withValues(alpha: 0.5)
                              : const Color(0xFFFAFAFA)),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: isSelected
                            ? context.primaryColor
                            : context.borderColor.withValues(alpha: 0.6),
                        width: isSelected ? 1.6 : 0.8,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: CachedNetworkImage(
                            imageUrl: method['logo'] as String,
                            height: 26.h,
                            fit: BoxFit.contain,
                            placeholder: (_, __) =>
                                const SizedBox.shrink(),
                            errorWidget: (_, __, ___) => Icon(
                              Icons.payment_rounded,
                              size: 20.sp,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(1.5.r),
                              decoration: BoxDecoration(
                                color: context.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check_rounded,
                                size: 10.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─── 4. Compact Terms & Conditions ───────────────────────────────────────
  Widget _buildCompactTerms(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 20.r,
            height: 20.r,
            child: Checkbox(
              value: _isTermsAccepted,
              activeColor: context.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.r),
              ),
              onChanged: (val) =>
                  setState(() => _isTermsAccepted = val ?? false),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 11.sp,
                  color: context.textSecondary,
                  height: 1.3,
                ),
                children: [
                  const TextSpan(text: 'আমি লক্ষ্যের '),
                  TextSpan(
                    text: 'গোপনীয়তা নীতি',
                    style: TextStyle(
                      color: context.primaryColor,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => Navigator.of(context, rootNavigator: true)
                              .push(
                            MaterialPageRoute(
                              builder: (_) => BaseWebView(
                                title: 'Privacy Policy',
                                url: Endpoints.privacyPolicy,
                              ),
                            ),
                          ),
                  ),
                  const TextSpan(text: ', '),
                  TextSpan(
                    text: 'শর্তাবলী',
                    style: TextStyle(
                      color: context.primaryColor,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => Navigator.of(context, rootNavigator: true)
                              .push(
                            MaterialPageRoute(
                              builder: (_) => BaseWebView(
                                title: 'Terms & Conditions',
                                url: Endpoints.termsPolicy,
                              ),
                            ),
                          ),
                  ),
                  const TextSpan(text: ' মেনে নিচ্ছি।'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Sticky Bottom Bar ───────────────────────────────────────────────────
  Widget _buildStickyBottomBar(
    BuildContext context, {
    required String finalPayableStr,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: context.isDark ? const Color(0xFF1E293B) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.35 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: context.borderColor.withValues(alpha: 0.6),
            width: 0.8,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'মোট পরিশোধযোগ্য',
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      color: context.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    '৳$finalPayableStr',
                    style: TextStyle(
                      fontSize: 18.5.sp,
                      fontWeight: FontWeight.w800,
                      color: context.primaryColor,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 44.h,
                child: ElevatedButton(
                  onPressed: _isLoadingPayment ? null : _makePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoadingPayment
                      ? SizedBox(
                          width: 18.r,
                          height: 18.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.lock_rounded, size: 14.sp),
                            SizedBox(width: 6.w),
                            Text(
                              'পেমেন্ট সম্পন্ন করুন',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
