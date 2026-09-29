class Coupon {
  final int? id;
  final String? code;
  final String? type;
  final String? value;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? isActive;
  final int? usageLimit;
  final int? usageCount;
  final String? minPurchaseAmount;
  final String? maxAmount;
  final dynamic createdAt;
  final DateTime? updatedAt;
  final dynamic deletedAt;

  Coupon({
    this.id,
    this.code,
    this.type,
    this.value,
    this.startDate,
    this.endDate,
    this.isActive,
    this.usageLimit,
    this.usageCount,
    this.minPurchaseAmount,
    this.maxAmount,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) => Coupon(
        id: json["id"],
        code: json["code"],
        type: json["type"],
        value: json["value"],
        startDate: json["start_date"] == null
            ? null
            : DateTime.parse(json["start_date"]),
        endDate:
            json["end_date"] == null ? null : DateTime.parse(json["end_date"]),
        isActive: json["is_active"],
        usageLimit: json["usage_limit"],
        usageCount: json["usage_count"],
        minPurchaseAmount: json["min_purchase_amount"],
        maxAmount: json["max_amount"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "code": code,
        "type": type,
        "value": value,
        "start_date": startDate?.toIso8601String(),
        "end_date": endDate?.toIso8601String(),
        "is_active": isActive,
        "usage_limit": usageLimit,
        "usage_count": usageCount,
        "min_purchase_amount": minPurchaseAmount,
        "max_amount": maxAmount,
        "created_at": createdAt,
        "updated_at": updatedAt?.toIso8601String(),
        "deleted_at": deletedAt,
      };
}
