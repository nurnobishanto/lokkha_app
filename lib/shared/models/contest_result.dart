import 'package:lokkha/shared/models/user.dart';
import 'package:lokkha/features/contest/contest.dart';

class ContestResult {
  final int? id;
  final int? contestId;
  final int? userId;
  final int? totalQuestions;
  final int? correctAnswers;
  final int? incorrectAnswers;
  final int? positiveMark;
  final double? negativeMark;
  final int? selectDuration;
  final int? completeDuration;
  final dynamic createdAt;
  final dynamic updatedAt;
  final User? user;
  final List<dynamic>? activities;
  final Contest? contest;

  ContestResult({
    this.id,
    this.contestId,
    this.userId,
    this.totalQuestions,
    this.correctAnswers,
    this.incorrectAnswers,
    this.positiveMark,
    this.negativeMark,
    this.selectDuration,
    this.completeDuration,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.activities,
    this.contest,
  });

  factory ContestResult.fromJson(Map<String, dynamic> json) => ContestResult(
        id: json["id"],
        contestId: json["contest_id"],
        userId: json["user_id"],
        totalQuestions: json["total_questions"],
        correctAnswers: json["correct_answers"],
        incorrectAnswers: json["incorrect_answers"],
        positiveMark: json["positive_mark"],
        negativeMark: json["negative_mark"]?.toDouble(),
        selectDuration: json["select_duration"],
        completeDuration: json["complete_duration"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        activities: json["activities"] == null
            ? []
            : List<dynamic>.from(json["activities"]!.map((x) => x)),
        contest:
            json["contest"] == null ? null : Contest.fromJson(json["contest"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "contest_id": contestId,
        "user_id": userId,
        "total_questions": totalQuestions,
        "correct_answers": correctAnswers,
        "incorrect_answers": incorrectAnswers,
        "positive_mark": positiveMark,
        "negative_mark": negativeMark,
        "select_duration": selectDuration,
        "complete_duration": completeDuration,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "user": user?.toJson(),
        "activities": activities == null
            ? []
            : List<dynamic>.from(activities!.map((x) => x)),
        "contest": contest?.toJson(),
      };
}
