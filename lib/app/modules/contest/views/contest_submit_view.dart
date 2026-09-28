import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:lokkha/app/modules/contest/models/contest_submit_model.dart';

import '../../../../config/theme/light_theme_colors.dart';
import '../../../../styles/text_style.dart';
import '../../../../utils/constants.dart';
import '../../../views/views/pdf_viewer.dart';
import '../../../views/widgets/exam_custom_button.dart';
import '../controller/contest_submit_controller.dart';

class ContestSubmitView extends StatelessWidget {
  final ContestSubmitModel model;
  const ContestSubmitView({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final questionList = model.results;
    Get.put(ContestSubmitController());
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
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                itemCount: questionList!.length,
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
                            if (question.question!.questionImage != null)
                              Image.network(
                                "${AppConstants.storageUrl}${question.question!.questionImage}",
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.error, color: Colors.red),
                              ),
                            question.question!.questionImage != null
                                ? const SizedBox(height: 10.00)
                                : const SizedBox.shrink(),

                            /// des
                            if (question.question!.description != null)
                              HtmlWidget(
                                question.question!.description.toString(),
                              ),
                            question.question!.description != null
                                ? const SizedBox(height: 10.00)
                                : const SizedBox.shrink(),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 10,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: HtmlWidget(
                                        "${index + 1}. ${question.question!.title}",
                                        textStyle: AppTextStyles.body1
                                            .copyWith(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            //customQuestionWidget(question),
                            customSingleChoice(question)
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

  Widget customSingleChoice(Result question) {
    String userSelectedAnswer = "";

    if (question.userAnswer != null) {
      if (question.isAttempt == true) {
        userSelectedAnswer = question.userAnswer!.first.toString();
      }
    }

    String? selectedAnswer = "";
    if (userSelectedAnswer.isNotEmpty) {
      selectedAnswer = userSelectedAnswer.toString();
      RegExp regex = RegExp(r'answer:\s*(.*)}');
      Match? match = regex.firstMatch(userSelectedAnswer.toString());
      if (match != null) {
        selectedAnswer = match.group(1)!;
      }
    }
    return Column(
      children: [
        Column(
          children: question.question!.options!.map((option) {
            bool isSelected = question.isAttempt == true;
            return RadioListTile<String>(
              dense: true,
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              value: option.key.toString(),
              groupValue: selectedAnswer!.trim(),
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
          spacing: 10.0,
          children: [
            Expanded(
              child: ExamCustomButton(
                text: "উত্তর ও সমাধান",
                onPressed: () {
                  Get.defaultDialog(
                      title: "উত্তর ও সমাধান",
                      content: AnswerAndSolutionWidgets(question: question));
                },
              ),
            ),
          ],
        )
      ],
    );
  }

  // Widget customQuestionWidget(
  //     Result result) {
  //
  //
  //   switch (result.question!.questionType) {
  //     case QuestionType.FILL_IN_THE_BLANK:
  //       return customFillInTheBlank(controller, question);
  //     case QuestionType.SINGLE_CHOICE:
  //       return customSingleChoice(controller, question);
  //     case QuestionType.MULTIPLE_CHOICE:
  //       return customMultipleChoice(controller, question);
  //     default:
  //       return Container();
  //   }
  // }
  // Helper method to display each summary item
  Widget _buildSummaryItem(String title, dynamic value) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.00),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                value.toString(),
                style: AppTextStyles.heading6,
              ),
              Text(
                title,
                style: AppTextStyles.body1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnswerAndSolutionWidgets extends StatelessWidget {
  final dynamic question;

  const AnswerAndSolutionWidgets({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (question.question != null && question.question!.options != null)
          _buildAnswerSection(),
        (question.question != null && question.question!.explanation != null)
            ? _buildExplanationSection(context)
            : const SizedBox.shrink(),
        (question.question != null &&
                question.question!.explanationImage != null)
            ? _buildExplanationImage()
            : const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildAnswerSection() {
    return SizedBox(
      width: Get.width,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "সঠিক উত্তর",
              style: AppTextStyles.heading5,
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 8),
            // if (question.question!.questionType == QuestionType.FILL_IN_THE_BLANK)
            //   ...question.question!.answer!.map((answer) => Padding(
            //     padding: const EdgeInsets.only(bottom: 4.0),
            //     child: Text(answer['answer'],
            //         style: const TextStyle(fontSize: 14)),
            //   ))
            // else
            ...question.question!.options!.map((option) {
              return option.value != null && option.isCorrect == true
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: HtmlWidget(
                        option.value!,
                        textStyle: AppTextStyles.body1,
                      ),
                    )
                  : const SizedBox.shrink();
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationSection(context) {
    return SizedBox(
      width: Get.width,
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

  Widget _buildExplanationImage() {
    String fileUrl = AppConstants.storageUrl +
        question.question!.explanationImage.toString();
    bool isPdf = fileUrl.toLowerCase().endsWith('.pdf');
    return SizedBox(
      width: Get.width,
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
                    Get.to(() => PdfViewerScreen(
                          title: 'ব্যাখ্যা',
                          file: fileUrl,
                        ));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.picture_as_pdf,
                            color: Colors.red, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          "ব্যাখ্যা",
                          style: AppTextStyles.heading5
                              .copyWith(color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                )
              : Image.network(
                  AppConstants.storageUrl +
                      question.question!.explanationImage.toString(),
                  fit: BoxFit.cover,
                ),
        ],
      ),
    );
  }
}
