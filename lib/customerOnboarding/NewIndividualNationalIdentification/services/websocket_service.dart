import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:coopengageplus/constants/config/config.dart';
import 'package:http/http.dart' as http;

/// WebSocket service for Fayda authentication
class WebSocketService {
  static WebSocketChannel? _channel;
  static String? _clientId;
  static Completer<Map<String, dynamic>>? _authCompleter;
  static Completer<bool>? _registrationCompleter;

  static bool _isConnecting = false;
  static String? _authUrl;
  static String? _authState;
  static String? _originalAuthState;
  
  /// Generate a unique client ID
  static String generateClientId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return (timestamp % 100000).toString();
  }
  
  /// Set a specific client ID for testing
  static void setClientId(String clientId) {
    _clientId = clientId;
    debugPrint('Client ID set to: $_clientId');
  }



  /// Initialize WebSocket and get authentication URL (without waiting for result)
  static Future<String> initializeAuthentication() async {
    // Reset authentication state to start fresh
    _resetAuthenticationState();
    
    _isConnecting = true;
    
    // Generate a unique client ID for this session
    _clientId = generateClientId();
    debugPrint('🆔 [WebSocketService] Generated unique client ID for this session: $_clientId');

    try {
      debugPrint('Initializing Fayda authentication with clientId: $_clientId');
      
      // Step 1: Establish WebSocket connection
      await _connectWebSocket();
      
      // Step 2: Register client and wait for success
      final registrationSuccess = await _registerClientAndWait();
      if (!registrationSuccess) {
        throw Exception('Client registration failed - cannot proceed');
      }
      
      // Step 3: Get authentication URL
      final authData = await _getAuthenticationUrl();
      debugPrint('Auth data received: $authData');
      
      _authUrl = authData['url'] as String?;
      _authState = authData['state'] as String?;
      _originalAuthState = _authState;
      
      debugPrint('Authentication URL received: $_authUrl');
      debugPrint('State: $_authState');
      
      if (_authUrl == null || _authUrl!.isEmpty) {
        throw Exception('Invalid authentication URL received');
      }
      
      return _authUrl!;
    } catch (e) {
      _isConnecting = false;
      // Don't cleanup WebSocket connection on error - keep it open for callback processing
      throw e;
    }
  }
  
  /// Wait for authentication result from WebSocket (call after opening URL)
  static Future<Map<String, dynamic>> waitForAuthenticationResult() async {
    if (!_isConnecting) {
      throw Exception('Authentication not initialized. Call initializeAuthentication first.');
    }
    
    try {
      // Wait for authentication result from WebSocket
      final result = await _waitForAuthenticationResult();
      return result;
    } finally {
      _isConnecting = false;
      // Don't cleanup here - let the authentication_result handler close the connection
    }
  }

  /// Connect to WebSocket server
  static Future<void> _connectWebSocket() async {
    final wsUrl = _getWebSocketUrl();
    
    try {
      debugPrint('Attempting to connect to WebSocket: $wsUrl');
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      // Listen for messages
      _channel!.stream.listen(
        _handleWebSocketMessage,
        onError: (error) {
          debugPrint('WebSocket error: $error');
          if (_authCompleter != null && !_authCompleter!.isCompleted) {
            _authCompleter!.completeError(Exception('WebSocket connection failed: $error'));
          }
        },
        onDone: () {
          debugPrint('WebSocket connection closed');
          if (_authCompleter != null && !_authCompleter!.isCompleted) {
            _authCompleter!.completeError(
              Exception('WebSocket connection closed unexpectedly')
            );
          }
        },
      );

      // Wait for connection to be established
      await Future.delayed(const Duration(milliseconds: 1000));

      debugPrint('WebSocket connected, registering client...');
      _registerClient();
    } catch (e) {
      throw Exception('WebSocket connection failed: $e');
    }
  }

  /// Get WebSocket URL
  static String _getWebSocketUrl() {
    final wsUrl = AppConstants.webSocketUrl;
    debugPrint('WebSocket URL: $wsUrl');
    return wsUrl;
  }

  /// Register client with WebSocket server
  static void _registerClient() {
    if (_channel != null && _clientId != null) {
      // Step 2: Send registration message as per requirements
      final message = {
        'type': 'register_client',
        'clientId': _clientId,
      };
      
      final jsonMessage = jsonEncode(message);
      _channel!.sink.add(jsonMessage);
      debugPrint('Sending client registration: $jsonMessage');
    } else {
      debugPrint('Cannot register client: channel=${_channel != null}, clientId=$_clientId');
    }
  }
  
  /// Register client and wait for registration success
  static Future<bool> _registerClientAndWait() async {
    _registrationCompleter = Completer<bool>();
    
    debugPrint('Starting client registration wait...');
    
    // Register the client
    _registerClient();
    
    final result = await _registrationCompleter!.future;
    debugPrint('Client registration result: $result');
    return result;
  }

  /// Get authentication URL from backend
  static Future<Map<String, dynamic>> _getAuthenticationUrl() async {
    final baseUrl = AppConstants.baseUrl;
    final apiUrl = '$baseUrl/fayda/authenticate-url-ws?clientId=$_clientId';
    
    try {
      debugPrint('Requesting authentication URL from: $apiUrl');
      debugPrint('Using clientId: $_clientId');
      
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      debugPrint('API Response Status: ${response.statusCode}');
      debugPrint('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        debugPrint('Parsed response data: $responseData');
        
        // Validate required fields
        if (responseData.containsKey('url') && 
            responseData.containsKey('clientId') && 
            responseData.containsKey('state')) {
          debugPrint('Authentication data received: ${responseData['url']}');
          debugPrint('State from API: ${responseData['state']}');
          return responseData;
        } else {
          debugPrint('ERROR: Invalid response format - missing required fields');
          throw Exception('Invalid response format - missing required fields (url, clientId, state)');
        }
      } else {
        debugPrint('ERROR: API call failed with status: ${response.statusCode}');
        throw Exception('API call failed with status: ${response.statusCode}, body: ${response.body}');
      }
    } catch (e) {
      debugPrint('Failed to get authentication URL: $e');
      throw Exception('Failed to get authentication URL: $e');
    }
  }

  /// Wait for authentication result from WebSocket
  static Future<Map<String, dynamic>> _waitForAuthenticationResult() async {
    _authCompleter = Completer<Map<String, dynamic>>();
    return _authCompleter!.future;
  }

  /// Handle incoming WebSocket messages
  static void _handleWebSocketMessage(dynamic message) {
    try {
      final data = jsonDecode(message.toString());
      debugPrint('Received WebSocket message: $data');

      switch (data['type']) {
        case 'registration_success':
          // Handle registration success as per requirements
          if (data['clientId'] == _clientId) {
            debugPrint('Client registered successfully for clientId: ${data['clientId']}');
            if (_registrationCompleter != null && !_registrationCompleter!.isCompleted) {
              _registrationCompleter!.complete(true);
            }
          }
          break;

        case 'authentication_result':
          // Handle authentication result as per requirements
          if (data['clientId'] == _clientId) {
            debugPrint('Authentication successful for clientId: ${data['clientId']}');
            debugPrint('User data received: ${data['data']}');
            if (_authCompleter != null && !_authCompleter!.isCompleted) {
              _authCompleter!.complete(data['data']);
            }
            
            // Close WebSocket connection after successful authentication
            closeConnection();
          }
          break;

        case 'error':
          debugPrint('Authentication error: ${data['message']}');
          if (_registrationCompleter != null && !_registrationCompleter!.isCompleted) {
            _registrationCompleter!.complete(false);
          }
          if (_authCompleter != null && !_authCompleter!.isCompleted) {
            _authCompleter!.completeError(Exception(data['message']));
          }
          break;

        case 'registration_error':
          debugPrint('Registration error: ${data['message']}');
          if (_registrationCompleter != null && !_registrationCompleter!.isCompleted) {
            _registrationCompleter!.complete(false);
          }
          break;

        default:
          debugPrint('Unknown message type: ${data['type']}');
      }
    } catch (e) {
      debugPrint('Error parsing WebSocket message: $e');
      if (_registrationCompleter != null && !_registrationCompleter!.isCompleted) {
        _registrationCompleter!.complete(false);
      }
      if (_authCompleter != null && !_authCompleter!.isCompleted) {
        _authCompleter!.completeError(e);
      }
    }
  }

  /// Reset authentication state to start fresh
  static void _resetAuthenticationState() {
    debugPrint('Resetting authentication state');
    
    // Close existing WebSocket connection
    if (_channel != null) {
      debugPrint('Closing existing WebSocket connection');
      _channel!.sink.close();
      _channel = null;
    }
    
    // Reset all state variables
    _isConnecting = false;
    _authCompleter = null;
    _registrationCompleter = null;
    _clientId = null;
    _authUrl = null;
    _authState = null;
    _originalAuthState = null;
    
    debugPrint('Authentication state reset complete');
  }

  /// Clean up WebSocket resources
  static void _cleanup() {
    debugPrint('Cleaning up WebSocket resources');
    
    if (_channel != null) {
      debugPrint('Closing WebSocket connection during cleanup');
      _channel!.sink.close();
      _channel = null;
    }
    
    _authCompleter = null;
    _registrationCompleter = null;
    _clientId = null;
    _authUrl = null;
    _authState = null;
    _originalAuthState = null;
  }
  
  /// Process authentication callback with code and state
  static Future<void> processAuthCallback(String code, String state) async {
    final baseUrl = AppConstants.baseUrl;
    final callbackUrl = '$baseUrl/fayda/callback?code=$code&state=$state';
    
    try {
      debugPrint('Processing auth callback: $callbackUrl');
      debugPrint('WebSocket connection status: ${_channel != null ? 'Connected' : 'Disconnected'}');
      debugPrint('Current clientId: $_clientId');
      debugPrint('Original authState: $_originalAuthState');
      debugPrint('Callback state: $state');
      
      // Check if authentication was properly initialized
      if (_originalAuthState == null) {
        debugPrint('ERROR: Authentication was not properly initialized!');
        throw Exception('Authentication not initialized - cannot process callback. Please complete the authentication flow first.');
      }
      
      // Check WebSocket connection and ensure it's active
      if (_channel == null) {
        debugPrint('WebSocket is not active - reconnecting...');
        
        // Reinitialize clientId if needed
        if (_clientId == null) {
          _clientId = generateClientId();
          debugPrint('Restored clientId: $_clientId');
        }
        
        // Connect to WebSocket
        await _connectWebSocket();
        debugPrint('WebSocket connected successfully');
        
        // Send registration message
        debugPrint('Sending client registration message...');
        _registerClient();
        
        // Wait for registration success
        final registrationSuccess = await _registerClientAndWait();
        if (!registrationSuccess) {
          debugPrint('WARNING: Client registration failed');
        }
      }
      
      // Call the callback API
      debugPrint('Calling callback API: $callbackUrl');
      
      final response = await http.get(
        Uri.parse(callbackUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Callback Response Status: ${response.statusCode}');
      debugPrint('Callback Response Body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('Callback API call successful - waiting for WebSocket authentication result');
        // Don't complete anything here - let the WebSocket listener handle the result
        // The WebSocket will receive the authentication_result message and complete the process
      } else {
        debugPrint('Callback failed with status: ${response.statusCode}');
        throw Exception('Callback failed with status: ${response.statusCode}, body: ${response.body}');
      }
    } catch (e) {
      debugPrint('Failed to process callback: $e');
      throw e;
    }
  }

  /// Close WebSocket connection manually
  static void closeConnection() {
    if (_channel != null) {
      debugPrint('Closing WebSocket connection');
      _channel!.sink.close(1000, 'Authentication completed');
      _channel = null;
    }
  }

  /// Check if WebSocket is connected
  static bool get isConnected => _channel != null;

  /// Get current client ID
  static String? get clientId => _clientId;
  
  /// Check if authentication was properly initialized
  static bool get isAuthenticationInitialized => _originalAuthState != null && _clientId != null;
  
  /// Check if authentication flow has been started
  static bool get isAuthenticationStarted => _isConnecting || _originalAuthState != null || _clientId != null;
  
  /// Get current authentication URL
  static String? get authUrl => _authUrl;
  
  /// Get current authentication state
  static String? get authState => _authState;
  
  /// Reset authentication state (public method)
  static void resetAuthentication() {
    _resetAuthenticationState();
  }
} 