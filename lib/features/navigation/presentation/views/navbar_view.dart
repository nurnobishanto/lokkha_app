import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/features/app_system/app_system.dart';
import 'package:lokkha/features/exam/exam.dart';
import 'package:lokkha/features/home/home.dart';
import 'package:lokkha/features/navigation/presentation/controllers/navbar_notifier.dart';
import 'package:lokkha/features/packages/packages.dart';
import 'package:lokkha/features/profile/profile.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class NavbarView extends ConsumerStatefulWidget {
  final Widget? child;
  const NavbarView({super.key, this.child});

  @override
  ConsumerState<NavbarView> createState() => _NavbarViewState();
}

class _NavbarViewState extends ConsumerState<NavbarView> {
  final List<Widget> _navBarBody = const [
    HomeView(),
    ExamCategoryView(),
    MessengerRedirectScreen(),
    PremiumPackagesView(),
    DashboardPortalView(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(navbarNotifierProvider.notifier).getMeProfileInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final navState = ref.watch(navbarNotifierProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBody: false,
      body: widget.child ?? _navBarBody[navState.currentIndex],
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
