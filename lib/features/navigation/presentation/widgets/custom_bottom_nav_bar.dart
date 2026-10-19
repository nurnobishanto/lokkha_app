import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/auth/auth.dart';
import '../riverpod/navbar_notifier.dart';

class CustomBottomNavBar extends ConsumerWidget {
  final StatefulNavigationShell? navigationShell;
  const CustomBottomNavBar({super.key, this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navState = ref.watch(navbarNotifierProvider);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userLoggedIn = ref.watch(isLoggedInProvider) || navState.isLoggedIn || isLoggedIn.value;
    final activeIndex = navigationShell?.currentIndex ?? navState.currentIndex;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.only(
        left: 14.w,
        right: 14.w,
        top: 4.h,
        bottom: bottomInset > 0 ? bottomInset : 12.h,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.09),
              blurRadius: 24,
              spreadRadius: 1,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: LightThemeColors.primaryColor.withValues(alpha: isDark ? 0.2 : 0.12),
              blurRadius: 16,
              spreadRadius: -2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B).withValues(alpha: 0.92)
                    : Colors.white.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF334155).withValues(alpha: 0.8)
                      : Colors.white.withValues(alpha: 0.9),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // 1. হোম (Home)
                  _buildNavItem(
                    ref: ref,
                    index: 0,
                    currentIndex: activeIndex,
                    label: "হোম",
                    inactiveLabelColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    iconBuilder: (isSelected) => Icon(
                      isSelected ? Icons.home_rounded : Icons.home_outlined,
                      size: 20.r,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                    ),
                  ),

                  // 2. পরীক্ষা (Exam)
                  _buildNavItem(
                    ref: ref,
                    index: 1,
                    currentIndex: activeIndex,
                    label: "পরীক্ষা",
                    inactiveLabelColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    iconBuilder: (isSelected) => FaIcon(
                      FontAwesomeIcons.graduationCap,
                      size: 17.r,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                    ),
                  ),

                  // 3. প্রিমিয়াম (Premium)
                  _buildNavItem(
                    ref: ref,
                    index: 2,
                    currentIndex: activeIndex,
                    label: "প্রিমিয়াম",
                    activeGradient: const LinearGradient(
                      colors: [Color(0xFFFFA000), Color(0xFFFF6F00)],
                    ),
                    inactiveLabelColor: const Color(0xFFD97706),
                    iconBuilder: (isSelected) {
                      return Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.crown,
                            size: 17.r,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFFF59E0B),
                          ),
                          Positioned(
                            top: -6.h,
                            right: -10.w,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 3.5.w,
                                vertical: 0.5.h,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF3D00),
                                    Color(0xFFFF9100)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(5.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.withValues(alpha: 0.4),
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Text(
                                "PRO",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 7.sp,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.2,
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  // 4. প্রোফাইল / লগইন (Profile / Login)
                  _buildNavItem(
                    ref: ref,
                    index: 3,
                    currentIndex: activeIndex,
                    label: !userLoggedIn ? "লগইন" : "প্রোফাইল",
                    inactiveLabelColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    iconBuilder: (isSelected) => Icon(
                      isSelected
                          ? Icons.person_rounded
                          : Icons.person_outline_rounded,
                      size: 20.r,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required WidgetRef ref,
    required int index,
    required int currentIndex,
    required String label,
    required Widget Function(bool isSelected) iconBuilder,
    Gradient? activeGradient,
    Color? activeColor,
    Color? inactiveLabelColor,
  }) {
    final bool isSelected = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (navigationShell != null) {
            navigationShell!.goBranch(
              index,
              initialLocation: index == navigationShell!.currentIndex,
            );
          }
          ref.read(navbarNotifierProvider.notifier).changeIndex(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: 6.w,
            vertical: 6.h,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? (activeGradient == null
                    ? (activeColor ?? LightThemeColors.primaryColor)
                    : null)
                : Colors.transparent,
            gradient: isSelected ? activeGradient : null,
            borderRadius: BorderRadius.circular(15.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: (activeColor ?? LightThemeColors.primaryColor)
                          .withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 18.r,
                child: Center(
                  child: iconBuilder(isSelected),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (inactiveLabelColor ?? const Color(0xFF64748B)),
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
