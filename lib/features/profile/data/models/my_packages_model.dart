import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:lokkha/shared/models/user.dart';
import 'package:lokkha/shared/models/package.dart';

MyPackagesModel myPackagesModelFromJson(String str) =>
    MyPackagesModel.fromJson(json.decode(str) as Map<String, dynamic>);

String myPackagesModelToJson(MyPackagesModel data) =>
    json.encode(data.toJson());

/// Typedef for Clean Architecture
typedef UserPackagesResponseModel = MyPackagesModel;

class MyPackagesModel {
  final bool success;
  final String? message;
  final List<PackageElement> packages;

  MyPackagesModel({
    this.success = false,
    this.message,
    this.packages = const [],
  });

  // Backward compatibility getters
  bool? get status => success;
  List<PackageElement> get items => packages;

  factory MyPackagesModel.fromJson(Map<String, dynamic> json) {
    List<PackageElement> parsedPackages = [];

    final rawData = json["data"];
    if (rawData is Map<String, dynamic>) {
      if (rawData["items"] is List) {
        parsedPackages = (rawData["items"] as List)
            .whereType<Map<String, dynamic>>()
            .map(PackageElement.fromJson)
            .toList();
      } else if (rawData["subscriptions"] is List) {
        parsedPackages = (rawData["subscriptions"] as List)
            .whereType<Map<String, dynamic>>()
            .map(PackageElement.fromJson)
            .toList();
      }
    } else if (rawData is List) {
      parsedPackages = rawData
          .whereType<Map<String, dynamic>>()
          .map(PackageElement.fromJson)
          .toList();
    } else if (json["packages"] is List) {
      parsedPackages = (json["packages"] as List)
          .whereType<Map<String, dynamic>>()
          .map(PackageElement.fromJson)
          .toList();
    } else if (json["items"] is List) {
      parsedPackages = (json["items"] as List)
          .whereType<Map<String, dynamic>>()
          .map(PackageElement.fromJson)
          .toList();
    }

    final isSuccess = json["success"] == true ||
        json["status"] == true ||
        json["status"]?.toString().toLowerCase() == "success";

    return MyPackagesModel(
      success: isSuccess,
      message: json["message"]?.toString(),
      packages: parsedPackages,
    );
  }

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": {
          "items": packages.map((x) => x.toJson()).toList(),
        },
      };
}

class PackageElement {
  final int? id;
  final int? userId;
  final int? packageId;
  final String? name;
  final String? status;
  final DateTime? subscribedAt;
  final DateTime? cancelledAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final PackagePackage? package;
  final User? user;

  PackageElement({
    this.id,
    this.userId,
    this.packageId,
    this.name,
    this.status,
    this.subscribedAt,
    this.cancelledAt,
    this.createdAt,
    this.updatedAt,
    this.package,
    this.user,
  });

  /// Guaranteed name for the card
  String get packageName {
    if (package?.name != null && package!.name!.trim().isNotEmpty) {
      return package!.name!.trim();
    }
    if (name != null && name!.trim().isNotEmpty) {
      return name!.trim();
    }
    return "ফিচারসমূহ";
  }

  /// Subscription start date
  DateTime get startDate => subscribedAt ?? createdAt ?? DateTime.now();

  /// Subscription expiration / end date
  DateTime get endDate => cancelledAt ?? DateTime.now();

  /// Returns true if currently active
  bool get isActive {
    if (status?.toLowerCase() == 'active') {
      return true;
    }
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  /// Formatted date strings
  String get formattedStartDate =>
      DateFormat('dd MMM, yyyy').format(startDate);

  String get formattedEndDate =>
      DateFormat('dd MMM, yyyy').format(endDate);

  /// Resolved package ID
  int get effectivePackageId => packageId ?? package?.id ?? id ?? 0;

  /// Convert to Package model for details and checkout
  Package toPackage() {
    return Package(
      id: effectivePackageId,
      name: packageName,
      description: package?.description,
      regularPrice: package?.regularPrice,
      discountedPrice: package?.discountedPrice,
      duration: package?.duration,
      durationDays: package?.duration,
      isCurrentlyActive: isActive,
    );
  }

  factory PackageElement.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    final pkgJson = json["package"] is Map<String, dynamic>
        ? PackagePackage.fromJson(json["package"])
        : null;

    final subDate = parseDate(json["subscribed_at"]) ??
        parseDate(json["start_date"]) ??
        parseDate(json["created_at"]);

    final expDate = parseDate(json["cancelled_at"]) ??
        parseDate(json["expires_at"]) ??
        parseDate(json["end_date"]);

    return PackageElement(
      id: json["id"] is int
          ? json["id"]
          : int.tryParse(json["id"]?.toString() ?? ''),
      userId: json["user_id"] is int
          ? json["user_id"]
          : int.tryParse(json["user_id"]?.toString() ?? ''),
      packageId: json["package_id"] is int
          ? json["package_id"]
          : int.tryParse(json["package_id"]?.toString() ?? ''),
      name: json["package_name"]?.toString() ?? json["name"]?.toString(),
      status: json["status"]?.toString(),
      subscribedAt: subDate,
      cancelledAt: expDate,
      createdAt: parseDate(json["created_at"]),
      updatedAt: parseDate(json["updated_at"]),
      package: pkgJson,
      user: json["user"] == null ? null : User.fromJson(json["user"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "package_id": packageId,
        "name": name,
        "status": status,
        "subscribed_at": subscribedAt?.toIso8601String(),
        "cancelled_at": cancelledAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "package": package?.toJson(),
        "user": user?.toJson(),
      };
}

class PackagePackage {
  final int? id;
  final String? name;
  final String? description;
  final String? regularPrice;
  final int? duration;
  final String? discount;
  final String? discountedPrice;
  final bool? status;
  final bool? isFeatured;
  final dynamic features;
  final bool? isTrial;
  final dynamic trialDuration;
  final dynamic termsAndConditions;

  PackagePackage({
    this.id,
    this.name,
    this.description,
    this.regularPrice,
    this.duration,
    this.discount,
    this.discountedPrice,
    this.status,
    this.isFeatured,
    this.features,
    this.isTrial,
    this.trialDuration,
    this.termsAndConditions,
  });

  factory PackagePackage.fromJson(Map<String, dynamic> json) => PackagePackage(
        id: json["id"] is int
            ? json["id"]
            : int.tryParse(json["id"]?.toString() ?? ''),
        name: json["name"]?.toString(),
        description: json["description"]?.toString(),
        regularPrice: json["regular_price"]?.toString(),
        duration: json["duration_days"] is int
            ? json["duration_days"]
            : (json["duration"] is int
                ? json["duration"]
                : int.tryParse(json["duration"]?.toString() ?? '')),
        discount: json["discount"]?.toString(),
        discountedPrice: json["discounted_price"]?.toString(),
        status: json["status"] == true ||
            json["status"] == 1 ||
            json["status"]?.toString() == "1" ||
            json["status"]?.toString().toLowerCase() == "true",
        isFeatured: json["is_featured"] == true ||
            json["is_featured"] == 1 ||
            json["is_featured"]?.toString() == "1",
        features: json["features"],
        isTrial: json["is_trial"] == true ||
            json["is_trial"] == 1 ||
            json["is_trial"]?.toString() == "1",
        trialDuration: json["trial_duration_days"] ?? json["trial_duration"],
        termsAndConditions: json["terms_and_conditions"],
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
        "is_featured": isFeatured,
        "features": features,
        "is_trial": isTrial,
        "trial_duration": trialDuration,
        "terms_and_conditions": termsAndConditions,
      };
}
