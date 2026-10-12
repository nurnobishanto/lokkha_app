import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:lokkha/app/router/router.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/shared/models/question.dart';

class ExplanationDialog {
  static void show(Question question, [BuildContext? context]) {
    final ctx = context ?? rootNavigatorKey.currentContext;
    if (ctx == null) return;
    showDialog(
      context: ctx,
      builder: (dialogContext) => AlertDialog(
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
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text("বন্ধ করুন"),
          )
        ],
      ),
    );
  }
}
