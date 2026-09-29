import 'dart:io';

import 'package:flutter/material.dart';

import 'package:lokkha/shared/shared.dart';
import 'package:lokkha/core/core.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateView extends StatelessWidget {
  final Uri url;
  const AppUpdateView({required this.url, super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20),
              // App icon
              CircleAvatar(
                radius: 50,
                //backgroundImage: const AssetImage(AppImages.icon),
                backgroundColor: Colors.grey[200],
                child: Center(
                  child: Image.asset(
                    AssetImagePaths.appIcon,
                    width: 80,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Title
              const Text(
                "নতুন ফিচারসমূহ দেখতে অ্যাপটি আপডেট করুন",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              // Subtitles
              if (Platform.isAndroid)
                const Text(
                  "সম্মানিত ইউজার,অ্যাপ আপডেট করাকালীন কোন সমস্যা সৃষ্টি হলে ব্যবহৃত অ্যাপটি প্রথমে আন-ইন্সটল করুন এবং পুনরায় প্লে-ষ্টোর হতে ইন্সটল করুন। ধন্যবাদ",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                )
              else if (Platform.isIOS)
                const Text(
                  "সম্মানিত ইউজার,অ্যাপ আপডেট করাকালীন কোন সমস্যা সৃষ্টি হলে ব্যবহৃত অ্যাপটি প্রথমে আন-ইন্সটল করুন এবং পুনরায় অ্যাপ-ষ্টোর হতে ইন্সটল করুন। ধন্যবাদ",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              const SizedBox(height: 70),
              // Update button
              SizedBox(
                height: 52.0,
                child: CustomActionButton(
                  text: "আপডেট করুন",
                  onPressed: () async {
                    // url lunch
                    if (!await launchUrl(url)) {
                      throw Exception('Could not launch $url');
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
