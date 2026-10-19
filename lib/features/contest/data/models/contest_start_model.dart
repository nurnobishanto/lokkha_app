import 'dart:convert';
import 'package:lokkha/shared/models/contest.dart';
import 'package:lokkha/shared/models/question.dart';

ContestStartModel contestStartModelFromJson(String str) =>
    ContestStartModel.fromJson(json.decode(str));

String contestStartModelToJson(ContestStartModel data) =>
    json.encode(data.toJson());

class ContestStartModel {
  final bool? status;
  final Contest? contest;
  final List<Question>? questions;
  final String? message;
  final bool? packageRequired;

  ContestStartModel({
    this.status,
    this.contest,
    this.questions,
    this.message,
    this.packageRequired,
  });

  factory ContestStartModel.fromJson(Map<String, dynamic> json) =>
      ContestStartModel(
        status: json["status"],
        contest:
            json["contest"] == null ? null : Contest.fromJson(json["contest"]),
        questions: json["questions"] == null
            ? []
            : List<Question>.from(
                json["questions"]!.map((x) => Question.fromJson(x))),
        message: json["message"]?.toString(),
        packageRequired: json["package_required"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "contest": contest?.toJson(),
        "questions": questions == null
            ? []
            : List<dynamic>.from(questions!.map((x) => x.toJson())),
        "message": message,
        "package_required": packageRequired,
      };
}

class UserAnswer {
  final int questionId;
  dynamic answers;

  UserAnswer({
    required this.questionId,
    this.answers,
  });

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'answer': answers,
    };
  }

  factory UserAnswer.fromJson(Map<String, dynamic> json) {
    return UserAnswer(
      questionId: json['question_id'],
      answers: json['answer'],
    );
  }

  @override
  String toString() {
    return '{question_id: $questionId, answer: $answers}';
  }
}

