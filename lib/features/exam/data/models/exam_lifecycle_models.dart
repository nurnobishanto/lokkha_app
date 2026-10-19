
/// Pre-exam Metadata Information
class ExamMetaInfo {
  final int id;
  final String title;
  final int duration; // in minutes
  final int totalQuestions;
  final double positiveMark;
  final double negativeMark;
  final double passMark;
  final String examType;
  final String examMode;
  final bool isActive;
  final String? description;
  final String? slug;
  final String? image;

  const ExamMetaInfo({
    required this.id,
    required this.title,
    this.duration = 60,
    this.totalQuestions = 0,
    this.positiveMark = 1.0,
    this.negativeMark = 0.0,
    this.passMark = 0.0,
    this.examType = 'free',
    this.examMode = 'exam',
    this.isActive = true,
    this.description,
    this.slug,
    this.image,
  });

  factory ExamMetaInfo.fromJson(Map<String, dynamic> json) {
    return ExamMetaInfo(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title'] as String? ?? json['name'] as String? ?? 'পরীক্ষা',
      duration: json['duration'] is int
          ? json['duration'] as int
          : int.tryParse(json['duration']?.toString() ?? '') ??
              json['duration_minutes'] as int? ??
              60,
      totalQuestions: json['total_questions'] is int
          ? json['total_questions'] as int
          : int.tryParse(json['total_questions']?.toString() ?? '') ??
              json['questions_count'] as int? ??
              0,
      positiveMark: (json['positive_mark'] is num)
          ? (json['positive_mark'] as num).toDouble()
          : double.tryParse(json['positive_mark']?.toString() ?? '') ?? 1.0,
      negativeMark: (json['negative_mark'] is num)
          ? (json['negative_mark'] as num).toDouble()
          : double.tryParse(json['negative_mark']?.toString() ?? '') ?? 0.0,
      passMark: (json['pass_mark'] is num)
          ? (json['pass_mark'] as num).toDouble()
          : double.tryParse(json['pass_mark']?.toString() ?? '') ?? 0.0,
      examType: json['exam_type'] as String? ?? (json['is_paid'] == true ? 'paid' : 'free'),
      examMode: json['exam_mode'] as String? ?? 'exam',
      isActive: json['is_active'] as bool? ?? true,
      description: json['description']?.toString(),
      slug: json['slug'] as String?,
      image: json['image'] as String? ?? json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'duration': duration,
        'total_questions': totalQuestions,
        'positive_mark': positiveMark,
        'negative_mark': negativeMark,
        'pass_mark': passMark,
        'exam_type': examType,
        'exam_mode': examMode,
        'is_active': isActive,
        'description': description,
        'slug': slug,
        'image': image,
      };
}

/// Candidate Eligibility Status
class UserEligibility {
  final bool canTakeExam;
  final String? reason;
  final bool isLoggedIn;
  final bool requiresPackage;
  final bool hasActiveSession;
  final dynamic activeSessionId;

  const UserEligibility({
    this.canTakeExam = true,
    this.reason,
    this.isLoggedIn = true,
    this.requiresPackage = false,
    this.hasActiveSession = false,
    this.activeSessionId,
  });

  factory UserEligibility.fromJson(Map<String, dynamic> json) {
    return UserEligibility(
      canTakeExam: json['can_take_exam'] as bool? ?? true,
      reason: json['reason'] as String?,
      isLoggedIn: json['is_logged_in'] as bool? ?? true,
      requiresPackage: json['requires_package'] as bool? ?? false,
      hasActiveSession: json['has_active_session'] as bool? ?? false,
      activeSessionId: json['active_session_id'],
    );
  }

  Map<String, dynamic> toJson() => {
        'can_take_exam': canTakeExam,
        'reason': reason,
        'is_logged_in': isLoggedIn,
        'requires_package': requiresPackage,
        'has_active_session': hasActiveSession,
        'active_session_id': activeSessionId,
      };
}

/// Ready-to-use In-App WebView URLs
class ExamWebViewUrls {
  final String start;
  final String read;
  final String? result;

  const ExamWebViewUrls({
    required this.start,
    required this.read,
    this.result,
  });

