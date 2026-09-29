import 'package:lokkha/shared/models/question.dart';

class Tag {
  final int id;
  final String? name;
  final String? slug;
  final String? description;
  final bool? status;
  final List<Question>? questions;
  final String? image;
  final dynamic questionCount;

  Tag({
    required this.id,
    this.name,
    this.slug,
    this.description,
    this.status,
    this.questions,
    this.image,
    this.questionCount,
  });

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
        id: json["id"],
        name: json["name"],
        slug: json["slug"],
        description: json["description"],
        status: json["status"],
        questions: json["questions"] == null
            ? []
            : List<Question>.from(
                json["questions"]!.map((x) => Question.fromJson(x))),
        image: json["image"],
        questionCount: json["questions_count"],
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
        "image": image,
        "questions_count": questionCount,
      };
}
