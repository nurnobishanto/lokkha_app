class Payment {
  final int? id;
  final int? userId;
  final int? orderId;
  final String? transactionId;
  final String? amount;
  final String? paymentMethod;
  final String? status;
  final String? request;
  final String? response;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? paymentUrl;

  Payment({
    this.id,
    this.userId,
    this.orderId,
    this.transactionId,
    this.amount,
    this.paymentMethod,
    this.status,
    this.request,
    this.response,
    this.createdAt,
    this.updatedAt,
    this.paymentUrl,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        id: json["id"],
        userId: json["user_id"],
        orderId: json["order_id"],
        transactionId: json["transaction_id"],
        amount: json["amount"],
        paymentMethod: json["payment_method"],
        status: json["status"],
        request: json["request"],
        response: json["response"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        paymentUrl: json["payment_url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "order_id": orderId,
        "transaction_id": transactionId,
        "amount": amount,
        "payment_method": paymentMethod,
        "status": status,
        "request": request,
        "response": response,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "payment_url": paymentUrl,
      };
}
