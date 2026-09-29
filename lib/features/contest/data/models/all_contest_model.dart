import 'dart:convert';
import 'package:lokkha/shared/models/contest.dart';

AllContestModel allContestModelFromJson(String str) =>
    AllContestModel.fromJson(json.decode(str));
String allContestModelToJson(AllContestModel data) =>
    json.encode(data.toJson());

class AllContestModel {
  final bool? status;
  final List<Contest>? contests;

  AllContestModel({
    this.status,
    this.contests,
  });

  factory AllContestModel.fromJson(Map<String, dynamic> json) =>
      AllContestModel(
        status: json["status"],
        contests: json["contests"] == null
            ? []
            : List<Contest>.from(
                json["contests"]!.map((x) => Contest.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "contests": contests == null
            ? []
            : List<dynamic>.from(contests!.map((x) => x.toJson())),
      };
}
