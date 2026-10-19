import 'package:flutter/material.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/quick_practice/quick_practice.dart';

class MockTestTabView extends StatelessWidget {
  const MockTestTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: const CustomAppBar(
        title: "কুইক প্র্যাকটিস",
        centerTitle: true,
      ),
      body: const SafeArea(
        maintainBottomViewPadding: true,
        child: QuickPracticeSubjectsView(),
      ),
    );
  }
}
