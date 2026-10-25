import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
                  // 1. হোম (Home) — Premium Duotone Home Icon
                  _buildNavItem(
                    ref: ref,
                    index: 0,
                    currentIndex: activeIndex,
                    label: "হোম",
                    inactiveLabelColor: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                    iconBuilder: (isSelected) => _buildHomeSvgIcon(
                      isSelected: isSelected,
                      isDark: isDark,
                    ),
                  ),

                  // 2. পরীক্ষা (Exam) — Premium Duotone Exam/Test Icon
                  _buildNavItem(
                    ref: ref,
                    index: 1,
                    currentIndex: activeIndex,
                    label: "পরীক্ষা",
                    inactiveLabelColor: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                    iconBuilder: (isSelected) => _buildExamSvgIcon(
                      isSelected: isSelected,
                      isDark: isDark,
                    ),
                  ),

                  // 3. প্রিমিয়াম (Premium) — Kept unchanged as requested
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

                  // 4. প্রোফাইল / লগইন (Profile / Login) — Premium Duotone Profile Icon
                  _buildNavItem(
                    ref: ref,
                    index: 3,
                    currentIndex: activeIndex,
                    label: !userLoggedIn ? "লগইন" : "প্রোফাইল",
                    inactiveLabelColor: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                    iconBuilder: (isSelected) => _buildProfileSvgIcon(
                      isSelected: isSelected,
                      isDark: isDark,
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
                height: 20.r,
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

  /// ১. হোম (Home) — প্রিমিয়াম ডুয়োটোন মডার্ন হোম আইকন
  Widget _buildHomeSvgIcon({
    required bool isSelected,
    required bool isDark,
  }) {
    final String strokeColor = isSelected
        ? '#FFFFFF'
        : (isDark ? '#CBD5E1' : '#334155');
    final String fillTone = isSelected
        ? '#FFFFFF'
        : (isDark ? '#10B981' : '#10B981');
    final String fillOpacity = isSelected ? '0.26' : '0.16';
    final String accentColor = isSelected
        ? '#FFFFFF'
        : '#10B981';

    final String svg = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M4.5 10.2L12 3.8L19.5 10.2V18.8C19.5 19.9046 18.6046 20.8 17.5 20.8H6.5C5.39543 20.8 4.5 19.9046 4.5 18.8V10.2Z" fill="$fillTone" fill-opacity="$fillOpacity"/>
  <path d="M3 10.8L10.8284 4.11991C11.5032 3.54408 12.4968 3.54408 13.1716 4.11991L21 10.8" stroke="$strokeColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M5 9.8V18.8C5 19.9046 5.89543 20.8 7 20.8H17C18.1046 20.8 19 19.9046 19 18.8V9.8" stroke="$strokeColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M9.8 20.8V15C9.8 13.8954 10.6954 13 11.8 13H12.2C13.3046 13 14.2 13.8954 14.2 15V20.8" fill="$accentColor" fill-opacity="${isSelected ? '0.35' : '0.28'}" stroke="$accentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';

    return SvgPicture.string(
      svg,
      width: 20.r,
      height: 20.r,
    );
  }

  /// ২. পরীক্ষা (Exam) — প্রিমিয়াম ডুয়োটোন এক্সাম পেপার ও ভেরিফায়েড চেকমার্ক আইকন
  Widget _buildExamSvgIcon({
    required bool isSelected,
    required bool isDark,
  }) {
    final String strokeColor = isSelected
        ? '#FFFFFF'
        : (isDark ? '#CBD5E1' : '#334155');
    final String fillTone = isSelected ? '#FFFFFF' : '#0EA5E9';
    final String fillOpacity = isSelected ? '0.24' : '0.15';
    final String badgeColor = isSelected ? '#FFFFFF' : '#10B981';
    final String checkColor = isSelected ? '#15803D' : '#FFFFFF';

    final String svg = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="4.5" y="4.2" width="13.5" height="16.5" rx="3" fill="$fillTone" fill-opacity="$fillOpacity" stroke="$strokeColor" stroke-width="1.85" stroke-linejoin="round"/>
  <path d="M8.5 2.8H14C14.8284 2.8 15.5 3.47157 15.5 4.3C15.5 5.12843 14.8284 5.8 14 5.8H8.5C7.67157 5.8 7 5.12843 7 4.3C7 3.47157 7.67157 2.8 8.5 2.8Z" fill="$badgeColor" stroke="$strokeColor" stroke-width="1.6"/>
  <path d="M8 9.5H14.5" stroke="$strokeColor" stroke-width="1.8" stroke-linecap="round"/>
  <path d="M8 13H12.5" stroke="$strokeColor" stroke-width="1.8" stroke-linecap="round"/>
  <path d="M8 16.5H10.5" stroke="$strokeColor" stroke-width="1.8" stroke-linecap="round"/>
  <circle cx="17.2" cy="16.8" r="4.3" fill="$badgeColor" stroke="${isSelected ? '#15803D' : badgeColor}" stroke-width="1.2"/>
  <path d="M15.4 16.8L16.65 18.05L19.1 15.6" stroke="$checkColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';

    return SvgPicture.string(
      svg,
      width: 20.r,
      height: 20.r,
    );
  }

  /// ৪. প্রোফাইল / লগইন (Profile / Login) — প্রিমিয়াম ডুয়োটোন ইউজার অবতার ব্যাজ আইকন
  Widget _buildProfileSvgIcon({
    required bool isSelected,
    required bool isDark,
  }) {
    final String strokeColor = isSelected
        ? '#FFFFFF'
        : (isDark ? '#CBD5E1' : '#334155');
    final String fillTone = isSelected ? '#FFFFFF' : '#6366F1';
    final String fillOpacity = isSelected ? '0.26' : '0.16';
    final String accentColor = isSelected ? '#FFFFFF' : '#10B981';

    final String svg = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="12" cy="12" r="9.2" fill="$fillTone" fill-opacity="$fillOpacity" stroke="$strokeColor" stroke-width="1.85"/>
  <circle cx="12" cy="9.3" r="3.2" fill="$accentColor" fill-opacity="${isSelected ? '0.4' : '0.25'}" stroke="$strokeColor" stroke-width="1.8"/>
  <path d="M6.4 18.8C7.65 16.35 9.68 15 12 15C14.32 15 16.35 16.35 17.6 18.8" stroke="$accentColor" stroke-width="1.95" stroke-linecap="round"/>
</svg>
''';

    return SvgPicture.string(
      svg,
      width: 20.r,
      height: 20.r,
    );
  }
}
