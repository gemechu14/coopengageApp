import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import '../model/national_id_models.dart';
import 'package:uuid/uuid.dart';

class SimpleFaydaService {
  static const String _wsUrl = "ws://10.12.53.33:9062/ws/fayda";

  WebSocketChannel? _channel;
  String? _clientId;
  Completer<bool>? _registrationCompleter;
  Completer<FaydaUserData>? _authCompleter;

  /// Step 1: Connect to WebSocket
  Future<void> connectWebSocket() async {
    print('🔌 Step 1: Connecting to WebSocket...');
    _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));
    _channel!.stream.listen(_handleMessage);
    print('✅ WebSocket connected');
  }

  /// Step 2: Register client (keep open)
  Future<void> registerClient() async {
    print('📡 Step 2: Registering client...');

    // Generate unique client ID
    _clientId = 'client_${DateTime.now().millisecondsSinceEpoch}';
    print('🆔 Generated client ID: $_clientId');

    // Send registration message
    _registrationCompleter = Completer<bool>();
    _channel!.sink
        .add(jsonEncode({"type": "register_client", "clientId": _clientId}));

    // Wait for registration success
    await _registrationCompleter!.future;
    print('✅ Client registered successfully');
  }

  /// Step 3: Get auth URL (keep open)
  Future<String> getAuthUrl(String baseUrl) async {
    print('🔗 Step 3: Getting auth URL...');

    final response = await http.post(
      Uri.parse('${baseUrl}api/v1/fayda/auth'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'clientId': _clientId}),
    );

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
    _authCompleter = Completer<FaydaUserData>();
    return await _authCompleter!.future;
  }

  /// Handle WebSocket messages
  void _handleMessage(dynamic message) async {
    try {
      final data = jsonDecode(message.toString());
      print('📨 WebSocket message: ${data['type']}');

      switch (data['type']) {
        case 'registration_success':
          if (data['clientId'] == _clientId &&
              !_registrationCompleter!.isCompleted) {
            _registrationCompleter!.complete(true);
          }
          break;

        case 'authentication_result':
          print('🎉 Authentication result received!');
          if (data['clientId'] == _clientId && !_authCompleter!.isCompleted) {
            String? savedImagePath;
            final base64Picture = data['data']['picture']?.toString();

            if (base64Picture != null && base64Picture.isNotEmpty) {
              try {
                final decodedBytes = base64Decode(base64Picture);

                final directory = await getApplicationDocumentsDirectory();
                final fileName = '${const Uuid().v4()}.jpg';
                final filePath = '${directory.path}/$fileName';

                final imageFile = File(filePath);
                await imageFile.writeAsBytes(decodedBytes);

                savedImagePath = filePath;
                print('🖼️ Picture saved at: $filePath');
              } catch (e) {
                print('❌ Error saving picture: $e');
              }
            }
            // Parse user data
            final userData = FaydaUserData(
              sub: data['data']['sub']?.toString() ?? '',
              name: data['data']['name']?.toString() ?? '',
              email: 'no-email@example.com', // Default since not provided
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

            print('✅ User: ${userData.name}');
            _authCompleter!.complete(userData);

            // Close WebSocket - operation finished
            print('🔌 Closing WebSocket - operation finished');
            close();
          }
          break;
      }
    } catch (e) {
      print('❌ Error parsing message: $e');
    }
  }

  /// Close WebSocket connection
  void close() {
    _channel?.sink.close();
    _channel = null;
    print('🔌 WebSocket closed');
  }

  /// Check if WebSocket is connected
  bool get isConnected => _channel != null;
}
