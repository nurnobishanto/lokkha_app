import 'package:intl/intl.dart';

class ExamHistoryModel {
  final String id;
  final int? rawId;
  final int? examId;
  final String title;
  final bool isPractice;
  final int totalQuestions;
  final int correctCount;
  final int wrongCount;
  final int attempted;
  final int avoided;
  final double positiveMark;
  final double negativeMark;
  final double score;
  final double totalMarks;
  final double scorePercent;
  final String resultStatus;
  final String submittedAt;

  // Optional manual overrides for mock/testing
  final String? _customDate;
  final String? _customStatus;
  final String? _customObtainedMark;
  final bool? _customIsPassed;

  const ExamHistoryModel({
    required this.id,
    this.rawId,
    this.examId,
    required this.title,
    this.isPractice = false,
    required this.totalQuestions,
    required this.correctCount,
    required this.wrongCount,
    this.attempted = 0,
    this.avoided = 0,
    this.positiveMark = 1.0,
    this.negativeMark = 0.0,
    this.score = 0.0,
    this.totalMarks = 0.0,
    this.scorePercent = 0.0,
    this.resultStatus = '',
    this.submittedAt = '',
    String? date,
    String? status,
    String? obtainedMark,
    bool? isPassed,
  })  : _customDate = date,
        _customStatus = status,
        _customObtainedMark = obtainedMark,
        _customIsPassed = isPassed;

  /// Returns numeric ID for API requests (e.g., 431)
  int get numericId {
    if (rawId != null) return rawId!;
    final sanitized = id.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(sanitized) ?? 0;
  }

  /// Returns whether the candidate passed the exam
  bool get isPassed {
    if (_customIsPassed != null) return _customIsPassed!;
    if (resultStatus.isNotEmpty) {
      return resultStatus.toLowerCase() == 'passed' ||
          resultStatus.toLowerCase() == 'pass';
    }
    return scorePercent >= 40.0;
  }

  /// Returns date formatted as '15 Sep, 2026 • 11:45 AM'
  String get date {
    if (_customDate != null && _customDate!.isNotEmpty) {
      return _customDate!;
    }
    if (submittedAt.isEmpty) return '';

    try {
      final parsed = DateTime.tryParse(submittedAt);
      if (parsed != null) {
        return DateFormat("d MMM, yyyy • hh:mm a").format(parsed);
      }
    } catch (_) {}
    return submittedAt;
  }

  /// Returns formatted status like 'Passed (67.5%)' or 'Failed (-2.5%)'
  String get status {
    if (_customStatus != null && _customStatus!.isNotEmpty) {
      return _customStatus!;
    }
    final label = resultStatus.isNotEmpty
        ? resultStatus
        : (isPassed ? 'Passed' : 'Failed');

    if (scorePercent != 0.0) {
      final formattedPercent = _formatNumber(scorePercent);
      return "$label ($formattedPercent%)";
    }
    return label;
  }

  /// Returns formatted obtained mark like '135' or '-0.5'
  String get obtainedMark {
    if (_customObtainedMark != null && _customObtainedMark!.isNotEmpty) {
      return _customObtainedMark!;
    }
    return _formatNumber(score);
  }

  static String _formatNumber(num val) {
    if (val.truncateToDouble() == val) {
      return val.toInt().toString();
    }
    return val.toStringAsFixed(1);
  }

