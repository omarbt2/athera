class ApiResponse<T> {
  final bool success;
  final T? data;
  final ApiError? error;

  ApiResponse({required this.success, this.data, this.error});

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return ApiResponse(
      success: json['success'] as bool,
      data: json['success'] && json['data'] != null ? fromJsonT(json['data']) : null,
      error: !json['success'] && json['error'] != null ? ApiError.fromJson(json['error']) : null,
    );
  }
}

class ApiError {
  final String code;
  final String message;
  final int statusCode;

  ApiError({required this.code, required this.message, required this.statusCode});

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] as String,
      message: json['message'] as String,
      statusCode: json['statusCode'] as int,
    );
  }
}
