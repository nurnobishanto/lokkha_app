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

  factory GetSubjectsModel.fromJson(Map<String, dynamic> json) {
    List<Subject> parseList(dynamic raw) {
      if (raw is List) {
        return raw
            .whereType<Map<String, dynamic>>()
            .map((x) => Subject.fromJson(x))
            .toList();
      }
      return [];
    }

    dynamic rawSubjects = json["subjects"];
    if (rawSubjects == null && json["data"] is Map<String, dynamic>) {
      final dataMap = json["data"] as Map<String, dynamic>;
      rawSubjects = dataMap["subject_wise_banks"] ?? dataMap["subjects"];
    } else if (rawSubjects == null && json["subject_wise_banks"] != null) {
      rawSubjects = json["subject_wise_banks"];
    }

    final isSuccess = json["status"] == true || json["success"] == true;

    return GetSubjectsModel(
      status: isSuccess,
      message: json["message"]?.toString(),
      subjects: parseList(rawSubjects),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "subjects": subjects == null ? [] : List<dynamic>.from(subjects!.map((x) => x.toJson())),
  };
}


