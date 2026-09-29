import 'dart:convert';

class ExamQuestionResultModel {
  final int questionNumber;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex; // 0 = A, 1 = B, 2 = C, 3 = D
  final int? userSelectedOptionIndex; // null if avoided
  final String? studentAnswer;
  final String? correctAnswer;
  final String? explanation;
  final String? explanationImage;
  final bool? _explicitIsCorrect;

  const ExamQuestionResultModel({
    required this.questionNumber,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    this.userSelectedOptionIndex,
    this.studentAnswer,
    this.correctAnswer,
    this.explanation,
    this.explanationImage,
    bool? isCorrect,
  }) : _explicitIsCorrect = isCorrect;

  bool get isCorrect =>
      _explicitIsCorrect ??
      (userSelectedOptionIndex != null &&
          userSelectedOptionIndex == correctOptionIndex);

  bool get isAvoided => userSelectedOptionIndex == null;

  bool get isWrong => !isCorrect && !isAvoided;

  factory ExamQuestionResultModel.fromJson(Map<String, dynamic> json, {int index = 1}) {
    // Check if question fields are nested inside a `question` object
    final Map<String, dynamic> qMap = (json['question'] is Map<String, dynamic>)
        ? json['question'] as Map<String, dynamic>
        : (json['question'] is Map
            ? Map<String, dynamic>.from(json['question'] as Map)
            : json);

    // 1. Question Number
    final qNum = json['question_number'] is int
        ? json['question_number'] as int
        : (qMap['id'] is int
            ? index
            : int.tryParse(json['question_number']?.toString() ?? '') ?? index);

    // 2. Question Text (Check question_title first as used in V1 API)
    final qText = (qMap['question_title'] ??
            json['question_title'] ??
            qMap['question_text'] ??
            json['question_text'] ??
            qMap['title'] ??
            json['title'] ??
            (qMap['question'] is String ? qMap['question'] : null) ??
            (json['question'] is String ? json['question'] : null) ??
            qMap['name'] ??
            json['name'] ??
            qMap['question_name'] ??
            json['question_name'] ??
            '')
        .toString()
        .trim();

    // 3. Option Key Map and Parsing
    final rawOptions = qMap['options'] ?? json['options'];
    List<String> parsedOptions = [];
    int detectedCorrectIndex = -1;
    Map<String, int> optionKeyMap = {}; // Maps key/letter to index

    if (rawOptions is List) {
      for (int i = 0; i < rawOptions.length; i++) {
        final opt = rawOptions[i];
        final letter = String.fromCharCode(65 + i); // A, B, C, D
        optionKeyMap[letter.toLowerCase()] = i;
        optionKeyMap['$i'] = i;
        optionKeyMap['${i + 1}'] = i;

        if (opt is String) {
          parsedOptions.add(opt);
        } else if (opt is Map) {
          final optText = opt['value']?.toString() ??
              opt['title']?.toString() ??
              opt['option']?.toString() ??
              opt['text']?.toString() ??
              opt['name']?.toString() ??
              opt['option_text']?.toString() ??
              opt['option_title']?.toString() ??
              '';
          parsedOptions.add(optText);

          final optKey = opt['key']?.toString();
          if (optKey != null) {
            optionKeyMap[optKey.toLowerCase()] = i;
          }

          if (opt['is_correct'] == true || opt['isCorrect'] == true) {
            detectedCorrectIndex = i;
          }
        }
      }
    } else if (rawOptions is Map) {
      // Check for indexed keys like option_1, option_2 or 1, 2, 3, 4
      final optKeys = [
        'option_1',
        'option_2',
        'option_3',
        'option_4',
        'option1',
        'option2',
        'option3',
        'option4',
        'opt_1',
        'opt_2',
        'opt_3',
        'opt_4'
      ];
      bool hasIndexedKeys = optKeys.any((k) => rawOptions.containsKey(k));
      if (hasIndexedKeys) {
        for (int i = 1; i <= 4; i++) {
          final val = rawOptions['option_$i'] ??
              rawOptions['option$i'] ??
              rawOptions['opt_$i'] ??
              rawOptions['opt$i'] ??
              rawOptions['$i'];
          final text = val?.toString() ?? '';
          parsedOptions.add(text);
          optionKeyMap['$i'] = i - 1;
          optionKeyMap['${i - 1}'] = i - 1;
          optionKeyMap[String.fromCharCode(65 + (i - 1)).toLowerCase()] = i - 1;
        }
      } else {
        int i = 0;
        rawOptions.forEach((k, v) {
          parsedOptions.add(v?.toString() ?? '');
          optionKeyMap[k.toString().toLowerCase()] = i;
          final letter = String.fromCharCode(65 + i);
          optionKeyMap[letter.toLowerCase()] = i;
          optionKeyMap['$i'] = i;
          optionKeyMap['${i + 1}'] = i;
          i++;
        });
      }
    } else {
      // Flat keys inside json or qMap
      final opt1 = qMap['option_1'] ?? json['option_1'];
      final opt2 = qMap['option_2'] ?? json['option_2'];
      final opt3 = qMap['option_3'] ?? json['option_3'];
      final opt4 = qMap['option_4'] ?? json['option_4'];
      if (opt1 != null || opt2 != null || opt3 != null || opt4 != null) {
        final list = [opt1, opt2, opt3, opt4];
        for (int i = 0; i < list.length; i++) {
          parsedOptions.add(list[i]?.toString() ?? '');
          optionKeyMap['${i + 1}'] = i;
          optionKeyMap['$i'] = i;
          optionKeyMap[String.fromCharCode(65 + i).toLowerCase()] = i;
        }
      }
    }

    // Default to 4 standard options (A, B, C, D) if empty
    if (parsedOptions.isEmpty) {
      parsedOptions = ['', '', '', ''];
      for (int i = 0; i < 4; i++) {
        optionKeyMap['$i'] = i;
        optionKeyMap['${i + 1}'] = i;
        optionKeyMap[String.fromCharCode(65 + i).toLowerCase()] = i;
      }
    }

    // Helper to safely extract index from dynamic input (handles nested lists, json string, map, int)
    int? parseIndex(dynamic raw) {
      if (raw == null) return null;
      if (raw is int) {
        if (raw >= 0 && raw < parsedOptions.length) return raw;
        if (raw > 0 && raw <= parsedOptions.length) return raw - 1;
        return raw;
      }
      if (raw is List) {
        if (raw.isEmpty) return null;
        return parseIndex(raw.first);
      }
      if (raw is Map) {
        return parseIndex(
            raw['key'] ?? raw['answer'] ?? raw['value'] ?? raw['id']);
      }
      String str = raw.toString().trim();
      if (str.isEmpty || str.toLowerCase() == 'null') return null;

      // Try JSON decoding if it starts with [ or {
      if (str.startsWith('[') || str.startsWith('{')) {
        try {
          final decoded = jsonDecode(str);
          final res = parseIndex(decoded);
          if (res != null) return res;
        } catch (_) {}
      }

      // Check regex for pattern like answer: 1 or key: 1
      final regexMatch =
          RegExp(r'(?:answer|key):\s*([0-9a-zA-Z]+)').firstMatch(str);
      if (regexMatch != null && regexMatch.groupCount >= 1) {
        str = regexMatch.group(1)!.trim();
      }

      // Strip extra brackets, quotes, escapes e.g. "[["1"]]" -> "1"
      str = str
          .replaceAll('[', '')
          .replaceAll(']', '')
          .replaceAll('"', '')
          .replaceAll("'", '')
          .replaceAll(r'\', '')
          .trim();

      if (optionKeyMap.containsKey(str.toLowerCase())) {
        return optionKeyMap[str.toLowerCase()];
      }

      final parsed = int.tryParse(str);
      if (parsed != null) {
        if (parsed >= 0 && parsed < parsedOptions.length) return parsed;
        if (parsed > 0 && parsed <= parsedOptions.length) return parsed - 1;
        return parsed;
      }

      // Match by exact option text
      final foundIdx =
          parsedOptions.indexWhere((o) => o.trim().toLowerCase() == str.toLowerCase());
      if (foundIdx != -1) return foundIdx;

      return null;
    }

    // 4. Correct Answer & Text extraction
    int correctIdx = detectedCorrectIndex;
    String? correctText;
    dynamic rawCorrect = json['correct_option_index'] ??
        json['correct_answer'] ??
        json['right_answer'] ??
        qMap['correct_answer'] ??
        qMap['right_answer'];

    if (rawCorrect != null) {
      if (rawCorrect is String &&
          (rawCorrect.startsWith('[') || rawCorrect.startsWith('{'))) {
        try {
          final decoded = jsonDecode(rawCorrect);
          if (decoded is List && decoded.isNotEmpty) {
            final first = decoded.first;
            if (first is Map) {
              correctText = first['value']?.toString() ??
                  first['title']?.toString() ??
                  first['text']?.toString();
            }
          } else if (decoded is Map) {
            correctText = decoded['value']?.toString() ??
                decoded['title']?.toString() ??
                decoded['text']?.toString();
          }
        } catch (_) {}
      } else if (rawCorrect is List && rawCorrect.isNotEmpty) {
        final first = rawCorrect.first;
        if (first is Map) {
          correctText = first['value']?.toString() ??
              first['title']?.toString() ??
              first['text']?.toString();
        }
      } else if (rawCorrect is Map) {
        correctText = rawCorrect['value']?.toString() ??
            rawCorrect['title']?.toString() ??
            rawCorrect['text']?.toString();
      }

      final parsedCorr = parseIndex(rawCorrect);
      if (parsedCorr != null &&
          parsedCorr >= 0 &&
          parsedCorr < parsedOptions.length) {
        correctIdx = parsedCorr;
      }
    }

    if (correctIdx == -1 && parsedOptions.isNotEmpty) {
      correctIdx = 0;
    }

    // Fill option text from correct_answer if option text was null/empty
    if (correctText != null &&
        correctText.trim().isNotEmpty &&
        correctIdx >= 0 &&
        correctIdx < parsedOptions.length) {
      if (parsedOptions[correctIdx].trim().isEmpty) {
        parsedOptions[correctIdx] = correctText.trim();
      }
    }

    // 5. Student Answer
    dynamic rawStudent = json['user_selected_option_index'] ??
        json['student_answer'] ??
        json['user_answer'] ??
        json['selected_option'] ??
        json['submitted_answer'] ??
        qMap['user_answer'] ??
        qMap['student_answer'];

    int? studentIdx;
    if (rawStudent != null &&
        rawStudent.toString().trim().isNotEmpty &&
        rawStudent.toString().trim().toLowerCase() != 'null') {
      studentIdx = parseIndex(rawStudent);
    }

    final explicitIsCorrect = json['is_correct'] is bool
        ? json['is_correct'] as bool
        : (json['is_correct'] != null
            ? json['is_correct'].toString().toLowerCase() == 'true' ||
                json['is_correct'].toString() == '1'
            : (qMap['is_correct'] is bool
                ? qMap['is_correct'] as bool
                : (qMap['is_correct'] != null
                    ? qMap['is_correct'].toString().toLowerCase() == 'true' ||
                        qMap['is_correct'].toString() == '1'
                    : null)));

    final rawExplanation = qMap['explanation'] ??
        json['explanation'] ??
        qMap['note'] ??
        json['note'];

    final rawExplImage = qMap['explanation_image'] ??
        json['explanation_image'];

    return ExamQuestionResultModel(
      questionNumber: qNum,
      questionText: qText,
      options: parsedOptions,
      correctOptionIndex: correctIdx,
      userSelectedOptionIndex: studentIdx,
      studentAnswer: rawStudent?.toString(),
      correctAnswer: correctText ?? rawCorrect?.toString(),
      explanation: rawExplanation?.toString(),
      explanationImage: rawExplImage?.toString(),
      isCorrect: explicitIsCorrect,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_number': questionNumber,
      'question_text': questionText,
      'options': options,
      'correct_option_index': correctOptionIndex,
      'user_selected_option_index': userSelectedOptionIndex,
      'student_answer': studentAnswer,
      'correct_answer': correctAnswer,
      'explanation': explanation,
      'explanation_image': explanationImage,
      'is_correct': isCorrect,
      'is_avoided': isAvoided,
      'is_wrong': isWrong,
    };
  }
}
