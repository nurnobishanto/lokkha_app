import 'dart:convert';
import 'package:lokkha/core/network/endpoints.dart';

int? _safeInt(dynamic val) {
  if (val == null) return null;
  if (val is int) return val;
  if (val is num) return val.toInt();
  if (val is String) return int.tryParse(val);
  return null;
}

bool _safeBool(dynamic val) {
  if (val == null) return false;
  if (val is bool) return val;
  if (val is num) return val == 1;
  if (val is String) {
    final lower = val.toLowerCase().trim();
    return lower == 'true' || lower == '1';
  }
  return false;
}

/// 1. Option in Current Affairs
class CurrentAffairsOptionItem {
  final dynamic key;
  final String? labelBn;
  final String value;
  final bool isCorrect;

  const CurrentAffairsOptionItem({
    required this.key,
    this.labelBn,
    required this.value,
    this.isCorrect = false,
  });

  String get keyAsString => key?.toString() ?? '';
  String get displayLabel => (labelBn != null && labelBn!.isNotEmpty) ? labelBn! : keyAsString;
  String get displayValue {
    if (!value.contains('<')) return value;
    return CurrentAffairsFeedItem.stripHtmlToPlainText(value);
  }

  factory CurrentAffairsOptionItem.fromJson(Map<String, dynamic> json) {
    return CurrentAffairsOptionItem(
      key: json['key'] ?? '',
      labelBn: json['label_bn']?.toString(),
      value: json['value']?.toString() ?? '',
      isCorrect: _safeBool(json['is_correct']),
    );
  }

  Map<String, dynamic> toJson() => {
    'key': key,
    'label_bn': labelBn,
    'value': value,
    'is_correct': isCorrect,
  };
}

/// Category metadata attached to question
class CurrentAffairsCategoryInfo {
  final int id;
  final String name;
  final String type; // 'bangladesh' or 'international'

  const CurrentAffairsCategoryInfo({
    required this.id,
    required this.name,
    required this.type,
  });

  factory CurrentAffairsCategoryInfo.fromJson(Map<String, dynamic> json) {
    return CurrentAffairsCategoryInfo(
      id: _safeInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
  };
}

/// Subject metadata attached to question
class CurrentAffairsSubjectItem {
  final int id;
  final String name;
  final String? slug;
  final int? parentId;

  const CurrentAffairsSubjectItem({
    required this.id,
    required this.name,
    this.slug,
    this.parentId,
  });

