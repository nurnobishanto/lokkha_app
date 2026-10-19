/// Pagination metadata for V1 responses
class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int? from;
  final int? to;
  final bool hasMore;

  const PaginationMeta({
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 15,
    this.total = 0,
    this.from,
    this.to,
    this.hasMore = false,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PaginationMeta();
    final current = json['current_page'] as int? ?? 1;
    final last = json['last_page'] as int? ?? 1;
    return PaginationMeta(
      currentPage: current,
      lastPage: last,
      perPage: json['per_page'] as int? ?? 15,
      total: json['total'] as int? ?? 0,
      from: json['from'] as int?,
      to: json['to'] as int?,
      hasMore: json['has_more'] as bool? ?? (current < last),
    );
  }

  Map<String, dynamic> toJson() => {
        'current_page': currentPage,
        'last_page': lastPage,
        'per_page': perPage,
        'total': total,
        'from': from,
        'to': to,
        'has_more': hasMore,
      };
}

/// ─── Top-Level Subject Model ──────────────────────────────────────────────
class QuickPracticeSubject {
  final int id;
  final String name;
  final String? slug;
  final int? parentId;
  final String? image;
  final String? description;
  final bool status;
  final bool showApp;
  final int questionsCount;
  final int childrenCount;
  final int questionCount;

  const QuickPracticeSubject({
    required this.id,
    required this.name,
    this.slug,
    this.parentId,
    this.image,
    this.description,
    this.status = true,
    this.showApp = true,
    this.questionsCount = 0,
    this.childrenCount = 0,
    this.questionCount = 0,
  });

  int get totalQuestions => questionsCount > 0 ? questionsCount : questionCount;

  bool get hasChildren => childrenCount > 0;

  String get formattedQuestionsCount {
    final count = totalQuestions;
    if (count >= 1000) {
      final inK = count / 1000.0;
      return '${inK.toStringAsFixed(inK % 1 == 0 ? 0 : 1)}k';
    }
    return '$count';
  }

