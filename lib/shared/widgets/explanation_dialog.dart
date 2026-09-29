import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/shared/models/question.dart';

class ExplanationDialog {
  static void show(Question question) {
    Get.dialog(
      AlertDialog(
        title: Text(
          "ব্যাখ্যা",
          textAlign: TextAlign.center,
          style: AppTextStyles.heading4.copyWith(
            color: LightThemeColors.primaryColor,
          ),
        ),
        content: SingleChildScrollView(
          child: HtmlWidget(
            question.explanation ?? '',
            textStyle: AppTextStyles.body1,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("বন্ধ করুন"),
          )
        ],
      ),
    );
  }
}
