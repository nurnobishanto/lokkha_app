import 'package:fl_chart/fl_chart.dart';
import 'accuracy_exam_item_model.dart';
import 'accuracy_metric_model.dart';
import 'accuracy_trend_point_model.dart';

/// Full response model for GET /api/v1/user/accuracy
class AccuracyResponseModel {
  final bool success;
  final String message;
  final AccuracyMetricsDataModel metrics;
  final AccuracyChartDataModel chart;
  final AccuracyHistoryDataModel history;

  const AccuracyResponseModel({
    this.success = true,
    this.message = '',
    this.metrics = const AccuracyMetricsDataModel(),
    this.chart = const AccuracyChartDataModel(),
    this.history = const AccuracyHistoryDataModel(),
  });

  factory AccuracyResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    return AccuracyResponseModel(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? '',
      metrics: AccuracyMetricsDataModel.fromJson(
        data['metrics'] as Map<String, dynamic>? ?? {},
      ),
      chart: AccuracyChartDataModel.fromJson(
        data['chart'] as Map<String, dynamic>? ?? {},
      ),
      history: AccuracyHistoryDataModel.fromJson(
        data['history'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': {
          'metrics': metrics.toJson(),
          'chart': chart.toJson(),
          'history': history.toJson(),
        },
      };

  AccuracyResponseModel copyWith({
    bool? success,
    String? message,
    AccuracyMetricsDataModel? metrics,
    AccuracyChartDataModel? chart,
    AccuracyHistoryDataModel? history,
  }) {
    return AccuracyResponseModel(
      success: success ?? this.success,
      message: message ?? this.message,
      metrics: metrics ?? this.metrics,
      chart: chart ?? this.chart,
      history: history ?? this.history,
    );
  }
}

/// Metrics summary object in /api/v1/user/accuracy
class AccuracyMetricsDataModel {
  final int totalQuestionsAnswered;
  final int totalCorrectAnswers;
  final int totalIncorrectAnswers;
  final int totalAvoidedAnswers;
  final double accuracyRate;
  final double highestAccuracy;

  const AccuracyMetricsDataModel({
    this.totalQuestionsAnswered = 0,
    this.totalCorrectAnswers = 0,
    this.totalIncorrectAnswers = 0,
    this.totalAvoidedAnswers = 0,
    this.accuracyRate = 0.0,
    this.highestAccuracy = 0.0,
  });

  factory AccuracyMetricsDataModel.fromJson(Map<String, dynamic> json) {
    return AccuracyMetricsDataModel(
      totalQuestionsAnswered: json['total_questions_answered'] is int
          ? json['total_questions_answered'] as int
          : int.tryParse(json['total_questions_answered']?.toString() ?? '0') ??
              0,
      totalCorrectAnswers: json['total_correct_answers'] is int
          ? json['total_correct_answers'] as int
          : int.tryParse(json['total_correct_answers']?.toString() ?? '0') ?? 0,
      totalIncorrectAnswers: json['total_incorrect_answers'] is int
          ? json['total_incorrect_answers'] as int
          : int.tryParse(json['total_incorrect_answers']?.toString() ?? '0') ??
              0,
      totalAvoidedAnswers: json['total_avoided_answers'] is int
          ? json['total_avoided_answers'] as int
          : int.tryParse(json['total_avoided_answers']?.toString() ?? '0') ?? 0,
      accuracyRate: json['accuracy_rate'] is num
          ? (json['accuracy_rate'] as num).toDouble()
          : double.tryParse(json['accuracy_rate']?.toString() ?? '0.0') ?? 0.0,
      highestAccuracy: json['highest_accuracy'] is num
          ? (json['highest_accuracy'] as num).toDouble()
          : double.tryParse(json['highest_accuracy']?.toString() ?? '0.0') ??
              0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'total_questions_answered': totalQuestionsAnswered,
        'total_correct_answers': totalCorrectAnswers,
        'total_incorrect_answers': totalIncorrectAnswers,
        'total_avoided_answers': totalAvoidedAnswers,
        'accuracy_rate': accuracyRate,
        'highest_accuracy': highestAccuracy,
      };

  String get avgAccuracyStr {
    if (accuracyRate % 1 == 0) {
      return "${accuracyRate.toInt()}%";
    }
    return "${accuracyRate.toStringAsFixed(1)}%";
  }

  String get highestAccuracyStr {
    if (highestAccuracy % 1 == 0) {
      return "${highestAccuracy.toInt()}%";
    }
    return "${highestAccuracy.toStringAsFixed(1)}%";
  }

  /// Compatibility adapter with legacy AccuracyMetricModel
  AccuracyMetricModel toLegacyMetricModel() {
    return AccuracyMetricModel(
      avgAccuracy: avgAccuracyStr,
      highestAccuracy: highestAccuracyStr,
      totalQuestionsAnswered: totalQuestionsAnswered,
      correctCount: totalCorrectAnswers,
      wrongCount: totalIncorrectAnswers,
    );
  }
}

/// Chart data containing coordinates and labels for fl_chart
class AccuracyChartDataModel {
  final List<String> labels;
  final List<double> data;
  final List<String> titles;
  final List<AccuracyChartPointModel> points;

