import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/app/router/routes.dart';
import 'package:lokkha/features/auth/auth.dart';
import 'package:lokkha/features/packages/packages.dart';

class PremiumPackagesView extends ConsumerWidget {
  const PremiumPackagesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(premiumPackagesNotifierProvider);

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar:
          const CustomAppBar(title: 'প্রিমিয়াম প্যাকেজ', centerTitle: true),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () => ref
                  .read(premiumPackagesNotifierProvider.notifier)
                  .fetchPremiumPackages(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.borderColor)),
                child: Column(
                  children: [
                    _buildHeaderRow(context),
                    Divider(height: 0, color: context.borderColor),
                    Flexible(
                      child: ListView.builder(
                        itemCount: state.packages.length,
                        itemBuilder: (context, index) {
                          final pkg = state.packages[index];
                          return Column(
                            children: [
                              _buildPackageTable(
                                context: context,
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
                                        builder: (_) =>
                                            PremiumPackageCheckoutView(
                                          packagesModel: pkg,
                                        ),
                                      ),
                                    );
                                  } else {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const AuthGatewayView(),
                                      ),
                                    );
                                  }
                                },
                                title: pkg.name.toString(),
                                duration: '${pkg.duration.toString()} দিন',
                                price: pkg.discountedPrice.toString(),
                                oldPrice: pkg.regularPrice.toString(),
                                discount: '- ${pkg.discount.toString()}%',
                                features: pkg.featureTexts,
                                isFemale: (pkg.isFemale == true) ? 1 : 0,
                              ),
                              Divider(height: 0, color: context.borderColor),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '📦 প্যাকেজ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: context.textPrimary,
            ),
          ),
          Text(
            '💰 মূল্য',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageTable({
    required BuildContext context,
    required String title,
    required String price,
    required String oldPrice,
    required String discount,
    required String duration,
    required int isFemale,
    void Function()? onTapCheckout,
    void Function()? onTapDetails,
    required List<String> features,
  }) {
    return InkWell(
      onTap: onTapDetails ?? onTapCheckout,
      child: Container(
        color: isFemale == 1
            ? (context.isDark
                ? const Color(0xFF4C0519).withValues(alpha: 0.5)
                : LightThemeColors.red.withValues(alpha: .2))
            : context.cardColor,
        child: Padding(
          padding: const EdgeInsets.only(top: 3, bottom: 1, left: 8, right: 8),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FixedColumnWidth(6),
              2: FlexColumnWidth(2),
            },
            children: [
              TableRow(
                children: [
                  // Title + Features
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: context.textPrimary,
                        ),
                      ),
                      Text(
                        duration,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: context.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ...features.map(
                        (f) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            f,
                            style: TextStyle(
                              fontSize: 12,
                              color: context.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Divider
                  Center(
                    child: Container(
                      height: 90,
                      width: 1,
                      color: context.borderColor,
                    ),
                  ),

                  // Price + Button
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        price,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: context.textPrimary,
                        ),
                      ),
                      Text(
                        oldPrice,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textMuted,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      Text(
                        discount,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.isDark
                              ? const Color(0xFF34D399)
                              : Colors.green,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ElevatedButton(
                        onPressed: onTapCheckout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isFemale == 1
                              ? LightThemeColors.red
                              : context.primaryColor,
                          minimumSize: const Size(90, 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                        ),
                        child: Text(
                          'প্যাকেজ কিনুন',
                          style: AppTextStyles.body1.copyWith(
                            color: Colors.white,
                            fontSize: 12.0.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
