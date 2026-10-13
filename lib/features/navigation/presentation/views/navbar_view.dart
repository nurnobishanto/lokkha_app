import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lokkha/features/navigation/presentation/riverpod/navbar_notifier.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class NavbarView extends ConsumerStatefulWidget {
  final StatefulNavigationShell? navigationShell;
  final Widget? child;
  const NavbarView({super.key, this.navigationShell, this.child});

  @override
  ConsumerState<NavbarView> createState() => _NavbarViewState();
}

class _NavbarViewState extends ConsumerState<NavbarView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(navbarNotifierProvider.notifier).getMeProfileInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBody: false,
      body: widget.navigationShell ?? widget.child ?? const SizedBox.shrink(),
      bottomNavigationBar: CustomBottomNavBar(
        navigationShell: widget.navigationShell,
      ),
    );
  }
}
