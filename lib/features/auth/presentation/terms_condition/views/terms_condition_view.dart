import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/terms_condition_controller.dart';

class TermsConditionView extends GetView<TermsConditionController> {
  const TermsConditionView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TermsConditionView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'TermsConditionView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
