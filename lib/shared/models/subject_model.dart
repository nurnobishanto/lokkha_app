import 'dart:convert';
import 'package:lokkha/shared/models/subject.dart';

SubjectModel subjectModelFromJson(String str) =>
    SubjectModel.fromJson(json.decode(str));

String subjectModelToJson(SubjectModel data) => json.encode(data.toJson());

class SubjectModel {
  final bool? status;
  final String? message;
  final List<Subject>? subjects;

  SubjectModel({
    this.status,
    this.message,
    this.subjects,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) => SubjectModel(
        status: json["status"],
        message: json["message"],
        subjects: json["subjects"] == null
            ? []
            : List<Subject>.from(
                json["subjects"]!.map((x) => Subject.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "subjects": subjects == null
            ? []
            : List<dynamic>.from(subjects!.map((x) => x.toJson())),
      };
}