  factory QuickPracticeSubject.fromJson(Map<String, dynamic> json) {
    return QuickPracticeSubject(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String?,
      parentId: json['parent_id'] as int?,
      image: (json['image_url'] ?? json['image']) as String?,
      description: json['description'] as String?,
      status: json['status'] is bool ? json['status'] as bool : (json['status'] == 1 || json['status'] == '1'),
      showApp: json['show_app'] is bool ? json['show_app'] as bool : (json['show_app'] != false && json['show_app'] != 0),
      questionsCount: json['questions_count'] as int? ?? json['question_count'] as int? ?? 0,
      childrenCount: json['children_count'] as int? ?? 0,
      questionCount: json['question_count'] as int? ?? json['questions_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'parent_id': parentId,
        'image': image,
        'description': description,
        'status': status,
        'show_app': showApp,
        'questions_count': questionsCount,
        'children_count': childrenCount,
        'question_count': questionCount,
      };
}

/// Top-Level Subjects API Response Wrapper
class QuickPracticeSubjectsResponse {
  final bool success;
  final String? message;
  final List<QuickPracticeSubject> subjects;

  const QuickPracticeSubjectsResponse({
    this.success = false,
    this.message,
    this.subjects = const [],
  });

  factory QuickPracticeSubjectsResponse.fromJson(dynamic json) {
    if (json is List) {
      return QuickPracticeSubjectsResponse(
        success: true,
        subjects: json.map((e) => QuickPracticeSubject.fromJson(e as Map<String, dynamic>)).toList(),
      );
    }

    if (json is Map<String, dynamic>) {
      final success = json['success'] as bool? ?? json['status'] as bool? ?? false;
      final message = json['message'] as String?;
      List<QuickPracticeSubject> subjects = [];

      final rawData = json['data'] ?? json['subjects'];
      if (rawData is List) {
        subjects = rawData.map((e) => QuickPracticeSubject.fromJson(e as Map<String, dynamic>)).toList();
      } else if (rawData is Map<String, dynamic> && rawData['items'] is List) {
        subjects = (rawData['items'] as List)
            .map((e) => QuickPracticeSubject.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return QuickPracticeSubjectsResponse(
        success: success,
        message: message,
        subjects: subjects,
      );
    }

    return const QuickPracticeSubjectsResponse();
  }
}

/// ─── Subject Child / Subtopic Model ───────────────────────────────────────
class SubjectChild {
  final int id;
  final String name;
  final String? slug;
  final int? parentId;
  final int questionsCount;

  const SubjectChild({
    required this.id,
    required this.name,
    this.slug,
    this.parentId,
    this.questionsCount = 0,
  });

  String get formattedQuestionsCount {
    if (questionsCount >= 1000) {
      final inK = questionsCount / 1000.0;
      return '${inK.toStringAsFixed(inK % 1 == 0 ? 0 : 1)}k';
    }
    return '$questionsCount';
  }

  factory SubjectChild.fromJson(Map<String, dynamic> json) {
    return SubjectChild(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String?,
      parentId: json['parent_id'] as int?,
      questionsCount: json['questions_count'] as int? ?? json['question_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'parent_id': parentId,
        'questions_count': questionsCount,
      };
}

/// Subject Children API Response Wrapper
class SubjectChildrenResponse {
  final bool success;
  final String? message;
  final List<SubjectChild> items;
  final PaginationMeta meta;

  const SubjectChildrenResponse({
    this.success = false,
    this.message,
    this.items = const [],
    this.meta = const PaginationMeta(),
  });

  factory SubjectChildrenResponse.fromJson(Map<String, dynamic> json) {
    final success = json['success'] as bool? ?? json['status'] as bool? ?? false;
    final message = json['message'] as String?;
    List<SubjectChild> items = [];

    final rawData = json['data'];
    if (rawData is Map<String, dynamic> && rawData['items'] is List) {
      items = (rawData['items'] as List)
          .map((e) => SubjectChild.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (rawData is List) {
      items = rawData.map((e) => SubjectChild.fromJson(e as Map<String, dynamic>)).toList();
    }

    final meta = PaginationMeta.fromJson(
      (json['meta'] as Map<String, dynamic>?) ??
          (rawData is Map<String, dynamic> ? rawData['meta'] as Map<String, dynamic>? : null),
    );

    return SubjectChildrenResponse(
      success: success,
      message: message,
      items: items,
      meta: meta,
    );
  }
}

/// ─── Practice Question Option ─────────────────────────────────────────────
class PracticeQuestionOption {
  final dynamic key;
  final String letter;
  final String value;
  final bool isCorrect;

  const PracticeQuestionOption({
    required this.key,
    required this.letter,
    required this.value,
    required this.isCorrect,
  });

  String get bengaliLetter {
    switch (letter.toUpperCase().trim()) {
      case 'A':
        return 'ক';
      case 'B':
        return 'খ';
      case 'C':
        return 'গ';
      case 'D':
        return 'ঘ';
      case 'E':
        return 'ঙ';
      default:
        return letter;
    }
  }

  factory PracticeQuestionOption.fromJson(Map<String, dynamic> json) {
    return PracticeQuestionOption(
      key: json['key'] ?? json['letter'] ?? 0,
      letter: json['letter']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
      isCorrect: json['is_correct'] == true ||
          json['is_correct'] == 1 ||
          json['is_correct']?.toString().toLowerCase() == 'true',
    );
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'letter': letter,
        'value': value,
        'is_correct': isCorrect,
      };
}

/// ─── Practice Question Model ──────────────────────────────────────────────
class PracticeQuestion {
  final int id;
  final String title;
  final String? description;
  final String? questionImage;
  final String? explanationImage;
  final String? explanation;
  final List<PracticeQuestionOption> options;
  final String? correctLetter;

  const PracticeQuestion({
    required this.id,
    required this.title,
    this.description,
    this.questionImage,
    this.explanationImage,
    this.explanation,
    this.options = const [],
    this.correctLetter,
  });

  PracticeQuestionOption? get correctOption {
    try {
      return options.firstWhere(
        (o) => o.isCorrect || (correctLetter != null && o.letter.toUpperCase() == correctLetter!.toUpperCase()),
      );
    } catch (_) {
      return null;
    }
  }

  String get bengaliCorrectLetter {
    final letter = correctLetter ?? correctOption?.letter ?? '';
    switch (letter.toUpperCase().trim()) {
      case 'A':
        return 'ক';
      case 'B':
        return 'খ';
      case 'C':
        return 'গ';
      case 'D':
        return 'ঘ';
      case 'E':
        return 'ঙ';
      default:
        return letter;
    }
  }

  factory PracticeQuestion.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'] as List? ?? [];
    final parsedOptions = rawOptions
        .map((e) => PracticeQuestionOption.fromJson(e as Map<String, dynamic>))
        .toList();

    return PracticeQuestion(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      questionImage: json['question_image'] as String?,
      explanationImage: json['explanation_image'] as String?,
      explanation: json['explanation'] as String?,
      options: parsedOptions,
      correctLetter: json['correct_letter'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'question_image': questionImage,
        'explanation_image': explanationImage,
        'explanation': explanation,
        'options': options.map((e) => e.toJson()).toList(),
        'correct_letter': correctLetter,
      };
}

/// Subject Questions API Response Wrapper
class SubjectQuestionsResponse {
  final bool success;
  final String? message;
  final List<PracticeQuestion> items;
  final PaginationMeta meta;

  const SubjectQuestionsResponse({
    this.success = false,
    this.message,
    this.items = const [],
    this.meta = const PaginationMeta(),
  });

  factory SubjectQuestionsResponse.fromJson(Map<String, dynamic> json) {
    final success = json['success'] as bool? ?? json['status'] as bool? ?? false;
    final message = json['message'] as String?;
    List<PracticeQuestion> items = [];

    final rawData = json['data'];
    if (rawData is Map<String, dynamic> && rawData['items'] is List) {
      items = (rawData['items'] as List)
          .map((e) => PracticeQuestion.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (rawData is List) {
      items = rawData.map((e) => PracticeQuestion.fromJson(e as Map<String, dynamic>)).toList();
    }

    final meta = PaginationMeta.fromJson(
      (json['meta'] as Map<String, dynamic>?) ??
          (rawData is Map<String, dynamic> ? rawData['meta'] as Map<String, dynamic>? : null),
    );

    return SubjectQuestionsResponse(
      success: success,
      message: message,
      items: items,
      meta: meta,
    );
  }
}

/// ─── Subject Section Overview Model (GET /api/v1/subject-sections) ───────
class SubjectSectionOverview {
  final int id;
  final String name;
  final String? slug;
  final String? description;
  final bool status;
  final bool showApp;
  final int? subjectsCount;

  const SubjectSectionOverview({
    required this.id,
    required this.name,
    this.slug,
    this.description,
    this.status = true,
    this.showApp = true,
    this.subjectsCount,
  });

  factory SubjectSectionOverview.fromJson(Map<String, dynamic> json) {
    return SubjectSectionOverview(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String?,
      description: json['description'] as String?,
      status: json['status'] is bool
          ? json['status'] as bool
          : (json['status'] == 1 || json['status'] == '1'),
      showApp: json['show_app'] is bool
          ? json['show_app'] as bool
          : (json['show_app'] != false && json['show_app'] != 0),
      subjectsCount: json['subjects_count'] as int? ?? json['subject_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'description': description,
        'status': status,
        'show_app': showApp,
        'subjects_count': subjectsCount,
      };
}

/// ─── Subject Exam Option Models (POST /api/v1/subject-sections/subjects/{id}/start-exam)
class SubjectStartExamRequest {
  final int? questionCount;
  final bool enableTimer;
  final int? time;
  final bool enableNegativeMark;
  final double? negativeMark;
  final String? questionOption; // random, latest, unanswered, answered, wrong_answered, correct_answered

  const SubjectStartExamRequest({
    this.questionCount = 10,
    this.enableTimer = true,
    this.time = 15,
    this.enableNegativeMark = true,
    this.negativeMark = 0.25,
    this.questionOption = 'random',
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (questionCount != null) map['question_count'] = questionCount;
    map['enable_timer'] = enableTimer;
    if (time != null) map['time'] = time;
    map['enable_negative_mark'] = enableNegativeMark;
    if (negativeMark != null) map['negative_mark'] = negativeMark;
    if (questionOption != null) map['question_option'] = questionOption;
    return map;
  }
}

class SubjectExamSession {
  final int examId;
  final int totalQuestions;
  final int duration;
  final List<String> guidelines;
  final Map<String, String> webviewUrls;

  const SubjectExamSession({
    required this.examId,
    this.totalQuestions = 0,
    this.duration = 0,
    this.guidelines = const [],
    this.webviewUrls = const {},
  });

  String? get startUrl => webviewUrls['start'];
  String? get resultUrl => webviewUrls['result'];

  factory SubjectExamSession.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    final rawGuidelines = data['guidelines'] as List? ?? [];
    final guidelines = rawGuidelines.map((e) => e.toString()).toList();

    final rawUrls = data['webview_urls'] as Map<String, dynamic>? ?? {};
    final webviewUrls = rawUrls.map((k, v) => MapEntry(k.toString(), v.toString()));

    return SubjectExamSession(
      examId: data['exam_id'] is int
          ? data['exam_id'] as int
          : int.tryParse(data['exam_id']?.toString() ?? '') ?? 0,
      totalQuestions: data['total_questions'] as int? ?? 0,
      duration: data['duration'] as int? ?? 0,
      guidelines: guidelines,
      webviewUrls: webviewUrls,
    );
  }

  Map<String, dynamic> toJson() => {
        'exam_id': examId,
        'total_questions': totalQuestions,
        'duration': duration,
        'guidelines': guidelines,
        'webview_urls': webviewUrls,
      };
}