  const AccuracyChartDataModel({
    this.labels = const [],
    this.data = const [],
    this.titles = const [],
    this.points = const [],
  });

  factory AccuracyChartDataModel.fromJson(Map<String, dynamic> json) {
    final rawLabels = (json['labels'] as List<dynamic>?) ?? [];
    final labelsList = rawLabels.map((e) => e?.toString() ?? '').toList();

    final rawData = (json['data'] as List<dynamic>?) ?? [];
    final dataList = rawData
        .map((e) => (e is num) ? e.toDouble() : double.tryParse(e?.toString() ?? '0.0') ?? 0.0)
        .toList();

    final rawTitles = (json['titles'] as List<dynamic>?) ?? [];
    final titlesList = rawTitles.map((e) => e?.toString() ?? '').toList();

    final rawPoints = (json['points'] as List<dynamic>?) ?? [];

    // Fallback: extract labels from points if labels array was empty
    if (labelsList.isEmpty && rawPoints.isNotEmpty) {
      for (final p in rawPoints) {
        if (p is Map<String, dynamic>) {
          final l = p['label']?.toString() ?? p['date']?.toString();
          if (l != null && l.isNotEmpty) labelsList.add(l);
        }
      }
    }

    List<AccuracyChartPointModel> pointsList = [];

    // Prioritize dataList which contains the actual numeric accuracy percentages
    if (dataList.isNotEmpty) {
      pointsList = dataList.asMap().entries.map((entry) {
        final index = entry.key;
        final yVal = entry.value;
        final label = index < labelsList.length ? labelsList[index] : null;
        final title = index < titlesList.length ? titlesList[index] : null;
        return AccuracyChartPointModel(
          x: index.toDouble(),
          y: yVal,
          label: label,
          title: title,
        );
      }).toList();
    } else if (rawPoints.isNotEmpty) {
      pointsList = rawPoints.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        if (item is Map<String, dynamic>) {
          return AccuracyChartPointModel.fromJson(item, fallbackIndex: index);
        } else if (item is List && item.length >= 2) {
          final x = (item[0] is num) ? (item[0] as num).toDouble() : index.toDouble();
          final y = (item[1] is num)
              ? (item[1] as num).toDouble()
              : double.tryParse(item[1]?.toString() ?? '0.0') ?? 0.0;
          return AccuracyChartPointModel(
            x: x,
            y: y,
            label: index < labelsList.length ? labelsList[index] : null,
            title: index < titlesList.length ? titlesList[index] : null,
          );
        } else if (item is num) {
          return AccuracyChartPointModel(
            x: index.toDouble(),
            y: item.toDouble(),
            label: index < labelsList.length ? labelsList[index] : null,
            title: index < titlesList.length ? titlesList[index] : null,
          );
        }
        return AccuracyChartPointModel(x: index.toDouble(), y: 0.0);
      }).toList();
    }

    return AccuracyChartDataModel(
      labels: labelsList,
      data: dataList,
      titles: titlesList,
      points: pointsList,
    );
  }

  Map<String, dynamic> toJson() => {
        'labels': labels,
        'data': data,
        'titles': titles,
        'points': points.map((p) => p.toJson()).toList(),
      };

