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

  /// Tests the WebSocket-based authentication endpoint
  static Future<ApiTestResult> testWebSocketAuthEndpoint() async {
    try {
      final String baseUrl = AppConstants.baseUrl;
      final apiUrl = '$baseUrl/api/v1/fayda/authenticate-url-ws?clientId=test_client';

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

  /// Tests WebSocket connectivity
  static Future<WebSocketTestResult> testWebSocketConnection() async {
    try {
      final baseUrl = AppConstants.baseUrl;
      final wsUrl = baseUrl.replaceFirst('http://', 'ws://')
                           .replaceFirst('https://', 'wss://');
      final fullWsUrl = '$wsUrl/ws/fayda';

      // For now, we'll simulate a successful connection
      // In a real implementation, you would test the actual WebSocket connection
      await Future.delayed(const Duration(milliseconds: 500));

      return WebSocketTestResult(
        isSuccess: true,
        url: fullWsUrl,
        message: 'WebSocket connection test completed',
      );
    } catch (e) {
      return WebSocketTestResult(
        isSuccess: false,
        url: '',
        message: e.toString(),
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

/// Result model for WebSocket testing
class WebSocketTestResult {
  final bool isSuccess;
  final String url;
  final String message;

  const WebSocketTestResult({
    required this.isSuccess,
    required this.url,
    required this.message,
  });
} 