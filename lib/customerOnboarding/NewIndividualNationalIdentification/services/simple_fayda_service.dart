// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:coopengageplus/constants/config/config.dart';
// import 'package:coopengageplus/features/onboarding/pages/home/HomePage.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:http/http.dart' as http;
// import '../model/national_id_models.dart';
// import 'package:uuid/uuid.dart';

// class SimpleFaydaService {
//   // static const String _wsUrl = "ws://10.12.53.33:9062/ws/fayda";
//   static const String _wsUrl = AppConstants.webSocketUrl;

//   WebSocketChannel? _channel;
//   String? _clientId;
//   Completer<bool>? _registrationCompleter;
//   Completer<FaydaUserData>? _authCompleter;
//   bool _isConnecting = false;
//   bool _isClosing = false;
//   Timer? _heartbeatTimer;

//   /// Step 1: Connect to WebSocket
//   Future<void> connectWebSocket() async {
//     // Always close existing connection first
//     if (_channel != null) {
//       print('🔄 Closing existing WebSocket connection...');
//       await _forceCloseConnection();
//     }

//     if (_isConnecting) {
//       print('⚠️ Already connecting to WebSocket...');
//       return;
//     }

//     try {
//       print('🔌 Step 1: Connecting to WebSocket...');
//       _isConnecting = true;
//       _cleanupTimers(); // Clean up any existing timers

//       _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));

//       // Add error handling for the WebSocket connection
//       _channel!.stream.listen(
//         _handleMessage,
//         onError: (error) {
//           print('❌ WebSocket error: $error');
//           _handleWebSocketError(error);
//         },
//         onDone: () {
//           print('🔌 WebSocket connection closed');
//           _handleWebSocketClosed();
//         },
//       );

//       // Start heartbeat to keep connection alive
//       _startHeartbeat();
      
//       print('✅ WebSocket connected');
//       _isConnecting = false;
//     } catch (e) {
//       print('❌ Failed to connect to WebSocket: $e');
//       _isConnecting = false;
//       _cleanupTimers();
//       throw Exception('Failed to connect to WebSocket: $e');
//     }
//   }

//   /// Step 2: Register client (keep open)
//   Future<void> registerClient() async {
//     print('📡 Step 2: Registering client...');

//     // Check if WebSocket is connected
//     if (_channel == null) {
//       throw Exception('WebSocket not connected. Cannot register client.');
//     }

//     // Generate unique client ID
//     _clientId = 'client_${DateTime.now().millisecondsSinceEpoch}';
//     print('🆔 Generated client ID: $_clientId');

//     try {
//       // Send registration message
//       _registrationCompleter = Completer<bool>();

//       // Validate WebSocket connection before sending
//       if (_channel == null || _isClosing) {
//         throw Exception('WebSocket connection lost during registration');
//       }

//       _channel!.sink
//           .add(jsonEncode({"type": "register_client", "clientId": _clientId}));

//       // Wait for registration success with timeout
//       await _registrationCompleter!.future.timeout(
//         const Duration(seconds: 30),
//         onTimeout: () {
//           throw Exception('Registration timeout. Server did not respond.');
//         },
//       );

//       print('✅ Client registered successfully');
//     } catch (e) {
//       print('❌ Registration failed: $e');
//       _registrationCompleter = null;
//       throw Exception('Failed to register client: $e');
//     }
//   }

//   /// Step 3: Get auth URL (keep open)
//   Future<String> getAuthUrl(String baseUrl) async {
//     print('🔗 Step 3: Getting auth URL...');
//     final token = await storage.read(key: "token");
//     print("kdfndklnkkkkkkkkdfdfdf");

//     print(token);
//     print(_clientId);
//     print(baseUrl);
//     final response = await http.get(
//       Uri.parse(
//         '$baseUrl/api/v1/fayda/authenticate-url-ws?clientId=$_clientId',
//       ),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token', // Add your token here
//       },
//     );

//     // final response = await http.get(
//     //   Uri.parse(
//     //       '${baseUrl}/api/v1/fayda/authenticate-url-ws?clientId=$_clientId'),
//     //   headers: {'Content-Type': 'application/json'},
//     //   // body: jsonEncode({'clientId': _clientId}),
//     // );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       final authUrl = data['url'] as String;
//       print('✅ Auth URL received: $authUrl');
//       return authUrl;
//     }

//     throw Exception('Failed to get auth URL: ${response.statusCode}');
//   }

//   /// Step 4: Wait for authentication result after callback
//   Future<FaydaUserData> waitForAuthResult() async {
//     print('⏳ Step 4: Waiting for authentication result...');