  /// Returns FlSpot coordinates ready for fl_chart's LineChartBarData.
  /// Prioritizes `data` (exact accuracy array) as source of truth.
  List<FlSpot> get flSpots {
    if (data.isNotEmpty) {
      return data
          .asMap()
          .entries
          .map((entry) => FlSpot(entry.key.toDouble(), entry.value.clamp(0.0, 100.0)))
          .toList();
    }
    if (points.isNotEmpty) {
      return points.map((p) => FlSpot(p.x, p.y.clamp(0.0, 100.0))).toList();
    }
    return const [];
  }

  /// Converts to legacy AccuracyTrendPointModel list
  List<AccuracyTrendPointModel> toLegacyTrendPoints() {
    return points.map((p) => AccuracyTrendPointModel(
      date: p.label ?? "E${p.x.toInt() + 1}",
      percentage: p.y,
    )).toList();
  }
}

/// Single coordinate point for fl_chart
class AccuracyChartPointModel {
  final double x;
  final double y;
  final String? label;
  final String? title;

  const AccuracyChartPointModel({
    required this.x,
    required this.y,
    this.label,
    this.title,
  });

  factory AccuracyChartPointModel.fromJson(Map<String, dynamic> json, {int fallbackIndex = 0}) {
    final xVal = json['x'] is num
        ? (json['x'] as num).toDouble()
        : double.tryParse(json['x']?.toString() ?? '$fallbackIndex') ?? fallbackIndex.toDouble();

    final yVal = json['y'] is num
        ? (json['y'] as num).toDouble()
        : (json['accuracy'] is num
            ? (json['accuracy'] as num).toDouble()
            : double.tryParse(json['y']?.toString() ?? json['accuracy']?.toString() ?? '0.0') ?? 0.0);

    return AccuracyChartPointModel(
      x: xVal,
      y: yVal,
      label: json['label']?.toString() ?? json['date']?.toString(),
      title: json['title']?.toString() ?? json['exam_title']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        if (label != null) 'label': label,
        if (title != null) 'title': title,
      };
}

/// Paginated exam accuracy history
class AccuracyHistoryDataModel {
  final List<AccuracyExamItemModel> items;
  final ExamHistoryMetaModel meta;

  const AccuracyHistoryDataModel({
    this.items = const [],
    this.meta = const ExamHistoryMetaModel(),
  });

  factory AccuracyHistoryDataModel.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>?) ?? [];
    final itemsList = rawItems.map((e) {
      if (e is Map<String, dynamic>) {
        return AccuracyExamItemModel.fromJson(e);
      }
      return AccuracyExamItemModel.empty();
    }).toList();

    final metaMap = json['meta'] as Map<String, dynamic>? ?? {};

    return AccuracyHistoryDataModel(
      items: itemsList,
      meta: ExamHistoryMetaModel.fromJson(metaMap),
    );
  }

  Map<String, dynamic> toJson() => {
        'items': items.map((e) => e.toJson()).toList(),
        'meta': meta.toJson(),
      };
}

/// Metadata for paginated accuracy history
class AccuracyHistoryMetaModel {
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  const AccuracyHistoryMetaModel({
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
    this.perPage = 10,
  });

  factory AccuracyHistoryMetaModel.fromJson(Map<String, dynamic> json) {
    return AccuracyHistoryMetaModel(
      currentPage: json['current_page'] is int
          ? json['current_page'] as int
          : int.tryParse(json['current_page']?.toString() ?? '1') ?? 1,
      lastPage: json['last_page'] is int
          ? json['last_page'] as int
          : int.tryParse(json['last_page']?.toString() ?? '1') ?? 1,
      total: json['total'] is int
          ? json['total'] as int
          : int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      perPage: json['per_page'] is int
          ? json['per_page'] as int
          : int.tryParse(json['per_page']?.toString() ?? '10') ?? 10,
    );
  }

  Map<String, dynamic> toJson() => {
        'current_page': currentPage,
        'last_page': lastPage,
        'total': total,
        'per_page': perPage,
      };
}

typedef ExamHistoryMetaModel = AccuracyHistoryMetaModel;

