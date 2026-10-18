import 'package:intl/intl.dart';

/// Response model for {{LokkhaApiUrl}}/v1/user/content-history
class ContentHistoryResponseModel {
  final bool success;
  final String message;
  final ContentHistorySummaryModel summary;
  final List<UserContestItemModel> recentContests;
  final List<UserSavedQuestionModel> recentSavedQuestions;

  const ContentHistoryResponseModel({
    this.success = true,
    this.message = '',
    this.summary = const ContentHistorySummaryModel(),
    this.recentContests = const [],
    this.recentSavedQuestions = const [],
  });

  factory ContentHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    final summaryMap = data['summary'] as Map<String, dynamic>? ?? {};
    final contestsList = (data['recent_contests'] as List<dynamic>?) ?? [];
    final savedList = (data['recent_saved_questions'] as List<dynamic>?) ?? [];

    return ContentHistoryResponseModel(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? '',
      summary: ContentHistorySummaryModel.fromJson(summaryMap),
      recentContests: contestsList
          .map((e) => UserContestItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentSavedQuestions: savedList
          .map((e) => UserSavedQuestionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': {
          'summary': summary.toJson(),
          'recent_contests': recentContests.map((e) => e.toJson()).toList(),
          'recent_saved_questions':
              recentSavedQuestions.map((e) => e.toJson()).toList(),
        },
      };

  ContentHistoryResponseModel copyWith({
    bool? success,
    String? message,
    ContentHistorySummaryModel? summary,
    List<UserContestItemModel>? recentContests,
    List<UserSavedQuestionModel>? recentSavedQuestions,
  }) {
    return ContentHistoryResponseModel(
      success: success ?? this.success,
      message: message ?? this.message,
      summary: summary ?? this.summary,
      recentContests: recentContests ?? this.recentContests,
      recentSavedQuestions:
          recentSavedQuestions ?? this.recentSavedQuestions,
    );
  }
}

/// Summary counts for contests and saved questions
class ContentHistorySummaryModel {
  final int totalContests;
  final int totalSavedQuestions;

  const ContentHistorySummaryModel({
    this.totalContests = 0,
    this.totalSavedQuestions = 0,
  });

