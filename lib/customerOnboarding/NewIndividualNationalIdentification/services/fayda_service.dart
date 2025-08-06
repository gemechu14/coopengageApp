import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import '../model/national_id_models.dart';

class FaydaService {
  static const String _clientId = "12344";
  static const String _wsUrl = "ws://10.8.100.111:9062/ws/fayda";
  
  WebSocketChannel? _channel;
  final _registrationCompleter = Completer<bool>();
  final _authCompleter = Completer<FaydaUserData>();
  
  // Step 1: Connect to WebSocket and register client
  Future<void> connectAndRegister() async {
    print('🔌 [FaydaService] STEP 1: Starting WebSocket connection...');
    print('🔌 [FaydaService] WebSocket URL: $_wsUrl');
    print('🔌 [FaydaService] Client ID: $_clientId');
    
    _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));
    print('🔌 [FaydaService] WebSocket channel created');
    print('🔌 [FaydaService] WebSocket connected: ${_channel != null}');
    
    // Listen for messages
    _channel!.stream.listen(_handleMessage);
    print('🔌 [FaydaService] WebSocket stream listener set up');
    
    // Step 2: Send registration message
    final registrationMessage = {
      "type": "register_client",
      "clientId": _clientId
    };
    
    print('🔌 [FaydaService] STEP 2: Sending registration message: $registrationMessage');
    _channel!.sink.add(jsonEncode(registrationMessage));
    print('🔌 [FaydaService] Registration message sent');
    print('🔌 [FaydaService] WebSocket status after registration: ${isConnected}');
    
    // Wait for registration success
    print('🔌 [FaydaService] Waiting for registration success...');
    final isRegistered = await _registrationCompleter.future;
    print('🔌 [FaydaService] Registration result: $isRegistered');
    print('🔌 [FaydaService] WebSocket status after registration complete: ${isConnected}');
    
    if (!isRegistered) {
      print('❌ [FaydaService] Registration failed - throwing exception');
      throw Exception('Registration failed - cannot proceed to next step');
    }
    
    print('✅ [FaydaService] Registration successful, WebSocket ready for next steps');
  }
  
  // Step 3: Get authentication URL
  Future<String> getAuthUrl(String baseUrl) async {
    print('🌐 [FaydaService] STEP 3: Getting authentication URL...');
    print('🌐 [FaydaService] Base URL: $baseUrl');
    print('🌐 [FaydaService] Client ID: $_clientId');
    print('🌐 [FaydaService] WebSocket status before API call: ${isConnected}');
    
    final url = '${baseUrl}/api/v1/fayda/authenticate-url-ws?clientId=$_clientId';
    print('🌐 [FaydaService] Full API URL: $url');
    
    try {
      final response = await http.get(Uri.parse(url));
      print('🌐 [FaydaService] API Response status: ${response.statusCode}');
      print('🌐 [FaydaService] API Response body: ${response.body}');
      print('🌐 [FaydaService] WebSocket status after API call: ${isConnected}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authUrl = data['url'] as String;
        print('✅ [FaydaService] Auth URL retrieved: $authUrl');
        print('🌐 [FaydaService] WebSocket status after successful auth URL: ${isConnected}');
        return authUrl;
      }
      
      print('❌ [FaydaService] Failed to get auth URL - status: ${response.statusCode}');
      throw Exception('Failed to get auth URL: ${response.statusCode}');
    } catch (e) {
      print('❌ [FaydaService] Exception getting auth URL: $e');
      print('🌐 [FaydaService] WebSocket status after exception: ${isConnected}');
      throw e;
    }
  }
  
  // Step 4: Call callback API with code and state
  Future<void> processCallback(String baseUrl, String code, String state) async {
    print('📞 [FaydaService] STEP 4: Processing callback...');
    print('📞 [FaydaService] Base URL: $baseUrl');
    print('📞 [FaydaService] Code: $code');
    print('📞 [FaydaService] State: $state');
    print('📞 [FaydaService] WebSocket status BEFORE callback API: ${isConnected}');
    print('📞 [FaydaService] WebSocket channel exists: ${_channel != null}');
    
    final url = '${baseUrl}/api/v1/fayda/callback?code=$code&state=$state';
    print('📞 [FaydaService] Callback API URL: $url');
    print('📞 [FaydaService] ✅ USING GET REQUEST (not POST)');
    
    try {
      print('📞 [FaydaService] Making HTTP GET request...');
      final response = await http.get(Uri.parse(url)); // ✅ CHANGED TO GET
      
      print('📞 [FaydaService] Callback API Response status: ${response.statusCode}');
      print('📞 [FaydaService] Callback API Response body: ${response.body}');
      print('📞 [FaydaService] WebSocket status AFTER callback API: ${isConnected}');
      print('📞 [FaydaService] WebSocket channel still exists: ${_channel != null}');
      
      if (response.statusCode != 200) {
        print('❌ [FaydaService] Callback API failed with status: ${response.statusCode}');
        print('❌ [FaydaService] Response body: ${response.body}');
        print('📞 [FaydaService] WebSocket status during error: ${isConnected}');
        throw Exception('Callback failed: ${response.statusCode} - ${response.body}');
      }
      
      print('✅ [FaydaService] Callback API successful with GET request');
      print('📞 [FaydaService] WebSocket status after successful callback: ${isConnected}');
    } catch (e) {
      print('❌ [FaydaService] Exception in callback API: $e');
      print('📞 [FaydaService] WebSocket status during exception: ${isConnected}');
      throw e;
    }
  }
  
  // Step 5: Wait for authentication result
  Future<FaydaUserData> waitForAuthResult() async {
    print('⏳ [FaydaService] STEP 5: Waiting for authentication result...');
    print('⏳ [FaydaService] WebSocket status before waiting: ${isConnected}');
    return await _authCompleter.future;
  }
  
  // Helper method to extract callback parameters from URL
  static Map<String, String>? extractCallbackParams(String url) {
    try {
      final uri = Uri.parse(url);
      final code = uri.queryParameters['code'];
      final state = uri.queryParameters['state'];
      
      if (code != null && state != null) {
        return {'code': code, 'state': state};
      }
    } catch (e) {
      // Invalid URL format
    }
    return null;
  }
  
  // Check if URL is a callback URL
  static bool isCallbackUrl(String url) {
    return url.contains('/callback') || 
           url.contains('code=') || 
           url.contains('state=');
  }
  
  void _handleMessage(dynamic message) {
    print('📨 [FaydaService] WebSocket message received: $message');
    print('📨 [FaydaService] WebSocket status on message: ${isConnected}');
    
    try {
      final data = jsonDecode(message.toString());
      print('📨 [FaydaService] Parsed message data: $data');
      
      switch (data['type']) {
        case 'registration_success':
          print('✅ [FaydaService] Registration success message received');
          if (data['clientId'] == _clientId) {
            print('✅ [FaydaService] Client ID matches: ${data['clientId']}');
            if (!_registrationCompleter.isCompleted) {
              print('✅ [FaydaService] Completing registration completer');
              _registrationCompleter.complete(true);
            } else {
              print('⚠️ [FaydaService] Registration completer already completed');
            }
          } else {
            print('⚠️ [FaydaService] Client ID mismatch: expected $_clientId, got ${data['clientId']}');
          }
          break;
          
        case 'authentication_result':
          print('🎉 [FaydaService] Authentication result received');
          print('🎉 [FaydaService] WebSocket status when auth result received: ${isConnected}');
          if (data['clientId'] == _clientId) {
            print('🎉 [FaydaService] Client ID matches for auth result: ${data['clientId']}');
            print('🎉 [FaydaService] User data: ${data['data']}');
            final userData = FaydaUserData.fromJson(data['data']);
            if (!_authCompleter.isCompleted) {
              print('🎉 [FaydaService] Completing auth completer');
              _authCompleter.complete(userData);
            } else {
              print('⚠️ [FaydaService] Auth completer already completed');
            }
            print('🔌 [FaydaService] NOT closing WebSocket here - keeping open for provider');
            print('🔌 [FaydaService] WebSocket status after auth result: ${isConnected}');
          } else {
            print('⚠️ [FaydaService] Client ID mismatch for auth result: expected $_clientId, got ${data['clientId']}');
          }
          break;
          
        default:
          print('❓ [FaydaService] Unknown message type: ${data['type']}');
          // Handle errors or unknown types
          if (data['type']?.contains('error') == true) {
            print('❌ [FaydaService] Error message received: ${data['message']}');
            if (!_registrationCompleter.isCompleted) {
              print('❌ [FaydaService] Completing registration with error');
              _registrationCompleter.complete(false);
            }
            if (!_authCompleter.isCompleted) {
              print('❌ [FaydaService] Completing auth with error');
              _authCompleter.completeError(Exception(data['message'] ?? 'Authentication error'));
            }
          }
      }
    } catch (e) {
      print('❌ [FaydaService] Error parsing WebSocket message: $e');
    }
    
    print('📨 [FaydaService] WebSocket status after handling message: ${isConnected}');
  }
  
  // Explicitly close the WebSocket when the service is disposed
  void dispose() {
    print('🔴 [FaydaService] Disposing service and closing WebSocket');
    print('🔴 [FaydaService] WebSocket status before dispose: ${isConnected}');
    _channel?.sink.close();
    _channel = null;
    print('🔴 [FaydaService] WebSocket closed and set to null');
  }
  
  // Check if WebSocket is still connected
  bool get isConnected {
    final connected = _channel != null;
    // print('🔍 [FaydaService] WebSocket connection check: $connected');
    return connected;
  }
  
  // Get current client ID
  String get clientId => _clientId;
} 