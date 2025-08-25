import 'package:coopengageplus/features/onboarding/pages/home/HomePage.dart';
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
  Future<void> callEsignetApi([String? clientId]) async {
    print('NationalIdProvider: callEsignetApi called with clientId: $clientId');
    try {
      state = state.copyWith(
        isLoading: true,
        isError: false,
        errorMessage: null,
      );
// Get token from storage
      final token = await storage.read(key: "token");

      print("dkfkdfdkfkjdkjfkdjdkfjdkj");
      print(token);
      // Construct the API URL
      final String baseUrl = AppConstants.baseURL;
      final String actualClientId =
          clientId ?? '12344'; // fallback to default if not provided

      final apiUrl =
          '$baseUrl/api/v1/fayda/authenticate-url-ws?clientId=$actualClientId';

      print('NationalIdProvider: Calling API URL: $apiUrl');

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Add token here
        },
      ).timeout(const Duration(seconds: 400));

      print('NationalIdProvider: Response status: ${response.statusCode}');
      print('NationalIdProvider: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('url')) {
          final authUrl = responseData['url'];
          print('NationalIdProvider: Extracted auth URL: $authUrl');

          state = state.copyWith(
            authUrl: authUrl,
            isLoading: false,
          );
        } else {
          print(
              'NationalIdProvider: No URL found in response data: $responseData');
          throw Exception('No URL found in response');
        }
      } else {
        print(
            'NationalIdProvider: API call failed with status: ${response.statusCode}');
        throw Exception('API call failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('NationalIdProvider: Error in callEsignetApi: $e');
      if (e.toString().contains('SocketException')) {}
      state = state.copyWith(
        isError: true,
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  // // Account verification
  // Future<Map<String, dynamic>?> verifyAccount(
  //     String code, String stateParam) async {
  //   try {
  //     state = state.copyWith(isLoading: true);
  //     String? token = await storage.read(key: "token");

  //     if (token == null) {
  //       throw Exception("Token not found");
  //     }

  //     // Construct the verification URL
  //     final String baseUrl = AppConstants.baseURL;
  //     final String verifyUrl =
  //         // '$baseUrl/api/v1/fayda/verify-account?code=$code&state=$stateParam';
  //         '$baseUrl/api/v1/fayda/get-verify-account-info?code=$code&state=$stateParam';

  //     // Make the verification API call
  //     final response = await http.post(
  //       Uri.parse(verifyUrl),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token'
  //       },
  //     );

  //     state = state.copyWith(isLoading: false);

  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> responseData = json.decode(response.body);
  //       // Map new response fields to old expected fields
  //       final Map<String, dynamic> mappedData =
  //           Map<String, dynamic>.from(responseData);
  //       if (responseData.containsKey('phone_number')) {
  //         mappedData['phone'] = responseData['phone_number'];
  //       }
  //       if (responseData.containsKey('gender')) {
  //         mappedData['sex'] = responseData['gender'];
  //       }
  //       if (responseData.containsKey('birthdate')) {
  //         mappedData['dateOfBirth'] = responseData['birthdate'];
  //       }
  //       if (responseData.containsKey('name')) {
  //         mappedData['fullName'] = responseData['name'];
  //       }
  //       if (responseData.containsKey('sub')) {
  //         mappedData['legalId'] = responseData['sub'];
  //       }

  //       ///

  //       // ✅ Map nested address fields
  //       if (responseData.containsKey('address') &&
  //           responseData['address'] is Map) {
  //         final address = responseData['address'] as Map<String, dynamic>;

  //         if (address.containsKey('country')) {
  //           mappedData['country'] = address['country'];
  //         }
  //         if (address.containsKey('region')) {
  //           mappedData['state'] = address[
  //               'region']; // Assuming "region" maps to your "state" field
  //         }
  //       }

  //       ///

  //       if (mappedData.containsKey('id') ||
  //           mappedData.containsKey('fullName')) {
  //         state = state.copyWith(
  //           isAuthCompleted: true,
  //           authResult: mappedData,
  //         );
  //         return mappedData;
  //       } else {
  //         throw Exception(
  //             'Verification response missing required fields (id or fullName)');
  //       }
  //     } else {
  //       throw Exception(
  //           'Verification failed with status: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     state = state.copyWith(
  //       isLoading: false,
  //       isError: true,
  //       errorMessage: e.toString(),
  //     );
  //     rethrow;
  //   }
  // }

  void markAuthCompleted() {
    state = state.copyWith(isAuthCompleted: true);
  }

  // Clear auth URL to force showing completion state
  void clearAuthUrl() {
    state = state.copyWith(authUrl: null);
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
