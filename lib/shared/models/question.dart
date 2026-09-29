import 'package:lokkha/shared/models/subject.dart';
import 'package:lokkha/shared/models/tag.dart';
import 'package:lokkha/core/enums/question_type.dart';

class Question {
  final int? id;
  final QuestionType? questionType;
  final String? title;
  final String? description;
  final List<Option>? options;
  final String? explanation;
  final String? questionImage;
  final String? explanationImage;
  final String? note;
  final String? reference;
  final String? date;
  final String? status;
  final String? customId;
  final String? comment;
  final List<Tag>? tags;
  final List<Subject>? subjects;

  Question({
    this.id,
    this.questionType,
    this.title,
    this.description,
    this.options,
    this.explanation,
    this.questionImage,
    this.explanationImage,
    this.note,
    this.reference,
    this.date,
    this.status,
    this.customId,
    this.comment,
    this.tags,
    this.subjects,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        id: json["id"],
        questionType: questionTypeValues.map[json["question_type"]]!,
        title: json["title"],
        description: json["description"],
        options: json["options"] == null
            ? []
            : List<Option>.from(
                json["options"]!.map((x) => Option.fromJson(x))),
        explanation: json["explanation"],
        questionImage: json["question_image"],
        explanationImage: json["explanation_image"],
        note: json["note"],
        reference: json["reference"],
        date: json["date"],
        status: json["status"],
        customId: json["custom_id"],
        comment: json["comment"],
        //tags: json["tags"] == null ? [] : List<Tag>.from(json["tags"]!.map((x) => Tag.fromJson(x))),
        //subjects: json["subjects"] == null ? [] : List<Subject>.from(json["subjects"]!.map((x) => Subject.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "question_type": questionTypeValues.reverse[questionType],
        "title": title,
        "description": description,
        "options": options == null
            ? []
            : List<dynamic>.from(options!.map((x) => x.toJson())),
        "explanation": explanation,
        "question_image": questionImage,
        "explanation_image": explanationImage,
        "note": note,
        "reference": reference,
        "date": date,
        "status": status,
        "custom_id": customId,
        "comment": comment,
        "tags": tags == null
            ? []
            : List<dynamic>.from(tags!.map((x) => x.toJson())),
        "subjects": subjects == null
            ? []
            : List<dynamic>.from(subjects!.map((x) => x.toJson())),
      };
}

class Option {
  final int? key;
  final String? value;
  final bool? isCorrect;

  Option({
    this.key,
    this.value,
    this.isCorrect,
  });

  factory Option.fromJson(Map<String, dynamic> json) => Option(
        key: json["key"],
        value: json["value"],
        isCorrect: json["is_correct"],
      );

  Map<String, dynamic> toJson() => {
        "key": key,
        "value": value,
        "is_correct": isCorrect,
      };
}
