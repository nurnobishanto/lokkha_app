class SelfExamActivityModel {
  final String time;
  final int totalQuestions;
  final String totalMark;
  final String positiveMark;
  final String studentName;
  final String studentId;
  final String fullMark;
  final String yourMark;
  final String attempt;
  final String avoid;
  final String correct;
  final String wrong;

  const SelfExamActivityModel({
    required this.time,
    required this.totalQuestions,
    required this.totalMark,
    required this.positiveMark,
    required this.studentName,
    required this.studentId,
    required this.fullMark,
    required this.yourMark,
    required this.attempt,
    required this.avoid,
    required this.correct,
    required this.wrong,
  });

  static String toBengaliDigits(dynamic number) {
    const banglaDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    final str = number.toString();
    final sb = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final codeUnit = str.codeUnitAt(i);
      if (codeUnit >= 48 && codeUnit <= 57) {
        sb.write(banglaDigits[codeUnit - 48]);
      } else {
        sb.write(str[i]);
      }
    }
    return sb.toString();
  }

  static String formatBengaliDuration(int? totalSeconds) {
    if (totalSeconds == null || totalSeconds <= 0) {
      return "০ মিনিট ০ সেকেন্ড";
    }
    final mins = totalSeconds ~/ 60;
    final secs = totalSeconds % 60;
    final bMins = toBengaliDigits(mins);
    final bSecs = toBengaliDigits(secs);
    return "$bMins মিনিট $bSecs সেকেন্ড";
  }

  factory SelfExamActivityModel.fromExam(
    dynamic exam, {
    String studentName = 'sadman',
    String studentId = '250500049',
  }) {
    final tQuestions = (exam.totalQuestions as int?) ?? 0;
    final cCount = (exam.correctCount as int?) ?? 0;
    final wCount = (exam.wrongCount as int?) ?? 0;

    final attemptedVal = (exam.attempted as int?) ?? 0;
    final attemptCount = attemptedVal > 0 ? attemptedVal : (cCount + wCount);

    final avoidedVal = (exam.avoided as int?) ?? 0;
    final avoidCount = avoidedVal > 0
        ? avoidedVal
        : (tQuestions - attemptCount).clamp(0, tQuestions);

    final attemptPct =
        tQuestions > 0 ? ((attemptCount / tQuestions) * 100).toInt() : 0;
    final avoidPct =
        tQuestions > 0 ? ((avoidCount / tQuestions) * 100).toInt() : 0;
    final correctPct =
        tQuestions > 0 ? ((cCount / tQuestions) * 100).toInt() : 0;
    final wrongPct =
        tQuestions > 0 ? ((wCount / tQuestions) * 100).toInt() : 0;

    final scoreStr = exam.obtainedMark?.toString() ?? '0';
    final statusStr = (exam.resultStatus != null &&
            exam.resultStatus.toString().isNotEmpty)
        ? exam.resultStatus.toString()
        : (exam.isPassed == true ? 'Passed' : 'Failed');
    final scorePctStr =
        ((exam.scorePercent as num?)?.toInt() ?? 0).toString();

    final posMarkInt = ((exam.positiveMark as num?)?.toInt() ?? 1);
    final scoreInt = ((exam.score as num?)?.toInt() ?? 0);
    final fullMarkVal = ((exam.totalMarks as num?)?.toInt() ?? 0);

    return SelfExamActivityModel(
      time: formatBengaliDuration(exam.completeDuration as int?),
      totalQuestions: tQuestions,
      totalMark: "X $posMarkInt = $scoreInt",
      positiveMark: "$posMarkInt",
      studentName: studentName,
      studentId: studentId,
      fullMark: "${fullMarkVal > 0 ? fullMarkVal : tQuestions}",
      yourMark: "$scoreStr ($scorePctStr) / $statusStr",
      attempt: "$attemptCount ($attemptPct%)",
      avoid: "$avoidCount ($avoidPct%)",
      correct: "$cCount ($correctPct%)",
      wrong: "$wCount ($wrongPct%)",
    );
  }
}