  factory CurrentAffairsSubjectItem.fromJson(Map<String, dynamic> json) {
    return CurrentAffairsSubjectItem(
      id: _safeInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString(),
      parentId: _safeInt(json['parent_id']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'parent_id': parentId,
  };
}

/// Tag metadata attached to question
class CurrentAffairsTagItem {
  final int id;
  final String name;

  const CurrentAffairsTagItem({
    required this.id,
    required this.name,
  });

  factory CurrentAffairsTagItem.fromJson(Map<String, dynamic> json) {
    return CurrentAffairsTagItem(
      id: _safeInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}

/// Main Question item model
class CurrentAffairsFeedItem {
  final int id;
  final String? customId;
  final String title;
  final String? cleanTitle;
  final String? description;
  final String? questionType;
  final CurrentAffairsCategoryInfo? category;
  final String? date;
  final String? dateFormatted;
  final String? dateBn;
  final String? answer;
  final List<String> answers;
  final List<CurrentAffairsOptionItem> options;
  final String? explanation;
  final String? explanationHtml;
  final String? note;
  final String? reference;
  final String? questionImage;
  final String? explanationImage;
  final bool isBookmarked;
  final List<CurrentAffairsSubjectItem> subjects;
  final List<CurrentAffairsTagItem> tags;

  const CurrentAffairsFeedItem({
    required this.id,
    this.customId,
    required this.title,
    this.cleanTitle,
    this.description,
    this.questionType,
    this.category,
    this.date,
    this.dateFormatted,
    this.dateBn,
    this.answer,
    this.answers = const [],
    this.options = const [],
    this.explanation,
    this.explanationHtml,
    this.note,
    this.reference,
    this.questionImage,
    this.explanationImage,
    this.isBookmarked = false,
    this.subjects = const [],
    this.tags = const [],
  });

  /// Returns a clean plain-text title (all HTML tags stripped, entities decoded, extra whitespace collapsed).
  String get displayTitle {
    final candidate = (cleanTitle != null && cleanTitle!.trim().isNotEmpty)
        ? cleanTitle!
        : title;
    return stripHtmlToPlainText(candidate);
  }

  /// Generates sanitized HTML string for question title, removing empty paragraphs,
  /// redundant tags, fixing unclosed tags, handling dark mode, and attaching the serial prefix.
  String buildSanitizedHtmlTitle({String prefix = '', bool isDark = false}) {
    final raw = (title.trim().isNotEmpty) ? title : (cleanTitle ?? '');
    return sanitizeTitleHtml(raw, prefix: prefix, isDark: isDark);
  }

  /// Strips all HTML tags and decodes common HTML entities for plain text display.
  static String stripHtmlToPlainText(String raw) {
    if (raw.trim().isEmpty) return '';
    var s = raw.trim();

    // 1. Remove empty <p></p>, <div></div>, <span></span>
    final emptyTags = RegExp(
      r'<(?:p|div|span)\b[^>]*>(?:\s|&nbsp;|<br\s*/?>)*</(?:p|div|span)>',
      caseSensitive: false,
    );
    while (emptyTags.hasMatch(s)) {
      s = s.replaceAll(emptyTags, '');
    }

    // 2. Strip all HTML tags
    s = s.replaceAll(RegExp(r'<[^>]+>'), ' ');

    // 3. Decode common HTML entities
    s = s
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&lsquo;', '‘')
        .replaceAll('&rsquo;', '’')
        .replaceAll('&ldquo;', '“')
        .replaceAll('&rdquo;', '”')
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');

    // 4. Collapse multiple spaces and line breaks
    return s.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Sanitizes HTML question title for fast, clean, and readable rendering in [HtmlWidget].
  static String sanitizeTitleHtml(
    String raw, {
    String prefix = '',
    bool isDark = false,
  }) {
    if (raw.trim().isEmpty) {
      if (prefix.isNotEmpty) {
        return '<span style="color: #059669; font-weight: bold;">$prefix</span>';
      }
      return '';
    }

    var s = raw.trim();

    // In dark mode, strip hardcoded inline text colors so text stays legible
    if (isDark) {
      s = s.replaceAll(RegExp(r'color\s*:\s*[^;"]+;?', caseSensitive: false), '');
    }
    s = s.replaceAll(RegExp(r'background-color\s*:\s*[^;"]+;?', caseSensitive: false), '');

    // 1. Remove empty <p></p>, <div></div>, <span></span> repeatedly
    final emptyTags = RegExp(
      r'<(?:p|div|span)\b[^>]*>(?:\s|&nbsp;|<br\s*/?>)*</(?:p|div|span)>',
      caseSensitive: false,
    );
    while (emptyTags.hasMatch(s)) {
      s = s.replaceAll(emptyTags, '');
    }

    // 2. Replace paragraph breaks </p><p> with <br/>
    s = s.replaceAll(RegExp(r'</p>\s*<p\b[^>]*>', caseSensitive: false), '<br/>');

    // 3. Remove all <p> and </p> tags so it renders inline as a single cohesive block
    s = s.replaceAll(RegExp(r'</?p\b[^>]*>', caseSensitive: false), '');

    // 4. Remove orphan/trailing unclosed tags or <br> at start/end
    s = s.replaceAll(RegExp(r'^(?:\s*<br\s*/?>)+', caseSensitive: false), '');
    s = s.replaceAll(RegExp(r'(?:<br\s*/?>\s*)+$', caseSensitive: false), '');
    s = s.replaceAll(RegExp(r'<(?:br|div|span|p)\b[^>]*>\s*$', caseSensitive: false), '');
    s = s.replaceAll(RegExp(r'^\s*</(?:br|div|span|p)>', caseSensitive: false), '');
    s = s.replaceAll(RegExp(r'</(?:br|div|span|p)>\s*$', caseSensitive: false), '');

    // 5. Collapse excessive whitespace and line breaks
    s = s.replaceAll(RegExp(r'[\r\n]+'), ' ').trim();

    if (prefix.isNotEmpty) {
      return '<span style="color: #059669; font-weight: bold;">$prefix</span> $s';
    }
    return s;
  }

  String? get resolvedQuestionImage => Endpoints.resolveUrl(questionImage);
  String? get resolvedExplanationImage => Endpoints.resolveUrl(explanationImage);

  CurrentAffairsFeedItem copyWith({
    bool? isBookmarked,
  }) {
    return CurrentAffairsFeedItem(
      id: id,
      customId: customId,
      title: title,
      cleanTitle: cleanTitle,
      description: description,
      questionType: questionType,
      category: category,
      date: date,
      dateFormatted: dateFormatted,
      dateBn: dateBn,
      answer: answer,
      answers: answers,
      options: options,
      explanation: explanation,
      explanationHtml: explanationHtml,
      note: note,
      reference: reference,
      questionImage: questionImage,
      explanationImage: explanationImage,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      subjects: subjects,
      tags: tags,
    );
  }

  factory CurrentAffairsFeedItem.fromJson(Map<String, dynamic> json) {
    List<String> parsedAnswers = [];
    if (json['answers'] is List) {
      parsedAnswers = (json['answers'] as List).map((e) => e.toString()).toList();
    } else if (json['answer'] != null) {
      parsedAnswers = [json['answer'].toString()];
    }

    List<CurrentAffairsOptionItem> parsedOptions = [];
    if (json['options'] is List) {
      parsedOptions = (json['options'] as List)
          .map((e) => CurrentAffairsOptionItem.fromJson(
              e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e)))
          .toList();
    }

    List<CurrentAffairsSubjectItem> parsedSubjects = [];
    if (json['subjects'] is List) {
      parsedSubjects = (json['subjects'] as List)
          .map((e) => CurrentAffairsSubjectItem.fromJson(
              e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e)))
          .toList();
    }

    List<CurrentAffairsTagItem> parsedTags = [];
    if (json['tags'] is List) {
      parsedTags = (json['tags'] as List)
          .map((e) => CurrentAffairsTagItem.fromJson(
              e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e)))
          .toList();
    }

    CurrentAffairsCategoryInfo? parsedCategory;
    if (json['category'] is Map) {
      parsedCategory = CurrentAffairsCategoryInfo.fromJson(
          Map<String, dynamic>.from(json['category']));
    }

    return CurrentAffairsFeedItem(
      id: _safeInt(json['id']) ?? 0,
      customId: json['custom_id']?.toString(),
      title: json['title']?.toString() ?? '',
      cleanTitle: json['clean_title']?.toString(),
      description: json['description']?.toString(),
      questionType: json['question_type']?.toString(),
      category: parsedCategory,
      date: json['date']?.toString(),
      dateFormatted: json['date_formatted']?.toString(),
      dateBn: json['date_bn']?.toString(),
      answer: json['answer']?.toString(),
      answers: parsedAnswers,
      options: parsedOptions,
      explanation: json['explanation']?.toString(),
      explanationHtml: json['explanation_html']?.toString(),
      note: json['note']?.toString(),
      reference: json['reference']?.toString(),
      questionImage: json['question_image']?.toString(),
      explanationImage: json['explanation_image']?.toString(),
      isBookmarked: _safeBool(json['is_bookmarked']),
      subjects: parsedSubjects,
      tags: parsedTags,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'custom_id': customId,
    'title': title,
    'clean_title': cleanTitle,
    'description': description,
    'question_type': questionType,
    'category': category?.toJson(),
    'date': date,
    'date_formatted': dateFormatted,
    'date_bn': dateBn,
    'answer': answer,
    'answers': answers,
    'options': options.map((e) => e.toJson()).toList(),
    'explanation': explanation,
    'explanation_html': explanationHtml,
    'note': note,
    'reference': reference,
    'question_image': questionImage,
    'explanation_image': explanationImage,
    'is_bookmarked': isBookmarked,
    'subjects': subjects.map((e) => e.toJson()).toList(),
    'tags': tags.map((e) => e.toJson()).toList(),
  };
}

/// Grouped by Date Item
class CurrentAffairsDateGroup {
  final String date;
  final String? dateFormatted;
  final String? dateBn;
  final int totalQuestions;
  final List<CurrentAffairsFeedItem> questions;

  const CurrentAffairsDateGroup({
    required this.date,
    this.dateFormatted,
    this.dateBn,
    this.totalQuestions = 0,
    this.questions = const [],
  });

  CurrentAffairsDateGroup copyWith({
    List<CurrentAffairsFeedItem>? questions,
  }) {
    return CurrentAffairsDateGroup(
      date: date,
      dateFormatted: dateFormatted,
      dateBn: dateBn,
      totalQuestions: totalQuestions,
      questions: questions ?? this.questions,
    );
  }

  factory CurrentAffairsDateGroup.fromJson(Map<String, dynamic> json) {
    List<CurrentAffairsFeedItem> parsedQuestions = [];
    if (json['questions'] is List) {
      parsedQuestions = (json['questions'] as List)
          .map((e) => CurrentAffairsFeedItem.fromJson(
              e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e)))
          .toList();
    }

    return CurrentAffairsDateGroup(
      date: json['date']?.toString() ?? '',
      dateFormatted: json['date_formatted']?.toString(),
      dateBn: json['date_bn']?.toString(),
      totalQuestions: _safeInt(json['total_questions']) ?? parsedQuestions.length,
      questions: parsedQuestions,
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'date_formatted': dateFormatted,
    'date_bn': dateBn,
    'total_questions': totalQuestions,
    'questions': questions.map((e) => e.toJson()).toList(),
  };
}

/// Pagination Metadata
class CurrentAffairsPagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMore;

  const CurrentAffairsPagination({
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 20,
    this.total = 0,
    this.hasMore = false,
  });

  factory CurrentAffairsPagination.fromJson(Map<String, dynamic> json) {
    final cur = _safeInt(json['current_page']) ?? 1;
    final last = _safeInt(json['last_page']) ?? 1;
    final totalCount = _safeInt(json['total']) ?? 0;
    final per = _safeInt(json['per_page']) ?? 20;
    final hasMoreFlag = json['has_more'] != null ? _safeBool(json['has_more']) : cur < last;

    return CurrentAffairsPagination(
      currentPage: cur,
      lastPage: last,
      perPage: per,
      total: totalCount,
      hasMore: hasMoreFlag,
    );
  }

  Map<String, dynamic> toJson() => {
    'current_page': currentPage,
    'last_page': lastPage,
    'per_page': perPage,
    'total': total,
    'has_more': hasMore,
  };
}

/// 1. Feed Response
class CurrentAffairsFeedResponse {
  final bool success;
  final String message;
  final List<CurrentAffairsFeedItem> items;
  final List<CurrentAffairsDateGroup> groupedByDate;
  final CurrentAffairsPagination pagination;

  const CurrentAffairsFeedResponse({
    this.success = true,
    this.message = '',
    this.items = const [],
    this.groupedByDate = const [],
    this.pagination = const CurrentAffairsPagination(),
  });

  factory CurrentAffairsFeedResponse.fromJson(Map<String, dynamic> json) {
    final success = _safeBool(json['success'] ?? json['status'] ?? true);
    final message = json['message']?.toString() ?? '';

    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : (json['data'] is Map ? Map<String, dynamic>.from(json['data']) : json);

    List<CurrentAffairsFeedItem> parsedItems = [];
    if (data['items'] is List) {
      parsedItems = (data['items'] as List)
          .map((e) => CurrentAffairsFeedItem.fromJson(
              e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e)))
          .toList();
    }

    List<CurrentAffairsDateGroup> parsedGroups = [];
    if (data['grouped_by_date'] is List) {
      parsedGroups = (data['grouped_by_date'] as List)
          .map((e) => CurrentAffairsDateGroup.fromJson(
              e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e)))
          .toList();
    }

    CurrentAffairsPagination parsedPagination = const CurrentAffairsPagination();
    if (data['pagination'] is Map) {
      parsedPagination = CurrentAffairsPagination.fromJson(
          Map<String, dynamic>.from(data['pagination']));
    }

    return CurrentAffairsFeedResponse(
      success: success,
      message: message,
      items: parsedItems,
      groupedByDate: parsedGroups,
      pagination: parsedPagination,
    );
  }
}

/// 2. Monthly Digest Models
class CurrentAffairsSubscriptionPrompt {
  final String? title;
  final String? message;
  final String? actionText;
  final String? upgradeUrl;

