
import 'dart:convert';
import 'package:coopengageplus/features/onboarding/pages/home/HomePage.dart';
import 'package:dio/dio.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/link_generator_models.dart';


/// Exception for link generation errors
class LinkGenerationException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;
  LinkGenerationException(
    this.message, {
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => message;
}

/// Service class for link generation API calls
class LinkGeneratorService {
  final Dio _dio;
  final String baseUrl;

  LinkGeneratorService({
    required Dio dio,
    required this.baseUrl,
  }) : _dio = dio;

  /// Send email invitation (for Email platform)
  Future<void> sendEmailInvitation(EmailInvitationRequest request) async {
    try {
      final url = '$baseUrl/api/v1/invitations/send';
      
      // Get authentication token from secure storage
      String? token = await storage.read(key: "token");

      final response = await _dio.post(
        url,
        data: jsonEncode(request.toJson()),
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json"
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Email sent successfully
        return;
      } else if (response.statusCode == 400) {
        final errorMsg = _extractErrorMessage(response.data);
        throw LinkGenerationException(
          errorMsg ?? 'Invalid request. Please check your input.',
          statusCode: response.statusCode,
        );
      } else if (response.statusCode == 401) {
        throw LinkGenerationException(
          'Unauthorized. Please login again.',
          statusCode: response.statusCode,
        );
      } else if (response.statusCode == 403) {
        throw LinkGenerationException(
          'You do not have permission to perform this action.',
          statusCode: response.statusCode,
        );
      } else if (response.statusCode == 404) {
        throw LinkGenerationException(
          'API endpoint not found.',
          statusCode: response.statusCode,
        );
      } else {
        throw LinkGenerationException(
          'Request failed with status code ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      if (e is LinkGenerationException) {
        rethrow;
      }
      throw LinkGenerationException(
        'An unexpected error occurred: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Generate shareable link via API (for WhatsApp/Telegram)
  Future<LinkGenerationResponse> generateLink(
    LinkGenerationRequest request,
  ) async {
    try {
      final url = '$baseUrl/api/v1/invitations/social/generate-link';

      // Get authentication token from secure storage
      String? token = await storage.read(key: "token");

      final response = await _dio.post(
        url,
        data: jsonEncode(request.toJson()),
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json"
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = _parseResponseData(response.data);
        return LinkGenerationResponse.fromJson(data);
      } else if (response.statusCode == 400) {
        final errorMsg = _extractErrorMessage(response.data);
        throw LinkGenerationException(
          errorMsg ?? 'Invalid request. Please check your input.',
          statusCode: response.statusCode,
        );
      } else if (response.statusCode == 401) {
        throw LinkGenerationException(
          'Unauthorized. Please login again.',
          statusCode: response.statusCode,
        );
      } else if (response.statusCode == 403) {
        throw LinkGenerationException(
          'You do not have permission to perform this action.',
          statusCode: response.statusCode,
        );
      } else if (response.statusCode == 404) {
        throw LinkGenerationException(
          'API endpoint not found.',
          statusCode: response.statusCode,
        );
      } else {
        throw LinkGenerationException(
          'Request failed with status code ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      if (e is LinkGenerationException) {
        rethrow;
      }
      throw LinkGenerationException(
        'An unexpected error occurred: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Parse response data (handles both Map and String responses)
  /// Also extracts the 'data' field if response is wrapped
  Map<String, dynamic> _parseResponseData(dynamic data) {
    Map<String, dynamic> parsedData;

    if (data is Map<String, dynamic>) {
      parsedData = data;
    } else if (data is String) {
      try {
        parsedData = jsonDecode(data) as Map<String, dynamic>;
      } catch (e) {
        throw LinkGenerationException(
          'Failed to parse response data',
          originalError: e,
        );
      }
    } else {
      throw LinkGenerationException('Unexpected response format');
    }

    // Check if response is wrapped in a 'data' field
    if (parsedData.containsKey('data') &&
        parsedData['data'] is Map<String, dynamic>) {
      return parsedData['data'] as Map<String, dynamic>;
    }

    return parsedData;
  }

  /// Extract error message from response
  String? _extractErrorMessage(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        return data['message'] as String? ??
            data['error'] as String? ??
            data['detail'] as String?;
      } else if (data is String) {
        final parsed = jsonDecode(data) as Map<String, dynamic>?;
        return parsed?['message'] as String? ??
            parsed?['error'] as String? ??
            parsed?['detail'] as String?;
      }
    } catch (e) {
      // If parsing fails, return null
    }
    return null;
  }

  /// Handle Dio exceptions
  LinkGenerationException _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return LinkGenerationException(
          'Request timeout. Please check your internet connection.',
          originalError: e,
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final errorMsg = _extractErrorMessage(e.response?.data);
        return LinkGenerationException(
          errorMsg ?? 'Server error occurred',
          statusCode: statusCode,
          originalError: e,
        );
      case DioExceptionType.cancel:
        return LinkGenerationException(
          'Request was cancelled',
          originalError: e,
        );
      case DioExceptionType.connectionError:
        return LinkGenerationException(
          'No internet connection. Please check your network.',
          originalError: e,
        );
      case DioExceptionType.badCertificate:
        return LinkGenerationException(
          'SSL certificate error',
          originalError: e,
        );
      case DioExceptionType.unknown:
      return LinkGenerationException(
          'Network error: ${e.message ?? "Unknown error"}',
          originalError: e,
        );
    }
  }
}
