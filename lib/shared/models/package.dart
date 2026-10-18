import 'dart:convert';

/// Normalized Package Feature checklist item for V1 API
class PackageFeature {
  final String text;
  final bool included;

  PackageFeature({required this.text, this.included = true});

  factory PackageFeature.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      final rawText = json['text']?.toString().trim();
      final cleanText = (rawText != null &&
              rawText.toLowerCase() != 'null' &&
              rawText.toLowerCase() != '<p>null</p>')
          ? rawText
          : '';
      return PackageFeature(
        text: cleanText,
        included: json['included'] == true ||
            json['included'] == 1 ||
            json['included']?.toString() == '1' ||
            json['included']?.toString().toLowerCase() == 'true',
      );
    }
    final rawText = json?.toString().trim();
    final cleanText = (rawText != null &&
            rawText.toLowerCase() != 'null' &&
            rawText.toLowerCase() != '<p>null</p>')
        ? rawText
        : '';
    return PackageFeature(text: cleanText, included: true);
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'included': included,
      };
}

class Package {
  final int? id;
  final String? name;
  final String? description;
  final String? regularPrice;
  final int? duration;
  final String? discount;
  final String? discountedPrice;
  final double? effectivePrice;
  final int? durationDays;
  final String? formattedDuration;
  final bool? status;
  final bool? isMega;
  final bool? isFemale;
  final bool? isFeatured;
  final dynamic features;
  final List<PackageFeature>? featureList;
  final bool? isTrial;
  final dynamic trialDuration;
  final int? trialDurationDays;
  final bool? canClaimTrial;
  final bool? isCurrentlyActive;
  final dynamic userSubscription;
  final dynamic termsAndConditions;
  final List<String>? termsList;
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
    this.effectivePrice,
    this.durationDays,
    this.formattedDuration,
    this.status,
    this.isMega,
    this.isFemale,
    this.isFeatured,
    this.features,
    this.featureList,
    this.isTrial,
    this.trialDuration,
    this.trialDurationDays,
    this.canClaimTrial,
    this.isCurrentlyActive,
    this.userSubscription,
    this.termsAndConditions,
    this.termsList,
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

