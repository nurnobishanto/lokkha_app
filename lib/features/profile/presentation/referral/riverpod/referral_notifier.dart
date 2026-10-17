import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/utils/share_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';
import 'package:lokkha/core/utils/global.dart';
import 'package:lokkha/features/profile/data/repositories/referral_repository.dart';

class ReferralState {
  final String referralCode;
  final String referralLink;
  final int totalInvited;
  final int earnedPoints;
  final int successfulReferrals;
  final List<dynamic> referredUsers;

  const ReferralState({
    this.referralCode = '',
    this.referralLink = '',
    this.totalInvited = 0,
    this.earnedPoints = 0,
    this.successfulReferrals = 0,
    this.referredUsers = const [],
  });

  ReferralState copyWith({
    String? referralCode,
    String? referralLink,
    int? totalInvited,
    int? earnedPoints,
    int? successfulReferrals,
    List<dynamic>? referredUsers,
  }) {
    return ReferralState(
      referralCode: referralCode ?? this.referralCode,
      referralLink: referralLink ?? this.referralLink,
      totalInvited: totalInvited ?? this.totalInvited,
      earnedPoints: earnedPoints ?? this.earnedPoints,
      successfulReferrals: successfulReferrals ?? this.successfulReferrals,
      referredUsers: referredUsers ?? this.referredUsers,
    );
  }
}

class ReferralNotifier extends Notifier<ReferralState> {
  final ReferralRepository _referralRepo = ReferralRepository();

  @override
  ReferralState build() {
    final user = myUser;
    final code = (user.referralCode != null && user.referralCode!.isNotEmpty)
        ? user.referralCode!
        : "LK${user.userId ?? 'C05189'}";
    final link = "https://lokkha.com/register?ref=$code";

    final initialState = ReferralState(
      referralCode: code,
      referralLink: link,
    );

    _loadStats();
    return initialState;
  }

  Future<void> _loadStats() async {
    final stats = await _referralRepo.getReferralStats();
    if (stats != null) {
      state = state.copyWith(
        referralCode: stats.referralCode.isNotEmpty ? stats.referralCode : state.referralCode,
        referralLink: stats.referralLink.isNotEmpty ? stats.referralLink : state.referralLink,
        totalInvited: stats.totalInvited,
        earnedPoints: stats.earnedPoints,
        successfulReferrals: stats.successfulReferrals,
        referredUsers: stats.referredUsers,
      );
    }
  }

  void copyReferralCode() {
    if (state.referralCode.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: state.referralCode));
      CustomSnackBar.showCustomToast(message: "রেফার কোড কপি করা হয়েছে!");
    }
  }

  void copyReferralLink() {
    if (state.referralLink.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: state.referralLink));
      CustomSnackBar.showCustomToast(message: "রেফারেল লিংক কপি করা হয়েছে!");
    }
  }

  Future<void> shareReferral() async {
    final message = "লক্ষ্য অ্যাপে আমার রেফারেল কোড: ${state.referralCode} ব্যবহার করে "
        "রেজিস্ট্রেশন করুন এবং এক্সক্লুসিভ বেনিফিট পান!\n\nলিংক: ${state.referralLink}";
    await ShareHelper.share(message, subject: "লক্ষ্য অ্যাপ রেফারেল");
  }

  Future<void> shareWhatsApp() async {
    final link = state.referralLink;
    final url = "whatsapp://send?text=${Uri.encodeComponent('Join Lokkha: $link')}";
    await _launchURL(url);
  }

  void shareFacebook() {
    final link = state.referralLink;
    ShareHelper.share("Join Lokkha: $link");
  }

  Future<void> shareTelegram() async {
    final link = state.referralLink;
    final url = "https://t.me/share/url?url=${Uri.encodeComponent(link)}";
    await _launchURL(url);
  }

  void shareGeneric() {
    final link = state.referralLink;
    ShareHelper.share("Join Lokkha: $link");
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ShareHelper.share("Join Lokkha: ${state.referralLink}");
      }
    } catch (_) {
      ShareHelper.share("Join Lokkha: ${state.referralLink}");
    }
  }
}

final referralNotifierProvider = NotifierProvider<ReferralNotifier, ReferralState>(ReferralNotifier.new);
