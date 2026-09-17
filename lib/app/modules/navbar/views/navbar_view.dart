import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/navbar_controller.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class NavbarView extends GetView<NavbarController> {
  const NavbarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      extendBody: false,
      body: GetBuilder<NavbarController>(
        builder: (controller) {
          return controller.nabBarBody[controller.currentIndex];
        },
      ),
      bottomNavigationBar: GetBuilder<NavbarController>(
        builder: (controller) {
          return CustomBottomNavBar(controller: controller);
        },
      ),
    );
  }
}
