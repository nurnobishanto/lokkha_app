class Package {
  final int? id;
  final String? name;
  final String? description;
  final String? regularPrice;
  final int? duration;
  final String? discount;
  final String? discountedPrice;
  final bool? status;
  final bool? isMega;
  final bool? isFemale;
  final bool? isFeatured;
  final dynamic features;
  final bool? isTrial;
  final dynamic trialDuration;
  final dynamic termsAndConditions;
  final dynamic metaTitle;
  final String? metaDescription;
  final dynamic metaKeywords;
  final String? metaImage;
  final dynamic metaAuthor;
  final dynamic metaUrl;
  final dynamic metaData;
  final dynamic headerCode;
  final dynamic footerCode;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic deletedAt;

  Package({
    this.id,
    this.name,
    this.description,
    this.regularPrice,
    this.duration,
    this.discount,
    this.discountedPrice,
    this.status,
    this.isMega,
    this.isFemale,
    this.isFeatured,
    this.features,
    this.isTrial,
    this.trialDuration,
    this.termsAndConditions,
    this.metaTitle,
    this.metaDescription,
    this.metaKeywords,
    this.metaImage,
    this.metaAuthor,
    this.metaUrl,
    this.metaData,
    this.headerCode,
    this.footerCode,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Package.fromJson(Map<String, dynamic> json) => Package(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        regularPrice: json["regular_price"],
        duration: json["duration"],
        discount: json["discount"],
        discountedPrice: json["discounted_price"],
        status: json["status"] == null
            ? null
            : (json["status"] is bool
                ? json["status"]
                : (json["status"] == 1 || json["status"] == "1" || json["status"] == "true")),
        isMega: json["is_mega"] == null
            ? null
            : (json["is_mega"] is bool
                ? json["is_mega"]
                : (json["is_mega"] == 1 || json["is_mega"] == "1" || json["is_mega"] == "true")),
        isFemale: json["is_female"] == null
            ? null
            : (json["is_female"] is bool
                ? json["is_female"]
                : (json["is_female"] == 1 || json["is_female"] == "1" || json["is_female"] == "true")),
        isFeatured: json["is_featured"] == null
            ? null
            : (json["is_featured"] is bool
                ? json["is_featured"]
                : (json["is_featured"] == 1 || json["is_featured"] == "1" || json["is_featured"] == "true")),
        features: json["features"],
        isTrial: json["is_trial"] == null
            ? null
            : (json["is_trial"] is bool
                ? json["is_trial"]
                : (json["is_trial"] == 1 || json["is_trial"] == "1" || json["is_trial"] == "true")),
        trialDuration: json["trial_duration"],
        termsAndConditions: json["terms_and_conditions"],
        metaTitle: json["meta_title"],
        metaDescription: json["meta_description"],
        metaKeywords: json["meta_keywords"],
        metaImage: json["meta_image"],
        metaAuthor: json["meta_author"],
        metaUrl: json["meta_url"],
        metaData: json["meta_data"],
        headerCode: json["header_code"],
        footerCode: json["footer_code"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "regular_price": regularPrice,
        "duration": duration,
        "discount": discount,
        "discounted_price": discountedPrice,
        "status": status,
        "is_mega": isMega,
        "is_female": isFemale,
        "is_featured": isFeatured,
        "features": features,
        "is_trial": isTrial,
        "trial_duration": trialDuration,
        "terms_and_conditions": termsAndConditions,
        "meta_title": metaTitle,
        "meta_description": metaDescription,
        "meta_keywords": metaKeywords,
        "meta_image": metaImage,
        "meta_author": metaAuthor,
        "meta_url": metaUrl,
        "meta_data": metaData,
        "header_code": headerCode,
        "footer_code": footerCode,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "deleted_at": deletedAt,
      };
}