  const CurrentAffairsSubscriptionPrompt({
    this.title,
    this.message,
    this.actionText,
    this.upgradeUrl,
  });

  factory CurrentAffairsSubscriptionPrompt.fromJson(Map<String, dynamic> json) {
    return CurrentAffairsSubscriptionPrompt(
      title: json['title']?.toString(),
      message: json['message']?.toString(),
      actionText: json['action_text']?.toString(),
      upgradeUrl: json['upgrade_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'message': message,
    'action_text': actionText,
    'upgrade_url': upgradeUrl,
  };
}

class CurrentAffairsDigestStatistics {
  final int totalQuestions;
  final int bangladesh;
  final int international;

  const CurrentAffairsDigestStatistics({
    this.totalQuestions = 0,
    this.bangladesh = 0,
    this.international = 0,
  });

  factory CurrentAffairsDigestStatistics.fromJson(Map<String, dynamic> json) {
    return CurrentAffairsDigestStatistics(
      totalQuestions: _safeInt(json['total_questions']) ?? 0,
      bangladesh: _safeInt(json['bangladesh']) ??
          _safeInt(json['total_national']) ??
          _safeInt(json['national']) ??
          0,
      international: _safeInt(json['international']) ??
          _safeInt(json['total_international']) ??
          0,
    );
  }

  Map<String, dynamic> toJson() => {
    'total_questions': totalQuestions,
    'bangladesh': bangladesh,
    'international': international,
  };
}

class CurrentAffairsDigestDownloads {
  final String? withOptionsPdf;
  final String? withoutOptionsPdf;

  const CurrentAffairsDigestDownloads({
    this.withOptionsPdf,
    this.withoutOptionsPdf,
  });

  factory CurrentAffairsDigestDownloads.fromJson(Map<String, dynamic> json) {
    return CurrentAffairsDigestDownloads(
      withOptionsPdf: json['with_options_pdf']?.toString(),
      withoutOptionsPdf: json['without_options_pdf']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'with_options_pdf': withOptionsPdf,
    'without_options_pdf': withoutOptionsPdf,
  };
}

class CurrentAffairsDigestCategory {
  final int id;
  final String name;
  final String? slug;
  final int totalQuestions;
  final List<CurrentAffairsFeedItem> questions;

  const CurrentAffairsDigestCategory({
    required this.id,
    required this.name,
    this.slug,
    this.totalQuestions = 0,
    this.questions = const [],
  });

  factory CurrentAffairsDigestCategory.fromJson(Map<String, dynamic> json) {
    List<CurrentAffairsFeedItem> parsedQuestions = [];
    if (json['questions'] is List) {
      parsedQuestions = (json['questions'] as List)
          .map((e) => CurrentAffairsFeedItem.fromJson(
              e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e)))
          .toList();
    }

    return CurrentAffairsDigestCategory(
      id: _safeInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString(),
      totalQuestions: _safeInt(json['total_questions']) ?? parsedQuestions.length,
      questions: parsedQuestions,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'total_questions': totalQuestions,
    'questions': questions.map((e) => e.toJson()).toList(),
  };
}

class CurrentAffairsMonthlyDigestResponse {
  final bool success;
  final String message;
  final String month;
  final String monthName;
  final String? monthNameEn;
  final bool isLocked;
  final CurrentAffairsSubscriptionPrompt? subscriptionPrompt;
  final CurrentAffairsDigestStatistics statistics;
  final CurrentAffairsDigestDownloads downloads;
  final List<CurrentAffairsDigestCategory> categories;

  const CurrentAffairsMonthlyDigestResponse({
    this.success = true,
    this.message = '',
    required this.month,
    required this.monthName,
    this.monthNameEn,
    this.isLocked = false,
    this.subscriptionPrompt,
    this.statistics = const CurrentAffairsDigestStatistics(),
    this.downloads = const CurrentAffairsDigestDownloads(),
    this.categories = const [],
  });

  factory CurrentAffairsMonthlyDigestResponse.fromJson(Map<String, dynamic> json) {
    final success = _safeBool(json['success'] ?? json['status'] ?? true);
    final message = json['message']?.toString() ?? '';

    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : (json['data'] is Map ? Map<String, dynamic>.from(json['data']) : json);

    CurrentAffairsSubscriptionPrompt? prompt;
    if (data['subscription_prompt'] is Map) {
      prompt = CurrentAffairsSubscriptionPrompt.fromJson(
          Map<String, dynamic>.from(data['subscription_prompt']));
    }

    CurrentAffairsDigestStatistics stats = const CurrentAffairsDigestStatistics();
    if (data['statistics'] is Map) {
      stats = CurrentAffairsDigestStatistics.fromJson(
          Map<String, dynamic>.from(data['statistics']));
    }

    CurrentAffairsDigestDownloads dls = const CurrentAffairsDigestDownloads();
    if (data['downloads'] is Map) {
      dls = CurrentAffairsDigestDownloads.fromJson(
          Map<String, dynamic>.from(data['downloads']));
    }

    List<CurrentAffairsDigestCategory> cats = [];
    if (data['categories'] is List) {
      cats = (data['categories'] as List)
          .map((e) => CurrentAffairsDigestCategory.fromJson(
              e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e)))
          .toList();
    } else {
      if (data['national_affairs'] is Map) {
        final na = data['national_affairs'] as Map;
        final items = na['items'] is List
            ? (na['items'] as List)
                .map((e) => CurrentAffairsFeedItem.fromJson(
                    e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e)))
                .toList()
            : <CurrentAffairsFeedItem>[];
        cats.add(CurrentAffairsDigestCategory(
          id: 5,
          name: 'বাংলাদেশ বিষয়াবলি',
          slug: 'bangladesh-affairs',
          totalQuestions: _safeInt(na['count']) ?? items.length,
          questions: items,
        ));
      }
      if (data['international_affairs'] is Map) {
        final ia = data['international_affairs'] as Map;
        final items = ia['items'] is List
            ? (ia['items'] as List)
                .map((e) => CurrentAffairsFeedItem.fromJson(
                    e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e)))
                .toList()
            : <CurrentAffairsFeedItem>[];
        cats.add(CurrentAffairsDigestCategory(
          id: 8,
          name: 'আন্তর্জাতিক বিষয়াবলি',
          slug: 'international-affairs',
          totalQuestions: _safeInt(ia['count']) ?? items.length,
          questions: items,
        ));
      }
    }

    final monthStr = data['month']?.toString() ?? data['selected_month']?.toString() ?? '';

    return CurrentAffairsMonthlyDigestResponse(
      success: success,
      message: message,
      month: monthStr,
      monthName: data['month_name']?.toString() ?? '',
      monthNameEn: data['month_name_en']?.toString(),
      isLocked: _safeBool(data['is_locked']),
      subscriptionPrompt: prompt,
      statistics: stats,
      downloads: dls,
      categories: cats,
    );
  }
}

/// 3. Months Archive Item
class CurrentAffairsMonthItem {
  final String month; // e.g. "2026-10"
  final String labelBn;
  final String? labelEn;
  final int year;
  final int monthNumber;
  final int totalQuestions;
  final String? display;

