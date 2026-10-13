import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/core/network/endpoints.dart';
import 'package:lokkha/features/contest/contest.dart';
import 'package:lokkha/shared/shared.dart';

class ContestSubmitView extends StatelessWidget {
  final ContestSubmitModel model;
  const ContestSubmitView({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final questionList = model.results;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          "ফলাফল",
          style: AppTextStyles.heading3.copyWith(color: LightThemeColors.white),
        ),
        iconTheme: const IconThemeData(color: LightThemeColors.white),
        centerTitle: true,
        backgroundColor: LightThemeColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.00),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title for the result summary
              Text(
                "ফলাফল সারাংশ",
                style: AppTextStyles.heading3
                    .copyWith(color: LightThemeColors.primaryColor),
              ),
              const SizedBox(height: 8),
              if (model.summary != null) ...[
                FittedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSummaryItem("মোট প্রশ্ন", model.summary!.total),
                      _buildSummaryItem("চেষ্টা", model.summary!.attempt),
                      _buildSummaryItem("নম্বর", model.summary!.mark),
                    ],
                  ),
                ),
                const SizedBox(height: 5.00),
                FittedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSummaryItem("ভুল উত্তর", model.summary!.incorrect),
                      _buildSummaryItem("সঠিক উত্তরসমূহ", model.summary!.correct),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              if (questionList != null)
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: questionList.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final question = questionList[index];
                    return Card(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: LightThemeColors.primaryColor, width: 1.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (question.question?.questionImage != null)
                                Image.network(
                                  "${Endpoints.storageUrl}${question.question!.questionImage}",
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.error,
                                          color: Colors.red),
                                ),
                              if (question.question?.questionImage != null)
                                const SizedBox(height: 10.00),

                              if (question.question?.description != null)
                                HtmlWidget(
                                  question.question!.description.toString(),
                                ),
                              if (question.question?.description != null)
                                const SizedBox(height: 10.00),

                              Container(
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  color: LightThemeColors.primaryColor,
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(8.0),
                                    topLeft: Radius.circular(8.0),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 10,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: HtmlWidget(
                                          "${index + 1}. ${question.question?.title ?? ''}",
                                          textStyle: AppTextStyles.body1
                                              .copyWith(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              customSingleChoice(context, question),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget customSingleChoice(BuildContext context, Result question) {
    String userSelectedAnswer = "";

    if (question.userAnswer != null) {
      if (question.isAttempt == true) {
        userSelectedAnswer = question.userAnswer!.first.toString();
      }
    }

    String selectedAnswer = "";
    if (userSelectedAnswer.isNotEmpty) {
      selectedAnswer = userSelectedAnswer;
      RegExp regex = RegExp(r'answer:\s*(.*)}');
      Match? match = regex.firstMatch(userSelectedAnswer);
      if (match != null) {
        selectedAnswer = match.group(1) ?? '';
      }
    }

    final options = question.question?.options ?? [];

    return Column(
      children: [
        Column(
          children: options.map((option) {
            bool isSelected = question.isAttempt == true;
            return RadioListTile<String>(
              dense: true,
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              value: option.key.toString(),
              groupValue: selectedAnswer.trim(),
              onChanged: null,
              title: HtmlWidget(
                option.value ?? '',
                textStyle: AppTextStyles.body1.copyWith(
                  color: isSelected
                      ? (option.isCorrect == true ? Colors.green : Colors.red)
                      : Colors.black,
                ),
              ),
              activeColor: LightThemeColors.primaryColor,
              controlAffinity: ListTileControlAffinity.leading,
            );
          }).toList(),
        ),
        Row(
          children: [
            Expanded(
              child: ExamCustomButton(
                text: "উত্তর ও সমাধান",
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("উত্তর ও সমাধান"),
                      content: SingleChildScrollView(
                        child: AnswerAndSolutionWidgets(question: question),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("বন্ধ করুন"),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildSummaryItem(String label, dynamic value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: LightThemeColors.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Text(label, style: AppTextStyles.body2),
          const SizedBox(height: 2),
          Text(
            value?.toString() ?? '0',
            style: AppTextStyles.heading5
                .copyWith(color: LightThemeColors.primaryColor),
          ),
        ],
      ),
    );
  }
}

class AnswerAndSolutionWidgets extends StatelessWidget {
  final Result question;
  const AnswerAndSolutionWidgets({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAnswerSection(context),
        if (question.question?.explanation != null) ...[
          const SizedBox(height: 10),
          _buildExplanationSection(context),
        ],
        if (question.question?.explanationImage != null) ...[
          const SizedBox(height: 10),
          _buildExplanationImage(context),
        ],
      ],
    );
  }

  Widget _buildAnswerSection(BuildContext context) {
    final options = question.question?.options ?? [];
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "সঠিক উত্তর",
            style: AppTextStyles.heading5,
          ),
          const SizedBox(height: 8),
          ...options.where((o) => o.isCorrect == true).map(
                (option) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: HtmlWidget(
                    option.value ?? '',
                    textStyle: AppTextStyles.body1,
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildExplanationSection(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ব্যাখ্যা",
            style: AppTextStyles.heading5,
          ),
          const SizedBox(height: 8),
          HtmlWidget(
            question.question!.explanation.toString(),
            textStyle: AppTextStyles.body1,
          ),
        ],
      ),
    );
  }

  Widget _buildExplanationImage(BuildContext context) {
    String fileUrl = Endpoints.storageUrl +
        question.question!.explanationImage.toString();
    bool isPdf = fileUrl.toLowerCase().endsWith('.pdf');
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ছবির ব্যাখ্যা",
            style: AppTextStyles.heading5,
          ),
          const SizedBox(height: 8),
          isPdf
              ? InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PdfViewerScreen(
                          title: 'ব্যাখ্যা',
                          file: fileUrl,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.picture_as_pdf, color: Colors.red),
                        SizedBox(width: 8),
                        Text('পিডিএফ দেখুন'),
                      ],
                    ),
                  ),
                )
              : Image.network(
                  fileUrl,
                  errorBuilder: (_, __, ___) => const Icon(Icons.error),
                ),
        ],
      ),
    );
  }
}
