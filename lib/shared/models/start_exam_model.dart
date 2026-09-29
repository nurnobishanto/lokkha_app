import 'dart:convert';
import 'package:lokkha/shared/models/question.dart';

StartExamModel startExamModelFromJson(String str) =>
    StartExamModel.fromJson(json.decode(str));
String startExamModelToJson(StartExamModel data) => json.encode(data.toJson());

class StartExamModel {
  final bool? status;
  final String? examName;
  final String? type;
  final int? duration;
  final DateTime? startTime;
  final bool? isNegativeMark;
  final double? negativeMark;
  final bool? isSetTime;
  final int? questionsCount;
  final List<Question>? questions;

  StartExamModel({
    this.status,
    this.examName,
    this.type,
    this.duration,
    this.startTime,
    this.isNegativeMark,
    this.negativeMark,
    this.isSetTime,
    this.questionsCount,
    this.questions,
  });

  factory StartExamModel.fromJson(Map<String, dynamic> json) => StartExamModel(
        status: json["status"],
        examName: json["exam_name"],
        type: json["type"],
        duration: json["duration"],
        startTime: json["start_time"] == null
            ? null
            : DateTime.parse(json["start_time"]),
        isNegativeMark: json["is_negative_mark"],
        negativeMark: json["negative_mark"]?.toDouble(),
        isSetTime: json["is_set_time"],
        questionsCount: json["questions_count"],
        questions: json["questions"] == null
            ? []
            : List<Question>.from(
                json["questions"]!.map((x) => Question.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "exam_name": examName,
        "type": type,
        "duration": duration,
        "start_time": startTime?.toIso8601String(),
        "is_negative_mark": isNegativeMark,
        "negative_mark": negativeMark,
        "is_set_time": isSetTime,
        "questions_count": questionsCount,
        "questions": questions == null
            ? []
            : List<dynamic>.from(questions!.map((x) => x.toJson())),
      };
}
