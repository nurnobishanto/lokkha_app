class BookmarkedQuestion {
  final int id;
  final String questionText;
  final String subject;
  final String? topic;
  final List<String> options;
  final String correctAnswer;
  final String? explanation;
  final String? savedAt;

  BookmarkedQuestion({
    required this.id,
    required this.questionText,
    required this.subject,
    this.topic,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    this.savedAt,
  });

  factory BookmarkedQuestion.fromJson(Map<String, dynamic> json) {
    return BookmarkedQuestion(
      id: json['id'] as int? ?? 0,
      questionText: json['question'] as String? ?? json['title'] as String? ?? '',
      subject: json['subject'] as String? ?? 'সাধারণ জ্ঞান',
      topic: json['topic'] as String?,
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e is Map ? e['value']?.toString() ?? '' : e.toString())
              .toList() ??
          [],
      correctAnswer: json['correct_answer'] as String? ?? json['answer'] as String? ?? '',
      explanation: json['explanation'] as String?,
      savedAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': questionText,
        'subject': subject,
        'topic': topic,
        'options': options,
        'correct_answer': correctAnswer,
        'explanation': explanation,
        'created_at': savedAt,
      };
}
