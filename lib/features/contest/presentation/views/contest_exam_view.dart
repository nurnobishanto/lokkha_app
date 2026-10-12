import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import 'package:lokkha/core/constants/app_constants.dart';
import 'package:lokkha/core/enums/question_type.dart';
import 'package:lokkha/features/contest/contest.dart';
import 'package:lokkha/shared/models/question.dart';
import 'package:lokkha/shared/widgets/custom_action_button.dart';

class ContestExamView extends ConsumerWidget {
  final ContestStartModel examStartModel;

  const ContestExamView({super.key, required this.examStartModel});

  void _showExitConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('পরীক্ষা বাতিল?'),
        content: const Text(
            'আপনি যদি এখন পরীক্ষা বাতিল করেন,আপনার উত্তর সংরক্ষিত হবে না।'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text("না"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop(); // Close dialog
              Navigator.of(context).pop(); // Exit exam page
            },
            child: const Text('হ্যাঁ, বাতিল'),
          ),
        ],
      ),
    );
  }

  void _showSubmitConfirmationDialog(
      BuildContext context, ContestExamNotifier notifier) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('পরীক্ষা জমা দিবেন?'),
        content: const Text(
            'একবার জমা দিলে আপনি আর পরিবর্তন করতে পারবেন না। নিশ্চিত?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text("না"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              notifier.finalSubmitExam(context: context);
            },
            child: const Text('হ্যাঁ, জমা দিবো'),
          ),
        ],
      ),
    );
  }

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examState = ref.watch(contestExamNotifierProvider(examStartModel));
    final notifier =
        ref.read(contestExamNotifierProvider(examStartModel).notifier);
    final questionList = examStartModel.questions;

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
          child: Text('কোন প্রশ্ন নেই!'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: LightThemeColors.primaryColor,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => _showExitConfirmationDialog(context),
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
          // Timer
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    "সময় বাকি : ${_formatDuration(examState.durationSeconds)} মিনিট",
                    style: AppTextStyles.heading4
                        .copyWith(color: LightThemeColors.white),
                  ),
                ],
              ),
            ),
          ),

          // Question list
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

                          if (question.description != null)
                            HtmlWidget(question.description.toString()),
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
                          _buildSingleChoice(examState, notifier, question),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          examState.isLoading
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(),
                )
              : CustomActionButton(
                  text: "সাবমিট এক্সাম",
                  onPressed: () =>
                      _showSubmitConfirmationDialog(context, notifier),
                ),
        ],
      ),
    );
  }

  Widget _buildSingleChoice(ContestExamState examState,
      ContestExamNotifier notifier, Question question) {
    if (question.options == null) return const SizedBox.shrink();

    return Column(
      children: question.options!.map((option) {
        return RadioListTile<String>(
          dense: true,
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          value: option.key.toString(),
          groupValue: examState.selectedAnswers[question.id] ?? '',
          onChanged: (value) {
            if (value != null &&
                examState.selectedAnswers[question.id] == null) {
              notifier.selectAnswer(question.id!.toInt(), value);
            }
          },
          title: HtmlWidget(option.value.toString()),
          activeColor: LightThemeColors.primaryColor,
          controlAffinity: ListTileControlAffinity.leading,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
        );
      }).toList(),
    );
  }
}
