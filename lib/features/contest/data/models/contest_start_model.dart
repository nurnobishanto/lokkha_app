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

  ContestStartModel({
    this.status,
    this.contest,
    this.questions,
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
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "contest": contest?.toJson(),
        "questions": questions == null
            ? []
            : List<dynamic>.from(questions!.map((x) => x.toJson())),
      };
}
