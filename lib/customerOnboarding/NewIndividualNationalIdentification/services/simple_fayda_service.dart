import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:coopengageplus/constants/config/config.dart';
import 'package:coopengageplus/features/onboarding/pages/home/HomePage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import '../model/national_id_models.dart';
import 'package:uuid/uuid.dart';

class SimpleFaydaService {
  // static const String _wsUrl = "ws://10.12.53.33:9062/ws/fayda";
  static const String _wsUrl = AppConstants.webSocketUrl;

  WebSocketChannel? _channel;
  String? _clientId;
  Completer<bool>? _registrationCompleter;
  Completer<FaydaUserData>? _authCompleter;
  bool _isConnecting = false;
  bool _isClosing = false;
  bool _isReconnecting = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 3;
  Timer? _reconnectTimer;

  /// Step 1: Connect to WebSocket
  Future<void> connectWebSocket() async {
    if (_isConnecting) {
      print('⚠️ Already connecting to WebSocket...');
      return;
    }

    if (_channel != null) {
      print('⚠️ WebSocket already connected');
      return;
    }

    try {
      print('🔌 Step 1: Connecting to WebSocket...');
      _isConnecting = true;

      _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));

      // Add error handling for the WebSocket connection
      _channel!.stream.listen(
        _handleMessage,
        onError: (error) {
          print('❌ WebSocket error: $error');
          _handleWebSocketError(error);
        },
        onDone: () {
          print('🔌 WebSocket connection closed');
          _handleWebSocketClosed();
        },
      );

