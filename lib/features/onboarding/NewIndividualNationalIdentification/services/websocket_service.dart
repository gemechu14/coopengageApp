import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:coopengageplus/constants/config/config.dart';
// import 'package:http/http.dart' as http; // Uncomment when using real HTTP requests

/// WebSocket service for Fayda authentication
class WebSocketService {
  static WebSocketChannel? _channel;
  static String? _clientId;
  static Completer<Map<String, dynamic>>? _authCompleter;
  static Timer? _connectionTimer;
  static bool _isConnecting = false;
  
  /// Set to true when backend endpoint is ready
  static const bool _useRealHttpRequest = false;

  /// Generate a unique client ID
  static String generateClientId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomPart = String.fromCharCodes(
      Iterable.generate(9, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
    return 'client_${randomPart}_$timestamp';
  }

  /// Initialize WebSocket connection and start authentication
  static Future<Map<String, dynamic>> authenticate() async {
    if (_isConnecting) {
      throw Exception('Authentication already in progress');
    }

    _isConnecting = true;
    _clientId = generateClientId();

    try {
      // 1. Establish WebSocket connection
      await _connectWebSocket();

      // 2. Get authentication URL
      await _getAuthenticationUrl();

      // 3. Wait for authentication result
      final result = await _waitForAuthenticationResult();

      return result;
    } finally {
      _isConnecting = false;
      _cleanup();
    }
  }

  /// Connect to WebSocket server
  static Future<void> _connectWebSocket() async {
    final wsUrl = _getWebSocketUrl();
    
    try {
      debugPrint('Attempting to connect to WebSocket: $wsUrl');
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      // Set up connection timeout
      _connectionTimer = Timer(const Duration(seconds: 10), () {
        if (_authCompleter != null && !_authCompleter!.isCompleted) {
          _authCompleter!.completeError(
            TimeoutException('WebSocket connection timeout. Please check if the WebSocket server is running at $wsUrl', const Duration(seconds: 10))
          );
        }
      });

      // Listen for messages
      _channel!.stream.listen(
        _handleWebSocketMessage,
        onError: (error) {
          debugPrint('WebSocket error: $error');
          final errorMessage = _getWebSocketErrorMessage(error, wsUrl);
          if (_authCompleter != null && !_authCompleter!.isCompleted) {
            _authCompleter!.completeError(Exception(errorMessage));
          }
        },
        onDone: () {
          debugPrint('WebSocket connection closed');
          if (_authCompleter != null && !_authCompleter!.isCompleted) {
            _authCompleter!.completeError(
              Exception('WebSocket connection closed unexpectedly. Please check if the WebSocket server is running.')
            );
          }
        },
      );

      // Wait for connection to be established
      await Future.delayed(const Duration(milliseconds: 500));

      // Register client
      _registerClient();
    } catch (e) {
      final errorMessage = _getWebSocketErrorMessage(e, wsUrl);
      throw Exception(errorMessage);
    }
  }

  /// Get user-friendly error message for WebSocket errors
  static String _getWebSocketErrorMessage(dynamic error, String wsUrl) {
    final errorStr = error.toString();
    
    if (errorStr.contains('was not upgraded to websocket')) {
      return 'WebSocket server not available at $wsUrl. The server may not support WebSocket connections or the endpoint may be incorrect.';
    } else if (errorStr.contains('Connection refused') || errorStr.contains('Failed to connect')) {
      return 'Cannot connect to WebSocket server at $wsUrl. Please check if the server is running and accessible.';
    } else if (errorStr.contains('Timeout')) {
      return 'WebSocket connection timed out. Please check your network connection and server availability.';
    } else {
      return 'WebSocket connection failed: $errorStr';
    }
  }

  /// Get WebSocket URL
  static String _getWebSocketUrl() {
    final baseUrl = AppConstants.baseUrl;
    
    // Parse the base URL to extract host and port
    final uri = Uri.parse(baseUrl);
    final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
    final host = uri.host;
    final port = uri.hasPort ? ':${uri.port}' : '';
    
    // Construct WebSocket URL without any API path prefix
    final wsUrl = '$scheme://$host$port/ws/fayda';
    
    debugPrint('WebSocket URL: $wsUrl');
    return wsUrl;
  }

  /// Register client with WebSocket server
  static void _registerClient() {
    if (_channel != null && _clientId != null) {
      final message = {
        'type': 'register_client',
        'clientId': _clientId,
      };
      
      _channel!.sink.add(jsonEncode(message));
      debugPrint('Client registered with ID: $_clientId');
    }
  }

  /// Get authentication URL from backend
  static Future<String> _getAuthenticationUrl() async {
    final baseUrl = AppConstants.baseUrl;
    
    if (_useRealHttpRequest) {
      return _getRealAuthenticationUrl(baseUrl);
    } else {
      return _getSimulatedAuthenticationUrl(baseUrl);
    }
  }

  /// Get authentication URL from real backend API
  static Future<String> _getRealAuthenticationUrl(String baseUrl) async {
    // Uncomment import 'package:http/http.dart' as http; at the top of the file when using this
    /*
    final apiUrl = '$baseUrl/api/v1/fayda/authenticate-url-ws?clientId=$_clientId';
    
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('url')) {
          final url = responseData['url'];
          if (url != null && url is String) {
            return url;
          } else {
            throw Exception('Invalid URL format in response');
          }
        } else {
          throw Exception('No authentication URL received');
        }
      } else {
        throw Exception('API call failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get authentication URL: $e');
    }
    */
    
    // Fallback to simulation if real implementation is not ready
    return _getSimulatedAuthenticationUrl(baseUrl);
  }

  /// Get simulated authentication URL for development/testing
  static Future<String> _getSimulatedAuthenticationUrl(String baseUrl) async {
    try {
      final simulatedResponse = await Future.delayed(
        const Duration(milliseconds: 500),
        () => <String, dynamic>{
          'url': '$baseUrl/api/v1/fayda/auth?clientId=$_clientId&state=${_clientId}_state'
        }
      );

      if (simulatedResponse.containsKey('url')) {
        final url = simulatedResponse['url'];
        if (url != null && url is String) {
          return url;
        } else {
          throw Exception('Invalid URL format in response');
        }
      } else {
        throw Exception('No authentication URL received');
      }
    } catch (e) {
      throw Exception('Failed to get authentication URL: $e');
    }
  }

  /// Wait for authentication result from WebSocket
  static Future<Map<String, dynamic>> _waitForAuthenticationResult() async {
    _authCompleter = Completer<Map<String, dynamic>>();
    
    // Set timeout for authentication
    Timer(const Duration(minutes: 5), () {
      if (_authCompleter != null && !_authCompleter!.isCompleted) {
        _authCompleter!.completeError(
          TimeoutException('Authentication timeout', const Duration(minutes: 5))
        );
      }
    });

    return _authCompleter!.future;
  }

  /// Handle incoming WebSocket messages
  static void _handleWebSocketMessage(dynamic message) {
    try {
      final data = jsonDecode(message.toString());
      debugPrint('Received WebSocket message: $data');

      switch (data['type']) {
        case 'registration_success':
          debugPrint('Client registered successfully');
          break;

        case 'authentication_result':
          if (data['clientId'] == _clientId) {
            debugPrint('Authentication successful: ${data['data']}');
            if (_authCompleter != null && !_authCompleter!.isCompleted) {
              _authCompleter!.complete(data['data']);
            }
          }
          break;

        case 'error':
          debugPrint('Authentication error: ${data['message']}');
          if (_authCompleter != null && !_authCompleter!.isCompleted) {
            _authCompleter!.completeError(Exception(data['message']));
          }
          break;

        case 'registration_error':
          debugPrint('Registration error: ${data['message']}');
          if (_authCompleter != null && !_authCompleter!.isCompleted) {
            _authCompleter!.completeError(Exception(data['message']));
          }
          break;

        default:
          debugPrint('Unknown message type: ${data['type']}');
      }
    } catch (e) {
      debugPrint('Error parsing WebSocket message: $e');
      if (_authCompleter != null && !_authCompleter!.isCompleted) {
        _authCompleter!.completeError(e);
      }
    }
  }

  /// Clean up WebSocket resources
  static void _cleanup() {
    _connectionTimer?.cancel();
    _connectionTimer = null;
    
    if (_channel != null) {
      _channel!.sink.close();
      _channel = null;
    }
    
    _authCompleter = null;
    _clientId = null;
  }

  /// Close WebSocket connection manually
  static void closeConnection() {
    if (_channel != null) {
      _channel!.sink.close(1000, 'Authentication completed');
    }
    _cleanup();
  }

  /// Check if WebSocket is connected
  static bool get isConnected => _channel != null;

  /// Get current client ID
  static String? get clientId => _clientId;
} 