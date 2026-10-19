import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/features/auth/auth.dart';
import 'package:lokkha/features/packages/packages.dart';
import 'package:lokkha/shared/models/package.dart';

class PremiumPackagesView extends ConsumerWidget {
  const PremiumPackagesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(premiumPackagesNotifierProvider);

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: const CustomAppBar(
        title: 'প্রিমিয়াম প্যাকেজ',
        centerTitle: true,
      ),
      body: state.isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: context.primaryColor,
              ),
            )
          : RefreshIndicator(
              color: context.primaryColor,
              onRefresh: () => ref
                  .read(premiumPackagesNotifierProvider.notifier)
                  .fetchPremiumPackages(),
              child: state.packages.isEmpty
                  ? _buildEmptyState(context, ref, state.errorMessage)
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 12.h,
                      ),
                      children: [
                        // ─── 1. Hero Pro Banner ──────────────────────────────
                        _buildHeroBanner(context),

                        SizedBox(height: 16.h),

                        // ─── 2. Section Header ───────────────────────────────
                        Text(
                          'প্যাকেজ নির্বাচন করুন',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: context.textPrimary,
                          ),
                        ),

                        SizedBox(height: 10.h),

                        // ─── 3. Package Cards ────────────────────────────────
                        ...state.packages.map((pkg) {
                          return _PackageCard(
                            package: pkg,
                            onTapDetails: () {
                              context.push(
                                Routes.packageDetails,
                                extra: {
                                  'id': pkg.id ?? 0,
                                  'package': pkg,
                                },
                              );
                            },
                            onTapCheckout: () {
                              final isAuth = isLoggedIn.value;
                              if (isAuth) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => PremiumPackageCheckoutView(
                                      packagesModel: pkg,
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const AuthGatewayView(),
                                  ),
                                );
                              }
                            },
                          );
                        }),

                        SizedBox(height: 10.h),

                        // ─── 4. Trust & Security Banner ──────────────────────
                        _buildTrustFooter(context),

                        SizedBox(height: 20.h),
                      ],
                    ),
            ),
    );
  }

  // ─── Hero Banner (Sleek, Clean & Fresh) ──────────────────────────────────
  Widget _buildHeroBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: context.isDark
              ? [const Color(0xFF064E3B), const Color(0xFF022C22)]
              : [const Color(0xFF006A4E), const Color(0xFF047857)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF006A4E).withValues(alpha: 0.16),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 0.8,
              ),
            ),
            child: Icon(
              Icons.workspace_premium_rounded,
              size: 22.sp,
              color: const Color(0xFFFDE047),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'লক্ষ্য প্রো সাবস্ক্রিপশন',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 1.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE047),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        'PRO',
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF004D38),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                Text(
                  'সকল মডেল টেস্ট, বিষয়ভিত্তিক পরীক্ষা ও নির্ভুল ব্যাখ্যা',
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Trust Footer (Clean & Minimal without Subtitles) ─────────────────────
  Widget _buildTrustFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: context.surfaceSubtle,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        children: [
          _buildTrustRow(
            context,
            icon: Icons.security_rounded,
            iconColor: const Color(0xFF0284C7),
            title: '১০০% নিরাপদ পেমেন্ট',
          ),
          SizedBox(height: 8.h),
          Divider(height: 1, thickness: 0.6, color: context.borderColor),
          SizedBox(height: 8.h),
          _buildTrustRow(
            context,
            icon: Icons.bolt_rounded,
            iconColor: const Color(0xFFD97706),
            title: 'তাৎক্ষণিক অ্যাক্টিভেশন',
          ),
          SizedBox(height: 8.h),
          Divider(height: 1, thickness: 0.6, color: context.borderColor),
          SizedBox(height: 8.h),
          _buildTrustRow(
            context,
            icon: Icons.headset_mic_rounded,
            iconColor: const Color(0xFF059669),
            title: 'সার্বক্ষণিক সাপোর্ট',
          ),
        ],
      ),
    );
  }

  Widget _buildTrustRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(5.5.r),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 14.sp, color: iconColor),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Empty / Error State ─────────────────────────────────────────────────
  Widget _buildEmptyState(
    BuildContext context,
    WidgetRef ref,
    String? errorMessage,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: (errorMessage != null
                        ? Colors.redAccent
                        : context.primaryColor)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                errorMessage != null
                    ? Icons.error_outline_rounded
                    : Icons.inventory_2_outlined,
                size: 40.sp,
                color: errorMessage != null
                    ? Colors.redAccent
                    : context.primaryColor,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              errorMessage ?? 'বর্তমানে কোনো প্যাকেজ পাওয়া যায়নি',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: () => ref
                  .read(premiumPackagesNotifierProvider.notifier)
                  .fetchPremiumPackages(),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 9.h),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('পুনরায় চেষ্টা করুন'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Clean Modern Package Card ─────────────────────────────────────────────
class _PackageCard extends StatelessWidget {
  final Package package;
  final VoidCallback onTapDetails;
  final VoidCallback onTapCheckout;

  const _PackageCard({
    required this.package,
    required this.onTapDetails,
    required this.onTapCheckout,
  });

  String _cleanPrice(String? price) {
    if (price == null || price.trim().isEmpty) return '0';
    var p = price.trim();
    if (p.contains('.')) {
      p = p.replaceAll(RegExp(r'\.0+$'), '');
    }
    return p.isEmpty ? '0' : p;
  }

  String _cleanDiscount(String? discount) {
    if (discount == null || discount.trim().isEmpty) return '';
    var d = discount.trim().replaceAll('%', '').replaceAll('-', '').trim();
    if (d.contains('.')) {
      final val = double.tryParse(d);
      if (val != null) {
        d = val.toStringAsFixed(val % 1 == 0 ? 0 : 1);
      }
    }
    return d.isEmpty ? '' : '$d%';
  }

  @override
  Widget build(BuildContext context) {
    final isFemale = package.isFemale == true ||
        (package.name?.contains('অপরাজিতা') ?? false);
    final isFeatured = package.isFeatured == true;
    final isBestValue = (package.duration ?? 0) >= 365 ||
        (double.tryParse(package.discount ?? '0') ?? 0) >= 20;

    final regularPrice = _cleanPrice(package.regularPrice);
    final salePrice = _cleanPrice(package.discountedPrice ?? package.regularPrice);
    final discountStr = _cleanDiscount(package.discount);

    final double? regVal = double.tryParse(regularPrice);
    final double? saleVal = double.tryParse(salePrice);
    final bool hasDiscount =
        regVal != null && saleVal != null && regVal > saleVal && saleVal > 0;

    // Theme Accent Colors
    final Color accentColor = isFemale
        ? const Color(0xFFE11D48) // Rose
        : context.primaryColor; // Emerald

    final Color badgeBgColor = isFemale
        ? (context.isDark ? const Color(0xFF4C0519) : const Color(0xFFFFF1F2))
        : (context.isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5));

    final Color cardBorderColor = isFemale
        ? const Color(0xFFE11D48).withValues(alpha: context.isDark ? 0.35 : 0.25)
        : (isFeatured || isBestValue
            ? context.primaryColor
                .withValues(alpha: context.isDark ? 0.45 : 0.3)
            : context.borderColor);

    // Feature bullet points
    final features = package.featureTexts.isNotEmpty
        ? package.featureTexts
        : [
            'সকল বিষয়ের আনলিমিটেড মডেল টেস্ট ও প্র্যাকটিস',
            'প্রতিটি প্রশ্নের বিস্তারিত নির্ভুল সমাধান ও ব্যাখ্যা',
            'লাইভ লিডারবোর্ড ও বিস্তারিত মেধা তালিকা যাচাই',
          ];

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: cardBorderColor, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: context.isDark ? 0.25 : 0.04,
            ),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTapDetails,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(14.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Header: Badge / Category Pill ──────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: isFemale
                            ? Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 3.h,
                                ),
                                decoration: BoxDecoration(
                                  color: badgeBgColor,
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: const Color(0xFFE11D48)
                                        .withValues(alpha: 0.3),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.auto_awesome_rounded,
                                      size: 11.5.sp,
                                      color: const Color(0xFFE11D48),
                                    ),
                                    SizedBox(width: 4.w),
                                    Flexible(
                                      child: Text(
                                        discountStr.isNotEmpty
                                            ? 'অপরাজিতা স্পেশাল • $discountStr ছাড়'
                                            : 'অপরাজিতা স্পেশাল',
                                        style: TextStyle(
                                          fontSize: 10.5.sp,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFFE11D48),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : (isBestValue || isFeatured)
                                ? Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 3.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: badgeBgColor,
                                      borderRadius: BorderRadius.circular(20.r),
                                      border: Border.all(
                                        color: context.primaryColor
                                            .withValues(alpha: 0.3),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.local_fire_department_rounded,
                                          size: 12.sp,
                                          color: context.primaryColor,
                                        ),
                                        SizedBox(width: 4.w),
                                        Flexible(
                                          child: Text(
                                            discountStr.isNotEmpty
                                                ? 'সেরা ভ্যালু • $discountStr ছাড়'
                                                : 'সেরা ভ্যালু প্যাক',
                                            style: TextStyle(
                                              fontSize: 10.5.sp,
                                              fontWeight: FontWeight.w700,
                                              color: context.primaryColor,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 3.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: context.surfaceSubtle,
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.star_outline_rounded,
                                          size: 12.sp,
                                          color: context.textMuted,
                                        ),
                                        SizedBox(width: 4.w),
                                        Flexible(
                                          child: Text(
                                            'স্ট্যান্ডার্ড প্ল্যান',
                                            style: TextStyle(
                                              fontSize: 10.5.sp,
                                              fontWeight: FontWeight.w600,
                                              color: context.textMuted,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                      ),
                    ),
                    SizedBox(width: 8.w),

                    // Duration Badge Pill
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 11.5.sp,
                            color: accentColor,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            package.duration != null
                                ? '${package.duration} দিন মেয়াদ'
                                : 'মেয়াদ',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10.h),

                // ─── Package Name ────────────────────────────────────────────
                Text(
                  package.name?.trim().isNotEmpty == true
                      ? package.name!
                      : 'প্রো প্যাকেজ',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                    height: 1.25,
                  ),
                ),

                SizedBox(height: 10.h),

                // ─── Key Features (Up to 3 bullets) ──────────────────────────
                ...features.take(3).map((feat) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 6.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 14.5.sp,
                          color: accentColor,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            feat,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: context.textSecondary,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                SizedBox(height: 6.h),
                Divider(
                  height: 16.h,
                  thickness: 0.7,
                  color: context.borderColor.withValues(alpha: 0.7),
                ),

                // ─── Bottom: Price Display & Action Button ───────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Price Block
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6.w,
                            runSpacing: 2.h,
                            children: [
                              Text(
                                '৳$salePrice',
                                style: TextStyle(
                                  fontSize: 19.sp,
                                  fontWeight: FontWeight.w800,
                                  color: context.textPrimary,
                                ),
                              ),
                              if (hasDiscount)
                                Text(
                                  '৳$regularPrice',
                                  style: TextStyle(
                                    fontSize: 11.5.sp,
                                    color: context.textMuted,
                                    decoration: TextDecoration.lineThrough,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                          if (hasDiscount && discountStr.isNotEmpty)
                            Text(
                              '$discountStr সাশ্রয় হচ্ছে',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: isFemale
                                    ? const Color(0xFFE11D48)
                                    : const Color(0xFF059669),
                              ),
                            ),
                        ],
                      ),
                    ),

                    SizedBox(width: 8.w),

                    // Buy Button (Vibrant & Gradient)
                    InkWell(
                      onTap: onTapCheckout,
                      borderRadius: BorderRadius.circular(10.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 7.5.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isFemale
                                ? [
                                    const Color(0xFFE11D48),
                                    const Color(0xFFBE123C),
                                  ]
                                : [
                                    context.primaryColor,
                                    const Color(0xFF047857),
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10.r),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'প্যাকেজ কিনুন',
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 13.sp,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