  const CurrentAffairsMonthItem({
    required this.month,
    required this.labelBn,
    this.labelEn,
    required this.year,
    required this.monthNumber,
    this.totalQuestions = 0,
    this.display,
  });

  String get value => month;
  int get count => totalQuestions;
  String get displayTitle => (display != null && display!.isNotEmpty) ? display! : labelBn;

  factory CurrentAffairsMonthItem.fromJson(Map<String, dynamic> json) {
    final value = json['value']?.toString() ?? json['month']?.toString() ?? '';
    final count = _safeInt(json['count']) ?? _safeInt(json['total_questions']) ?? 0;
    return CurrentAffairsMonthItem(
      month: value,
      labelBn: json['label_bn']?.toString() ?? value,
      labelEn: json['label_en']?.toString(),
      year: _safeInt(json['year']) ?? 2026,
      monthNumber: _safeInt(json['month_number']) ?? (_safeInt(json['month']) ?? 1),
      totalQuestions: count,
      display: json['display']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'month': month,
    'value': month,
    'label_bn': labelBn,
    'label_en': labelEn,
    'year': year,
    'month_number': monthNumber,
    'total_questions': totalQuestions,
    'count': totalQuestions,
    if (display != null) 'display': display,
  };
}

/// 4. Topic Category Tree Item
class CurrentAffairsTopicTreeItem {
  final int id;
  final String name;
  final String? slug;
  final int questionsCount;
  final List<CurrentAffairsTopicTreeItem> children;

