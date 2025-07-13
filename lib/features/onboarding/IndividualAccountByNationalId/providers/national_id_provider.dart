import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:coopengageplus/constants/config/config.dart';

// State class for National ID authentication
class NationalIdState {
  final bool isLoading;
  final bool isError;
  final String? authUrl;
  final String? errorMessage;
  final bool isAuthCompleted;
  final Map<String, dynamic>? authResult;

  const NationalIdState({
    this.isLoading = false,
    this.isError = false,
    this.authUrl,
    this.errorMessage,
    this.isAuthCompleted = false,
    this.authResult,
  });

  NationalIdState copyWith({
    bool? isLoading,
    bool? isError,
    String? authUrl,
    String? errorMessage,
    bool? isAuthCompleted,
    Map<String, dynamic>? authResult,
  }) {
    return NationalIdState(
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      authUrl: authUrl ?? this.authUrl,
      errorMessage: errorMessage ?? this.errorMessage,
      isAuthCompleted: isAuthCompleted ?? this.isAuthCompleted,
      authResult: authResult ?? this.authResult,
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
      print('NationalIdProvider: State updated to loading');

      // Construct the API URL
      final String baseUrl = AppConstants.baseURL;
      final apiUrl = '$baseUrl/api/v1/fayda/authenticate-url';

      print('NationalIdProvider: Base URL: $baseUrl');
      print('NationalIdProvider: Full API URL: $apiUrl');

      // Make the API call
      print('NationalIdProvider: Making HTTP request to: $apiUrl');
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 400));
      print('NationalIdProvider: HTTP request completed');

      print('NationalIdProvider: Response status: ${response.statusCode}');
      print('NationalIdProvider: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('NationalIdProvider: Response data: $responseData');

        if (responseData.containsKey('url')) {
          final authUrl = responseData['url'];
          print('NationalIdProvider: Auth URL from response: $authUrl');
          
          state = state.copyWith(
            authUrl: authUrl,
            isLoading: false,
          );
          print('NationalIdProvider: Auth URL stored in state: ${state.authUrl}');
        } else {
          print('NationalIdProvider: No URL found in response');
          print('NationalIdProvider: Available keys in response: ${responseData.keys.toList()}');
          throw Exception('No URL found in response');
        }
      } else {
        print('NationalIdProvider: API call failed with status: ${response.statusCode}');
        print('NationalIdProvider: Error response body: ${response.body}');
        throw Exception('API call failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('NationalIdProvider: Error calling API: $e');
      print('NationalIdProvider: Error type: ${e.runtimeType}');
      if (e.toString().contains('SocketException')) {
        print('NationalIdProvider: Network connection error');
      }
      state = state.copyWith(
        isError: true,
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  // Account verification
  Future<Map<String, dynamic>?> verifyAccount(String code, String stateParam) async {
    print('NationalIdProvider: verifyAccount called');
    print('NationalIdProvider: Code: $code');
    print('NationalIdProvider: State: $stateParam');
    
    try {
      state = state.copyWith(isLoading: true);

      // Construct the verification URL
      final String baseUrl = AppConstants.baseURL;
      final String verifyUrl =
          '$baseUrl/api/v1/fayda/verify-account?code=$code&state=$stateParam';

      print('NationalIdProvider: Calling verification API: $verifyUrl');

      // Make the verification API call
      print('NationalIdProvider: Making HTTP POST request...');
      final response = await http.post(
        Uri.parse(verifyUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('NationalIdProvider: Verification response status: ${response.statusCode}');
      print('NationalIdProvider: Verification response body: ${response.body}');

      state = state.copyWith(isLoading: false);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('NationalIdProvider: Verification successful, response data: $responseData');
        
        // Validate that the response contains required fields
        if (responseData.containsKey('id') || responseData.containsKey('fullName')) {
          // Mark authentication as completed and store the result
          state = state.copyWith(
            isAuthCompleted: true,
            authResult: responseData,
          );
          print('NationalIdProvider: State updated - isAuthCompleted: true');
          print('NationalIdProvider: Auth result stored: ${state.authResult}');
          return responseData;
        } else {
          print('NationalIdProvider: Verification response missing required fields');
          print('NationalIdProvider: Available fields: ${responseData.keys.toList()}');
          throw Exception('Verification response missing required fields (id or fullName)');
        }
      } else {
        print('NationalIdProvider: Verification failed with status: ${response.statusCode}');
        print('NationalIdProvider: Error response body: ${response.body}');
        throw Exception(
            'Verification failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('NationalIdProvider: Error verifying account: $e');
      print('NationalIdProvider: Error type: ${e.runtimeType}');
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  // Mark authentication as completed
  void markAuthCompleted() {
    state = state.copyWith(isAuthCompleted: true);
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