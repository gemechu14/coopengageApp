
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:coopengageplus/core/config/config.dart';
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
