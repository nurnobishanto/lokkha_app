import 'package:flutter/material.dart';

import 'package:lokkha/core/compat/get_compat.dart';

import '../controllers/contest_controller.dart';

class ContestView extends GetView<ContestController> {
  const ContestView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ContestView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ContestView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
