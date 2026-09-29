import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/sponsor_ads_controller.dart';

class SponsorAdsView extends GetView<SponsorAdsController> {
  const SponsorAdsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SponsorAdsView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'SponsorAdsView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
