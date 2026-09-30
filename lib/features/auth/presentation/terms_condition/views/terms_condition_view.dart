import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:lokkha/core/services/app_update_service.dart';
import 'package:lokkha/shared/widgets/base_webview.dart';
import '../controllers/terms_condition_controller.dart';

class TermsConditionView extends GetView<TermsConditionController> {
  const TermsConditionView({super.key});

  @override
  Widget build(BuildContext context) {
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
