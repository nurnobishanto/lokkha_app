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
      status: json['status'] == true,
      message: json['message'] as String?,
      data: json['data'] != null ? DashboardData.fromJson(json['data']) : null,
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
  final List<DashboardSliderItem> sliders;
  final List<DashboardNoticeItem> notices;
  final List<DashboardCourseItem> activeCourses;
  final List<DashboardExamItem> upcomingExams;
  final double accuracyRate;
  final List<AccuracyPoint> accuracyPoints;

  DashboardData({
    this.user,
    this.sliders = const [],
    this.notices = const [],
    this.activeCourses = const [],
    this.upcomingExams = const [],
    this.accuracyRate = 0.0,
    this.accuracyPoints = const [],
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      user: json['user'] != null ? UserSummary.fromJson(json['user']) : null,
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
      accuracyRate: (json['accuracy_rate'] is num)
          ? (json['accuracy_rate'] as num).toDouble()
          : 0.0,
      accuracyPoints: (json['accuracy_points'] as List<dynamic>?)
              ?.map((e) => AccuracyPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'user': user?.toJson(),
        'sliders': sliders.map((e) => e.toJson()).toList(),
        'notices': notices.map((e) => e.toJson()).toList(),
        'active_courses': activeCourses.map((e) => e.toJson()).toList(),
        'upcoming_exams': upcomingExams.map((e) => e.toJson()).toList(),
        'accuracy_rate': accuracyRate,
        'accuracy_points': accuracyPoints.map((e) => e.toJson()).toList(),
      };
}

class UserSummary {
  final int? id;
  final String? name;
  final String? phone;
  final String? avatar;
  final int rewardPoints;
  final int streakDays;
  final bool havePackage;

  UserSummary({
    this.id,
    this.name,
    this.phone,
    this.avatar,
    this.rewardPoints = 0,
    this.streakDays = 0,
    this.havePackage = false,
  });

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    return UserSummary(
      id: json['id'] as int?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      rewardPoints: json['reward_points'] as int? ?? 0,
      streakDays: json['streak_days'] as int? ?? 0,
      havePackage: json['have_package'] == true || json['have_package'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'avatar': avatar,
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
