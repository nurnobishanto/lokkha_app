import 'package:flutter/material.dart';
import 'package:lokkha/core/core.dart';

class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.access_time_filled_rounded,
                size: 80,
                color: LightThemeColors.primaryColor,
              ),
              const SizedBox(height: 24),
              const Text(
                "Coming Soon",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: LightThemeColors.primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "We're working hard to bring you this feature. Stay tuned!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
