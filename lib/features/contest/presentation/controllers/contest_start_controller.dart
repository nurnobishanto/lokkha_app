import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lokkha/features/contest/contest.dart';

import 'package:lokkha/core/constants/app_constants.dart';
import 'package:lokkha/core/services/storage/my_shared_pref.dart';
import 'package:lokkha/core/network/api_call_status.dart';
import 'package:lokkha/core/network/base_client.dart';
import '../views/contest_submit_view.dart';

class ContestStartController extends GetxController {
  ContestStartModel? exam; // Exam data
  RxInt? duration;
  RxBool timerWork = false.obs;
  Timer? timer;
  RxBool isExamSubmitted = false.obs;

  var selectedAnswers = <int, dynamic>{}.obs;
  RxBool isLoading = true.obs;
  ApiCallStatus apiCallStatus = ApiCallStatus.holding;

  Future<void> finalSubmitExam() async {
    isLoading.value = true;
    String? token = MySharedPref.getUserToken();
    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    };
    final url = "${AppConstants.startContest}${exam!.contest!.id}/submit";
    // Convert userAnswers map to a list of JSON objects
    List<Map<String, dynamic>> userAnswersArray =
        userAnswers.values.map((userAnswer) => userAnswer.toJson()).toList();
    Map<String, dynamic> data = {
      'user_answers': userAnswersArray,
    };
    log("log${data.toString()}");

    BaseClient.safeApiCall(
      url,
      RequestType.post,
      headers: headers,
      data: data,
      onSuccess: (response) async {
        apiCallStatus = ApiCallStatus.success;
        if (response.data['status']) {
          log("Success Submit");
          // CustomSnackBar.showCustomToast(
          //     message: response.data['message'].toString());
          await MySharedPref.clearMockSubjects();
          //
          ContestSubmitModel modelData =
              ContestSubmitModel.fromJson(response.data);

          // log("My Data: ${modelData.toString()}");
          Get.snackbar("Exam", "Exam submitted successfully.");
          log("My Data: ${response.toString()}");
          isLoading.value = false;
          Get.off(ContestSubmitView(model: modelData));
        } else {
          log("Errrrrrrrr");
          // CustomSnackBar.showCustomToast(
          //     message: response.data["message"].toString());
          //Utils.toastMessage(response["message"].toString());
          isLoading.value = false;
        }
      },
    );
  }

  // Store user answers in a Map where key = question index, value = user's input
  var userAnswers = <int, UserAnswer>{}.obs;

  //MockExamQuestionController(this.exam) : duration = (exam!.duration != null ? exam.duration! * 60 : 0).obs;
  ContestStartController(this.exam)
      : duration =
            (exam!.contest!.duration != null ? exam.contest!.duration! : 0).obs,
        timerWork = true.obs;

  void selectAnswer(int questionId, dynamic answer) {
    // If the question doesn't have an answer already, allow the selection
    if (selectedAnswers[questionId] == null) {
      selectedAnswers[questionId] = answer;
    }
    _initializeUserAnswers();
  }

  @override
  void onInit() {
    super.onInit();
    if (timerWork.value) {
      startTimer();
    }
    _initializeUserAnswers();
  }

  void _initializeUserAnswers() {
    for (int i = 0; i < exam!.questions!.length; i++) {
      // Get the selected answer for the current question
      var selectedAnswer = selectedAnswers[exam!.questions![i].id];

      // Ensure the answer is always a list (if it's not null)
      var answerAsList = (selectedAnswer != null)
          ? (selectedAnswer is List ? selectedAnswer : [selectedAnswer])
          : null;

      // Initialize userAnswers for the current question with questionId and answer as a list
      userAnswers[i] = UserAnswer(
        questionId: exam!.questions![i].id!.toInt(),
        answers: answerAsList, // Store as list or null if no answer
      );
    }
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (duration!.value > 0) {
        duration!.value--;
      } else {
        submitExam();
        timer.cancel();
      }
    });
  }

  void submitExam() {
    finalSubmitExam();
    if (!isExamSubmitted.value) {
      isExamSubmitted.value = true;
    }
  }

  void showExitConfirmationDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('পরীক্ষা বাতিল?'),
        content: const Text(
            'আপনি যদি এখন পরীক্ষা বাতিল করেন,আপনার উত্তর সংরক্ষিত হবে না।'),
        actions: [
          TextButton(
            onPressed: () => Get.back(), // Close dialog
            child: const Text("না"),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(); // Exit the exam page
            },
            child: const Text('হ্যাঁ, বাতিল'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void showSubmitConfirmationDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('পরীক্ষা জমা দিবেন?'),
        content: const Text(
            'একবার জমা দিলে আপনি আর পরিবর্তন করতে পারবেন না। নিশ্চিত?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(), // Close dialog
            child: const Text("না"),
          ),
          TextButton(
            onPressed: () {
              submitExam(); // Execute submit function
              Get.back(); // Close dialog
            },
            child: const Text('হ্যাঁ, জমা দিবো'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}

class UserAnswer {
  final int questionId; // ID of the question
  dynamic answers; // List of answers for the question

  UserAnswer({
    required this.questionId,
    this.answers,
  });

  // Method to convert UserAnswer instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'answer': answers,
    };
  }

  // Factory method to create a UserAnswer instance from JSON
  factory UserAnswer.fromJson(Map<String, dynamic> json) {
    return UserAnswer(
      questionId: json['question_id'],
      answers: json['answer'],
    );
  }

  // Override toString to print UserAnswer details
  @override
  String toString() {
    return '{question_id: $questionId, answer: $answers}';
  }
}
