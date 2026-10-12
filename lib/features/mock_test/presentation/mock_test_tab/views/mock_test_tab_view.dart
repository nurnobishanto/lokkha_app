import 'package:flutter/material.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/features/exam/exam.dart';
import 'package:lokkha/features/mock_test/mock_test.dart';
import 'package:lokkha/shared/shared.dart';

class MockTestTabView extends StatelessWidget {
  const MockTestTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: LightThemeColors.primaryColor,
        appBar: const CustomAppBar(
          title: "বিষয়ভিত্তিক পরীক্ষা",
          centerTitle: true,
          fontSize: 18.0,
        ),
        body: SafeArea(
          maintainBottomViewPadding: true,
          child: Column(
            children: [
              Container(
                color: LightThemeColors.primaryColor,
                child: const TabBar(
                  indicatorColor: LightThemeColors.white,
                  labelColor: LightThemeColors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: [
                    Tab(
                      child: Text(
                        "বিষয় সমূহ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        "প্রশ্ন ব্যাংক",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(
                child: TabBarView(
                  children: [
                    MockTestView(),
                    FastPracticeView(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
