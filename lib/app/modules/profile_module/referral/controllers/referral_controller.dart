import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../components/custom_snackbar.dart';
import '../../../../helper/global.dart';

class ReferralController extends GetxController {
  final referralCode = ''.obs;
  final referralLink = ''.obs;

  final totalInvited = 0.obs;
  final earnedPoints = 0.obs;
  final successfulReferrals = 0.obs;

  final referredUsers = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initReferralData();
  }

  void _initReferralData() {
    final user = myUser;
    final code = (user.referralCode != null && user.referralCode!.isNotEmpty)
        ? user.referralCode!
        : "LK${user.userId ?? 'C05189'}";
    referralCode.value = code;
    referralLink.value = "https://lokkha.com/register?ref=$code";
  }

  void copyReferralCode() {
    if (referralCode.value.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: referralCode.value));
      CustomSnackBar.showCustomToast(message: "রেফার কোড কপি করা হয়েছে!");
    }
  }

  void copyReferralLink() {
    if (referralLink.value.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: referralLink.value));
      CustomSnackBar.showCustomToast(message: "রেফারেল লিংক কপি করা হয়েছে!");
    }
  }

  Future<void> shareWhatsApp() async {
    final link = referralLink.value;
    final url = "whatsapp://send?text=${Uri.encodeComponent('Join Lokkha: $link')}";
    await _launchURL(url);
  }

  void shareFacebook() {
    final link = referralLink.value;
    SharePlus.instance.share(
      ShareParams(text: "Join Lokkha: $link"),
    );
  }

  Future<void> shareTelegram() async {
    final link = referralLink.value;
    final url = "https://t.me/share/url?url=${Uri.encodeComponent(link)}";
    await _launchURL(url);
  }

  void shareGeneric() {
    final link = referralLink.value;
    SharePlus.instance.share(
      ShareParams(text: "Join Lokkha: $link"),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        SharePlus.instance.share(
          ShareParams(text: "Join Lokkha: ${referralLink.value}"),
        );
      }
    } catch (_) {
      SharePlus.instance.share(
        ShareParams(text: "Join Lokkha: ${referralLink.value}"),
      );
    }
  }
}
