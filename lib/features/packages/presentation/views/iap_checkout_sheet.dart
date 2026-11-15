import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/shared/models/package.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// IapCheckoutSheet
///
/// Fully Apple Review Guideline 3.1.1 compliant checkout modal for iOS.
/// Displays localized StoreKit pricing, duration, feature bullets, Apple Pay / IAP
/// action button, Restore Purchases button, and required Terms & Privacy links.
/// ─────────────────────────────────────────────────────────────────────────────
class IapCheckoutSheet extends StatefulWidget {
  final Package package;

  const IapCheckoutSheet({super.key, required this.package});

  static Future<void> show(BuildContext context, Package package) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => IapCheckoutSheet(package: package),
    );
  }

  @override
  State<IapCheckoutSheet> createState() => _IapCheckoutSheetState();
}

class _IapCheckoutSheetState extends State<IapCheckoutSheet> {
  final InAppPurchaseService _iapService = InAppPurchaseService.instance;
  ProductDetails? _productDetails;
  bool _isLoadingProduct = false;

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
  }

  Future<void> _fetchProductDetails() async {
    _productDetails = _iapService.getProductDetails(widget.package);
    if (_productDetails == null && (Platform.isIOS || Platform.isMacOS)) {
      setState(() => _isLoadingProduct = true);
      await _iapService.loadProductsForPackages([widget.package]);
      if (mounted) {
        setState(() {
          _productDetails = _iapService.getProductDetails(widget.package);
          _isLoadingProduct = false;
        });
      }
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
    final isDark = context.isDark;
    final pkg = widget.package;

    final durationDays = pkg.duration ?? pkg.durationDays ?? 0;
    final durationLabel = durationDays > 0
        ? (durationDays == 365
            ? '৩৬৫ দিন (১ বছর)'
            : (durationDays == 180
                ? '১৮০ দিন (৬ মাস)'
                : (pkg.formattedDuration ?? '$durationDays দিন মেয়াদ')))
        : (pkg.formattedDuration ?? 'মেয়াদ');

    final fallbackPrice = '৳${_cleanPrice(pkg.discountedPrice ?? pkg.regularPrice)}';
    final displayPrice = _productDetails?.price ?? fallbackPrice;

    final features = pkg.featureTexts.isNotEmpty
        ? pkg.featureTexts
        : [
            'সকল বিষয়ের আনলিমিটেড মডেল টেস্ট ও প্র্যাকটিস',
            'প্রতিটি প্রশ্নের নির্ভুল সমাধান ও বিস্তারিত ব্যাখ্যা',
            'লাইভ লিডারবোর্ড ও পূর্ণ মেধা তালিকা যাচাই',
            'ওয়েব ও অ্যাপের সকল প্রিমিয়াম ফিচারে পূর্ণ অ্যাক্সেস',
          ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
      child: SafeArea(
        top: false,
        child: ValueListenableBuilder<bool>(
          valueListenable: _iapService.isPurchasing,
          builder: (context, isPurchasing, child) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 44.w,
                      height: 4.5.h,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Header with Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFF006A4E).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.workspace_premium_rounded,
                          color: Color(0xFF006A4E),
                          size: 26,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pkg.name ?? 'প্রিমিয়াম প্যাকেজ',
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              durationLabel,
                              style: TextStyle(
                                fontSize: 12.5.sp,
                                color: const Color(0xFF006A4E),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Price Tag
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _isLoadingProduct
                              ? SizedBox(
                                  width: 16.w,
                                  height: 16.w,
                                  child: const CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(
                                  displayPrice,
                                  style: TextStyle(
                                    fontSize: 19.sp,
                                    fontWeight: FontWeight.w800,
                                    color: context.textPrimary,
                                  ),
                                ),
                          Text(
                            'App Store প্রাইস',
                            style: TextStyle(
                              fontSize: 9.5.sp,
                              color: context.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),
                  Divider(height: 1, color: context.dividerColor),
                  SizedBox(height: 14.h),

                  // Features Bullet List
                  Text(
                    'প্যাকেজের সুবিধাসমূহ:',
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ...features.map(
                    (f) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 3.5.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 15.sp,
                            color: const Color(0xFF006A4E),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              f,
                              style: TextStyle(
                                fontSize: 12.5.sp,
                                color: context.textSecondary,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 18.h),

                  // Purchase Button
                  SizedBox(
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: isPurchasing
                          ? null
                          : () async {
                              final nav = Navigator.of(context);
                              final success = await _iapService.buyPackage(
                                context: context,
                                package: pkg,
                              );
                              if (success && mounted) {
                                nav.pop();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006A4E),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: isPurchasing
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 18.r,
                                  height: 18.r,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                ValueListenableBuilder<String?>(
                                  valueListenable: _iapService.purchaseStatusMessage,
                                  builder: (_, msg, __) => Text(
                                    msg ?? 'প্রসেস হচ্ছে...',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.apple_rounded, size: 20),
                                SizedBox(width: 6.w),
                                Text(
                                  'Apple দিয়ে কিনুন ($displayPrice)',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  SizedBox(height: 10.h),

                  // Restore Purchases Button (Mandatory for Guideline 3.1.1)
                  Center(
                    child: TextButton.icon(
                      onPressed: () => _iapService.restorePurchases(context),
                      icon: Icon(
                        Icons.restore_rounded,
                        size: 15.sp,
                        color: context.textSecondary,
                      ),
                      label: Text(
                        'পূর্বে কেনা সাবস্ক্রিপশন পুনরুদ্ধার করুন (Restore Purchases)',
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: context.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // Apple Required Terms & Privacy Links
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: context.surfaceSubtle,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: context.borderColor.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'সাবস্ক্রিপশনের অর্থ আপনার Apple ID অ্যাকাউন্টে চার্জ করা হবে। মেয়াদ শেষ হওয়ার ২৪ ঘণ্টার মধ্যে তা রিনিউ হতে পারে। আপনি যেকোনো সময় App Store অ্যাকাউন্ট সেটিংস থেকে এটি বাতিল করতে পারবেন।',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: context.textMuted,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildLegalLink(
                              context,
                              title: 'Privacy Policy',
                              url: Endpoints.privacyPolicy,
                            ),
                            Text(' • ', style: TextStyle(color: context.textMuted, fontSize: 10.sp)),
                            _buildLegalLink(
                              context,
                              title: 'Terms of Use (EULA)',
                              url: 'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/',
                            ),
                            Text(' • ', style: TextStyle(color: context.textMuted, fontSize: 10.sp)),
                            _buildLegalLink(
                              context,
                              title: 'শর্তাবলী',
                              url: Endpoints.termsPolicy,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLegalLink(BuildContext context, {required String title, required String url}) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BaseWebView(
              title: title,
              url: url,
            ),
          ),
        );
      },
      child: Text(
        title,
        style: TextStyle(
          fontSize: 10.5.sp,
          color: const Color(0xFF006A4E),
          decoration: TextDecoration.underline,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
