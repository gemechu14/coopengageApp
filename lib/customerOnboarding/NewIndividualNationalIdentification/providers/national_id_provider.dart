import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:coopengageplus/constants/config/config.dart';
import '../services/websocket_service.dart';
import 'package:coopengageplus/features/onboarding/pages/home/HomePage.dart';

// State class for National ID authentication
class NationalIdState {
  final bool isLoading;
  final bool isError;
  final String? authUrl;
  final String? errorMessage;
  final bool isAuthCompleted;
  final Map<String, dynamic>? authResult;
  final String? clientId;
  final bool isWebSocketConnected;

  const NationalIdState({
    this.isLoading = false,
    this.isError = false,
    this.authUrl,
    this.errorMessage,
    this.isAuthCompleted = false,
    this.authResult,
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

      // Use WebSocket-based authentication
      await _callWebSocketAuth();
    } catch (e) {
      print('NationalIdProvider: Authentication error: $e');
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
      
      // Reset WebSocket state to start fresh
      WebSocketService.resetAuthentication();
      
      // Use the same clientId as WebSocket service
      final clientId = "12344"; // Use consistent clientId
      
      state = state.copyWith(
        clientId: clientId,
        isWebSocketConnected: false,
      );

      // Initialize WebSocket and get authentication URL
      final authUrl = await WebSocketService.initializeAuthentication();
      
      state = state.copyWith(
        authUrl: authUrl,
        isLoading: false,
        isWebSocketConnected: true,
      );
      print('NationalIdProvider: WebSocket authentication URL received: $authUrl');
    } catch (e) {
      print('NationalIdProvider: WebSocket authentication failed: $e');
      
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: e.toString(),
      );
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



  // Reset state
  void reset() {
    // Reset WebSocket state
    // WebSocketService.resetAuthentication();
    state = const NationalIdState();
  }
}

// Provider
final nationalIdProvider =
    StateNotifierProvider<NationalIdNotifier, NationalIdState>((ref) {
  return NationalIdNotifier();
});