  factory ContentHistorySummaryModel.fromJson(Map<String, dynamic> json) {
    return ContentHistorySummaryModel(
      totalContests: json['total_contests'] as int? ?? 0,
      totalSavedQuestions: json['total_saved_questions'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'total_contests': totalContests,
        'total_saved_questions': totalSavedQuestions,
      };

  ContentHistorySummaryModel copyWith({
    int? totalContests,
    int? totalSavedQuestions,
  }) {
    return ContentHistorySummaryModel(
      totalContests: totalContests ?? this.totalContests,
      totalSavedQuestions: totalSavedQuestions ?? this.totalSavedQuestions,
    );
  }
}

/// Model representing a single contest participation record
class UserContestItemModel {
  final int id;
  final int contestId;
  final String contestTitle;
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final num score;
  final num positiveMark;
  final num negativeMark;
  final int selectDuration;
  final int completeDuration;
  final String participatedAt;

  const UserContestItemModel({
    required this.id,
    required this.contestId,
    required this.contestTitle,
    this.totalQuestions = 0,
    this.correctAnswers = 0,
    this.incorrectAnswers = 0,
    this.score = 0,
    this.positiveMark = 1,
    this.negativeMark = 0.25,
    this.selectDuration = 0,
    this.completeDuration = 0,
    this.participatedAt = '',
  });

  factory UserContestItemModel.fromJson(Map<String, dynamic> json) {
    return UserContestItemModel(
      id: json['id'] as int? ?? 0,
      contestId: json['contest_id'] as int? ?? 0,
      contestTitle: json['contest_title'] as String? ?? 'কনটেস্ট',
      totalQuestions: json['total_questions'] as int? ?? 0,
      correctAnswers: json['correct_answers'] as int? ?? 0,
      incorrectAnswers: json['incorrect_answers'] as int? ?? 0,
      score: json['score'] as num? ?? 0,
      positiveMark: json['positive_mark'] as num? ?? 1,
      negativeMark: json['negative_mark'] as num? ?? 0.25,
      selectDuration: json['select_duration'] as int? ?? 0,
      completeDuration: json['complete_duration'] as int? ?? 0,
      participatedAt: json['participated_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'contest_id': contestId,
        'contest_title': contestTitle,
        'total_questions': totalQuestions,
        'correct_answers': correctAnswers,
        'incorrect_answers': incorrectAnswers,
        'score': score,
        'positive_mark': positiveMark,
        'negative_mark': negativeMark,
        'select_duration': selectDuration,
        'complete_duration': completeDuration,
        'participated_at': participatedAt,
      };

  /// Formatted date string for UI display (e.g., "21 Apr, 2026 • 01:00 PM")
  String get formattedDate {
    if (participatedAt.isEmpty) return 'তারিখ অনুপলব্ধ';
    try {
      final dt = DateTime.tryParse(participatedAt);
      if (dt != null) {
        return DateFormat('d MMM, yyyy • hh:mm a').format(dt);
      }
    } catch (_) {}
    return participatedAt;
  }

  /// Formatted duration string for UI display (e.g. "70 সে." or "1 মি. 10 সে.")
  String? get formattedDuration {
    if (completeDuration <= 0) return null;
    if (completeDuration < 60) {
      return '$completeDuration সে.';
    }
    final mins = completeDuration ~/ 60;
    final secs = completeDuration % 60;
    if (secs == 0) {
      return '$mins মি.';
    }
    return '$mins মি. $secs সে.';
  }

  /// Formatted score with 2 decimals if fraction exists
  String get formattedScore {
    if (score % 1 == 0) {
      return score.toInt().toString();
    }
    return score.toStringAsFixed(2);
  }

  /// Accuracy percentage
  double get accuracy {
    final attempted = correctAnswers + incorrectAnswers;
    if (attempted <= 0) return 0.0;
    return (correctAnswers / attempted) * 100;
  }

  bool get isCompleted => completeDuration > 0 || (correctAnswers + incorrectAnswers) > 0;
}

/// Model representing a single saved / bookmarked question
class UserSavedQuestionModel {
  final int savedId;
  final int questionId;
  final String title;
  final Map<String, dynamic>? options;
  final String? answer;
  final String? explanation;
  final String savedAt;

  const UserSavedQuestionModel({
    required this.savedId,
    required this.questionId,
    required this.title,
    this.options,
    this.answer,
    this.explanation,
    this.savedAt = '',
  });

  factory UserSavedQuestionModel.fromJson(Map<String, dynamic> json) {
    return UserSavedQuestionModel(
      savedId: json['saved_id'] as int? ?? 0,
      questionId: json['question_id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      options: json['options'] is Map<String, dynamic>
          ? json['options'] as Map<String, dynamic>
          : null,
      answer: json['answer'] as String?,
      explanation: json['explanation'] as String?,
      savedAt: json['saved_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'saved_id': savedId,
        'question_id': questionId,
        'title': title,
        'options': options,
        'answer': answer,
        'explanation': explanation,
        'saved_at': savedAt,
      };

  /// Clean plain-text title (strips HTML tags)
  String get cleanTitle {
    return title.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  /// Formatted date string for UI display (e.g., "15 Oct, 2026 • 12:34 PM")
  String get formattedSavedDate {
    if (savedAt.isEmpty) return 'তারিখ অনুপলব্ধ';
    try {
      final dt = DateTime.tryParse(savedAt);
      if (dt != null) {
        return DateFormat('d MMM, yyyy • hh:mm a').format(dt);
      }
    } catch (_) {}
    return savedAt;
  }
}