  factory ExamWebViewUrls.fromJson(Map<String, dynamic> json) {
    return ExamWebViewUrls(
      start: json['start'] as String? ?? '',
      read: json['read'] as String? ?? '',
      result: json['result'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'start': start,
        'read': read,
        'result': result,
      };
}

/// Pre-Exam Instructions Response (GET /api/v1/exams/{id}/instructions)
class ExamInstructionsResponse {
  final bool success;
  final String message;
  final ExamInstructionsData data;

  const ExamInstructionsResponse({
    this.success = false,
    this.message = '',
    this.data = const ExamInstructionsData(),
  });

  factory ExamInstructionsResponse.fromJson(Map<String, dynamic> json) {
    return ExamInstructionsResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] is Map<String, dynamic>
          ? ExamInstructionsData.fromJson(json['data'] as Map<String, dynamic>)
          : const ExamInstructionsData(),
    );
  }
}

class ExamInstructionsData {
  final ExamMetaInfo exam;
  final List<String> instructions;
  final UserEligibility eligibility;
  final ExamWebViewUrls webviewUrls;

  const ExamInstructionsData({
    this.exam = const ExamMetaInfo(id: 0, title: ''),
    this.instructions = const [],
    this.eligibility = const UserEligibility(),
    this.webviewUrls = const ExamWebViewUrls(start: '', read: ''),
  });

  factory ExamInstructionsData.fromJson(Map<String, dynamic> json) {
    final rawList = json['instructions'] as List<dynamic>? ?? [];
    final instructionsList = rawList.map((e) => e.toString()).toList();

    return ExamInstructionsData(
      exam: json['exam'] is Map<String, dynamic>
          ? ExamMetaInfo.fromJson(json['exam'] as Map<String, dynamic>)
          : const ExamMetaInfo(id: 0, title: ''),
      instructions: instructionsList,
      eligibility: json['user_eligibility'] is Map<String, dynamic>
          ? UserEligibility.fromJson(json['user_eligibility'] as Map<String, dynamic>)
          : const UserEligibility(),
      webviewUrls: json['webview_urls'] is Map<String, dynamic>
          ? ExamWebViewUrls.fromJson(json['webview_urls'] as Map<String, dynamic>)
          : const ExamWebViewUrls(start: '', read: ''),
    );
  }
}

/// Exam Active / In-Progress Session
class ExamSessionInfo {
  final int resultId;
  final int examId;
  final String status;
  final String? startedAt;
  final int totalSeconds;
  final int remainingSeconds;
  final int elapsedSeconds;
  final bool isResumed;

  const ExamSessionInfo({
    required this.resultId,
    required this.examId,
    this.status = 'pending',
    this.startedAt,
    this.totalSeconds = 3600,
    this.remainingSeconds = 3600,
    this.elapsedSeconds = 0,
    this.isResumed = false,
  });

