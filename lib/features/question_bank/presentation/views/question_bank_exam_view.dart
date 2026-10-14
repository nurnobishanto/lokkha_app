import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/features/home/data/models/home_feed_model.dart';

class ExamQuestionItem {
  final int id;
  final String question;
  final List<String> options;
  final int correctIndex; // 0-based
  final String explanation;
  final String subject;

  const ExamQuestionItem({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.subject,
  });
}

class QuestionBankExamView extends StatefulWidget {
  final HomeQuestionBankItem bankItem;
  final int durationMinutes;
  final double negativeMark;
  final bool isPracticeMode;

  const QuestionBankExamView({
    super.key,
    required this.bankItem,
    this.durationMinutes = 15,
    this.negativeMark = 0.25,
    this.isPracticeMode = false,
  });

  @override
  State<QuestionBankExamView> createState() => _QuestionBankExamViewState();
}

class _QuestionBankExamViewState extends State<QuestionBankExamView> {
  late final List<ExamQuestionItem> _questions;
  final Map<int, int> _selectedAnswers = {}; // question index -> option index
  int _currentIndex = 0;

  Timer? _timer;
  late int _remainingSeconds;
  bool _isSubmitted = false;
  bool _showExplanations = false;

  @override
  void initState() {
    super.initState();
    _questions = _getSampleQuestions(widget.bankItem.title);
    _remainingSeconds = widget.durationMinutes * 60;

    if (!widget.isPracticeMode) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        _submitExam(autoSubmit: true);
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _toBengaliNumber(int num) {
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bn = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    String s = num.toString();
    for (int i = 0; i < 10; i++) {
      s = s.replaceAll(en[i], bn[i]);
    }
    return s;
  }

  String _formatTimer(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _selectOption(int optionIndex) {
    if (_isSubmitted && !widget.isPracticeMode) return;
    setState(() {
      _selectedAnswers[_currentIndex] = optionIndex;
    });
  }

  void _submitExam({bool autoSubmit = false}) {
    _timer?.cancel();
    setState(() {
      _isSubmitted = true;
    });

    _showResultDialog(autoSubmit);
  }

  void _showResultDialog(bool autoSubmit) {
    int correctCount = 0;
    int incorrectCount = 0;

    for (int i = 0; i < _questions.length; i++) {
      final selected = _selectedAnswers[i];
      if (selected != null) {
        if (selected == _questions[i].correctIndex) {
          correctCount++;
        } else {
          incorrectCount++;
        }
      }
    }

    final int unattempted = _questions.length - (correctCount + incorrectCount);
    final double totalMarks =
        (correctCount * 1.0) - (incorrectCount * widget.negativeMark);
    final double percentage = _questions.isNotEmpty
        ? ((correctCount / _questions.length) * 100).clamp(0, 100)
        : 0.0;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 30.h),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: context.borderColor,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 16.h),
              Icon(
                percentage >= 60
                    ? Icons.emoji_events_rounded
                    : Icons.sentiment_satisfied_alt_rounded,
                size: 50.r,
                color: percentage >= 60
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFF006A4E),
              ),
              SizedBox(height: 10.h),
              Text(
                autoSubmit
                    ? 'সময় সমাপ্ত! পরীক্ষা জমা হয়েছে'
                    : 'পরীক্ষা সফলভাবে সম্পন্ন হয়েছে!',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                widget.bankItem.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: context.textSecondary,
                ),
              ),
              SizedBox(height: 16.h),

              // Stats Row
              Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: context.scaffoldBg,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: context.borderColor.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildResultStat(
                        label: 'মোট নম্বর',
                        value: totalMarks.toStringAsFixed(1),
                        color: const Color(0xFF006A4E),
                      ),
                    ),
                    Expanded(
                      child: _buildResultStat(
                        label: 'সঠিক উত্তর',
                        value: '$correctCount',
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    Expanded(
                      child: _buildResultStat(
                        label: 'ভুল উত্তর',
                        value: '$incorrectCount',
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                    Expanded(
                      child: _buildResultStat(
                        label: 'উত্তরহীন',
                        value: '$unattempted',
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        setState(() {
                          _showExplanations = true;
                          _currentIndex = 0;
                        });
                      },
                      icon: const Icon(Icons.auto_stories_rounded, size: 18),
                      label: const Text('উত্তরমালা ও ব্যাখ্যা'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF006A4E),
                        side: const BorderSide(color: Color(0xFF006A4E)),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('সম্পন্ন'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006A4E),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          ),
        );
      },
    );
  }

  Widget _buildResultStat({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: context.textSecondary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.bankItem.title)),
        body: const Center(child: Text('কোনো প্রশ্ন পাওয়া যায়নি')),
      );
    }

    final question = _questions[_currentIndex];
    final selectedOption = _selectedAnswers[_currentIndex];

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF006A4E),
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () {
            if (!_isSubmitted && !widget.isPracticeMode) {
              _showExitConfirmation();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.bankItem.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              widget.isPracticeMode ? 'অনুশীলন মোড' : 'লাইভ পরীক্ষা',
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.white.withOpacity(0.85),
              ),
            ),
          ],
        ),
        actions: [
          if (!widget.isPracticeMode && !_isSubmitted) ...[
            Container(
              margin: EdgeInsets.only(right: 14.w),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: _remainingSeconds < 120
                    ? const Color(0xFFEF4444)
                    : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 16, color: Colors.white),
                  SizedBox(width: 4.w),
                  Text(
                    _formatTimer(_remainingSeconds),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _questions.length,
              backgroundColor: context.borderColor.withOpacity(0.4),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF006A4E)),
              minHeight: 4.h,
            ),

            // Top Status Bar: Question X of Y
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF006A4E).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      'প্রশ্ন ${_toBengaliNumber(_currentIndex + 1)} / ${_toBengaliNumber(_questions.length)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF006A4E),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      question.subject,
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: context.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Question Card & Options
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                children: [
                  // Question Box
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: context.cardColor,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: context.borderColor.withOpacity(0.6),
                      ),
                    ),
                    child: Text(
                      question.question,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: context.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),

                  SizedBox(height: 14.h),

                  // Options
                  ...List.generate(question.options.length, (optIndex) {
                    final isSelected = selectedOption == optIndex;
                    final isCorrect = question.correctIndex == optIndex;

                    Color optionBg = context.cardColor;
                    Color borderColor = context.borderColor.withOpacity(0.6);
                    Color textColor = context.textPrimary;
                    Widget? trailingIcon;

                    if (_showExplanations) {
                      if (isCorrect) {
                        optionBg = const Color(0xFF10B981).withOpacity(0.12);
                        borderColor = const Color(0xFF10B981);
                        textColor = const Color(0xFF059669);
                        trailingIcon = const Icon(Icons.check_circle_rounded,
                            color: Color(0xFF10B981), size: 20);
                      } else if (isSelected) {
                        optionBg = const Color(0xFFEF4444).withOpacity(0.1);
                        borderColor = const Color(0xFFEF4444);
                        textColor = const Color(0xFFDC2626);
                        trailingIcon = const Icon(Icons.cancel_rounded,
                            color: Color(0xFFEF4444), size: 20);
                      }
                    } else if (isSelected) {
                      optionBg = const Color(0xFF006A4E).withOpacity(0.1);
                      borderColor = const Color(0xFF006A4E);
                      textColor = const Color(0xFF006A4E);
                    }

                    const prefixes = ['A', 'B', 'C', 'D'];

                    return Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: InkWell(
                        onTap: () => _selectOption(optIndex),
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 14.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            color: optionBg,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: borderColor, width: 1.2),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28.r,
                                height: 28.r,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF006A4E)
                                      : context.scaffoldBg,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF006A4E)
                                        : context.borderColor,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    prefixes[optIndex],
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : context.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  question.options[optIndex],
                                  style: TextStyle(
                                    fontSize: 13.5.sp,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              if (trailingIcon != null) trailingIcon,
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  // Explanation Box (if reviewing or in practice mode)
                  if (_showExplanations ||
                      (widget.isPracticeMode && selectedOption != null)) ...[
                    SizedBox(height: 10.h),
                    Container(
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: const Color(0xFF10B981).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.lightbulb_outline_rounded,
                                  size: 18, color: Color(0xFF059669)),
                              SizedBox(width: 6.w),
                              Text(
                                'ব্যাখ্যা ও সমাধান',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF059669),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            question.explanation,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: context.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Bottom Navigation Actions
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: context.cardColor,
                border: Border(
                  top: BorderSide(
                    color: context.borderColor.withOpacity(0.4),
                  ),
                ),
              ),
              child: Row(
                children: [
                  if (_currentIndex > 0)
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _currentIndex--;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: const Text('পূর্ববর্তী'),
                    )
                  else
                    const SizedBox.shrink(),

                  const Spacer(),

                  if (_currentIndex < _questions.length - 1)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentIndex++;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006A4E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: const Text('পরবর্তী'),
                    )
                  else if (!_isSubmitted)
                    ElevatedButton.icon(
                      onPressed: () => _submitExam(),
                      icon: const Icon(Icons.send_rounded, size: 16),
                      label: const Text('জমা দিন'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('পরীক্ষা বাতিল করবেন?'),
        content: const Text(
            'আপনি পরীক্ষা শেষ করার আগেই প্রস্থান করছেন। আপনি কি নিশ্চিত?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('না, চালিয়ে যান'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('হ্যাঁ, বের হন'),
          ),
        ],
      ),
    );
  }

  // Realistic sample question bank generator for testing & offline readiness
  List<ExamQuestionItem> _getSampleQuestions(String title) {
    if (title.contains('বাংলা')) {
      return const [
        ExamQuestionItem(
          id: 1,
          question: '‘চর্যাপদ’ কোন ছন্দে রচিত?',
          options: ['অক্ষরবৃত্ত ছন্দ', 'মাত্রাবৃত্ত ছন্দ', 'স্বরবৃত্ত ছন্দ', 'পয়ার ছন্দ'],
          correctIndex: 1,
          explanation: 'চর্যাপদের পদগুলো প্রধানত মাত্রাবৃত্ত ছন্দে রচিত। মহামহোপাধ্যায় হরপ্রসাদ শাস্ত্রী ১৯০৭ সালে নেপালের রাজদরবারের রয়েল লাইব্রেরি থেকে চর্যাপদ আবিষ্কার করেন।',
          subject: 'বাংলা ভাষা ও সাহিত্য',
        ),
        ExamQuestionItem(
          id: 2,
          question: 'বাংলা সাহিত্যের প্রথম সার্থক মহাকাব্য কোনটি?',
          options: ['পদ্মাবতী', 'মেঘনাদবধ কাব্য', 'অন্নদামঙ্গল', 'মহাশ্মশান'],
          correctIndex: 1,
          explanation: 'মাইকেল মধুসূদন দত্ত রচিত ‘মেঘনাদবধ কাব্য’ (১৮৬১) বাংলা সাহিত্যের প্রথম সার্থক আধুনিক মহাকাব্য। এটি অমিত্রাক্ষর ছন্দে রচিত।',
          subject: 'বাংলা ভাষা ও সাহিত্য',
        ),
      ];
    } else if (title.contains('English')) {
      return const [
        ExamQuestionItem(
          id: 3,
          question: 'Which of the following words is synonymous with "Altruistic"?',
          options: ['Selfish', 'Benevolent', 'Hostile', 'Greedy'],
          correctIndex: 1,
          explanation: 'Altruistic means showing a disinterested and selfless concern for the well-being of others; unselfish. Benevolent is its true synonym.',
          subject: 'English Language',
        ),
        ExamQuestionItem(
          id: 4,
          question: 'Who wrote the famous tragedy "Macbeth"?',
          options: ['Christopher Marlowe', 'William Shakespeare', 'John Milton', 'Geoffrey Chaucer'],
          correctIndex: 1,
          explanation: 'Macbeth is a tragedy by William Shakespeare; it is thought to have been first performed in 1606.',
          subject: 'English Literature',
        ),
      ];
    } else {
      return const [
        ExamQuestionItem(
          id: 101,
          question: 'বাংলাদেশের বর্তমান সংবিধান কার্যকর হয় কোন তারিখে?',
          options: ['১৬ ডিসেম্বর ১৯৭১', '২৬ মার্চ ১৯৭২', '১৬ ডিসেম্বর ১৯৭২', '৪ নভেম্বর ১৯৭২'],
          correctIndex: 2,
          explanation: '১৯৭২ সালের ৪ নভেম্বর গণপরিষদে সংবিধান গৃহীত হয় এবং একই বছরের বিজয় দিবস ১৬ ডিসেম্বর থেকে তা কার্যকর হয়।',
          subject: 'বাংলাদেশ বিষয়াবলী',
        ),
        ExamQuestionItem(
          id: 102,
          question: 'বৃত্তের পরিধি ও ব্যাসের অনুপাতকে কী বলে?',
          options: ['পাই (π)', 'থিটা (θ)', 'ডেল্টা (Δ)', 'ল্যাম্বডা (λ)'],
          correctIndex: 0,
          explanation: 'যেকোনো বৃত্তের পরিধি এবং ব্যাসের অনুপাত একটি ধ্রুবক সংখ্যা, যাকে গ্রিক বর্ণ পাই (π) দ্বারা প্রকাশ করা হয় (প্রায় ৩.১৪১৫৯)।',
          subject: 'গাণিতিক যুক্তি',
        ),
        ExamQuestionItem(
          id: 103,
          question: 'কম্পিউটারের কেন্দ্রীয় প্রক্রিয়াকরণ ইউনিট (CPU)-কে কী বলা হয়?',
          options: ['কম্পিউটারের মস্তিষ্ক', 'হার্ডডিস্ক', 'র‍্যাম', 'মাদারবোর্ড'],
          correctIndex: 0,
          explanation: 'CPU (Central Processing Unit)-কে কম্পিউটারের ব্রেইন বা মস্তিষ্ক বলা হয়, কারণ এটি কম্পিউটারের যাবতীয় গাণিতিক ও যৌক্তিক কাজ নিয়ন্ত্রণ করে।',
          subject: 'কম্পিউটার ও তথ্যপ্রযুক্তি',
        ),
      ];
    }
  }
}
