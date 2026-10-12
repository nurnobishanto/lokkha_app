import 'package:flutter/material.dart';

class SponsorAdsView extends StatelessWidget {
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