  factory ExamSessionInfo.fromJson(Map<String, dynamic> json) {
    return ExamSessionInfo(
      resultId: json['result_id'] is int
          ? json['result_id'] as int
          : int.tryParse(json['result_id']?.toString() ?? '') ?? 0,
      examId: json['exam_id'] is int
          ? json['exam_id'] as int
          : int.tryParse(json['exam_id']?.toString() ?? '') ?? 0,
      status: json['status'] as String? ?? 'pending',
      startedAt: json['started_at'] as String?,
      totalSeconds: json['total_seconds'] is int
          ? json['total_seconds'] as int
          : int.tryParse(json['total_seconds']?.toString() ?? '') ?? 3600,
      remainingSeconds: json['remaining_seconds'] is int
          ? json['remaining_seconds'] as int
          : int.tryParse(json['remaining_seconds']?.toString() ?? '') ?? 3600,
      elapsedSeconds: json['elapsed_seconds'] is int
          ? json['elapsed_seconds'] as int
          : int.tryParse(json['elapsed_seconds']?.toString() ?? '') ?? 0,
      isResumed: json['is_resumed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'result_id': resultId,
        'exam_id': examId,
        'status': status,
        'started_at': startedAt,
        'total_seconds': totalSeconds,
        'remaining_seconds': remainingSeconds,
        'elapsed_seconds': elapsedSeconds,
        'is_resumed': isResumed,
      };
}

/// Sanitized Question Option
class ExamOptionItem {
  final String key;
  final String value;

  const ExamOptionItem({required this.key, required this.value});

  factory ExamOptionItem.fromJson(Map<String, dynamic> json) {
    return ExamOptionItem(
      key: json['key']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'key': key, 'value': value};
}

/// Sanitized Exam Question (is_correct stripped)
class ExamQuestionItem {
  final int id;
  final String title;
  final String? questionImage;
  final List<ExamOptionItem> options;
  final String? subject;

  const ExamQuestionItem({
    required this.id,
    required this.title,
    this.questionImage,
    this.options = const [],
    this.subject,
  });

  factory ExamQuestionItem.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'] as List<dynamic>? ?? [];
    return ExamQuestionItem(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title'] as String? ?? '',
      questionImage: json['question_image'] as String?,
      options: rawOptions.map((e) => ExamOptionItem.fromJson(e as Map<String, dynamic>)).toList(),
      subject: json['subject'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'question_image': questionImage,
        'options': options.map((e) => e.toJson()).toList(),
        'subject': subject,
      };
}

/// Start Exam Response (POST /api/v1/exams/{id}/start)
class ExamStartResponse {
  final bool success;
  final String message;
  final ExamSessionInfo session;
  final List<ExamQuestionItem> questions;
  final String? webviewUrl;

  const ExamStartResponse({
    this.success = false,
    this.message = '',
    this.session = const ExamSessionInfo(resultId: 0, examId: 0),
    this.questions = const [],
    this.webviewUrl,
  });

  factory ExamStartResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final rawQ = data['questions'] as List<dynamic>? ?? [];

    return ExamStartResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      session: data['session'] is Map<String, dynamic>
          ? ExamSessionInfo.fromJson(data['session'] as Map<String, dynamic>)
          : const ExamSessionInfo(resultId: 0, examId: 0),
      questions: rawQ.map((e) => ExamQuestionItem.fromJson(e as Map<String, dynamic>)).toList(),
      webviewUrl: data['webview_url'] as String?,
    );
  }
}

/// Active Session Response (GET /api/v1/exams/{id}/session)
class ActiveExamSessionResponse {
  final bool success;
  final String message;
  final bool hasActiveSession;
  final ExamSessionInfo? session;
  final Map<String, List<String>> savedAnswers;

  const ActiveExamSessionResponse({
    this.success = false,
    this.message = '',
    this.hasActiveSession = false,
    this.session,
    this.savedAnswers = const {},
  });

  factory ActiveExamSessionResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final answersMap = <String, List<String>>{};

    if (data['saved_answers'] is Map) {
      (data['saved_answers'] as Map).forEach((k, v) {
        if (v is List) {
          answersMap[k.toString()] = v.map((e) => e.toString()).toList();
        } else if (v != null) {
          answersMap[k.toString()] = [v.toString()];
        }
      });
    }

    return ActiveExamSessionResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      hasActiveSession: data['has_active_session'] as bool? ?? false,
      session: data['session'] is Map<String, dynamic>
          ? ExamSessionInfo.fromJson(data['session'] as Map<String, dynamic>)
          : null,
      savedAnswers: answersMap,
    );
  }
}

/// Autosave Answer Response (POST /api/v1/exams/{id}/save-answer)
class SaveAnswerResponse {
  final bool success;
  final String message;
  final int questionId;
  final List<String> userAnswer;
  final bool isSaved;

  const SaveAnswerResponse({
    this.success = false,
    this.message = '',
    this.questionId = 0,
    this.userAnswer = const [],
    this.isSaved = false,
  });

  factory SaveAnswerResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final rawAns = data['user_answer'];
    List<String> ansList = [];
    if (rawAns is List) {
      ansList = rawAns.map((e) => e.toString()).toList();
    } else if (rawAns != null) {
      ansList = [rawAns.toString()];
    }

    return SaveAnswerResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      questionId: data['question_id'] is int
          ? data['question_id'] as int
          : int.tryParse(data['question_id']?.toString() ?? '') ?? 0,
      userAnswer: ansList,
      isSaved: data['is_saved'] as bool? ?? false,
    );
  }
}

/// Exam Submit Response (POST /api/v1/exams/{id}/submit)
class ExamSubmitResponse {
  final bool success;
  final String message;
  final ExamSubmitResultData data;

  const ExamSubmitResponse({
    this.success = false,
    this.message = '',
    this.data = const ExamSubmitResultData(),
  });

  factory ExamSubmitResponse.fromJson(Map<String, dynamic> json) {
    return ExamSubmitResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] is Map<String, dynamic>
          ? ExamSubmitResultData.fromJson(json['data'] as Map<String, dynamic>)
          : const ExamSubmitResultData(),
    );
  }
}

class ExamSubmitResultData {
  final int resultId;
  final int examId;
  final double score;
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final int unanswered;
  final double scorePercent;
  final String status;
  final int rank;
  final int totalCandidates;
  final int durationSeconds;
  final String? webviewResultUrl;