  const CurrentAffairsTopicTreeItem({
    required this.id,
    required this.name,
    this.slug,
    this.questionsCount = 0,
    this.children = const [],
  });

  factory CurrentAffairsTopicTreeItem.fromJson(Map<String, dynamic> json) {
    List<CurrentAffairsTopicTreeItem> childList = [];
    if (json['children'] is List) {
      childList = (json['children'] as List)
          .map((e) => CurrentAffairsTopicTreeItem.fromJson(
              e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e)))
          .toList();
    }

    return CurrentAffairsTopicTreeItem(
      id: _safeInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString(),
      questionsCount: _safeInt(json['questions_count']) ?? 0,
      children: childList,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'questions_count': questionsCount,
    'children': children.map((e) => e.toJson()).toList(),
  };
}

class CurrentAffairsCategoriesResponse {
  final bool success;
  final String message;
  final List<CurrentAffairsTopicTreeItem> bangladesh;
  final List<CurrentAffairsTopicTreeItem> international;

  const CurrentAffairsCategoriesResponse({
    this.success = true,
    this.message = '',
    this.bangladesh = const [],
    this.international = const [],
  });

  factory CurrentAffairsCategoriesResponse.fromJson(Map<String, dynamic> json) {
    final success = _safeBool(json['success'] ?? json['status'] ?? true);
    final message = json['message']?.toString() ?? '';

    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : (json['data'] is Map ? Map<String, dynamic>.from(json['data']) : json);

    List<CurrentAffairsTopicTreeItem> bd = [];
    if (data['bangladesh'] is List) {
      bd = (data['bangladesh'] as List)
          .map((e) => CurrentAffairsTopicTreeItem.fromJson(
              e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e)))
          .toList();
    }