//     // Check if WebSocket is connected
//     if (_channel == null) {
//       throw Exception('WebSocket not connected. Call connectWebSocket() first.');
//     }

//     try {
//       _authCompleter = Completer<FaydaUserData>();

//       // Wait for authentication result with timeout (10 minutes)
//       return await _authCompleter!.future.timeout(
//         const Duration(minutes: 10),
//         onTimeout: () {
//           throw Exception(
//               'Authentication timeout. No result received from server after 10 minutes.');
//         },
//       );
//     } catch (e) {
//       print('❌ Error waiting for authentication result: $e');
//       _authCompleter = null;
//       rethrow;
//     }
//   }

//   /// Handle WebSocket messages
//   void _handleMessage(dynamic message) async {
//     try {
//       print('📨 Raw WebSocket message: $message');

//       final data = jsonDecode(message.toString());
//       print('📨 Parsed WebSocket message: ${data['type']}');

//       switch (data['type']) {
//         case 'registration_success':
//           print(
//               '✅ Registration success received for client: ${data['clientId']}');
//           if (data['clientId'] == _clientId &&
//               _registrationCompleter != null &&
//               !_registrationCompleter!.isCompleted) {
//             _registrationCompleter!.complete(true);
//           } else {
//             print(
//                 '⚠️ Registration success received but client ID mismatch or completer already completed');
//           }
//           break;

//         case 'authentication_result':
//           print('🎉 Authentication result received!');
//           if (data['clientId'] == _clientId &&
//               _authCompleter != null &&
//               !_authCompleter!.isCompleted) {
//             String? savedImagePath;
//             final base64Picture = data['data']['picture']?.toString();

//             if (base64Picture != null &&
//                 base64Picture.isNotEmpty &&
//                 base64Picture != "data:image/jpeg;base64,/") {
//               try {
//                 // Extract base64 data (remove data:image/jpeg;base64, prefix)
//                 final base64Data = base64Picture.replaceFirst(
//                     RegExp(r'^data:image/[^;]+;base64,'), '');

//                 if (base64Data.isNotEmpty) {
//                   final decodedBytes = base64Decode(base64Data);

//                   final directory = await getApplicationDocumentsDirectory();
//                   final fileName = '${const Uuid().v4()}.jpg';
//                   final filePath = '${directory.path}/$fileName';

//                   final imageFile = File(filePath);
//                   await imageFile.writeAsBytes(decodedBytes);

//                   savedImagePath = filePath;
//                   print('🖼️ Picture saved at: $filePath');
//                 } else {
//                   print('⚠️ Empty base64 data after removing prefix');
//                 }
//               } catch (e) {
//                 print('❌ Error saving picture: $e');
//                 print(
//                     '❌ Picture data: ${base64Picture.substring(0, 100)}...'); // Log first 100 chars
//               }
//             } else {
//               print('⚠️ No valid picture data received');
//             }

//             // Parse user data
//             final userData = FaydaUserData(
//               sub: data['data']['sub']?.toString() ?? '',
//               name: data['data']['name']?.toString() ?? '',
//               email: data['data']['email']?.toString() ?? '',
//               phoneNumber: data['data']['phone_number']?.toString(),
//               birthdate: data['data']['birthdate']?.toString(),
//               gender: data['data']['gender']?.toString(),
//               picture: savedImagePath,
//               address: data['data']['address'] != null
//                   ? FaydaAddress(
//                       country: data['data']['address']['country']?.toString(),
//                       region: data['data']['address']['region']?.toString(),
//                       zone: data['data']['address']['zone']?.toString(),
//                       woreda: data['data']['address']['woreda']?.toString(),
//                     )
//                   : null,
//             );

//             print('✅ User data parsed: ${userData.name}');
//             _authCompleter!.complete(userData);

//             // Close WebSocket - operation finished
//             print('🔌 Closing WebSocket - operation finished');
//             close();
//           } else {
//             print(
//                 '⚠️ Authentication result received but client ID mismatch or completer already completed');
//           }
//           break;

//         default:
//           print('⚠️ Unknown message type: ${data['type']}');
//           break;
//       }
//     } catch (e) {
//       print('❌ Error parsing WebSocket message: $e');
//       print('❌ Raw message was: $message');
//     }
//   }

//   /// Handle WebSocket errors
//   void _handleWebSocketError(dynamic error) {
//     print('❌ WebSocket error occurred: $error');

//     // Complete any pending operations with error
//     if (_registrationCompleter != null &&
//         !_registrationCompleter!.isCompleted) {
//       _registrationCompleter!.completeError('WebSocket error: $error');
//     }

