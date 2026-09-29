import 'dart:convert';

import 'package:lokkha/shared/models/question.dart';

RandomQuestionModel randomQuestionModelFromJson(String str) =>
    RandomQuestionModel.fromJson(json.decode(str));

String randomQuestionModelToJson(RandomQuestionModel data) =>
    json.encode(data.toJson());

class RandomQuestionModel {
  final bool? status;
  final bool? packageRequired;
  final String? message;
  final Question? question;

  RandomQuestionModel({
    this.status,
    this.packageRequired,
    this.message,
    this.question,
  });

  factory RandomQuestionModel.fromJson(Map<String, dynamic> json) =>
      RandomQuestionModel(
        status: json["status"],
        packageRequired: json["package_required"],
        message: json["message"],
        question: json["question"] == null
            ? null
            : Question.fromJson(json["question"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "package_required": packageRequired,
        "message": message,
        "question": question?.toJson(),
      };
}
