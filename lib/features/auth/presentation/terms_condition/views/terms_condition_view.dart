import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokkha/core/services/app_update_service.dart';
import 'package:lokkha/shared/widgets/base_webview.dart';

class TermsConditionView extends ConsumerWidget {
  const TermsConditionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final termsUrl = AppUpdateService()
                .appInfo
                .value
                ?.data
                .legalLinks
                .termsAndConditions
                .isNotEmpty ==
            true
        ? AppUpdateService().appInfo.value!.data.legalLinks.termsAndConditions
        : 'https://lokkha.com/terms-and-conditions';

    return BaseWebView(
      title: 'শর্তাবলী ও নীতিমালা',
      url: termsUrl,
    );
  }
}