    List<CurrentAffairsTopicTreeItem> intl = [];
    if (data['international'] is List) {
      intl = (data['international'] as List)
          .map((e) => CurrentAffairsTopicTreeItem.fromJson(
              e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e)))
          .toList();
    }

    return CurrentAffairsCategoriesResponse(
      success: success,
      message: message,
      bangladesh: bd,
      international: intl,
    );
  }
}

/// 5. Latest Highlights Response
class CurrentAffairsLatestResponse {
  final bool success;
  final String message;
  final List<CurrentAffairsFeedItem> bangladesh;
  final List<CurrentAffairsFeedItem> international;

  const CurrentAffairsLatestResponse({
    this.success = true,
    this.message = '',
    this.bangladesh = const [],
    this.international = const [],
  });

  factory CurrentAffairsLatestResponse.fromJson(Map<String, dynamic> json) {
    final success = _safeBool(json['success'] ?? json['status'] ?? true);
    final message = json['message']?.toString() ?? '';

    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : (json['data'] is Map ? Map<String, dynamic>.from(json['data']) : json);

    List<CurrentAffairsFeedItem> bd = [];
    if (data['bangladesh'] is List) {
      bd = (data['bangladesh'] as List)
          .map((e) => CurrentAffairsFeedItem.fromJson(
              e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e)))
          .toList();
    }

