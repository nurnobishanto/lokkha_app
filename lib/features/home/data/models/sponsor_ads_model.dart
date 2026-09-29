class SponsorAdsModel {
  final bool? status;
  final Map<String, List<Ad>>? appAds;

  SponsorAdsModel({this.status, this.appAds});

  factory SponsorAdsModel.fromJson(Map<String, dynamic> json) {
    final appAds = (json['app_ads'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(
        key,
        (value as List<dynamic>).map((ad) => Ad.fromJson(ad)).toList(),
      ),
    );

    return SponsorAdsModel(
      status: json['status'],
      appAds: appAds,
    );
  }

  Map<String, dynamic> toJson() {
    final appAdsJson = appAds!.map(
      (key, value) => MapEntry(
        key,
        value.map((ad) => ad.toJson()).toList(),
      ),
    );

    return {
      'status': status,
      'app_ads': appAdsJson,
    };
  }
}

class Ad {
  final int id;
  final String name;
  final String url;
  final String type;
  final String filePath;
  final String pageName;
  final bool? status;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Ad({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.filePath,
    required this.pageName,
    required this.status,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Ad.fromJson(Map<String, dynamic> json) {
    return Ad(
      id: json['id'],
      name: json['name'],
      url: json['url'],
      type: json['type'],
      filePath: json['file_path'],
      pageName: json['page_name'],
      status: json['status'],
      order: json['order'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'type': type,
      'file_path': filePath,
      'page_name': pageName,
      'status': status,
      'order': order,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}