  const ExamSubmitResultData({
    this.resultId = 0,
    this.examId = 0,
    this.score = 0.0,
    this.totalQuestions = 0,
    this.correctAnswers = 0,
    this.incorrectAnswers = 0,
    this.unanswered = 0,
    this.scorePercent = 0.0,
    this.status = 'Passed',
    this.rank = 0,
    this.totalCandidates = 0,
    this.durationSeconds = 0,
    this.webviewResultUrl,
  });

  factory ExamSubmitResultData.fromJson(Map<String, dynamic> json) {
    return ExamSubmitResultData(
      resultId: json['result_id'] is int
          ? json['result_id'] as int
          : int.tryParse(json['result_id']?.toString() ?? '') ?? 0,
      examId: json['exam_id'] is int
          ? json['exam_id'] as int
          : int.tryParse(json['exam_id']?.toString() ?? '') ?? 0,
      score: (json['score'] is num)
          ? (json['score'] as num).toDouble()
          : double.tryParse(json['score']?.toString() ?? '') ?? 0.0,
      totalQuestions: json['total_questions'] is int
          ? json['total_questions'] as int
          : int.tryParse(json['total_questions']?.toString() ?? '') ?? 0,
      correctAnswers: json['correct_answers'] is int
          ? json['correct_answers'] as int
          : int.tryParse(json['correct_answers']?.toString() ?? '') ?? 0,
      incorrectAnswers: json['incorrect_answers'] is int
          ? json['incorrect_answers'] as int
          : int.tryParse(json['incorrect_answers']?.toString() ?? '') ?? 0,
      unanswered: json['unanswered'] is int
          ? json['unanswered'] as int
          : int.tryParse(json['unanswered']?.toString() ?? '') ?? 0,
      scorePercent: (json['score_percent'] is num)
          ? (json['score_percent'] as num).toDouble()
          : double.tryParse(json['score_percent']?.toString() ?? '') ?? 0.0,
      status: json['status'] as String? ?? 'Passed',
      rank: json['rank'] is int ? json['rank'] as int : int.tryParse(json['rank']?.toString() ?? '') ?? 0,
      totalCandidates: json['total_candidates'] is int
          ? json['total_candidates'] as int
          : int.tryParse(json['total_candidates']?.toString() ?? '') ?? 0,
      durationSeconds: json['duration_seconds'] is int
          ? json['duration_seconds'] as int
          : int.tryParse(json['duration_seconds']?.toString() ?? '') ?? 0,
      webviewResultUrl: json['webview_result_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'result_id': resultId,
        'exam_id': examId,
        'score': score,
        'total_questions': totalQuestions,
        'correct_answers': correctAnswers,
        'incorrect_answers': incorrectAnswers,
        'unanswered': unanswered,
        'score_percent': scorePercent,
        'status': status,
        'rank': rank,
        'total_candidates': totalCandidates,
        'duration_seconds': durationSeconds,
        'webview_result_url': webviewResultUrl,
      };
}

/// Leaderboard Candidate Entry
class LeaderboardCandidate {
  final int rank;
  final dynamic userId;
  final String name;
  final String? avatar;
  final double score;
  final int durationSeconds;

  const LeaderboardCandidate({
    required this.rank,
    this.userId,
    required this.name,
    this.avatar,
    this.score = 0.0,
    this.durationSeconds = 0,
  });

  factory LeaderboardCandidate.fromJson(Map<String, dynamic> json) {
    return LeaderboardCandidate(
      rank: json['rank'] is int ? json['rank'] as int : int.tryParse(json['rank']?.toString() ?? '') ?? 0,
      userId: json['user_id'] ?? json['id'],
      name: json['name'] as String? ?? 'শিক্ষার্থী',
      avatar: json['avatar'] as String? ?? json['photo_url'] as String?,
      score: (json['score'] is num)
          ? (json['score'] as num).toDouble()
          : double.tryParse(json['score']?.toString() ?? '') ?? 0.0,
      durationSeconds: json['duration_seconds'] is int
          ? json['duration_seconds'] as int
          : int.tryParse(json['duration_seconds']?.toString() ?? '') ?? 0,
    );
  }
}

/// Exam Leaderboard Response (GET /api/v1/exams/{id}/leaderboard)
class ExamLeaderboardResponse {
  final bool success;
  final String message;
  final List<LeaderboardCandidate> candidates;

  const ExamLeaderboardResponse({
    this.success = false,
    this.message = '',
    this.candidates = const [],
  });

  factory ExamLeaderboardResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'] is List ? json['data'] as List : (json['candidates'] as List? ?? []);
    return ExamLeaderboardResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      candidates: rawList.map((e) => LeaderboardCandidate.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