  factory Package.fromJson(Map<String, dynamic> json) {
    // 1. Duration normalization
    final dur = json["duration_days"] ?? json["duration"];
    final int? durationVal = dur is int ? dur : int.tryParse(dur?.toString() ?? '');

    // 2. Pricing normalization
    final regPrice = json["regular_price"]?.toString();
    final disc = json["discount"]?.toString();
    final discPrice = json["discounted_price"]?.toString();
    final effPrice = json["effective_price"] != null
        ? num.tryParse(json["effective_price"].toString())?.toDouble()
        : (discPrice != null
            ? num.tryParse(discPrice)?.toDouble()
            : (regPrice != null ? num.tryParse(regPrice)?.toDouble() : null));

    // 3. Features checklist parsing
    List<PackageFeature> parsedFeatures = [];
    if (json["features"] is List) {
      parsedFeatures = (json["features"] as List)
          .where((f) => f != null)
          .map((f) => PackageFeature.fromJson(f))
          .where((f) =>
              f.text.trim().isNotEmpty &&
              f.text.trim().toLowerCase() != 'null' &&
              f.text.trim().toLowerCase() != '<p>null</p>')
          .toList();
    } else if (json["features"] is String) {
      final str = json["features"].toString().trim();
      if (str.startsWith('[')) {
        try {
          final decoded = jsonDecode(str);
          if (decoded is List) {
            parsedFeatures = decoded
                .where((f) => f != null)
                .map((f) => PackageFeature.fromJson(f))
                .where((f) =>
                    f.text.trim().isNotEmpty &&
                    f.text.trim().toLowerCase() != 'null' &&
                    f.text.trim().toLowerCase() != '<p>null</p>')
                .toList();
          }
        } catch (_) {}
      } else if (str.isNotEmpty &&
          str.toLowerCase() != 'null' &&
          str.toLowerCase() != '<p>null</p>') {
        final lines = str.contains('\n') ? str.split('\n') : str.split(',');
        parsedFeatures = lines
            .map((s) => s.trim())
            .where((s) =>
                s.isNotEmpty &&
                s.toLowerCase() != 'null' &&
                s.toLowerCase() != '<p>null</p>')
            .map((s) => PackageFeature(text: s, included: true))
            .toList();
      }
    }

    // 4. Terms and conditions parsing
    List<String> parsedTerms = [];
    final rawTerms = json["terms_and_conditions"];
    if (rawTerms is List) {
      parsedTerms = rawTerms
          .where((t) => t != null)
          .map((t) => t.toString().trim())
          .where((t) =>
              t.isNotEmpty &&
              t.toLowerCase() != 'null' &&
              t.toLowerCase() != '<p>null</p>' &&
              t.toLowerCase() != 'none')
          .toList();
    } else if (rawTerms is String) {
      final str = rawTerms.trim();
      if (str.startsWith('[')) {
        try {
          final decoded = jsonDecode(str);
          if (decoded is List) {
            parsedTerms = decoded
                .where((t) => t != null)
                .map((t) => t.toString().trim())
                .where((t) =>
                    t.isNotEmpty &&
                    t.toLowerCase() != 'null' &&
                    t.toLowerCase() != '<p>null</p>' &&
                    t.toLowerCase() != 'none')
                .toList();
          }
        } catch (_) {}
      } else if (str.isNotEmpty &&
          str.toLowerCase() != 'null' &&
          str.toLowerCase() != '<p>null</p>' &&
          str.toLowerCase() != 'none') {
        final lines = str.contains('\n') ? str.split('\n') : [str];
        parsedTerms = lines
            .map((s) => s.trim())
            .where((s) =>
                s.isNotEmpty &&
                s.toLowerCase() != 'null' &&
                s.toLowerCase() != '<p>null</p>' &&
                s.toLowerCase() != 'none')
            .toList();
      }
    }

    // 5. Trial duration normalization
    final trialDur = json["trial_duration_days"] ?? json["trial_duration"];
    final int? trialDurationVal =
        trialDur is int ? trialDur : int.tryParse(trialDur?.toString() ?? '');

    return Package(
      id: json["id"] is int
          ? json["id"]
          : int.tryParse(json["id"]?.toString() ?? ''),
      name: json["name"]?.toString(),
      description: json["description"]?.toString(),
      regularPrice: regPrice,
      duration: durationVal,
      durationDays: durationVal,
      discount: disc,
      discountedPrice: discPrice,
      effectivePrice: effPrice,
      formattedDuration: json["formatted_duration"]?.toString() ??
          (durationVal != null ? '$durationVal দিন' : null),
      status: json["status"] == null
          ? null
          : (json["status"] is bool
              ? json["status"]
              : (json["status"] == 1 ||
                  json["status"] == "1" ||
                  json["status"] == "true")),
      isMega: json["is_mega"] == null
          ? null
          : (json["is_mega"] is bool
              ? json["is_mega"]
              : (json["is_mega"] == 1 ||
                  json["is_mega"] == "1" ||
                  json["is_mega"] == "true")),
      isFemale: json["is_female"] == null
          ? null
          : (json["is_female"] is bool
              ? json["is_female"]
              : (json["is_female"] == 1 ||
                  json["is_female"] == "1" ||
                  json["is_female"] == "true")),
      isFeatured: json["is_featured"] == null
          ? null
          : (json["is_featured"] is bool
              ? json["is_featured"]
              : (json["is_featured"] == 1 ||
                  json["is_featured"] == "1" ||
                  json["is_featured"] == "true")),
      features: json["features"],
      featureList: parsedFeatures.isNotEmpty ? parsedFeatures : null,
      isTrial: json["is_trial"] == null
          ? null
          : (json["is_trial"] is bool
              ? json["is_trial"]
              : (json["is_trial"] == 1 ||
                  json["is_trial"] == "1" ||
                  json["is_trial"] == "true")),
      trialDuration: json["trial_duration"],
      trialDurationDays: trialDurationVal,
      canClaimTrial: json["can_claim_trial"] == true ||
          json["can_claim_trial"] == 1 ||
          json["can_claim_trial"]?.toString() == '1' ||
          json["can_claim_trial"]?.toString().toLowerCase() == 'true',
      isCurrentlyActive: json["is_currently_active"] == true ||
          json["is_currently_active"] == 1 ||
          json["is_currently_active"]?.toString() == '1' ||
          json["is_currently_active"]?.toString().toLowerCase() == 'true',
      userSubscription: json["user_subscription"],
      termsAndConditions: json["terms_and_conditions"],
      termsList: parsedTerms.isNotEmpty ? parsedTerms : null,
      metaTitle: json["meta_title"],
      metaDescription: json["meta_description"]?.toString(),
      metaKeywords: json["meta_keywords"],
      metaImage: json["meta_image"]?.toString(),
      metaAuthor: json["meta_author"],
      metaUrl: json["meta_url"],
      metaData: json["meta_data"],
      headerCode: json["header_code"],
      footerCode: json["footer_code"],
      createdAt: json["created_at"] == null
          ? null
          : DateTime.tryParse(json["created_at"].toString()),
      updatedAt: json["updated_at"] == null
          ? null
          : DateTime.tryParse(json["updated_at"].toString()),
      deletedAt: json["deleted_at"],
    );
  }

  /// Convenience helper to get feature text strings cleanly
  List<String> get featureTexts {
    if (featureList != null && featureList!.isNotEmpty) {
      return featureList!.map((f) => f.text).toList();
    }
    if (features is List) {
      return (features as List).map((f) {
        if (f is Map) return f['text']?.toString() ?? '';
        return f.toString();
      }).where((t) => t.isNotEmpty).toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "regular_price": regularPrice,
        "duration": duration,
        "duration_days": durationDays,
        "discount": discount,
        "discounted_price": discountedPrice,
        if (effectivePrice != null) "effective_price": effectivePrice,
        if (formattedDuration != null)
          "formatted_duration": formattedDuration,
        "status": status,
        "is_mega": isMega,
        "is_female": isFemale,
        "is_featured": isFeatured,
        "features": featureList != null
            ? featureList!.map((f) => f.toJson()).toList()
            : features,
        "is_trial": isTrial,
        "trial_duration": trialDuration,
        if (trialDurationDays != null)
          "trial_duration_days": trialDurationDays,
        if (canClaimTrial != null) "can_claim_trial": canClaimTrial,
        if (isCurrentlyActive != null)
          "is_currently_active": isCurrentlyActive,
        if (userSubscription != null)
          "user_subscription": userSubscription,
        "terms_and_conditions":
            termsList != null && termsList!.isNotEmpty
                ? termsList
                : termsAndConditions,
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
