import 'package:intl/intl.dart';

class SelfExamModel {
  final String id;
  final int? rawId;
  final String? type;
  final bool isExam;
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
  final int? selectDuration;
  final int? completeDuration;
  final String createdAt;
  final String title;

  // Custom manual overrides for backwards compatibility / mock test setups
  final String? _customDate;
  final String? _customDuration;
  final String? _customStatus;
  final bool? _customIsPassed;
  final String? _customObtainedMark;

  const SelfExamModel({
    required this.id,
    this.rawId,
    this.type,
    this.isExam = true,
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
    this.selectDuration,
    this.completeDuration,
    this.createdAt = '',
    this.title = 'সেলফ একাডেমি টেস্ট',
    String? date,
    String? duration,
    String? status,
    bool? isPassed,
    String? obtainedMark,
  })  : _customDate = date,
        _customDuration = duration,
        _customStatus = status,
        _customIsPassed = isPassed,
        _customObtainedMark = obtainedMark;

  /// Returns numeric ID for API requests (e.g. 10491)
  int get numericId {
    if (rawId != null) return rawId!;
    final sanitized = id.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(sanitized) ?? 0;
  }

  /// Whether the test was passed
  bool get isPassed {
    if (_customIsPassed != null) return _customIsPassed!;
    if (resultStatus.isNotEmpty) {
      final lower = resultStatus.toLowerCase();
      return lower == 'passed' || lower == 'pass';
    }
    return scorePercent >= 40.0;
  }

  /// Date formatted as '30 Aug, 2026 • 06:34 PM'
  String get date {
    if (_customDate != null && _customDate!.isNotEmpty) return _customDate!;
    if (createdAt.isEmpty) return '';
    try {
      final parsed = DateTime.tryParse(createdAt);
      if (parsed != null) {
        return DateFormat("d MMM, yyyy • hh:mm a").format(parsed);
      }
    } catch (_) {}
    return createdAt;
  }

  /// Duration string (e.g. '10 সে.' or '3 মি. 47 সে.'). Returns null if duration is 0 or absent.
  String? get duration {
    if (_customDuration != null) return _customDuration;
    if (completeDuration == null || completeDuration! <= 0) return null;
    final sec = completeDuration!;
    if (sec < 60) {
      return "$sec সে.";
    }
    final mins = sec ~/ 60;
    final remSec = sec % 60;
    if (remSec == 0) {
      return "$mins মিনিট";
    }
    return "$mins মি. $remSec সে.";
  }

  /// Formatted status like 'Passed (70%)' or 'Failed (0%)'
  String get status {
    if (_customStatus != null && _customStatus!.isNotEmpty) return _customStatus!;
    final label = resultStatus.isNotEmpty
        ? resultStatus
        : (isPassed ? 'Passed' : 'Failed');
    return "$label (${_formatNumber(scorePercent)}%)";
  }

  /// Formatted obtained mark string
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