//     if (_authCompleter != null && !_authCompleter!.isCompleted) {
//       _authCompleter!.completeError('WebSocket error: $error');
//     }

//     // Clean up the connection
//     _cleanupConnection();
//   }

//   /// Handle WebSocket closed
//   void _handleWebSocketClosed() {
//     print('🔌 WebSocket connection closed unexpectedly');

//     // Complete any pending operations with error
//     if (_registrationCompleter != null &&
//         !_registrationCompleter!.isCompleted) {
//       _registrationCompleter!.completeError('WebSocket connection closed');
//     }

//     if (_authCompleter != null && !_authCompleter!.isCompleted) {
//       _authCompleter!.completeError('WebSocket connection closed');
//     }

//     // Clean up the connection
//     _cleanupConnection();
//   }

//   /// Force close existing connection
//   Future<void> _forceCloseConnection() async {
//     try {
//       _isClosing = true;
//       _cleanupTimers();
//       if (_channel != null) {
//         await _channel!.sink.close();
//       }
//       _cleanupConnection();
//       print('✅ Existing connection closed');
//     } catch (e) {
//       print('⚠️ Error closing existing connection: $e');
//       _cleanupConnection();
//     }
//   }

//   /// Start heartbeat to keep connection alive
//   void _startHeartbeat() {
//     _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
//       if (_channel != null && !_isClosing) {
//         try {
//           _channel!.sink.add(jsonEncode({"type": "ping", "clientId": _clientId}));
//           print('💓 Heartbeat sent');
//         } catch (e) {
//           print('❌ Failed to send heartbeat: $e');
//           timer.cancel();
//         }
//       } else {
//         timer.cancel();
//       }
//     });
//   }

//   /// Clean up all timers
//   void _cleanupTimers() {
//     _heartbeatTimer?.cancel();
//     _heartbeatTimer = null;
//   }

//   /// Clean up WebSocket connection
//   void _cleanupConnection() {
//     _cleanupTimers();
//     _channel = null;
//     _isConnecting = false;
//     _isClosing = false;
//   }

//   /// Close WebSocket connection
//   void close() {
//     if (_isClosing || _channel == null) {
//       print('⚠️ WebSocket already closed or closing');
//       return;
//     }

//     try {
//       print('🔌 Closing WebSocket connection...');
//       _isClosing = true;
//       _cleanupTimers(); // Cancel all timers
//       _channel!.sink.close();
//       _cleanupConnection();
//       print('✅ WebSocket closed successfully');
//     } catch (e) {
//       print('❌ Error closing WebSocket: $e');
//       _cleanupConnection();
//     }
//   }

//   /// Get current connection status
//   String get connectionStatus {
//     if (_isConnecting) return 'Connecting...';
//     if (_channel != null && !_isClosing) return 'Connected';
//     return 'Disconnected';
//   }

//   /// Check if WebSocket is connected
//   bool get isConnected => _channel != null && !_isClosing;
// }



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

/// Clean and simple Fayda authentication service
/// Ensures WebSocket stays open until authentication data is received
class SimpleFaydaService {
  static const String _wsUrl = AppConstants.webSocketUrl;

  WebSocketChannel? _channel;
  String? _clientId;
  Completer<bool>? _registrationCompleter;
  Completer<FaydaUserData>? _authCompleter;
  Timer? _pingTimer;

