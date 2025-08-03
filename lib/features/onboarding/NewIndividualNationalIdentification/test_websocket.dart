import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Simple test for WebSocket flow
class WebSocketTest {
  static WebSocketChannel? _channel;
  static String? _clientId;
  static bool _registrationSuccess = false;

  /// Test the complete WebSocket flow
  static Future<void> testWebSocketFlow() async {
    try {
      debugPrint('=== Starting WebSocket Test ===');
      
      // Step 1: Connect to WebSocket
      await _connectWebSocket();
      
      // Step 2: Register client
      await _registerClient();
      
      // Step 3: Wait for registration success
      await _waitForRegistrationSuccess();
      
      debugPrint('=== WebSocket Test Completed Successfully ===');
      
    } catch (e) {
      debugPrint('=== WebSocket Test Failed: $e ===');
    }
  }

  /// Connect to WebSocket
  static Future<void> _connectWebSocket() async {
    final wsUrl = 'ws://10.8.100.111:9062/ws/fayda';
    debugPrint('Connecting to WebSocket: $wsUrl');
    
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    
    _channel!.stream.listen(
      (message) {
        debugPrint('Received: $message');
        _handleMessage(message);
      },
      onError: (error) {
        debugPrint('WebSocket error: $error');
      },
      onDone: () {
        debugPrint('WebSocket connection closed');
      },
    );
    
    // Wait for connection
    await Future.delayed(const Duration(milliseconds: 1000));
    debugPrint('WebSocket connected successfully');
  }

  /// Register client
  static Future<void> _registerClient() async {
    _clientId = "12344";
    
    final message = {
      'type': 'register_client',
      'clientId': _clientId,
    };
    
    final jsonMessage = jsonEncode(message);
    _channel!.sink.add(jsonMessage);
    debugPrint('Sent registration: $jsonMessage');
  }

  /// Wait for registration success
  static Future<void> _waitForRegistrationSuccess() async {
    int attempts = 0;
    while (!_registrationSuccess && attempts < 10) {
      await Future.delayed(const Duration(milliseconds: 500));
      attempts++;
    }
    
    if (_registrationSuccess) {
      debugPrint('Registration successful!');
    } else {
      throw Exception('Registration timeout');
    }
  }

  /// Handle incoming messages
  static void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message.toString());
      debugPrint('Parsed message: $data');
      
      if (data['type'] == 'registration_success' && data['clientId'] == _clientId) {
        debugPrint('Registration success confirmed!');
        _registrationSuccess = true;
      }
    } catch (e) {
      debugPrint('Error parsing message: $e');
    }
  }

  /// Close connection
  static void closeConnection() {
    if (_channel != null) {
      _channel!.sink.close();
      _channel = null;
    }
  }
} 