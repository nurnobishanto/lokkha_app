import 'dart:convert';

import 'package:lokkha/shared/models/subject.dart';

SubjectSectionModel subjectSectionModelFromJson(String str) =>
    SubjectSectionModel.fromJson(json.decode(str));
String subjectSectionModelToJson(SubjectSectionModel data) =>
    json.encode(data.toJson());

class SubjectSectionModel {
  final bool? status;
  final List<SubjectSection>? subjectSections;

  SubjectSectionModel({
    this.status,
    this.subjectSections,
  });

  factory SubjectSectionModel.fromJson(Map<String, dynamic> json) =>
      SubjectSectionModel(
        status: json["status"],
        subjectSections: json["subject_sections"] == null
            ? []
            : List<SubjectSection>.from(json["subject_sections"]!
                .map((x) => SubjectSection.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "subject_sections": subjectSections == null
            ? []
            : List<dynamic>.from(subjectSections!.map((x) => x.toJson())),
      };
}

class SubjectSection {
  final int? id;
  final int? subjectId;
  final String? name;
  final int? sorting;
  final bool? status;
  final dynamic deletedAt;
  final dynamic createdAt;
  final dynamic updatedAt;
  final Subject? subject;

  SubjectSection({
    this.id,
    this.subjectId,
    this.name,
    this.sorting,
    this.status,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.subject,
  });

  factory SubjectSection.fromJson(Map<String, dynamic> json) => SubjectSection(
        id: json["id"],
        subjectId: json["subject_id"],
        name: json["name"],
        sorting: json["sorting"],
        status: json["status"],
        deletedAt: json["deleted_at"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        subject:
            json["subject"] == null ? null : Subject.fromJson(json["subject"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "subject_id": subjectId,
        "name": name,
        "sorting": sorting,
        "status": status,
        "deleted_at": deletedAt,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "subject": subject?.toJson(),
      };
}