  factory SelfExamModel.fromJson(Map<String, dynamic> json) {
    final rawIdInt = json['id'] is int
        ? json['id'] as int
        : int.tryParse(json['id']?.toString() ?? '');
    final idStr = rawIdInt?.toString() ?? json['id']?.toString() ?? '';

    final totalQ = json['total_questions'] is int
        ? json['total_questions'] as int
        : int.tryParse(json['total_questions']?.toString() ?? '0') ?? 0;
    final correct = json['correct_answers'] is int
        ? json['correct_answers'] as int
        : (json['correct_count'] is int
            ? json['correct_count'] as int
            : int.tryParse(json['correct_answers']?.toString() ??
                    json['correct_count']?.toString() ??
                    '0') ??
                0);
    final wrong = json['incorrect_answers'] is int
        ? json['incorrect_answers'] as int
        : (json['wrong_count'] is int
            ? json['wrong_count'] as int
            : int.tryParse(json['incorrect_answers']?.toString() ??
                    json['wrong_count']?.toString() ??
                    '0') ??
                0);
    final attempted = json['attempted'] is int
        ? json['attempted'] as int
        : int.tryParse(json['attempted']?.toString() ?? '0') ?? (correct + wrong);
    final avoided = json['avoided'] is int
        ? json['avoided'] as int
        : int.tryParse(json['avoided']?.toString() ?? '0') ?? (totalQ - attempted);

    final posMark = json['positive_mark'] is num
        ? (json['positive_mark'] as num).toDouble()
        : double.tryParse(json['positive_mark']?.toString() ?? '1.0') ?? 1.0;
    final negMark = json['negative_mark'] is num
        ? (json['negative_mark'] as num).toDouble()
        : double.tryParse(json['negative_mark']?.toString() ?? '0.0') ?? 0.0;
    final scoreVal = json['score'] is num
        ? (json['score'] as num).toDouble()
        : double.tryParse(json['score']?.toString() ?? '0.0') ?? 0.0;
    final totalM = json['total_marks'] is num
        ? (json['total_marks'] as num).toDouble()
        : double.tryParse(json['total_marks']?.toString() ?? '0.0') ?? totalQ.toDouble();
    final scorePct = json['score_percent'] is num
        ? (json['score_percent'] as num).toDouble()
        : double.tryParse(json['score_percent']?.toString() ?? '0.0') ?? 0.0;

    final selectDur = json['select_duration'] is int
        ? json['select_duration'] as int
        : int.tryParse(json['select_duration']?.toString() ?? '');
    final compDur = json['complete_duration'] is int
        ? json['complete_duration'] as int
        : int.tryParse(json['complete_duration']?.toString() ?? '');

    return SelfExamModel(
      id: idStr,
      rawId: rawIdInt,
      type: json['type']?.toString(),
      isExam: json['is_exam'] == true,
      totalQuestions: totalQ,
      correctCount: correct,
      wrongCount: wrong,
      attempted: attempted,
      avoided: avoided,
      positiveMark: posMark,
      negativeMark: negMark,
      score: scoreVal,
      totalMarks: totalM,
      scorePercent: scorePct,
      resultStatus: json['result_status']?.toString() ?? '',
      selectDuration: selectDur,
      completeDuration: compDur,
      createdAt: json['created_at']?.toString() ?? json['date']?.toString() ?? '',
      title: json['title']?.toString() ?? 'সেলফ একাডেমি টেস্ট',
      date: json['date']?.toString(),
      duration: json['duration']?.toString(),
      status: json['status']?.toString(),
      isPassed: json['is_passed'] is bool ? json['is_passed'] as bool : null,
      obtainedMark: json['obtained_mark']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': rawId ?? id,
      'type': type,
      'is_exam': isExam,
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
      'select_duration': selectDuration,
      'complete_duration': completeDuration,
      'created_at': createdAt,
      'title': title,
    };
  }
}

class SelfAcademyHistoryResponseModel {
  final List<SelfExamModel> items;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int? from;
  final int? to;
  final bool hasMore;

  const SelfAcademyHistoryResponseModel({
    required this.items,
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 10,
    this.total = 0,
    this.from,
    this.to,
    this.hasMore = false,
  });

  factory SelfAcademyHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    List<SelfExamModel> itemsList = [];
    final data = json['data'];
    if (data is Map<String, dynamic> && data['items'] is List) {
      itemsList = (data['items'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => SelfExamModel.fromJson(item))
          .toList();
    } else if (data is List) {
      itemsList = data
          .whereType<Map<String, dynamic>>()
          .map((item) => SelfExamModel.fromJson(item))
          .toList();
    } else if (json['items'] is List) {
      itemsList = (json['items'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => SelfExamModel.fromJson(item))
          .toList();
    }

    final meta = json['meta'] is Map<String, dynamic>
        ? json['meta'] as Map<String, dynamic>
        : (data is Map<String, dynamic> && data['meta'] is Map<String, dynamic>
            ? data['meta'] as Map<String, dynamic>
            : <String, dynamic>{});

    return SelfAcademyHistoryResponseModel(
      items: itemsList,
      currentPage: meta['current_page'] is int
          ? meta['current_page'] as int
          : int.tryParse(meta['current_page']?.toString() ?? '1') ?? 1,
      lastPage: meta['last_page'] is int
          ? meta['last_page'] as int
          : int.tryParse(meta['last_page']?.toString() ?? '1') ?? 1,
      perPage: meta['per_page'] is int
          ? meta['per_page'] as int
          : int.tryParse(meta['per_page']?.toString() ?? '10') ?? 10,
      total: meta['total'] is int
          ? meta['total'] as int
          : int.tryParse(meta['total']?.toString() ?? '0') ?? itemsList.length,
      from: meta['from'] is int
          ? meta['from'] as int
          : int.tryParse(meta['from']?.toString() ?? ''),
      to: meta['to'] is int
          ? meta['to'] as int
          : int.tryParse(meta['to']?.toString() ?? ''),
      hasMore: meta['has_more'] == true,
    );
  }
}