  factory ExamHistoryModel.fromJson(Map<String, dynamic> json) {
    final rawIdInt = json['id'] is int
        ? json['id'] as int
        : int.tryParse(json['id']?.toString() ?? '');

    final idStr = json['id']?.toString() ?? '';
    final formattedId = idStr.startsWith('#')
        ? idStr
        : (rawIdInt != null ? '#$rawIdInt' : idStr);

    final scoreVal = json['score'] is num
        ? (json['score'] as num).toDouble()
        : double.tryParse(json['score']?.toString() ??
                json['obtained_mark']?.toString() ??
                '0.0') ??
            0.0;

    final scorePercentVal = json['score_percent'] is num
        ? (json['score_percent'] as num).toDouble()
        : double.tryParse(json['score_percent']?.toString() ?? '0.0') ?? 0.0;

    return ExamHistoryModel(
      id: formattedId,
      rawId: rawIdInt,
      examId: json['exam_id'] is int
          ? json['exam_id'] as int
          : int.tryParse(json['exam_id']?.toString() ?? ''),
      title: json['exam_title']?.toString() ??
          json['title']?.toString() ??
          '',
      isPractice: json['is_practice'] == true,
      totalQuestions: json['total_questions'] is int
          ? json['total_questions'] as int
          : int.tryParse(json['total_questions']?.toString() ?? '0') ?? 0,
      correctCount: json['correct_answers'] is int
          ? json['correct_answers'] as int
          : (json['correct_count'] is int
              ? json['correct_count'] as int
              : int.tryParse(json['correct_answers']?.toString() ??
                      json['correct_count']?.toString() ??
                      '0') ??
                  0),
      wrongCount: json['incorrect_answers'] is int
          ? json['incorrect_answers'] as int
          : (json['wrong_count'] is int
              ? json['wrong_count'] as int
              : int.tryParse(json['incorrect_answers']?.toString() ??
                      json['wrong_count']?.toString() ??
                      '0') ??
                  0),
      attempted: json['attempted'] is int
          ? json['attempted'] as int
          : int.tryParse(json['attempted']?.toString() ?? '0') ?? 0,
      avoided: json['avoided'] is int
          ? json['avoided'] as int
          : int.tryParse(json['avoided']?.toString() ?? '0') ?? 0,
      positiveMark: json['positive_mark'] is num
          ? (json['positive_mark'] as num).toDouble()
          : double.tryParse(json['positive_mark']?.toString() ?? '1.0') ?? 1.0,
      negativeMark: json['negative_mark'] is num
          ? (json['negative_mark'] as num).toDouble()
          : double.tryParse(json['negative_mark']?.toString() ?? '0.0') ?? 0.0,
      score: scoreVal,
      totalMarks: json['total_marks'] is num
          ? (json['total_marks'] as num).toDouble()
          : double.tryParse(json['total_marks']?.toString() ?? '0.0') ?? 0.0,
      scorePercent: scorePercentVal,
      resultStatus: json['result_status']?.toString() ??
          json['status']?.toString() ??
          '',
      submittedAt: json['submitted_at']?.toString() ??
          json['date']?.toString() ??
          '',
      date: json['date']?.toString(),
      status: json['status']?.toString(),
      obtainedMark: json['obtained_mark']?.toString(),
      isPassed: json['is_passed'] is bool ? json['is_passed'] as bool : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': rawId ?? id,
      'exam_id': examId,
      'exam_title': title,
      'is_practice': isPractice,
      'total_questions': totalQuestions,
      'correct_answers': correctCount,
      'incorrect_answers': wrongCount,
      'attempted': attempted,
      'avoided': avoided,
      'positive_mark': positiveMark,
      'negative_mark': negativeMark,
      'score': score,
      'total_marks': totalMarks,
      'score_percent': scorePercent,
      'result_status': resultStatus,
      'submitted_at': submittedAt,
      'date': date,
      'status': status,
      'obtained_mark': obtainedMark,
      'is_passed': isPassed,
    };
  }
}

class ExamHistoryResponseModel {
  final List<ExamHistoryModel> items;
  final int currentPage;
  final int lastPage;
  final int total;

  const ExamHistoryResponseModel({
    required this.items,
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
  });

  factory ExamHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    List<ExamHistoryModel> items = [];
    final data = json['data'];
    if (data is Map<String, dynamic> && data['items'] is List) {
      items = (data['items'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => ExamHistoryModel.fromJson(e))
          .toList();
    } else if (data is List) {
      items = data
          .whereType<Map<String, dynamic>>()
          .map((e) => ExamHistoryModel.fromJson(e))
          .toList();
    }

    final meta = json['meta'] as Map<String, dynamic>?;
    final currentPage = meta?['current_page'] is int
        ? meta!['current_page'] as int
        : int.tryParse(meta?['current_page']?.toString() ?? '1') ?? 1;
    final lastPage = meta?['last_page'] is int
        ? meta!['last_page'] as int
        : int.tryParse(meta?['last_page']?.toString() ?? '1') ?? 1;
    final total = meta?['total'] is int
        ? meta!['total'] as int
        : int.tryParse(meta?['total']?.toString() ?? '0') ?? items.length;

    return ExamHistoryResponseModel(
      items: items,
      currentPage: currentPage,
      lastPage: lastPage,
      total: total,
    );
  }
}
