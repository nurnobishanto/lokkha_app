import 'package:flutter/material.dart';
import 'package:lokkha/core/compat/get_compat.dart';

class OnboardingView extends GetView {
  const OnboardingView({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Text("Onboarding View"),
        ),
      ),
    );
  }
}
