import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lokkha/shared/shared.dart';
import 'package:lokkha/core/core.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CustomerSupportView extends GetView {
  const CustomerSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'কাস্টমার সাপোর্ট'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "হটলাইন নম্বর",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => makePhoneCall('+8801332804290'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CachedNetworkImage(
                      imageUrl: OnlineImagePaths.phoneCall,
                      scale: 25.00.r,
                      errorWidget: (_, error, stackTrace) {
                        return const Icon(
                          Icons.error,
                          color: Colors.grey,
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    const Text('+8801332804290',
                        style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CachedNetworkImage(
                    imageUrl: OnlineImagePaths.facebook,
                    scale: 3.0.r,
                    errorWidget: (_, __, stackTrace) {
                      return const Icon(
                        Icons.error,
                        color: Colors.grey,
                      );
                    },
                  ),
                  // Image.asset('assets/icons/facebook.png', width: 24, height: 24),
                  const SizedBox(width: 8),
                  const Text('ফেসবুক পেজ', style: TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  launchUrlString('https://facebook.com/lokkhabd');
                },
                child: Container(
                  height: 40,
                  width: 250,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF003277), Color(0xFF002AE8)],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Center(
                    child: Text(
                      'বার্তা পাঠান',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CachedNetworkImage(
                    imageUrl: OnlineImagePaths.whatsApp,
                    scale: 2.8.r,
                    errorWidget: (_, __, stackTrace) {
                      return const Icon(
                        Icons.error,
                        color: Colors.grey,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text('অনলাইন সাপোর্ট', style: TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  launchUrlString(
                      'https://api.whatsapp.com/send?phone=8801334260543&text=Hello');
                },
                child: Container(
                  height: 40,
                  width: 250,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF00492F), Color(0xFF00A667)],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Center(
                    child: Text(
                      'অনলাইন সাপোর্টে বার্তা পাঠান',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'কর্পোরেট অফিস',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'রূপায়ন-লতিফা শামসুদ্দিন স্কয়ার, ১০ম তলা, প্লট-০৩, রোড-০১, সেকশন-০১, মিরপুর, ঢাকা-১২১৬',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'ডেভেলপ করেছে:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 10),
                  CachedNetworkImage(
                    imageUrl: OnlineImagePaths.techyfo,
                    scale: 4.0.r,
                    errorWidget: (_, __, stackTrace) {
                      return const Icon(
                        Icons.error,
                        color: Colors.grey,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'ভার্সন: $appVersion',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrlString(launchUri.toString());
  }
}
