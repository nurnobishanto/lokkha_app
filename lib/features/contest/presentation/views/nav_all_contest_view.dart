import 'package:flutter/material.dart';

import 'package:lokkha/core/compat/get_compat.dart';

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
