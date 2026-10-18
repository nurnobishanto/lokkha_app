import 'dart:convert';
import 'package:lokkha/features/course/data/models/my_course_model.dart'
    show CoursePaginationMeta;
import 'package:lokkha/shared/models/package.dart';

PremiumPackageModel premiumPackageModelFromJson(String str) =>
    PremiumPackageModel.fromJson(json.decode(str) as Map<String, dynamic>);

String premiumPackageModelToJson(PremiumPackageModel data) =>
    json.encode(data.toJson());

/// Typedef for Clean Architecture
typedef PackagesResponseModel = PremiumPackageModel;

class PremiumPackageModel {
  final bool success;
  final String? message;
  final List<Package> packages;
  final bool isAuthenticated;
  final bool canClaimFreeTrial;
  final int? activeUserPackageId;
  final dynamic activeSubscription;
  final CoursePaginationMeta? meta;

  PremiumPackageModel({
    this.success = false,
    this.message,
    this.packages = const [],
    this.isAuthenticated = false,
    this.canClaimFreeTrial = false,
    this.activeUserPackageId,
    this.activeSubscription,
    this.meta,
  });

  // Compatibility getters
  bool? get status => success;
  List<Package> get items => packages;

  factory PremiumPackageModel.fromJson(Map<String, dynamic> json) {
    List<Package> parsedPackages = [];
    bool isAuth = false;
    bool canClaimTrial = false;
    int? activePkgId;
    dynamic activeSub;

    final rawData = json["data"];
    if (rawData is Map<String, dynamic>) {
      if (rawData["items"] is List) {
        parsedPackages = (rawData["items"] as List)
            .whereType<Map<String, dynamic>>()
            .map(Package.fromJson)
            .toList();
      }
      isAuth = rawData["is_authenticated"] == true;
      canClaimTrial = rawData["can_claim_free_trial"] == true;
      activePkgId = int.tryParse(rawData["active_user_package_id"]?.toString() ?? '');
      activeSub = rawData["active_subscription"];
    } else if (rawData is List) {
      parsedPackages = rawData
          .whereType<Map<String, dynamic>>()
          .map(Package.fromJson)
          .toList();
    } else if (json["packages"] is List) {
      parsedPackages = (json["packages"] as List)
          .whereType<Map<String, dynamic>>()
          .map(Package.fromJson)
          .toList();
    } else if (json["items"] is List) {
      parsedPackages = (json["items"] as List)
          .whereType<Map<String, dynamic>>()
          .map(Package.fromJson)
          .toList();
    }

    CoursePaginationMeta? paginationMeta;
    if (json["meta"] is Map<String, dynamic>) {
      paginationMeta = CoursePaginationMeta.fromJson(
          json["meta"] as Map<String, dynamic>);
    } else if (rawData is Map<String, dynamic> &&
        rawData["meta"] is Map<String, dynamic>) {
      paginationMeta = CoursePaginationMeta.fromJson(
          rawData["meta"] as Map<String, dynamic>);
    }

    final isSuccess = json["success"] == true ||
        json["status"] == true ||
        json["status"]?.toString().toLowerCase() == "success";

    return PremiumPackageModel(
      success: isSuccess,
      message: json["message"]?.toString(),
      packages: parsedPackages,
      isAuthenticated: isAuth,
      canClaimFreeTrial: canClaimTrial,
      activeUserPackageId: activePkgId,
      activeSubscription: activeSub,
      meta: paginationMeta,
    );
  }

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": {
          "items": packages.map((x) => x.toJson()).toList(),
          "is_authenticated": isAuthenticated,
          "can_claim_free_trial": canClaimFreeTrial,
          if (activeUserPackageId != null)
            "active_user_package_id": activeUserPackageId,
          if (activeSubscription != null)
            "active_subscription": activeSubscription,
        },
        if (meta != null) "meta": meta!.toJson(),
      };
}
