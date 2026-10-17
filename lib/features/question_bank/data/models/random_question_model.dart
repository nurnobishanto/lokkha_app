import 'package:lokkha/core/network/endpoints.dart';

/// Response wrapper for the random question endpoint
class RandomQuestionResponse {
  final bool success;
  final String? message;
  final RandomQuestionModel? data;

  RandomQuestionResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory RandomQuestionResponse.fromJson(Map<String, dynamic> json) {
    return RandomQuestionResponse(
      success: json['success'] == true || json['status'] == true,
      message: json['message'] as String?,
      data: json['data'] is Map<String, dynamic>
          ? RandomQuestionModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        if (message != null) 'message': message,
        if (data != null) 'data': data!.toJson(),
      };
}

/// Domain model for Random Question retrieved from /api/v1/question-bank/random
class RandomQuestionModel {
  final int id;
  final String title;
  final String? description;
  final String? questionImage;
  final String? questionType;
  final List<RandomQuestionOption> options;
  final bool isFavorite;
  final List<RandomQuestionSubject> subjects;
  final List<RandomQuestionTag> tags;
  final String? explanation;
  final String? explanationImage;
  final String? note;
  final String? reference;
  final String? correctAnswer;

  RandomQuestionModel({
    required this.id,
    required this.title,
    this.description,
    this.questionImage,
    this.questionType = 'single_choice',
    this.options = const [],
    this.isFavorite = false,
    this.subjects = const [],
    this.tags = const [],
    this.explanation,
    this.explanationImage,
    this.note,
    this.reference,
    this.correctAnswer,
  });

  /// Strips HTML tags and entities for a clean, minimal text presentation.
  String get cleanTitle {
    var text = title.replaceAll(RegExp(r'<[^>]*>'), ' ').trim();
    text = text
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&nbsp;', ' ');
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Finds the 0-based index of the correct option
  int? get rightAnswerIndex {
    final idx = options.indexWhere((opt) => opt.isCorrect);
    if (idx != -1) return idx;

    // Fallback if correctAnswer key is provided (e.g. "A", "B", "1")
    if (correctAnswer != null && correctAnswer!.trim().isNotEmpty) {
      final keyMatch = options.indexWhere(
        (opt) => opt.key.trim().toLowerCase() == correctAnswer!.trim().toLowerCase(),
      );
      if (keyMatch != -1) return keyMatch;
    }
    return null;
  }

  /// Primary subject name (e.g. "English Language" or "বাংলা")
  String? get primarySubject => subjects.isNotEmpty ? subjects.first.name : null;

  factory RandomQuestionModel.fromJson(Map<String, dynamic> json) {
    // Options
    List<RandomQuestionOption> parsedOptions = [];
    if (json['options'] is List) {
      parsedOptions = (json['options'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => RandomQuestionOption.fromJson(e))
          .toList();
    }

    // Subjects
    List<RandomQuestionSubject> parsedSubjects = [];
    if (json['subjects'] is List) {
      parsedSubjects = (json['subjects'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => RandomQuestionSubject.fromJson(e))
          .toList();
    }

    // Tags
    List<RandomQuestionTag> parsedTags = [];
    if (json['tags'] is List) {
      parsedTags = (json['tags'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => RandomQuestionTag.fromJson(e))
          .toList();
    }

    return RandomQuestionModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      questionImage: Endpoints.resolveImageUrl(json['question_image'] as String?),
      questionType: json['question_type'] as String? ?? 'single_choice',
      options: parsedOptions,
      isFavorite: json['is_favorite'] == true || json['is_favorite'] == 1,
      subjects: parsedSubjects,
      tags: parsedTags,
      explanation: json['explanation'] as String?,
      explanationImage: Endpoints.resolveImageUrl(json['explanation_image'] as String?),
      note: json['note'] as String?,
      reference: json['reference'] as String?,
      correctAnswer: json['correct_answer'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        if (description != null) 'description': description,
        if (questionImage != null) 'question_image': questionImage,
        'question_type': questionType,
        'options': options.map((e) => e.toJson()).toList(),
        'is_favorite': isFavorite,
        'subjects': subjects.map((e) => e.toJson()).toList(),
        'tags': tags.map((e) => e.toJson()).toList(),
        if (explanation != null) 'explanation': explanation,
        if (explanationImage != null) 'explanation_image': explanationImage,
        if (note != null) 'note': note,
        if (reference != null) 'reference': reference,
        if (correctAnswer != null) 'correct_answer': correctAnswer,
      };
}

/// Option item within a RandomQuestion
class RandomQuestionOption {
  final String key;
  final String value;
  final bool isCorrect;

  RandomQuestionOption({
    required this.key,
    required this.value,
    this.isCorrect = false,
  });

  /// Displays the option text nicely prefixed: e.g. "A) Neuter Gender"
  String get displayOption {
    final cleanVal = value.trim();
    if (cleanVal.startsWith(RegExp(r'^[A-Za-z0-9]\s*\)'))) {
      return cleanVal;
    }
    return '$key) $cleanVal';
  }

  factory RandomQuestionOption.fromJson(Map<String, dynamic> json) {
    return RandomQuestionOption(
      key: json['key']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
      isCorrect: json['is_correct'] == true ||
          json['is_correct'] == 1 ||
          json['is_correct']?.toString().toLowerCase() == 'true',
    );
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'value': value,
        'is_correct': isCorrect,
      };
}

/// Subject associated with a question
class RandomQuestionSubject {
  final int id;
  final String name;

  RandomQuestionSubject({
    required this.id,
    required this.name,
  });

  factory RandomQuestionSubject.fromJson(Map<String, dynamic> json) {
    return RandomQuestionSubject(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

/// Tag associated with a question
class RandomQuestionTag {
  final int id;
  final String name;

  RandomQuestionTag({
    required this.id,
    required this.name,
  });

  factory RandomQuestionTag.fromJson(Map<String, dynamic> json) {
    return RandomQuestionTag(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}
