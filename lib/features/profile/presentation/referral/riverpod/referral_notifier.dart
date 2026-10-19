import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/utils/share_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lokkha/shared/widgets/custom_snackbar.dart';
import 'package:lokkha/core/utils/global.dart';
import 'package:lokkha/features/profile/data/repositories/referral_repository.dart';
import 'package:lokkha/features/quick_practice/data/models/quick_practice_models.dart';

export 'package:lokkha/features/profile/data/models/referral_model.dart';

final referralRepositoryProvider = Provider<ReferralRepository>((ref) {
  return ReferralRepository();
});

class ReferralState {
  final String referralCode;
  final String referralLink;
  final int totalReferrals;
  final int successfulReferrals;
  final int totalPointsEarned;
  final List<ReferralItem> items;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final PaginationMeta meta;

  // Backward compatibility getters
  int get totalInvited => totalReferrals;
  int get earnedPoints => totalPointsEarned;
  List<dynamic> get referredUsers => items;

  const ReferralState({
    this.referralCode = '',
    this.referralLink = '',
    this.totalReferrals = 0,
    this.successfulReferrals = 0,
    this.totalPointsEarned = 0,
    this.items = const [],
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.meta = const PaginationMeta(),
  });

  ReferralState copyWith({
    String? referralCode,
    String? referralLink,
    int? totalReferrals,
    int? successfulReferrals,
    int? totalPointsEarned,
    List<ReferralItem>? items,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    PaginationMeta? meta,
  }) {
    return ReferralState(
      referralCode: referralCode ?? this.referralCode,
      referralLink: referralLink ?? this.referralLink,
      totalReferrals: totalReferrals ?? this.totalReferrals,
      successfulReferrals: successfulReferrals ?? this.successfulReferrals,
      totalPointsEarned: totalPointsEarned ?? this.totalPointsEarned,
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      meta: meta ?? this.meta,
    );
  }
}

class ReferralNotifier extends Notifier<ReferralState> {
  final ReferralRepository? _repoOverride;

  ReferralNotifier({ReferralRepository? repository}) : _repoOverride = repository;

  ReferralRepository get _referralRepo =>
      _repoOverride ?? ref.read(referralRepositoryProvider);

  @override
  ReferralState build() {
    final user = myUser;
    final code = (user.referralCode != null && user.referralCode!.isNotEmpty)
        ? user.referralCode!
        : "LK${user.userId ?? 'C05189'}";
    final link = (user.referralLink != null && user.referralLink!.isNotEmpty)
        ? user.referralLink!
        : "https://lokkha.com/register?ref=$code";

    final initialState = ReferralState(
      referralCode: code,
      referralLink: link,
      isLoading: true,
    );

    Future.microtask(() => loadReferralData());
    return initialState;
  }

  Future<void> loadReferralData({bool isRefresh = false}) async {
    state = state.copyWith(
      isLoading: !isRefresh && state.items.isEmpty,
      hasError: false,
      errorMessage: null,
    );

    try {
      final res = await _referralRepo.getReferralDetails(page: 1);
      if (res != null && res.success) {
        state = state.copyWith(
          referralCode: res.data.referralCode.isNotEmpty
              ? res.data.referralCode
              : state.referralCode,
          referralLink: res.data.referralLink.isNotEmpty
              ? res.data.referralLink
              : state.referralLink,
          totalReferrals: res.data.totalReferrals,
          successfulReferrals: res.data.successfulReferrals,
          totalPointsEarned: res.data.totalPointsEarned,
          items: res.data.items,
          meta: res.meta,
          isLoading: false,
          hasError: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          hasError: false, // fallback to initial empty state without harsh red error
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'রেফারেল তথ্য লোড করা যায়নি',
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

final referralNotifierProvider =
    NotifierProvider<ReferralNotifier, ReferralState>(ReferralNotifier.new);