  /// Step 1: Connect to WebSocket
  Future<void> connectWebSocket() async {
    if (_channel != null) return;

    print('🔌 Connecting to WebSocket...');
    _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));

    _channel!.stream.listen(
      _handleMessage,
      onError: (error) {
        print('❌ WebSocket error: $error');
        // DON'T complete with error - just log it and keep listening
        print('⚠️ WebSocket error occurred but keeping connection alive');
      },
      onDone: () {
        print('🔌 WebSocket closed by server');
        // DON'T complete with error - just log it
        print('⚠️ WebSocket closed but this is normal after authentication');
      },
    );

    _startPing();
    print('✅ WebSocket connected');
  }

  /// Step 2: Register client
  Future<void> registerClient() async {
    if (_channel == null) throw Exception('WebSocket not connected');

    _clientId = 'client_${DateTime.now().millisecondsSinceEpoch}';
    _registrationCompleter = Completer<bool>();

    _channel!.sink.add(jsonEncode({
      "type": "register_client",
      "clientId": _clientId,
    }));

    await _registrationCompleter!.future;
    print('✅ Client registered: $_clientId');
  }

  /// Step 3: Get auth URL
  Future<String> getAuthUrl(String baseUrl) async {
    final token = await storage.read(key: "token");
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/fayda/authenticate-url-ws?clientId=$_clientId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final authUrl = jsonDecode(response.body)['url'] as String;
      print('✅ Auth URL received');
      return authUrl;
    }

    throw Exception('Failed to get auth URL: ${response.statusCode}');
  }

  /// Step 4: Wait for authentication result (NO TIMEOUT - waits until data arrives)
  Future<FaydaUserData> waitForAuthResult() async {
    if (_channel == null) throw Exception('WebSocket not connected');

    _authCompleter = Completer<FaydaUserData>();
    print('⏳ Waiting for authentication result...');
    return await _authCompleter!.future; // WebSocket stays open until we get data
  }

  /// Handle incoming WebSocket messages
  void _handleMessage(dynamic message) async {
    try {
      final data = jsonDecode(message.toString());
      final type = data['type'];

      print('📨 Received message type: $type');

      switch (type) {
        case 'registration_success':
          _completeRegistration();
          break;

        case 'authentication_result':
          await _completeAuthentication(data);
          break;

        case 'registration_failed':
        case 'authentication_failed':
          print('❌ Server reported failure: $type');
          _completeWithError('Authentication failed');
          // DON'T close WebSocket on server failures - keep listening
          break;

        default:
          print('⚠️ Unknown message type: $type');
      }
    } catch (e) {
      print('❌ Error parsing message: $e');
      print('❌ Raw message: $message');
    }
  }

  /// Complete registration
  void _completeRegistration() {
    if (_registrationCompleter != null && !_registrationCompleter!.isCompleted) {
      _registrationCompleter!.complete(true);
    }
  }

  /// Complete authentication with user data
  Future<void> _completeAuthentication(Map<String, dynamic> data) async {
    if (_authCompleter == null || _authCompleter!.isCompleted) {
      print('⚠️ Auth completer already completed or null');
      return;
    }
    if (data['clientId'] != _clientId) {
      print('⚠️ Client ID mismatch: ${data['clientId']} != $_clientId');
      return;
    }

    try {
      final userData = FaydaUserData(
        sub: data['data']['sub']?.toString() ?? '',
        name: data['data']['name']?.toString() ?? '',
        email: data['data']['email']?.toString() ?? '',
        phoneNumber: data['data']['phone_number']?.toString(),
        birthdate: data['data']['birthdate']?.toString(),
        gender: data['data']['gender']?.toString(),
        picture: await _savePicture(data['data']['picture']),
        address: _parseAddress(data['data']['address']),
      );

      print('✅ Authentication completed: ${userData.name}');
      _authCompleter!.complete(userData);
      // DON'T close WebSocket - keep it open for listening
    } catch (e) {
      print('❌ Error completing authentication: $e');
      if (!_authCompleter!.isCompleted) {
        _authCompleter!.completeError('Authentication completion failed: $e');
      }
    }
  }

  /// Save picture from base64
  Future<String?> _savePicture(dynamic base64Picture) async {
    if (base64Picture == null || base64Picture.toString().isEmpty) return null;
    if (base64Picture == "data:image/jpeg;base64,/") return null;

    try {
      final base64Data = base64Picture
          .toString()
          .replaceFirst(RegExp(r'^data:image/[^;]+;base64,'), '');
      
      if (base64Data.isEmpty) return null;

      final decodedBytes = base64Decode(base64Data);
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${const Uuid().v4()}.jpg';
      await File(filePath).writeAsBytes(decodedBytes);
      
      print('🖼️ Picture saved');
      return filePath;
    } catch (e) {
      print('❌ Error saving picture: $e');
      return null;
    }
  }

  /// Parse address data
  FaydaAddress? _parseAddress(dynamic addressData) {
    if (addressData == null) return null;

    return FaydaAddress(
      country: addressData['country']?.toString(),
      region: addressData['region']?.toString(),
      zone: addressData['zone']?.toString(),
      woreda: addressData['woreda']?.toString(),
    );
  }

  /// Complete with error
  void _completeWithError(String error) {
    print('❌ Completing with error: $error');
    if (_registrationCompleter != null && !_registrationCompleter!.isCompleted) {
      _registrationCompleter!.completeError(error);
    }
    if (_authCompleter != null && !_authCompleter!.isCompleted) {
      _authCompleter!.completeError(error);
    }
  }

  /// Keep connection alive with periodic ping
  void _startPing() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(Duration(seconds: 30), (_) {
      if (_channel != null) {
        _channel!.sink.add(jsonEncode({"type": "ping"}));
      }
    });
  }

  /// Close connection (only call this when absolutely necessary)
  void close() {
    print('🔌 Manually closing WebSocket connection');
    _pingTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    print('✅ WebSocket manually closed');
  }

  bool get isConnected => _channel != null;
}
