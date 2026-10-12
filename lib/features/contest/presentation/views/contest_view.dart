import 'package:flutter/material.dart';

class ContestView extends StatelessWidget {
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
