import 'dart:convert';

import 'package:lokkha/shared/models/question.dart';

ContestSubmitModel contestSubmitModelFromJson(String str) =>
    ContestSubmitModel.fromJson(json.decode(str));

String contestSubmitModelToJson(ContestSubmitModel data) =>
    json.encode(data.toJson());

class ContestSubmitModel {
  final bool? status;
  final Summary? summary;
  final List<Result>? results;
  final String? message;

  ContestSubmitModel({
    this.status,
    this.summary,
    this.results,
    this.message,
  });

  factory ContestSubmitModel.fromJson(Map<String, dynamic> json) =>
      ContestSubmitModel(
        status: json["status"],
        summary:
            json["summary"] == null ? null : Summary.fromJson(json["summary"]),
        results: json["results"] == null
            ? []
            : List<Result>.from(
                json["results"]!.map((x) => Result.fromJson(x))),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "summary": summary?.toJson(),
        "results": results == null
            ? []
            : List<dynamic>.from(results!.map((x) => x.toJson())),
        "message": message,
      };
}

class Result {
  final Question? question;
  final List<String?>? userAnswer;
  final List<CorrectAnswer>? correctAnswer;
  final bool? isCorrect;
  final bool? isAttempt;

  Result({
    this.question,
    this.userAnswer,
    this.correctAnswer,
    this.isCorrect,
    this.isAttempt,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        question: json["question"] == null
            ? null
            : Question.fromJson(json["question"]),
        userAnswer: json["user_answer"] == null
            ? []
            : List<String?>.from(json["user_answer"]!.map((x) => x)),
        correctAnswer: json["correct_answer"] == null
            ? []
            : List<CorrectAnswer>.from(
                json["correct_answer"]!.map((x) => CorrectAnswer.fromJson(x))),
        isCorrect: json["is_correct"],
        isAttempt: json["is_attempt"],
      );

  Map<String, dynamic> toJson() => {
        "question": question?.toJson(),
        "user_answer": userAnswer == null
            ? []
            : List<dynamic>.from(userAnswer!.map((x) => x)),
        "correct_answer": correctAnswer == null
            ? []
            : List<dynamic>.from(correctAnswer!.map((x) => x.toJson())),
        "is_correct": isCorrect,
        "is_attempt": isAttempt,
      };
}

class CorrectAnswer {
  final int? answer;

  CorrectAnswer({
    this.answer,
  });

  factory CorrectAnswer.fromJson(Map<String, dynamic> json) => CorrectAnswer(
        answer: json["answer"],
      );

  Map<String, dynamic> toJson() => {
        "answer": answer,
      };
}

class Summary {
  final int? total;
  final int? correct;
  final int? incorrect;
  final int? attempt;
  final double? mark;

  Summary({
    this.total,
    this.correct,
    this.incorrect,
    this.attempt,
    this.mark,
  });

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
        total: json["total"],
        correct: json["correct"],
        incorrect: json["incorrect"],
        attempt: json["attempt"],
        mark: json["mark"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "total": total,
        "correct": correct,
        "incorrect": incorrect,
        "attempt": attempt,
        "mark": mark,
      };
}
