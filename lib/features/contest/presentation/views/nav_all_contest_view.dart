import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/all_contest_controller.dart';

class AllContestView extends GetView<AllContestController> {
  const AllContestView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AllContestView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'AllContestView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
