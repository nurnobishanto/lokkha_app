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
                        vertical: 14.h,
                      ),
                      children: [
                        // ─── Package Cards ───────────────────────────────────
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

                        // ─── Trust & Security Banner ─────────────────────────
                        _buildTrustFooter(context),

                        SizedBox(height: 20.h),
                      ],
                    ),
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

// ─── Clean, Minimal & Distinct Package Card ────────────────────────────────
class _PackageTierConfig {
  final String title;
  final String subtitle;
  final String badgeText;
  final IconData badgeIcon;
  final Color accentColor;
  final List<Color> gradientColors;
  final bool isProminent;

  const _PackageTierConfig({
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.badgeIcon,
    required this.accentColor,
    required this.gradientColors,
    this.isProminent = false,
  });

  factory _PackageTierConfig.fromPackage(Package package, String discountStr) {
    final name = package.name?.trim() ?? '';
    final title = name.isNotEmpty ? name : 'প্যাকেজ';
    final subtitle = (package.description != null && package.description!.trim().isNotEmpty)
        ? package.description!.trim()
        : '';

    final isAparajita = package.isFemale == true ||
        name.contains('অপরাজিতা') ||
        (package.description?.contains('নারী') ?? false) ||
        (package.description?.contains('মহিলা') ?? false);
    final isMaster = package.isMega == true ||
        name.contains('মাস্টার') ||
        name.toLowerCase().contains('master');
    final duration = package.duration ?? package.durationDays ?? 0;
    final isYearly = duration >= 365 || (package.isFeatured == true && duration > 180);

    // 1. Female / Aparajita Special (Rose Theme)
    if (isAparajita) {
      return _PackageTierConfig(
        title: title,
        subtitle: subtitle,
        badgeText: discountStr.isNotEmpty
            ? 'অপরাজিতা স্পেশাল • $discountStr ছাড়'
            : 'অপরাজিতা স্পেশাল',
        badgeIcon: Icons.auto_awesome_rounded,
        accentColor: const Color(0xFFE11D48),
        gradientColors: const [Color(0xFFE11D48), Color(0xFFBE123C)],
        isProminent: true,
      );
    }

    // 2. Master / Mega All-in-One (Royal Purple Theme)
    if (isMaster) {
      return _PackageTierConfig(
        title: title,
        subtitle: subtitle,
        badgeText: discountStr.isNotEmpty
            ? 'মাস্টার এক্সেস • $discountStr ছাড়'
            : 'মাস্টার এক্সেস',
        badgeIcon: Icons.workspace_premium_rounded,
        accentColor: const Color(0xFF7C3AED),
        gradientColors: const [Color(0xFF7C3AED), Color(0xFF6D28D9)],
        isProminent: true,
      );
    }

    // 3. Yearly Best Value (Emerald Green Theme)
    if (isYearly) {
      return _PackageTierConfig(
        title: title,
        subtitle: subtitle,
        badgeText: discountStr.isNotEmpty
            ? 'সেরা ভ্যালু • $discountStr ছাড়'
            : 'সেরা ভ্যালু প্যাক',
        badgeIcon: Icons.local_fire_department_rounded,
        accentColor: const Color(0xFF006A4E),
        gradientColors: const [Color(0xFF006A4E), Color(0xFF047857)],
        isProminent: true,
      );
    }

    // 4. Standard 6-Month / Default (Ocean Blue Theme)
    return _PackageTierConfig(
      title: title,
      subtitle: subtitle,
      badgeText: discountStr.isNotEmpty
          ? 'স্ট্যান্ডার্ড প্ল্যান • $discountStr ছাড়'
          : 'স্ট্যান্ডার্ড প্ল্যান',
      badgeIcon: Icons.bolt_rounded,
      accentColor: const Color(0xFF0284C7),
      gradientColors: const [Color(0xFF0284C7), Color(0xFF0369A1)],
      isProminent: false,
    );
  }
}

class _PackageCard extends StatelessWidget {
  final Package package;
  final VoidCallback onTapDetails;
  final VoidCallback onTapCheckout;

  const _PackageCard({
    required this.package,
    required this.onTapDetails,
    required this.onTapCheckout,
  });

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

  String _cleanDiscount(String? discount) {
    if (discount == null || discount.trim().isEmpty) return '';
    var d = discount.trim().replaceAll('%', '').replaceAll('-', '').trim();
    if (d.contains('.')) {
      final val = double.tryParse(d);
      if (val != null) {
        d = val.round().toString();
      }
    }
    return d.isEmpty ? '' : '$d%';
  }

