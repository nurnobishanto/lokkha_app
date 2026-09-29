import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:lokkha/features/study_material/study_material.dart';
import '../controllers/current_affairs_controller.dart';
import 'international_current_affairs_content_view.dart';

class CurrentAffairsView extends GetView<CurrentAffairsController> {
  const CurrentAffairsView({super.key});

  double _getResponsiveFontSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= 1024) return 20; // iPad Pro, etc.
    if (screenWidth >= 768) return 18; // Regular iPad
    if (screenWidth >= 480) return 16; // Large phones
    return 14; // Small phones
  }

  @override
  Widget build(BuildContext context) {
    final responsiveFontSize = _getResponsiveFontSize(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "কারেন্ট অ্যাফেয়ার্স",
            style: TextStyle(
              fontSize: responsiveFontSize + 2, // slightly larger title
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: TabBar(
            labelStyle: TextStyle(
              fontSize: responsiveFontSize,
              fontWeight: FontWeight.w600,
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: 'বাংলাদেশ'),
              Tab(text: 'আন্তর্জাতিক'),
            ],
          ),
        ),
        body: SafeArea(
          child: const TabBarView(
            children: [
              CurrentAffairsContentView(),
              InternationalCurrentAffairsContentView(),
            ],
          ),
        ),
      ),
    );
  }
}
