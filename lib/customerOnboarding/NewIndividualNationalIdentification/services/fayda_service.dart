import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import '../model/national_id_models.dart';

class FaydaService {
  static const String _wsUrl = "ws://10.12.53.33:9062/ws/fayda";

  // Generate unique client ID for each service instance
  late final String _clientId;

  WebSocketChannel? _channel;
  final _registrationCompleter = Completer<bool>();
  final _authCompleter = Completer<FaydaUserData>();

  // Constructor generates unique client ID
  FaydaService() {
    _clientId = _generateClientId();
    print('🆔 [FaydaService] Generated unique client ID: $_clientId');
  }

  /// Generate a unique client ID based on timestamp and random component
  // String _generateClientId() {
  //  return "121211211";
  // }

  String _generateClientId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp * 7) % 999999;
    return 'client_${timestamp}_${random}';
  }

  /// Get the current client ID for this service instance
  String get clientId => _clientId;

  // Step 1: Connect to WebSocket and register client
  Future<void> connectAndRegister() async {
    print('🔌 [FaydaService] STEP 1: Starting WebSocket connection...');
    print('🔌 [FaydaService] WebSocket URL: $_wsUrl');
    print('🔌 [FaydaService] Client ID: $_clientId');

    _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));
    print('🔌 [FaydaService] WebSocket channel created');
    print('🔌 [FaydaService] WebSocket connected: ${isConnected}');

    // Listen for messages
    _channel!.stream.listen(_handleMessage);
    print('🔌 [FaydaService] WebSocket stream listener set up');

    // Step 2: Send registration message
    final registrationMessage = {
      "type": "register_client",
      "clientId": _clientId
    };

    print(
        '🔌 [FaydaService] STEP 2: Sending registration message: $registrationMessage');
    _channel!.sink.add(jsonEncode(registrationMessage));
    print('🔌 [FaydaService] Registration message sent');
    print(
        '🔌 [FaydaService] WebSocket status after registration: ${isConnected}');

    // Wait for registration success
    print('🔌 [FaydaService] Waiting for registration success...');
    final isRegistered = await _registrationCompleter.future;
    print('🔌 [FaydaService] Registration result: $isRegistered');
    print(
        '🔌 [FaydaService] WebSocket status after registration complete: ${isConnected}');

    if (!isRegistered) {
      print('❌ [FaydaService] Registration failed - throwing exception');
      throw Exception('Registration failed - cannot proceed to next step');
    }

    print(
        '✅ [FaydaService] Registration successful, WebSocket ready for next steps');
  }

  // Step 3: Get authentication URL
  Future<String> getAuthUrl(String baseUrl) async {
    print('🌐 [FaydaService] STEP 3: Getting authentication URL...');
    print('🌐 [FaydaService] Base URL: $baseUrl');
    print('🌐 [FaydaService] Client ID: $_clientId');
    print('🌐 [FaydaService] WebSocket status before API call: ${isConnected}');

    final url =
        '${baseUrl}/api/v1/fayda/authenticate-url-ws?clientId=$_clientId';
    print('🌐 [FaydaService] Full API URL: $url');

    try {
      final response = await http.get(Uri.parse(url));
      print('🌐 [FaydaService] API Response status: ${response.statusCode}');
      print('🌐 [FaydaService] API Response body: ${response.body}');
      print(
          '🌐 [FaydaService] WebSocket status after API call: ${isConnected}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authUrl = data['url'] as String;
        print('✅ [FaydaService] Auth URL retrieved: $authUrl');
        print(
            '🌐 [FaydaService] WebSocket status after successful auth URL: ${isConnected}');
        return authUrl;
      }

      print(
          '❌ [FaydaService] Failed to get auth URL - status: ${response.statusCode}');
      throw Exception('Failed to get auth URL: ${response.statusCode}');
    } catch (e) {
      print('❌ [FaydaService] Exception getting auth URL: $e');
      print(
          '🌐 [FaydaService] WebSocket status after exception: ${isConnected}');
      throw e;
    }
  }

  // Step 5: Wait for authentication result
  Future<FaydaUserData> waitForAuthResult() async {
    print('⏳ [FaydaService] STEP 5: Waiting for authentication result...');
    print('⏳ [FaydaService] WebSocket status before waiting: ${isConnected}');
    print('⏳ [FaydaService] Client ID: $_clientId');
    print('⏳ [FaydaService] WebSocket channel exists: ${_channel != null}');

    if (!isConnected) {
      print(
          '❌ [FaydaService] WebSocket is not connected! Cannot wait for auth result');
      throw Exception('WebSocket is not connected');
    }

    print(
        '⏳ [FaydaService] Starting to wait for authentication_result message...');
    print('⏳ [FaydaService] Expected client ID in response: $_clientId');

    try {
      final result = await _authCompleter.future;
      print('🎉 [FaydaService] Authentication result received successfully!');
      return result;
    } catch (e) {
      print('❌ [FaydaService] Error waiting for auth result: $e');
      rethrow;
    }
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
    print('📨 [FaydaService] ===== WebSocket message received =====');
    print('📨 [FaydaService] Raw message: $message');
    print('📨 [FaydaService] WebSocket status on message: ${isConnected}');
    print('📨 [FaydaService] Current client ID: $_clientId');

    try {
      final data = jsonDecode(message.toString());
      print('📨 [FaydaService] Parsed message data: $data');

      // Check if this is an authentication result message (no 'type' field, just 'data')
      if (data.containsKey('data') && data['data'] != null) {
        print(
            '🎉 [FaydaService] ===== AUTHENTICATION RESULT MESSAGE RECEIVED =====');
        print('🎉 [FaydaService] User data received: ${data['data']}');

        try {
          // Create user data with required fields, handling missing ones
          final userDataJson = data['data'] as Map<String, dynamic>;

          // Ensure required fields exist, provide defaults if missing
          final userData = FaydaUserData(
            sub: userDataJson['sub']?.toString() ?? '',
            name: userDataJson['name']?.toString() ?? '',
            email: userDataJson['email']?.toString() ?? '', // Default email
            phoneNumber: userDataJson['phone_number']?.toString(),
            birthdate: userDataJson['birthdate']?.toString(),
            gender: userDataJson['gender']?.toString(),
            address: userDataJson['address'] != null
                ? FaydaAddress(
                    country: userDataJson['address']['country']?.toString(),
                    region: userDataJson['address']['region']?.toString(),
                    woreda: userDataJson['address']['woreda']?.toString(),
                    zone: userDataJson['address']['zone']?.toString(),
                  )
                : null,
          );

          if (!_authCompleter.isCompleted) {
            print('🎉 [FaydaService] Completing auth completer with user data');
            print(
                '🎉 [FaydaService] User: ${userData.name}, Sub: ${userData.sub}');
            _authCompleter.complete(userData);

            // Close WebSocket after successful authentication
            print(
                '🔌 [FaydaService] Authentication successful - closing WebSocket');
            dispose();
          } else {
            print('⚠️ [FaydaService] Auth completer already completed');
          }
        } catch (parseError) {
          print('❌ [FaydaService] Error parsing user data: $parseError');
          print('❌ [FaydaService] Raw user data: ${data['data']}');
          if (!_authCompleter.isCompleted) {
            _authCompleter.completeError(
                Exception('Failed to parse user data: $parseError'));
          }
        }
        return;
      }

      // Handle other message types if they have a 'type' field
      if (data.containsKey('type')) {
        final messageType = data['type']?.toString();
        print('📨 [FaydaService] Message type: $messageType');
        print('📨 [FaydaService] Message client ID: ${data['clientId']}');

        switch (messageType) {
          case 'registration_success':
            print('✅ [FaydaService] Registration success message received');
            if (data['clientId'] == _clientId) {
              print('✅ [FaydaService] Client ID matches: ${data['clientId']}');
              if (!_registrationCompleter.isCompleted) {
                print('✅ [FaydaService] Completing registration completer');
                _registrationCompleter.complete(true);
              } else {
                print(
                    '⚠️ [FaydaService] Registration completer already completed');
              }
            } else {
              print(
                  '⚠️ [FaydaService] Client ID mismatch: expected $_clientId, got ${data['clientId']}');
            }
            break;

          default:
            print('❓ [FaydaService] Unknown message type: $messageType');
            print('❓ [FaydaService] Full message data: $data');
            // Handle errors or unknown types
            if (messageType?.contains('error') == true) {
              print(
                  '❌ [FaydaService] Error message received: ${data['message']}');
              if (!_registrationCompleter.isCompleted) {
                print('❌ [FaydaService] Completing registration with error');
                _registrationCompleter.complete(false);
              }
              if (!_authCompleter.isCompleted) {
                print('❌ [FaydaService] Completing auth with error');
                _authCompleter.completeError(
                    Exception(data['message'] ?? 'Authentication error'));
              }
            }
        }
      } else {
        print('❓ [FaydaService] Message has no type field and no data field');
        print('❓ [FaydaService] Full message data: $data');
      }
    } catch (e) {
      print('❌ [FaydaService] Error parsing WebSocket message: $e');
      print('❌ [FaydaService] Raw message that failed to parse: $message');
    }

    print(
        '📨 [FaydaService] WebSocket status after handling message: ${isConnected}');
    print('📨 [FaydaService] ===== End of message handling =====');
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
}