      print('✅ WebSocket connected');
      _isConnecting = false;
    } catch (e) {
      print('❌ Failed to connect to WebSocket: $e');
      _isConnecting = false;
      throw Exception('Failed to connect to WebSocket: $e');
    }
  }

  /// Step 2: Register client (keep open)
  Future<void> registerClient() async {
    print('📡 Step 2: Registering client...');

    // Check if WebSocket is connected
    if (_channel == null) {
      throw Exception('WebSocket not connected. Cannot register client.');
    }

    // Generate unique client ID
    _clientId = 'client_${DateTime.now().millisecondsSinceEpoch}';
    print('🆔 Generated client ID: $_clientId');

    try {
      // Send registration message
      _registrationCompleter = Completer<bool>();

      // Validate WebSocket connection before sending
      if (_channel == null || _isClosing) {
        throw Exception('WebSocket connection lost during registration');
      }

      _channel!.sink
          .add(jsonEncode({"type": "register_client", "clientId": _clientId}));

      // Wait for registration success with timeout
      await _registrationCompleter!.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Registration timeout. Server did not respond.');
        },
      );

      print('✅ Client registered successfully');
    } catch (e) {
      print('❌ Registration failed: $e');
      _registrationCompleter = null;
      throw Exception('Failed to register client: $e');
    }
  }

  /// Step 3: Get auth URL (keep open)
  Future<String> getAuthUrl(String baseUrl) async {
    print('🔗 Step 3: Getting auth URL...');
    final token = await storage.read(key: "token");
    print("kdfndklnkkkkkkkkdfdfdf");

    print(token);
    print(_clientId);
    print(baseUrl);
    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/v1/fayda/authenticate-url-ws?clientId=$_clientId',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Add your token here
      },
    );

    // final response = await http.get(
    //   Uri.parse(
    //       '${baseUrl}/api/v1/fayda/authenticate-url-ws?clientId=$_clientId'),
    //   headers: {'Content-Type': 'application/json'},
    //   // body: jsonEncode({'clientId': _clientId}),
    // );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final authUrl = data['url'] as String;
      print('✅ Auth URL received: $authUrl');
      return authUrl;
    }

    throw Exception('Failed to get auth URL: ${response.statusCode}');
  }

  /// Step 4: Wait for authentication result after callback
  Future<FaydaUserData> waitForAuthResult() async {
    print('⏳ Step 4: Waiting for authentication result...');

    // Check if WebSocket is connected
    if (_channel == null) {
      throw Exception(
          'WebSocket not connected. Cannot wait for authentication result.');
    }

    try {
      _authCompleter = Completer<FaydaUserData>();

      // Wait for authentication result with timeout (5 minutes)
      return await _authCompleter!.future.timeout(
        const Duration(minutes: 6),
        onTimeout: () {
          throw Exception(
              'Authentication timeout. No result received from server.');
        },
      );
    } catch (e) {
      print('❌ Error waiting for authentication result: $e');
      _authCompleter = null;
      throw Exception('Failed to wait for authentication result: $e');
    }
  }

  /// Handle WebSocket messages
  void _handleMessage(dynamic message) async {
    
    try {
      print('📨 Raw WebSocket message: $message');

      final data = jsonDecode(message.toString());
      print('📨 Parsed WebSocket message: ${data['type']}');

      switch (data['type']) {
        case 'registration_success':
          print(
              '✅ Registration success received for client: ${data['clientId']}');
          if (data['clientId'] == _clientId &&
              _registrationCompleter != null &&
              !_registrationCompleter!.isCompleted) {
            _registrationCompleter!.complete(true);
          } else {
            print(
                '⚠️ Registration success received but client ID mismatch or completer already completed');
          }
          break;

        case 'authentication_result':
          print('🎉 Authentication result received!');
          if (data['clientId'] == _clientId &&
              _authCompleter != null &&
              !_authCompleter!.isCompleted) {
            String? savedImagePath;
            final base64Picture = data['data']['picture']?.toString();

            if (base64Picture != null &&
                base64Picture.isNotEmpty &&
                base64Picture != "data:image/jpeg;base64,/") {
              try {
                // Extract base64 data (remove data:image/jpeg;base64, prefix)
                final base64Data = base64Picture.replaceFirst(
                    RegExp(r'^data:image/[^;]+;base64,'), '');

                if (base64Data.isNotEmpty) {
                  final decodedBytes = base64Decode(base64Data);

                  final directory = await getApplicationDocumentsDirectory();
                  final fileName = '${const Uuid().v4()}.jpg';
                  final filePath = '${directory.path}/$fileName';

                  final imageFile = File(filePath);
                  await imageFile.writeAsBytes(decodedBytes);

                  savedImagePath = filePath;
                  print('🖼️ Picture saved at: $filePath');
                } else {
                  print('⚠️ Empty base64 data after removing prefix');
                }
              } catch (e) {
                print('❌ Error saving picture: $e');
                print(
                    '❌ Picture data: ${base64Picture.substring(0, 100)}...'); // Log first 100 chars
              }
            } else {
              print('⚠️ No valid picture data received');
            }

            // Parse user data
            final userData = FaydaUserData(
              sub: data['data']['sub']?.toString() ?? '',
              name: data['data']['name']?.toString() ?? '',
              email: data['data']['email']?.toString() ?? '',
              phoneNumber: data['data']['phone_number']?.toString(),
              birthdate: data['data']['birthdate']?.toString(),
              gender: data['data']['gender']?.toString(),
              picture: savedImagePath,
              address: data['data']['address'] != null
                  ? FaydaAddress(
                      country: data['data']['address']['country']?.toString(),
                      region: data['data']['address']['region']?.toString(),
                      zone: data['data']['address']['zone']?.toString(),
                      woreda: data['data']['address']['woreda']?.toString(),
                    )
                  : null,
            );

            print('✅ User data parsed: ${userData.name}');
            _authCompleter!.complete(userData);

            // Close WebSocket - operation finished
            print('🔌 Closing WebSocket - operation finished');
            close();
          } else {
            print(
                '⚠️ Authentication result received but client ID mismatch or completer already completed');
          }
          break;

        default:
          print('⚠️ Unknown message type: ${data['type']}');
          break;
      }
    } catch (e) {
      print('❌ Error parsing WebSocket message: $e');
      print('❌ Raw message was: $message');
    }
  }

  /// Handle WebSocket errors
  void _handleWebSocketError(dynamic error) {
    print('❌ WebSocket error occurred: $error');

    // Don't immediately close if we're in the middle of authentication
    if (_authCompleter != null && !_authCompleter!.isCompleted) {
      print('🔄 Authentication in progress - attempting reconnection...');
      _attemptReconnection();
      return;
    }

    // Complete any pending operations with error
    if (_registrationCompleter != null &&
        !_registrationCompleter!.isCompleted) {
      _registrationCompleter!.completeError('WebSocket error: $error');
    }

    if (_authCompleter != null && !_authCompleter!.isCompleted) {
      _authCompleter!.completeError('WebSocket error: $error');
    }

    // Clean up the connection
    _cleanupConnection();
  }

  /// Handle WebSocket closed
  void _handleWebSocketClosed() {
    print('🔌 WebSocket connection closed unexpectedly');

    // Don't immediately close if we're in the middle of authentication
    if (_authCompleter != null && !_authCompleter!.isCompleted) {
      print('🔄 Authentication in progress - attempting reconnection...');
      _attemptReconnection();
      return;
    }

    // Complete any pending operations with error
    if (_registrationCompleter != null &&
        !_registrationCompleter!.isCompleted) {
      _registrationCompleter!.completeError('WebSocket connection closed');
    }

    if (_authCompleter != null && !_authCompleter!.isCompleted) {
      _authCompleter!.completeError('WebSocket connection closed');
    }

    // Clean up the connection
    _cleanupConnection();
  }

  /// Attempt to reconnect WebSocket
  void _attemptReconnection() async {
    if (_isReconnecting || _reconnectAttempts >= _maxReconnectAttempts) {
      print('❌ Max reconnection attempts reached or already reconnecting');
      _cleanupConnection();
      return;
    }

    _reconnectAttempts++;
    _isReconnecting = true;

    print(
        '🔄 Attempting WebSocket reconnection (attempt $_reconnectAttempts/$_maxReconnectAttempts)');

    try {
      // Wait a bit before reconnecting
      await Future.delayed(Duration(seconds: _reconnectAttempts * 2));

      // Reconnect
      await connectWebSocket();

      // Re-register if we have a client ID
      if (_clientId != null) {
        await registerClient();
        print('✅ WebSocket reconnected and re-registered successfully');
      }

      _isReconnecting = false;
      _reconnectAttempts = 0;
    } catch (e) {
      print('❌ Reconnection attempt $_reconnectAttempts failed: $e');
      _isReconnecting = false;

      if (_reconnectAttempts < _maxReconnectAttempts) {
        // Try again
        _reconnectTimer = Timer(Duration(seconds: _reconnectAttempts * 3), () {
          _attemptReconnection();
        });
      } else {
        print('❌ Max reconnection attempts reached');
        _cleanupConnection();
      }
    }
  }

  /// Clean up WebSocket connection
  void _cleanupConnection() {
    _reconnectTimer?.cancel();
    _channel = null;
    _isConnecting = false;
    _isClosing = false;
    _isReconnecting = false;
  }

  /// Close WebSocket connection
  void close() {
    if (_isClosing || _channel == null) {
      print('⚠️ WebSocket already closed or closing');
      return;
    }

    try {
      print('🔌 Closing WebSocket connection...');
      _isClosing = true;
      _reconnectTimer?.cancel(); // Cancel any pending reconnection attempts
      _channel!.sink.close();
      _cleanupConnection();
      print('✅ WebSocket closed successfully');
    } catch (e) {
      print('❌ Error closing WebSocket: $e');
      _cleanupConnection();
    }
  }

  /// Check if WebSocket is connected
  bool get isConnected => _channel != null && !_isClosing;
}
