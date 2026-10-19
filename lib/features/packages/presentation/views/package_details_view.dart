import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/auth/auth.dart';
import 'package:lokkha/features/packages/presentation/providers/package_details_notifier.dart';
import 'package:lokkha/features/packages/presentation/views/premium_package_checkout_view.dart';
import 'package:lokkha/shared/models/package.dart';

class PackageDetailsView extends ConsumerStatefulWidget {
  final int packageId;
  final Package? initialPackage;

  const PackageDetailsView({
    super.key,
    required this.packageId,
    this.initialPackage,
  });

  @override
  ConsumerState<PackageDetailsView> createState() => _PackageDetailsViewState();
}

class _PackageDetailsViewState extends ConsumerState<PackageDetailsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.initialPackage != null) {
        ref
            .read(packageDetailsNotifierProvider(widget.packageId).notifier)
            .setInitialPackage(widget.initialPackage);
      }
      ref
          .read(packageDetailsNotifierProvider(widget.packageId).notifier)
          .fetchPackageDetails(widget.packageId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(packageDetailsNotifierProvider(widget.packageId));
    final notifier =
        ref.read(packageDetailsNotifierProvider(widget.packageId).notifier);
    final pkg = state.package ?? widget.initialPackage;

    // Check if we have complete package details (pricing, features, or duration)
    final bool hasCompleteDetails = state.package != null &&
        (state.package!.regularPrice != null ||
            state.package!.effectivePrice != null ||
            (state.package!.featureList != null &&
                state.package!.featureList!.isNotEmpty) ||
            state.package!.formattedDuration != null);

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: const CustomAppBar(
        title: 'প্যাকেজ বিস্তারিত',
        centerTitle: true,
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading && !hasCompleteDetails) {
            return const Center(
              child: CircularProgressIndicator(
                color: LightThemeColors.primaryColor,
              ),
            );
          }

          if (state.hasError && !hasCompleteDetails) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48.sp,
                      color: const Color(0xFFDC2626),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      state.errorMessage ?? "প্যাকেজের তথ্য পাওয়া যায়নি",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: context.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    ElevatedButton.icon(
                      onPressed: () =>
                          notifier.fetchPackageDetails(widget.packageId),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text(
                        "আবার চেষ্টা করুন",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: LightThemeColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (pkg == null) {
            return const SizedBox.shrink();
          }

          final features = (pkg.featureList ?? [])
              .where((f) =>
                  f.text.trim().isNotEmpty &&
                  f.text.trim().toLowerCase() != 'null' &&
                  f.text.trim().toLowerCase() != '<p>null</p>')
              .toList();

          final terms = (pkg.termsList ?? [])
              .map((t) => t.trim())
              .where((t) =>
                  t.isNotEmpty &&
                  t.toLowerCase() != 'null' &&
                  t.toLowerCase() != '<p>null</p>' &&
                  t.toLowerCase() != 'none')
              .toList();

          final bool isCurrentlyActive = pkg.isCurrentlyActive ?? false;
          final bool canClaimTrial =
              pkg.canClaimTrial == true || (pkg.isTrial == true && !isCurrentlyActive);

          final hasValidDescription = pkg.description != null &&
              pkg.description!.trim().isNotEmpty &&
              pkg.description!.trim().toLowerCase() != 'null' &&
              pkg.description!.trim().toLowerCase() != '<p>null</p>';

          return RefreshIndicator(
            color: LightThemeColors.primaryColor,
            onRefresh: () =>
                notifier.fetchPackageDetails(widget.packageId, isRefresh: true),
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                // 1. Header Card (Title, Badges, Duration)
                _buildHeaderCard(context, pkg),

                SizedBox(height: 14.h),

                // 2. Pricing Card
                _buildPricingCard(context, pkg),

                if (hasValidDescription) ...[
                  SizedBox(height: 14.h),
                  _buildDescriptionCard(context, pkg.description!),
                ],

                // 3. Free Trial Offer Box (If applicable)
                if (canClaimTrial) ...[
                  SizedBox(height: 14.h),
                  _buildTrialCard(context, pkg, state.isClaimingTrial, () {
                    notifier.claimFreeTrial(widget.packageId);
                  }),
                ],

                // 4. Features Checklist Card (Only show if there are valid features)
                if (features.isNotEmpty) ...[
                  SizedBox(height: 14.h),
                  _buildFeaturesCard(context, features),
                ],

                // 5. Terms & Conditions Card (Only show if there are actual valid terms)
                if (terms.isNotEmpty) ...[
                  SizedBox(height: 14.h),
                  _buildTermsCard(context, terms),
                ],
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: pkg != null
          ? _buildBottomBar(context, pkg)
          : null,
    );
  }

  Widget _buildHeaderCard(BuildContext context, Package pkg) {
    final bool isActive = pkg.isCurrentlyActive == true;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF9C3),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.workspace_premium_rounded,
                  size: 26.sp,
                  color: const Color(0xFFD97706),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pkg.name ?? "প্রিমিয়াম প্যাকেজ",
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w800,
                        color: context.textPrimary,
                        height: 1.25,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 13.sp,
                          color: context.textSecondary,
                        ),
                        SizedBox(width: 5.w),
                        Expanded(
                          child: Text(
                            pkg.formattedDuration ??
                                (pkg.durationDays != null
                                    ? "${pkg.durationDays} দিন"
                                    : "মেয়াদকাল"),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: context.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isActive)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Text(
                    "সক্রিয়",
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF059669),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard(BuildContext context, Package pkg) {
    final effective = pkg.effectivePrice ??
        num.tryParse(pkg.discountedPrice ?? '')?.toDouble() ??
        num.tryParse(pkg.regularPrice ?? '')?.toDouble() ??
        0.0;
    final regular = num.tryParse(pkg.regularPrice ?? '')?.toDouble() ?? 0.0;
    final hasDiscount = regular > effective;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "প্যাকেজ মূল্য",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: context.textSecondary,
                  ),
                ),
                SizedBox(height: 4.h),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8.w,
                  runSpacing: 4.h,
                  children: [
                    Text(
                      "৳ ${effective.toStringAsFixed(effective.truncateToDouble() == effective ? 0 : 2)}",
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFD97706),
                      ),
                    ),
                    if (hasDiscount)
                      Text(
                        "৳ ${regular.toStringAsFixed(regular.truncateToDouble() == regular ? 0 : 2)}",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: context.textSecondary,
                          decoration: TextDecoration.lineThrough,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          if (pkg.discount != null && pkg.discount!.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Text(
                "${pkg.discount}% ছাড়",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFDC2626),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(BuildContext context, String description) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 17.sp,
                color: LightThemeColors.primaryColor,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  "প্যাকেজ বিবরণ",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            description,
            style: TextStyle(
              fontSize: 13.sp,
              color: context.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrialCard(
    BuildContext context,
    Package pkg,
    bool isClaiming,
    VoidCallback onClaim,
  ) {
    final trialDays = pkg.trialDurationDays ?? 3;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFFCD34D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star_rounded,
                color: const Color(0xFFB45309),
                size: 20.sp,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  "ফ্রি ট্রায়াল অফার!",
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF92400E),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            "প্যাকেজটি কেনার পূর্বে $trialDays দিনের জন্য সম্পূর্ণ বিনামূল্যে ট্রায়াল নিতে পারবেন।",
            style: TextStyle(
              fontSize: 12.5.sp,
              color: const Color(0xFF78350F),
              height: 1.4,
            ),
          ),
          SizedBox(height: 12.h),
          ElevatedButton.icon(
            onPressed: isClaiming ? null : onClaim,
            icon: isClaiming
                ? SizedBox(
                    width: 14.r,
                    height: 14.r,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF78350F),
                    ),
                  )
                : const Icon(Icons.bolt_rounded, size: 16),
            label: Text(
              isClaiming ? "অপেক্ষা করুন..." : "$trialDays দিনের ফ্রি ট্রায়াল নিন",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: const Color(0xFF0F172A),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesCard(BuildContext context, List<PackageFeature> features) {
    final validFeatures = features
        .where((f) =>
            f.text.trim().isNotEmpty &&
            f.text.trim().toLowerCase() != 'null' &&
            f.text.trim().toLowerCase() != '<p>null</p>')
        .toList();

    if (validFeatures.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                size: 18.sp,
                color: const Color(0xFF059669),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  "প্যাকেজের অন্তর্ভুক্ত সুবিধাসমূহ",
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(height: 1, color: context.dividerColor),
          SizedBox(height: 10.h),
          ...validFeatures.map((f) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 6.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    f.included
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    size: 17.sp,
                    color: f.included
                        ? const Color(0xFF059669)
                        : const Color(0xFF94A3B8),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      f.text,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight:
                            f.included ? FontWeight.w600 : FontWeight.w400,
                        color: f.included
                            ? context.textPrimary
                            : context.textSecondary.withValues(alpha: 0.7),
                        decoration: f.included
                            ? null
                            : TextDecoration.lineThrough,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTermsCard(BuildContext context, List<String> terms) {
    final validTerms = terms
        .map((t) => t.trim())
        .where((t) =>
            t.isNotEmpty &&
            t.toLowerCase() != 'null' &&
            t.toLowerCase() != '<p>null</p>' &&
            t.toLowerCase() != 'none')
        .toList();

    if (validTerms.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.gavel_rounded,
                size: 17.sp,
                color: context.textSecondary,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  "শর্তাবলী ও নীতিমালা",
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Divider(height: 1, color: context.dividerColor),
          SizedBox(height: 8.h),
          ...validTerms.asMap().entries.map((entry) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "• ",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: context.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        color: context.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, Package pkg) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: context.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 48.h,
          child: ElevatedButton(
            onPressed: () {
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.r),
              ),
              elevation: 0,
            ),
            child: Text(
              pkg.isCurrentlyActive == true
                  ? "রিনিউ / আপগ্রেড করুন"
                  : "প্যাকেজটি সাবস্ক্রাইব করুন",
              style: TextStyle(
                fontSize: 14.5.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
