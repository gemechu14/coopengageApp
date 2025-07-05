// Service Result Model - Handles success/error responses from services
class ServiceResult {
  final bool isSuccess;
  final String? errorMessage;
  final String? userId;
  final Map<String, dynamic>? data;

  ServiceResult._({
    required this.isSuccess,
    this.errorMessage,
    this.userId,
    this.data,
  });

  factory ServiceResult.success({String? userId, Map<String, dynamic>? data}) {
    return ServiceResult._(
      isSuccess: true,
      userId: userId,
      data: data,
    );
  }

  factory ServiceResult.error(String errorMessage) {
    return ServiceResult._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }

  // Helper methods
  bool get hasData => data != null;
  bool get hasUserId => userId != null;

  // Type-safe data access
  T? getData<T>(String key) {
    if (data != null && data!.containsKey(key)) {
      return data![key] as T?;
    }
    return null;
  }

  // Convert to map for API responses
  Map<String, dynamic> toMap() {
    return {
      'success': isSuccess,
      if (errorMessage != null) 'error': errorMessage,
      if (userId != null) 'userId': userId,
      if (data != null) 'data': data,
    };
  }

  @override
  String toString() {
    return 'ServiceResult(isSuccess: $isSuccess, errorMessage: $errorMessage, userId: $userId)';
  }
} 