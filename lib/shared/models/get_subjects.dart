import 'dart:convert';
import 'package:lokkha/shared/models/subject.dart';

GetSubjectsModel getSubjectsModelFromJson(String str) => GetSubjectsModel.fromJson(json.decode(str));
String getSubjectsModelToJson(GetSubjectsModel data) => json.encode(data.toJson());

class GetSubjectsModel {
  final bool? status;
  final String? message;
  final List<Subject>? subjects;

  GetSubjectsModel({
    this.status,
    this.message,
    this.subjects,
  });

  factory GetSubjectsModel.fromJson(Map<String, dynamic> json) => GetSubjectsModel(
    status: json["status"],
    message: json["message"],
    subjects: json["subjects"] == null ? [] : List<Subject>.from(json["subjects"]!.map((x) => Subject.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "subjects": subjects == null ? [] : List<dynamic>.from(subjects!.map((x) => x.toJson())),
  };
}


