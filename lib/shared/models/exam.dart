import 'package:lokkha/shared/models/question.dart';

import 'exam_category.dart';

class Exam {
  final int? id;
  final DateTime? publishedAt;
  final bool? isPaid;
  final String? name;
  final String? image;
  final String? slug;
  final dynamic description;
  final int? duration;
  final int? positiveMark;
  final double? negativeMark;
  final dynamic examPolicy;
  final String? status;
  final int? createdBy;
  final int? updatedBy;
  final int? examCategoryId;
  final int? questionsCount;
  final bool? attempted;
  final List<Question>? questions;
  final int? possibleMark;
  final int? examResultsCount;
  final ExamCategory? examCategory;

  Exam({
    this.id,
    this.publishedAt,
    this.isPaid,
    this.name,
    this.image,
    this.slug,
    this.description,
    this.duration,
    this.positiveMark,
    this.negativeMark,
    this.examPolicy,
    this.status,
    this.createdBy,
    this.updatedBy,
    this.examCategoryId,
    this.questionsCount,
    this.attempted,
    this.questions,
    this.possibleMark,
    this.examResultsCount,
    this.examCategory,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      try {
        return DateTime.parse(val.toString());
      } catch (_) {
        return null;
      }
    }

    return Exam(
      id: json["id"],
      publishedAt: parseDate(json["published_at"] ?? json["created_at"]),
      isPaid: json["is_paid"],
      name: json["name"],
      image: json["image"] ?? json["image_url"],
      slug: json["slug"],
      description: json["description"],
      duration: json["duration"] ?? json["duration_minutes"],
      positiveMark: json["positive_mark"],
      negativeMark: json["negative_mark"] != null
          ? double.tryParse(json["negative_mark"].toString())
          : null,
      examPolicy: json["exam_policy"],
      status: json["status"],
      createdBy: json["created_by"],
      updatedBy: json["updated_by"],
      examCategoryId: json["exam_category_id"],
      questionsCount: json["questions_count"] ?? json["total_questions"],
      attempted: json["attempted"] ?? json["user_attempted"],
      questions: json["questions"] == null
          ? []
          : List<Question>.from(
              json["questions"]!.map((x) => Question.fromJson(x))),
      possibleMark: json["possible_mark"] != null
          ? int.tryParse(json["possible_mark"].toString())
          : (json["total_marks"] != null
              ? (double.tryParse(json["total_marks"].toString())?.toInt())
              : null),
      examResultsCount: json["exam_results_count"] ?? json["user_attempts_count"],
      examCategory: json["category"] == null
          ? null
          : ExamCategory.fromJson(json["category"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "published_at": publishedAt?.toIso8601String(),
        "is_paid": isPaid,
        "name": name,
        "image": image,
        "slug": slug,
        "description": description,
        "duration": duration,
        "positive_mark": positiveMark,
        "negative_mark": negativeMark,
        "exam_policy": examPolicy,
        "status": status,
        "created_by": createdBy,
        "updated_by": updatedBy,
        "exam_category_id": examCategoryId,
        "questions_count": questionsCount,
        "attempted": attempted,
        "questions": questions == null
            ? []
            : List<dynamic>.from(questions!.map((x) => x.toJson())),
        "exam_results_count": examResultsCount,
        "possible_mark": possibleMark,
        "category": examCategory,
      };
}