  @override
  Widget build(BuildContext context) {
    final regularPrice = _cleanPrice(package.regularPrice);
    final salePrice =
        _cleanPrice(package.discountedPrice ?? package.regularPrice);
    final discountStr = _cleanDiscount(package.discount);

    final double? regVal = double.tryParse(regularPrice);
    final double? saleVal = double.tryParse(salePrice);
    final bool hasDiscount =
        regVal != null && saleVal != null && regVal > saleVal && saleVal > 0;

    // Resolve unique tier identity
    final tier = _PackageTierConfig.fromPackage(package, discountStr);
    final isDark = context.isDark;

    // Dynamic borders & shadows
    final Color cardBorderColor = tier.accentColor.withValues(
      alpha: tier.isProminent ? (isDark ? 0.45 : 0.35) : (isDark ? 0.25 : 0.18),
    );

    final Color badgeBgColor = tier.accentColor.withValues(
      alpha: isDark ? 0.18 : 0.08,
    );

    // Feature bullet points directly from API
    final features = package.featureTexts.isNotEmpty
        ? package.featureTexts
        : [
            'সকল বিষয়ের আনলিমিটেড মডেল টেস্ট ও প্র্যাকটিস',
            'প্রতিটি প্রশ্নের বিস্তারিত নির্ভুল সমাধান ও ব্যাখ্যা',
            'লাইভ লিডারবোর্ড ও বিস্তারিত মেধা তালিকা যাচাই',
          ];

    final int durationDays =
        package.duration ?? package.durationDays ?? 0;
    final String durationLabel = durationDays > 0
        ? (durationDays == 365
            ? '৩৬৫ দিন (১ বছর)'
            : (durationDays == 180
                ? '১৮০ দিন (৬ মাস)'
                : (package.formattedDuration ?? '$durationDays দিন মেয়াদ')))
        : (package.formattedDuration ?? 'মেয়াদ');

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: cardBorderColor,
          width: tier.isProminent ? 1.4 : 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: tier.accentColor.withValues(
              alpha: tier.isProminent ? (isDark ? 0.18 : 0.07) : 0.02,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isDark ? 0.25 : 0.03,
            ),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTapDetails,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Header: Tier Badge & Duration Pill ────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left: Plan Badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.5.w,
                        vertical: 3.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBgColor,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: tier.accentColor.withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            tier.badgeIcon,
                            size: 12.sp,
                            color: tier.accentColor,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            tier.badgeText,
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w700,
                              color: tier.accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Right: Duration Pill
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF334155).withValues(alpha: 0.5)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 11.5.sp,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            durationLabel,
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFFCBD5E1)
                                  : const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10.h),

                // ─── Package Title & Subtitle ──────────────────────────────
                Text(
                  tier.title,
                  style: TextStyle(
                    fontSize: 15.5.sp,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary,
                    height: 1.25,
                  ),
                ),
                if (tier.subtitle.isNotEmpty) ...[
                  SizedBox(height: 3.h),
                  Text(
                    tier.subtitle,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      color: context.textMuted,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // ─── Key Feature Bullets ───────────────────────────────────
                if (features.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  ...features.map((feat) {
                    final cleanFeat = feat.replaceAll(RegExp(r'<[^>]*>'), '').trim();
                    if (cleanFeat.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: EdgeInsets.only(bottom: 5.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 1.5.h),
                            padding: EdgeInsets.all(1.5.r),
                            decoration: BoxDecoration(
                              color: tier.accentColor.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              size: 11.sp,
                              color: tier.accentColor,
                            ),
                          ),
                          SizedBox(width: 7.w),
                          Expanded(
                            child: Text(
                              cleanFeat,
                              style: TextStyle(
                                fontSize: 11.5.sp,
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
                ],

                SizedBox(height: 4.h),
                Divider(
                  height: 14.h,
                  thickness: 0.6,
                  color: context.borderColor.withValues(alpha: 0.6),
                ),

                // ─── Bottom: Price Block & CTA Button ──────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Price Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '৳$salePrice',
                                style: TextStyle(
                                  fontSize: 19.sp,
                                  fontWeight: FontWeight.w800,
                                  color: context.textPrimary,
                                  height: 1.0,
                                ),
                              ),
                              if (hasDiscount) ...[
                                SizedBox(width: 5.w),
                                Text(
                                  '৳$regularPrice',
                                  style: TextStyle(
                                    fontSize: 11.5.sp,
                                    color: context.textMuted,
                                    decoration: TextDecoration.lineThrough,
                                    fontWeight: FontWeight.w500,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (hasDiscount && discountStr.isNotEmpty) ...[
                            SizedBox(height: 3.h),
                            Text(
                              '$discountStr সাশ্রয় হচ্ছে',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: tier.accentColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    SizedBox(width: 8.w),

                    // Action Button with Gradient matching the Tier
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
                            colors: tier.gradientColors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10.r),
                          boxShadow: [
                            BoxShadow(
                              color: tier.accentColor.withValues(alpha: 0.28),
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
