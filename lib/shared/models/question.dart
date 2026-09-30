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
        id: json["id"] is int
            ? json["id"]
            : int.tryParse(json["id"]?.toString() ?? ''),
        questionType: json["question_type"] != null
            ? (questionTypeValues.map[json["question_type"]] ??
                QuestionType.SINGLE_CHOICE)
            : QuestionType.SINGLE_CHOICE,
        title: json["title"]?.toString(),
        description: json["description"]?.toString(),
        options: json["options"] == null
            ? []
            : List<Option>.from((json["options"] as List).map((x) =>
                Option.fromJson(
                    x is Map<String, dynamic> ? x : Map<String, dynamic>.from(x)))),
        explanation: json["explanation"]?.toString(),
        questionImage: json["question_image"]?.toString(),
        explanationImage: json["explanation_image"]?.toString(),
        note: json["note"]?.toString(),
        reference: json["reference"]?.toString(),
        date: json["date"]?.toString(),
        status: json["status"]?.toString(),
        customId: json["custom_id"]?.toString(),
        comment: json["comment"]?.toString(),
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
  final dynamic key;
  final String? value;
  final bool? isCorrect;

  Option({
    this.key,
    this.value,
    this.isCorrect,
  });

  int? get keyAsInt => key is int ? key : int.tryParse(key?.toString() ?? '');
  String get keyAsString => key?.toString() ?? '';

  factory Option.fromJson(Map<String, dynamic> json) => Option(
        key: json["key"],
        value: json["value"]?.toString(),
        isCorrect: json["is_correct"] == true ||
            json["is_correct"] == 1 ||
            json["is_correct"] == "1" ||
            json["is_correct"] == "true",
      );

  Map<String, dynamic> toJson() => {
        "key": key,
        "value": value,
        "is_correct": isCorrect,
      };
}
