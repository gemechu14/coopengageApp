import 'package:http/http.dart' as http;
import 'package:coopengageplus/constants/config/config.dart';

/// Service to handle API testing and utilities
class ApiService {
  
  /// Tests the API endpoint to verify connectivity
  static Future<ApiTestResult> testApiEndpoint() async {
    try {
      final String baseUrl = AppConstants.baseUrl;
      final apiUrl = '$baseUrl/api/v1/fayda/authenticate-url';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      return ApiTestResult(
        isSuccess: response.statusCode == 200,
        statusCode: response.statusCode,
        responseBody: response.body,
      );
    } catch (e) {
      return ApiTestResult(
        isSuccess: false,
        statusCode: 0,
        responseBody: e.toString(),
      );
    }
  }
}

/// Result model for API testing
class ApiTestResult {
  final bool isSuccess;
  final int statusCode;
  final String responseBody;

  const ApiTestResult({
    required this.isSuccess,
    required this.statusCode,
    required this.responseBody,
  });
} 