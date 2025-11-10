import 'dart:convert';
import 'package:coopengageplus/core/network/network_handler.dart';
import '../model/tin_verification_model.dart';

/// TIN Verification Service
/// Handles API calls for TIN verification
class TinVerificationService {
  final NetworkHandler _networkHandler = NetworkHandler();

  /// Verify TIN number and fetch business details
  /// 
  /// Returns [TinVerificationResponse] if successful
  /// Throws [Exception] if verification fails
  Future<TinVerificationResponse> verifyTinNumber(String tinNumber) async {
    try {
      // Validate TIN number format
      if (tinNumber.isEmpty) {
        throw Exception('TIN number cannot be empty');
      }

      if (tinNumber.length != 10) {
        throw Exception('TIN number must be 10 digits');
      }

      // API endpoint
      final url = '/api/v1/services/tin-number/$tinNumber';
      
      print('TIN Verification: Calling API for TIN: $tinNumber');

      // Make API call
      final response = await _networkHandler.fetchData(url);

      print('TIN Verification: Response status: ${response.statusCode}');

      // Check response status
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('TIN Verification: Success - Business Name: ${data['businessName']}');
        
        return TinVerificationResponse.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('TIN number not found');
      } else if (response.statusCode == 400) {
        throw Exception('Invalid TIN number format');
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Unauthorized access');
      } else {
        throw Exception('Failed to verify TIN: ${response.statusCode}');
      }
    } catch (e) {
      print('TIN Verification Error: $e');
      
      // Re-throw with user-friendly message
      if (e.toString().contains('SocketException') || 
          e.toString().contains('NetworkException')) {
        throw Exception('Network error. Please check your internet connection.');
      }
      
      rethrow;
    }
  }
}

