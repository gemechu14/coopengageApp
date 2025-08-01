import 'package:coopengageplus/features/onboarding/pages/home/HomePage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:coopengageplus/constants/config/config.dart';
import '../services/websocket_service.dart';

// State class for National ID authentication
class NationalIdState {
  final bool isLoading;
  final bool isError;
  final String? authUrl;
  final String? errorMessage;
  final bool isAuthCompleted;
  final Map<String, dynamic>? authResult;
  final bool useWebSocket;
  final String? clientId;
  final bool isWebSocketConnected;

  const NationalIdState({
    this.isLoading = false,
    this.isError = false,
    this.authUrl,
    this.errorMessage,
    this.isAuthCompleted = false,
    this.authResult,
    this.useWebSocket = true, // Default to WebSocket
    this.clientId,
    this.isWebSocketConnected = false,
  });

  NationalIdState copyWith({
    bool? isLoading,
    bool? isError,
    String? authUrl,
    String? errorMessage,
    bool? isAuthCompleted,
    Map<String, dynamic>? authResult,
    bool? useWebSocket,
    String? clientId,
    bool? isWebSocketConnected,
  }) {
    return NationalIdState(
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      authUrl: authUrl ?? this.authUrl,
      errorMessage: errorMessage ?? this.errorMessage,
      isAuthCompleted: isAuthCompleted ?? this.isAuthCompleted,
      authResult: authResult ?? this.authResult,
      useWebSocket: useWebSocket ?? this.useWebSocket,
      clientId: clientId ?? this.clientId,
      isWebSocketConnected: isWebSocketConnected ?? this.isWebSocketConnected,
    );
  }
}

// Provider for National ID authentication
class NationalIdNotifier extends StateNotifier<NationalIdState> {
  NationalIdNotifier() : super(const NationalIdState());

  // API call for National ID authentication
  Future<void> callEsignetApi() async {
    print('NationalIdProvider: callEsignetApi called');
    try {
      state = state.copyWith(
        isLoading: true,
        isError: false,
        errorMessage: null,
      );

      if (state.useWebSocket) {
        // Use WebSocket-based authentication
        await _callWebSocketAuth();
      } else {
        // Use traditional API authentication
        await _callTraditionalAuth();
      }
    } catch (e) {
      print('NationalIdProvider: Authentication error: $e');
      if (e.toString().contains('SocketException')) {
        // Handle socket exception specifically
      }
      state = state.copyWith(
        isError: true,
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  // WebSocket-based authentication
  Future<void> _callWebSocketAuth() async {
    try {
      print('NationalIdProvider: Starting WebSocket authentication');
      
      // Generate client ID
      final clientId = WebSocketService.generateClientId();
      
      state = state.copyWith(
        clientId: clientId,
        isWebSocketConnected: false,
      );

      // Start WebSocket authentication
      final result = await WebSocketService.authenticate();
      
      state = state.copyWith(
        isAuthCompleted: true,
        authResult: result,
        isLoading: false,
        isWebSocketConnected: true,
      );
      print('NationalIdProvider: WebSocket authentication completed successfully');
    } catch (e) {
      print('NationalIdProvider: WebSocket authentication failed: $e');
      
      // Check if it's a WebSocket connection error
      if (e.toString().contains('WebSocket') || e.toString().contains('Connection')) {
        print('NationalIdProvider: Primary connection failed, falling back to alternative method');
        
        // Automatically fallback to alternative API
        state = state.copyWith(
          useWebSocket: false,
          isLoading: true,
          isError: false,
          errorMessage: null,
        );
        
        try {
          await _callTraditionalAuth();
          return; // Exit early if alternative auth succeeds
        } catch (alternativeError) {
          print('NationalIdProvider: Alternative method also failed: $alternativeError');
          state = state.copyWith(
            isLoading: false,
            isError: true,
            errorMessage: 'Both primary and alternative methods failed. Primary: $e. Alternative: $alternativeError',
          );
          return;
        }
      }
      
      // For other errors, don't fallback
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  // Traditional API authentication
  Future<void> _callTraditionalAuth() async {
    try {
      print('NationalIdProvider: Starting traditional API authentication');
      
      // Construct the API URL
      final String baseUrl = AppConstants.baseURL;
      final apiUrl = '$baseUrl/api/v1/fayda/authenticate-url';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 400));
     
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('url')) {
          final authUrl = responseData['url'];          

          state = state.copyWith(
            authUrl: authUrl,
            isLoading: false,
          );
        } else {
          throw Exception('No URL found in response');
        }
      } else {
        throw Exception('API call failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('NationalIdProvider: Traditional API authentication failed: $e');
      rethrow;
    }
  }

  // Account verification
  Future<Map<String, dynamic>?> verifyAccount(
      String code, String stateParam) async {


    try {
      state = state.copyWith(isLoading: true);
      String? token = await storage.read(key: "token");

      if (token == null) {
        throw Exception("Token not found");
      }

      // Construct the verification URL
      final String baseUrl = AppConstants.baseURL;
      final String verifyUrl =
          '$baseUrl/api/v1/fayda/verify-account?code=$code&state=$stateParam';


      // Make the verification API call
      final response = await http.post(
        Uri.parse(verifyUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

   

      state = state.copyWith(isLoading: false);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('id') ||
            responseData.containsKey('fullName')) {
          state = state.copyWith(
            isAuthCompleted: true,
            authResult: responseData,
          );
    
          return responseData;
        } else {
    
          throw Exception(
              'Verification response missing required fields (id or fullName)');
        }
      } else {
 
        throw Exception(
            'Verification failed with status: ${response.statusCode}');
      }
    } catch (e) {
    
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  void markAuthCompleted() {
    state = state.copyWith(isAuthCompleted: true);
  }

  // Clear auth URL to force showing completion state
  void clearAuthUrl() {
    state = state.copyWith(authUrl: null);
  }

  // Toggle between WebSocket and traditional authentication
  void toggleWebSocketMode() {
    state = state.copyWith(useWebSocket: !state.useWebSocket);
  }

  // Set WebSocket mode explicitly
  void setWebSocketMode(bool useWebSocket) {
    state = state.copyWith(useWebSocket: useWebSocket);
  }

  // Get current authentication mode
  String getAuthenticationMode() {
    return state.useWebSocket ? 'Primary' : 'Alternative';
  }

  // Reset state
  void reset() {
    state = const NationalIdState();
  }
}

// Provider
final nationalIdProvider =
    StateNotifierProvider<NationalIdNotifier, NationalIdState>((ref) {
  return NationalIdNotifier();
});