    List<CurrentAffairsFeedItem> intl = [];
    if (data['international'] is List) {
      intl = (data['international'] as List)
          .map((e) => CurrentAffairsFeedItem.fromJson(
              e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e)))
          .toList();
    }

    return CurrentAffairsLatestResponse(
      success: success,
      message: message,
      bangladesh: bd,
      international: intl,
    );
  }
}

/// 6. Question Details Response
class CurrentAffairsDetailResponse {
  final bool success;
  final String message;
  final CurrentAffairsFeedItem? question;
  final List<CurrentAffairsFeedItem> relatedQuestions;

  const CurrentAffairsDetailResponse({
    this.success = true,
    this.message = '',
    this.question,
    this.relatedQuestions = const [],
  });

  factory CurrentAffairsDetailResponse.fromJson(Map<String, dynamic> json) {
    final success = _safeBool(json['success'] ?? json['status'] ?? true);
    final message = json['message']?.toString() ?? '';

    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : (json['data'] is Map ? Map<String, dynamic>.from(json['data']) : json);

    CurrentAffairsFeedItem? q;
    if (data['question'] is Map) {
      q = CurrentAffairsFeedItem.fromJson(
          Map<String, dynamic>.from(data['question']));
    }

    List<CurrentAffairsFeedItem> related = [];
    if (data['related_questions'] is List) {
      related = (data['related_questions'] as List)
          .map((e) => CurrentAffairsFeedItem.fromJson(
              e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e)))
          .toList();
    }

    return CurrentAffairsDetailResponse(
      success: success,
      message: message,
      question: q,
      relatedQuestions: related,
    );
  }
}

/// 7. Bookmark Toggle Response
class CurrentAffairsBookmarkResponse {
  final bool success;
  final String message;
  final bool isBookmarked;

  const CurrentAffairsBookmarkResponse({
    this.success = true,
    this.message = '',
    this.isBookmarked = false,
  });

  factory CurrentAffairsBookmarkResponse.fromJson(Map<String, dynamic> json) {
    final success = _safeBool(json['success'] ?? json['status'] ?? true);
    final message = json['message']?.toString() ?? '';

    bool bookmarked = false;
    if (json.containsKey('is_bookmarked')) {
      bookmarked = _safeBool(json['is_bookmarked']);
    } else if (json['data'] is Map && (json['data'] as Map).containsKey('is_bookmarked')) {
      bookmarked = _safeBool(json['data']['is_bookmarked']);
    }

    return CurrentAffairsBookmarkResponse(
      success: success,
      message: message,
      isBookmarked: bookmarked,
    );
  }
}
