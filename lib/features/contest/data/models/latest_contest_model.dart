// To parse this JSON data, do
//
//     final latestContestModel = latestContestModelFromJson(jsonString);

import 'dart:convert';

import 'package:lokkha/shared/models/subject.dart';

LatestContestModel latestContestModelFromJson(String str) =>
    LatestContestModel.fromJson(json.decode(str));

String latestContestModelToJson(LatestContestModel data) =>
    json.encode(data.toJson());

class LatestContestModel {
  final bool? status;
  final Contest? contest;

  LatestContestModel({
    this.status,
    this.contest,
  });

  factory LatestContestModel.fromJson(Map<String, dynamic> json) =>
      LatestContestModel(
        status: json["status"],
        contest:
            json["contest"] == null ? null : Contest.fromJson(json["contest"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "contest": contest?.toJson(),
      };
}

class Contest {
  final int? id;
  final String? name;
  final String? image;
  final String? slug;
  final dynamic description;
  final int? duration;
  final int? positiveMark;
  final double? negativeMark;
  final DateTime? startDatetime;
  final DateTime? endDatetime;
  final int? autoQuestionCount;
  final int? previousDayCount;
  final dynamic contestPolicy;
  final String? sponsorName;
  final String? sponsorUrl;
  final String? sponsorImage;
  final dynamic sponsorDetails;
  final dynamic prizeDetails;
  final String? status;
  final List<Subject>? subjects;

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
    this.subjects,
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
        subjects: json["subjects"] == null
            ? []
            : List<Subject>.from(
                json["subjects"]!.map((x) => Subject.fromJson(x))),
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
        "subjects": subjects == null
            ? []
            : List<dynamic>.from(subjects!.map((x) => x.toJson())),
      };
}
