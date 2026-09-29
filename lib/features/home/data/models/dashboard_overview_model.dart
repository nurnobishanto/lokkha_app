class DashboardOverviewModel {
  final bool status;
  final String? message;
  final DashboardData? data;

  DashboardOverviewModel({
    required this.status,
    this.message,
    this.data,
  });

  factory DashboardOverviewModel.fromJson(Map<String, dynamic> json) {
    return DashboardOverviewModel(
      status: json['status'] == true || json['success'] == true,
      message: json['message'] as String?,
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? DashboardData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'data': data?.toJson(),
      };
}

class DashboardData {
  final UserSummary? user;
  final DashboardActiveSubscription? activeSubscription;
  final DashboardCounts? counts;
  final DashboardPerformance? performance;
  final DashboardReferral? referral;
  final DashboardRewards? rewards;

  // Legacy/fallback optional fields
  final List<DashboardSliderItem> sliders;
  final List<DashboardNoticeItem> notices;
  final List<DashboardCourseItem> activeCourses;
  final List<DashboardExamItem> upcomingExams;
  final double accuracyRate;
  final List<AccuracyPoint> accuracyPoints;

  DashboardData({
    this.user,
    this.activeSubscription,
    this.counts,
    this.performance,
    this.referral,
    this.rewards,
    this.sliders = const [],
    this.notices = const [],
    this.activeCourses = const [],
    this.upcomingExams = const [],
    this.accuracyRate = 0.0,
    this.accuracyPoints = const [],
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final perf = json['performance'] != null && json['performance'] is Map<String, dynamic>
        ? DashboardPerformance.fromJson(json['performance'] as Map<String, dynamic>)
        : null;

    final double calcAccuracy = perf?.accuracyRate ??
        ((json['accuracy_rate'] is num)
            ? (json['accuracy_rate'] as num).toDouble()
            : 0.0);

    return DashboardData(
      user: json['user'] != null && json['user'] is Map<String, dynamic>
          ? UserSummary.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      activeSubscription: json['active_subscription'] != null &&
              json['active_subscription'] is Map<String, dynamic>
          ? DashboardActiveSubscription.fromJson(
              json['active_subscription'] as Map<String, dynamic>)
          : null,
      counts: json['counts'] != null && json['counts'] is Map<String, dynamic>
          ? DashboardCounts.fromJson(json['counts'] as Map<String, dynamic>)
          : null,
      performance: perf,
      referral: json['referral'] != null && json['referral'] is Map<String, dynamic>
          ? DashboardReferral.fromJson(json['referral'] as Map<String, dynamic>)
          : null,
      rewards: json['rewards'] != null && json['rewards'] is Map<String, dynamic>
          ? DashboardRewards.fromJson(json['rewards'] as Map<String, dynamic>)
          : null,
      sliders: (json['sliders'] as List<dynamic>?)
              ?.map((e) => DashboardSliderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      notices: (json['notices'] as List<dynamic>?)
              ?.map((e) => DashboardNoticeItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      activeCourses: (json['active_courses'] as List<dynamic>?)
              ?.map((e) => DashboardCourseItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      upcomingExams: (json['upcoming_exams'] as List<dynamic>?)
              ?.map((e) => DashboardExamItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      accuracyRate: calcAccuracy,
      accuracyPoints: (json['accuracy_points'] as List<dynamic>?)
              ?.map((e) => AccuracyPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'user': user?.toJson(),
        'active_subscription': activeSubscription?.toJson(),
        'counts': counts?.toJson(),
        'performance': performance?.toJson(),
        'referral': referral?.toJson(),
        'rewards': rewards?.toJson(),
        'sliders': sliders.map((e) => e.toJson()).toList(),
        'notices': notices.map((e) => e.toJson()).toList(),
        'active_courses': activeCourses.map((e) => e.toJson()).toList(),
        'upcoming_exams': upcomingExams.map((e) => e.toJson()).toList(),
        'accuracy_rate': accuracyRate,
        'accuracy_points': accuracyPoints.map((e) => e.toJson()).toList(),
      };
}

class DashboardActiveSubscription {
  final int? id;
  final int? packageId;
  final String? packageName;
  final String? subscribedAt;
  final String? expiresAt;
  final bool isTrial;
  final int daysLeft;
  final String? status;

  DashboardActiveSubscription({
    this.id,
    this.packageId,
    this.packageName,
    this.subscribedAt,
    this.expiresAt,
    this.isTrial = false,
    this.daysLeft = 0,
    this.status,
  });

  factory DashboardActiveSubscription.fromJson(Map<String, dynamic> json) {
    return DashboardActiveSubscription(
      id: json['id'] as int?,
      packageId: json['package_id'] as int?,
      packageName: json['package_name'] as String?,
      subscribedAt: json['subscribed_at'] as String?,
      expiresAt: json['expires_at'] as String?,
      isTrial: json['is_trial'] == true || json['is_trial'] == 1,
      daysLeft: json['days_left'] as int? ?? 0,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'package_id': packageId,
        'package_name': packageName,
        'subscribed_at': subscribedAt,
        'expires_at': expiresAt,
        'is_trial': isTrial,
        'days_left': daysLeft,
        'status': status,
      };
}

class DashboardCounts {
  final int totalOrders;
  final int totalExams;
  final int totalCourses;
  final int totalPackages;
  final int totalSelfExams;
  final int totalContests;

  DashboardCounts({
    this.totalOrders = 0,
    this.totalExams = 0,
    this.totalCourses = 0,
    this.totalPackages = 0,
    this.totalSelfExams = 0,
    this.totalContests = 0,
  });

  factory DashboardCounts.fromJson(Map<String, dynamic> json) {
    return DashboardCounts(
      totalOrders: json['total_orders'] as int? ?? 0,
      totalExams: json['total_exams'] as int? ?? 0,
      totalCourses: json['total_courses'] as int? ?? 0,
      totalPackages: json['total_packages'] as int? ?? 0,
      totalSelfExams: json['total_self_exams'] as int? ?? 0,
      totalContests: json['total_contests'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'total_orders': totalOrders,
        'total_exams': totalExams,
        'total_courses': totalCourses,
        'total_packages': totalPackages,
        'total_self_exams': totalSelfExams,
        'total_contests': totalContests,
      };
}

class DashboardPerformance {
  final int totalQuestionsAnswered;
  final int totalCorrectAnswers;
  final int totalIncorrectAnswers;
  final double accuracyRate;
  final double highestAccuracy;
  final DashboardPerformanceChart? chart;

  DashboardPerformance({
    this.totalQuestionsAnswered = 0,
    this.totalCorrectAnswers = 0,
    this.totalIncorrectAnswers = 0,
    this.accuracyRate = 0.0,
    this.highestAccuracy = 0.0,
    this.chart,
  });

  factory DashboardPerformance.fromJson(Map<String, dynamic> json) {
    return DashboardPerformance(
      totalQuestionsAnswered: json['total_questions_answered'] as int? ?? 0,
      totalCorrectAnswers: json['total_correct_answers'] as int? ?? 0,
      totalIncorrectAnswers: json['total_incorrect_answers'] as int? ?? 0,
      accuracyRate: (json['accuracy_rate'] is num)
          ? (json['accuracy_rate'] as num).toDouble()
          : 0.0,
      highestAccuracy: (json['highest_accuracy'] is num)
          ? (json['highest_accuracy'] as num).toDouble()
          : 0.0,
      chart: json['chart'] != null && json['chart'] is Map<String, dynamic>
          ? DashboardPerformanceChart.fromJson(json['chart'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'total_questions_answered': totalQuestionsAnswered,
        'total_correct_answers': totalCorrectAnswers,
        'total_incorrect_answers': totalIncorrectAnswers,
        'accuracy_rate': accuracyRate,
        'highest_accuracy': highestAccuracy,
        'chart': chart?.toJson(),
      };
}

class DashboardPerformanceChart {
  final List<String> labels;
  final List<double> data;
  final List<String> titles;
  final List<DashboardChartPoint> points;

  DashboardPerformanceChart({
    this.labels = const [],
    this.data = const [],
    this.titles = const [],
    this.points = const [],
  });

  factory DashboardPerformanceChart.fromJson(Map<String, dynamic> json) {
    return DashboardPerformanceChart(
      labels: (json['labels'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => (e is num) ? e.toDouble() : 0.0)
              .toList() ??
          [],
      titles: (json['titles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      points: (json['points'] as List<dynamic>?)
              ?.map((e) => DashboardChartPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'labels': labels,
        'data': data,
        'titles': titles,
        'points': points.map((e) => e.toJson()).toList(),
      };
}

class DashboardChartPoint {
  final int index;
  final String date;
  final String examTitle;
  final double accuracyRate;
  final int totalQuestions;
  final int correct;

  DashboardChartPoint({
    this.index = 0,
    this.date = '',
    this.examTitle = '',
    this.accuracyRate = 0.0,
    this.totalQuestions = 0,
    this.correct = 0,
  });

  factory DashboardChartPoint.fromJson(Map<String, dynamic> json) {
    return DashboardChartPoint(
      index: json['index'] as int? ?? 0,
      date: json['date'] as String? ?? '',
      examTitle: json['exam_title'] as String? ?? '',
      accuracyRate: (json['accuracy_rate'] is num)
          ? (json['accuracy_rate'] as num).toDouble()
          : 0.0,
      totalQuestions: json['total_questions'] as int? ?? 0,
      correct: json['correct'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'index': index,
        'date': date,
        'exam_title': examTitle,
        'accuracy_rate': accuracyRate,
        'total_questions': totalQuestions,
        'correct': correct,
      };
}

class DashboardReferral {
  final String? referralCode;
  final String? referralLink;
  final int totalReferrals;
  final int totalPoints;

  DashboardReferral({
    this.referralCode,
    this.referralLink,
    this.totalReferrals = 0,
    this.totalPoints = 0,
  });

  factory DashboardReferral.fromJson(Map<String, dynamic> json) {
    return DashboardReferral(
      referralCode: json['referral_code'] as String?,
      referralLink: json['referral_link'] as String?,
      totalReferrals: json['total_referrals'] as int? ?? 0,
      totalPoints: json['total_points'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'referral_code': referralCode,
        'referral_link': referralLink,
        'total_referrals': totalReferrals,
        'total_points': totalPoints,
      };
}

class DashboardRewards {
  final int balance;

  DashboardRewards({this.balance = 0});

  factory DashboardRewards.fromJson(Map<String, dynamic> json) {
    return DashboardRewards(
      balance: json['balance'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'balance': balance,
      };
}

class UserSummary {
  final int? id;
  final String? userId;
  final String? name;
  final String? phone;
  final String? email;
  final String? avatar;
  final String? photoUrl;
  final int rewardPoints;
  final int streakDays;
  final bool havePackage;

  UserSummary({
    this.id,
    this.userId,
    this.name,
    this.phone,
    this.email,
    this.avatar,
    this.photoUrl,
    this.rewardPoints = 0,
    this.streakDays = 0,
    this.havePackage = false,
  });

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    return UserSummary(
      id: json['id'] as int?,
      userId: json['user_id'] as String?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      avatar: json['avatar'] as String? ?? json['photo_url'] as String?,
      photoUrl: json['photo_url'] as String? ?? json['avatar'] as String?,
      rewardPoints: json['reward_points'] as int? ?? 0,
      streakDays: json['streak_days'] as int? ?? 0,
      havePackage: json['have_package'] == true || json['have_package'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'name': name,
        'phone': phone,
        'email': email,
        'avatar': avatar,
        'photo_url': photoUrl,
        'reward_points': rewardPoints,
        'streak_days': streakDays,
        'have_package': havePackage,
      };
}

class DashboardSliderItem {
  final int? id;
  final String? title;
  final String? image;
  final String? link;

  DashboardSliderItem({this.id, this.title, this.image, this.link});

  factory DashboardSliderItem.fromJson(Map<String, dynamic> json) {
    return DashboardSliderItem(
      id: json['id'] as int?,
      title: json['title'] as String?,
      image: json['image'] as String?,
      link: json['link'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'image': image,
        'link': link,
      };
}

class DashboardNoticeItem {
  final int? id;
  final String? title;
  final String? description;
  final String? createdAt;

  DashboardNoticeItem({this.id, this.title, this.description, this.createdAt});

  factory DashboardNoticeItem.fromJson(Map<String, dynamic> json) {
    return DashboardNoticeItem(
      id: json['id'] as int?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'created_at': createdAt,
      };
}

class DashboardCourseItem {
  final int? id;
  final String? title;
  final String? thumbnail;
  final double progress;

  DashboardCourseItem({this.id, this.title, this.thumbnail, this.progress = 0.0});

  factory DashboardCourseItem.fromJson(Map<String, dynamic> json) {
    return DashboardCourseItem(
      id: json['id'] as int?,
      title: json['title'] as String?,
      thumbnail: json['thumbnail'] as String?,
      progress: (json['progress'] is num) ? (json['progress'] as num).toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'thumbnail': thumbnail,
        'progress': progress,
      };
}

class DashboardExamItem {
  final int? id;
  final String? title;
  final String? startTime;
  final int? durationMinutes;
  final bool isContest;

  DashboardExamItem({
    this.id,
    this.title,
    this.startTime,
    this.durationMinutes,
    this.isContest = false,
  });

  factory DashboardExamItem.fromJson(Map<String, dynamic> json) {
    return DashboardExamItem(
      id: json['id'] as int?,
      title: json['title'] as String?,
      startTime: json['start_time'] as String?,
      durationMinutes: json['duration_minutes'] as int?,
      isContest: json['is_contest'] == true || json['is_contest'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'start_time': startTime,
        'duration_minutes': durationMinutes,
        'is_contest': isContest,
      };
}

class AccuracyPoint {
  final double x;
  final double y;
  final String? label;

  AccuracyPoint({required this.x, required this.y, this.label});

  factory AccuracyPoint.fromJson(Map<String, dynamic> json) {
    return AccuracyPoint(
      x: (json['x'] is num) ? (json['x'] as num).toDouble() : 0.0,
      y: (json['y'] is num) ? (json['y'] as num).toDouble() : 0.0,
      label: json['label'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        'label': label,
      };
}
