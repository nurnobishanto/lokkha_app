import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:lokkha/app/modules/contest/models/contest_start_model.dart';

import '../../../../config/theme/light_theme_colors.dart';
import '../../../../styles/text_style.dart';
import '../../../../utils/constants.dart';
import '../../../components/custom_action_button.dart';
import '../../../enums/question_type.dart';
import '../../../models/question.dart';
import '../controller/contest_start_controller.dart';

class ContestExamView extends StatefulWidget {
  final ContestStartModel examStartModel;

  const ContestExamView({super.key, required this.examStartModel});

  @override
  State<ContestExamView> createState() => _ContestExamViewState();
}

class _ContestExamViewState extends State<ContestExamView> {
  late final ContestStartController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ContestStartController(widget.examStartModel));
  }

  @override
  Widget build(BuildContext context) {
    final questionList = widget.examStartModel.questions;

    if (questionList == null || questionList.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            "পরীক্ষা",
            style:
                AppTextStyles.heading4.copyWith(color: LightThemeColors.white),
          ),
          centerTitle: true,
          backgroundColor: LightThemeColors.primaryColor,
        ),
        body: const Center(
          child: Text(
            'কোন প্রশ্ন নেই!',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: LightThemeColors.primaryColor,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            controller.showExitConfirmationDialog();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        iconTheme: const IconThemeData(color: LightThemeColors.white),
        title: Text(
          "পরীক্ষা",
          style: AppTextStyles.heading4.copyWith(color: LightThemeColors.white),
        ),
      ),
      body: Column(
        children: [
          // Display timer (isolated Obx so only timer updates every second)
          Obx(() {
            if (controller.timerWork.value != true || controller.duration == null) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.access_time,
                        size: 18.0, color: Colors.white),
                    const SizedBox(width: 8.0),
                    Text(
                      "সময় বাকি : ${_formatDuration(controller.duration!.value)} মিনিট",
                      style: AppTextStyles.heading4
                          .copyWith(color: LightThemeColors.white),
                    ),
                  ],
                ),
              ),
            );
          }),

            // Question choice area
            Expanded(
              child: ListView.builder(
                itemCount: questionList.length,
                itemBuilder: (context, index) {
                  final question = questionList[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
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
                            if (question.questionImage != null)
                              Image.network(
                                "${AppConstants.storageUrl}${question.questionImage}",
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.error, color: Colors.red),
                              ),
                            if (question.questionImage != null)
                              const SizedBox(height: 10.00),

                            /// Description
                            question.description != null
                                ? HtmlWidget(question.description.toString())
                                : const SizedBox(),
                            if (question.description != null)
                              const SizedBox(height: 10.00),

                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 7),
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
                                        "${index + 1}. ${question.title}",
                                        textStyle: AppTextStyles.body1
                                            .copyWith(color: Colors.white),
                                      ),
                                    ),
                                  ),

                                ],
                              ),
                            ),
                            customQuestionWidget(controller, question),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          CustomActionButton(
            text: "সাবমিট এক্সাম",
            onPressed: () {
              controller.showSubmitConfirmationDialog();
            },
          ),
        ],
      ),
    );
  }

  // Helper to format the remaining time as mm:ss
  String _formatDuration(int totalSeconds) {
    final hours = (totalSeconds / 3600).floor();
    final remainingMinutes = ((totalSeconds % 3600) / 60).floor();
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return "${hours.toString().padLeft(2, '0')}:${remainingMinutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
    } else {
      return "${remainingMinutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
    }
  }

  Widget customQuestionWidget(
      ContestStartController controller, Question question) {
    switch (question.questionType) {
      // case QuestionType.FILL_IN_THE_BLANK:
      //   return _buildFillInTheBlank(controller, question);
      case QuestionType.SINGLE_CHOICE:
        return _buildSingleChoice(controller, question);
      // case QuestionType.MULTIPLE_CHOICE:
      //   return _buildMultipleChoice(controller, question);
      default:
        return Container();
    }
  }

  Widget _buildSingleChoice(
      ContestStartController controller, Question question) {
    return Column(
      children: question.options!.map((option) {
        // Check if the option is already selected
        // bool isSelected =
        //     controller.selectedAnswers[question.id] == option;

        return Obx(() {
          return RadioListTile<String>(
            dense: true,
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            value: option.key.toString(),
            groupValue: controller.selectedAnswers[question.id] ??
                '', // The selected value of the group
            onChanged: (value) {
              debugPrint("evaluational$value");
              // Only allow selection if no answer has been chosen already
              if (controller.selectedAnswers[question.id] == null) {
                controller.selectAnswer(question.id!.toInt(), value!);
              }
            },
            title: HtmlWidget(option.value.toString()),

            activeColor: LightThemeColors.primaryColor,
            controlAffinity: ListTileControlAffinity.leading,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.0),
            ),
          );
        });
      }).toList(),
    );
  }
}
