import 'dart:convert';
import 'package:lokkha/shared/models/contest.dart';
import 'package:lokkha/shared/models/contest_result.dart';

ContestResultModel contestResultModelFromJson(String str) =>
    ContestResultModel.fromJson(json.decode(str));

String contestResultModelToJson(ContestResultModel data) =>
    json.encode(data.toJson());

class ContestResultModel {
  final bool? status;
  final Contest? contest;
  final List<ContestResult>? contestResults;

  ContestResultModel({
    this.status,
    this.contest,
    this.contestResults,
  });

  factory ContestResultModel.fromJson(Map<String, dynamic> json) =>
      ContestResultModel(
        status: json["status"],
        contest:
            json["contest"] == null ? null : Contest.fromJson(json["contest"]),
        contestResults: json["contest_results"] == null
            ? []
            : List<ContestResult>.from(
                json["contest_results"]!.map((x) => ContestResult.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "contest": contest?.toJson(),
        "contest_results": contestResults == null
            ? []
            : List<dynamic>.from(contestResults!.map((x) => x.toJson())),
      };
}
