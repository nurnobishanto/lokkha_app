class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final PaginationMeta? meta;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.meta,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic dataJson)? fromDataJson,
  ) {
    return ApiResponse<T>(
      success: json['success'] == true || json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && fromDataJson != null
          ? fromDataJson(json['data'])
          : json['data'] as T?,
      meta: json['meta'] != null && json['meta'] is Map
          ? PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
      errors: json['errors'] != null && json['errors'] is Map
          ? Map<String, dynamic>.from(json['errors'])
          : null,
    );
  }
}

class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMore;

  PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.hasMore,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) => PaginationMeta(
        currentPage: json['current_page'] ??
            json['pagination']?['current_page'] ??
            1,
        lastPage: json['last_page'] ??
            json['pagination']?['total_pages'] ??
            1,
        perPage: json['per_page'] ??
            json['pagination']?['per_page'] ??
            10,
        total: json['total'] ??
            json['pagination']?['total'] ??
            0,
        hasMore: json['has_more'] ??
            json['pagination']?['has_more_pages'] ??
            false,
      );
}
