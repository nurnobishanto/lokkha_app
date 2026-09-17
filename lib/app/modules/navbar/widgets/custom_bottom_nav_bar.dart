import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../../../config/theme/light_theme_colors.dart';
import '../../../helper/global.dart';
import '../controllers/navbar_controller.dart';

class CustomBottomNavBar extends StatelessWidget {
  final NavbarController controller;

  const CustomBottomNavBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      color: const Color(0xFFF8FAFC),
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
              color: Colors.black.withValues(alpha: 0.09),
              blurRadius: 24,
              spreadRadius: 1,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: LightThemeColors.primaryColor.withValues(alpha: 0.12),
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
                color: Colors.white.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.9),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // 1. হোম (Home)
                  _buildNavItem(
                    index: 0,
                    label: "হোম",
                    iconBuilder: (isSelected) => Icon(
                      isSelected ? Icons.home_rounded : Icons.home_outlined,
                      size: 20.r,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),

                  // 2. পরীক্ষা (Exam)
                  _buildNavItem(
                    index: 1,
                    label: "পরীক্ষা",
                    iconBuilder: (isSelected) => FaIcon(
                      FontAwesomeIcons.graduationCap,
                      size: 17.r,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),

                  // 3. মেসেঞ্জার (Messenger)
                  _buildNavItem(
                    index: 2,
                    label: "মেসেঞ্জার",
                    activeGradient: const LinearGradient(
                      colors: [Color(0xFF00C6FF), Color(0xFF0078FF)],
                    ),
                    inactiveLabelColor: const Color(0xFF0078FF),
                    iconBuilder: (isSelected) {
                      if (isSelected) {
                        return FaIcon(
                          FontAwesomeIcons.facebookMessenger,
                          size: 18.r,
                          color: Colors.white,
                        );
                      }
                      return Container(
                        width: 22.r,
                        height: 22.r,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF00C6FF), Color(0xFF0078FF)],
                          ),
                        ),
                        child: Center(
                          child: FaIcon(
                            FontAwesomeIcons.facebookMessenger,
                            size: 12.r,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),

                  // 4. প্রিমিয়াম (Premium)
                  _buildNavItem(
                    index: 3,
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
                                  colors: [Color(0xFFFF3D00), Color(0xFFFF9100)],
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

                  // 5. প্রোফাইল / লগইন (Profile / Login)
                  Obx(() {
                    final label = !isLoggedIn.value ? "লগইন" : "প্রোফাইল";
                    return _buildNavItem(
                      index: 4,
                      label: label,
                      iconBuilder: (isSelected) => Icon(
                        isSelected
                            ? Icons.person_rounded
                            : Icons.person_outline_rounded,
                        size: 20.r,
                        color: isSelected ? Colors.white : const Color(0xFF64748B),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required Widget Function(bool isSelected) iconBuilder,
    Gradient? activeGradient,
    Color? activeColor,
    Color? inactiveLabelColor,
  }) {
    final bool isSelected = controller.currentIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => controller.changeIndex(index),
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
