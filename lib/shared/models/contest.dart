import 'package:lokkha/shared/models/contest_result.dart';
import 'package:lokkha/shared/models/question.dart';
import 'package:lokkha/shared/models/subject.dart';

class Contest {
  final int? id;
  final String? name;
  final String? image;
  final String? slug;
  final String? description;
  final int? duration;
  final int? positiveMark;
  final double? negativeMark;
  final DateTime? startDatetime;
  final DateTime? endDatetime;
  final int? autoQuestionCount;
  final int? previousDayCount;
  final String? contestPolicy;
  final String? sponsorName;
  final String? sponsorUrl;
  final String? sponsorImage;
  final String? sponsorDetails;
  final String? prizeDetails;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<ContestResult>? results;
  final List<Subject>? subjects;
  final List<Question>? questions;

  Contest({
    this.id,
    this.name,
    this.image,
    this.slug,
    this.description,
    this.duration,
    this.positiveMark,
    this.negativeMark,
    this.startDatetime,
    this.endDatetime,
    this.autoQuestionCount,
    this.previousDayCount,
    this.contestPolicy,
    this.sponsorName,
    this.sponsorUrl,
    this.sponsorImage,
    this.sponsorDetails,
    this.prizeDetails,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.results,
    this.subjects,
    this.questions,
  });

  factory Contest.fromJson(Map<String, dynamic> json) => Contest(
        id: json["id"],
        name: json["name"],
        image: json["image"],
        slug: json["slug"],
        description: json["description"],
        duration: json["duration"],
        positiveMark: json["positive_mark"],
        negativeMark: json["negative_mark"]?.toDouble(),
        startDatetime: json["start_datetime"] == null
            ? null
            : DateTime.parse(json["start_datetime"]),
        endDatetime: json["end_datetime"] == null
            ? null
            : DateTime.parse(json["end_datetime"]),
        autoQuestionCount: json["auto_question_count"],
        previousDayCount: json["previous_day_count"],
        contestPolicy: json["contest_policy"],
        sponsorName: json["sponsor_name"],
        sponsorUrl: json["sponsor_url"],
        sponsorImage: json["sponsor_image"],
        sponsorDetails: json["sponsor_details"],
        prizeDetails: json["prize_details"],
        status: json["status"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        results: json["results"] == null
            ? []
            : List<ContestResult>.from(
                json["results"]!.map((x) => ContestResult.fromJson(x))),
        subjects: json["subjects"] == null
            ? []
            : List<Subject>.from(
                json["subjects"]!.map((x) => Subject.fromJson(x))),
        questions: json["questions"] == null
            ? []
            : List<Question>.from(
                json["questions"]!.map((x) => Question.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
        "slug": slug,
        "description": description,
        "duration": duration,
        "positive_mark": positiveMark,
        "negative_mark": negativeMark,
        "start_datetime": startDatetime?.toIso8601String(),
        "end_datetime": endDatetime?.toIso8601String(),
        "auto_question_count": autoQuestionCount,
        "previous_day_count": previousDayCount,
        "contest_policy": contestPolicy,
        "sponsor_name": sponsorName,
        "sponsor_url": sponsorUrl,
        "sponsor_image": sponsorImage,
        "sponsor_details": sponsorDetails,
        "prize_details": prizeDetails,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "results": results == null
            ? []
            : List<dynamic>.from(results!.map((x) => x.toJson())),
        "subjects": subjects == null
            ? []
            : List<dynamic>.from(subjects!.map((x) => x.toJson())),
        "questions": questions == null
            ? []
            : List<dynamic>.from(questions!.map((x) => x.toJson())),
      };
}
