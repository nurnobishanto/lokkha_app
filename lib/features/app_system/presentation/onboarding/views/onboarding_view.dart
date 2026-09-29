import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
