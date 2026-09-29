import 'package:lokkha/shared/models/question.dart';

class Subject {
  final int? id;
  final String? name;
  final String? slug;
  final String? description;
  final bool? status;
  final List<Question>? questions;
  final int? parentId;
  final int? questionCount;
  final List<Subject>? children;
  final String? image;
  final bool? showApp;
  final SubjectPivot? pivot;

  Subject({
    this.id,
    this.name,
    this.slug,
    this.description,
    this.status,
    this.questions,
    this.parentId,
    this.questionCount,
    this.children,
    this.image,
    this.showApp,
    this.pivot,
  });

  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
        id: json["id"],
        name: json["name"],
        slug: json["slug"],
        description: json["description"],
        status: json["status"] == null
            ? null
            : (json["status"] is bool
                ? json["status"]
                : (json["status"] == 1 || json["status"] == "1" || json["status"] == "true")),
        questions: json["questions"] == null
            ? []
            : List<Question>.from(
                json["questions"]!.map((x) => Question.fromJson(x))),
        parentId: json["parent_id"],
        questionCount: json["question_count"],
        children: json["children"] == null
            ? []
            : List<Subject>.from(
                json["children"]!.map((x) => Subject.fromJson(x))),
        image: json["image"],
        showApp: json["show_app"] == null
            ? null
            : (json["show_app"] is bool
                ? json["show_app"]
                : (json["show_app"] == 1 || json["show_app"] == "1" || json["show_app"] == "true")),
        pivot:
            json["pivot"] == null ? null : SubjectPivot.fromJson(json["pivot"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
        "description": description,
        "status": status,
        "questions": questions == null
            ? []
            : List<dynamic>.from(questions!.map((x) => x.toJson())),
        "parent_id": parentId,
        "question_count": questionCount,
        "children": children == null
            ? []
            : List<dynamic>.from(children!.map((x) => x.toJson())),
        "image": image,
        "show_app": showApp,
        "pivot": pivot?.toJson(),
      };
}

class SubjectPivot {
  final int? questionId;
  final int? subjectId;
  SubjectPivot({
    this.questionId,
    this.subjectId,
  });
  factory SubjectPivot.fromJson(Map<String, dynamic> json) => SubjectPivot(
        questionId: json["question_id"],
        subjectId: json["subject_id"],
      );

  Map<String, dynamic> toJson() => {
        "question_id": questionId,
        "subject_id": subjectId,
      };
}
