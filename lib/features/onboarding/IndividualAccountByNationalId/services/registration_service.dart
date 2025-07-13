import 'package:coopengageplus/features/onboarding/pages/home/HomePage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:coopengageplus/constants/config/config.dart';

class RegistrationService {
  static const String baseUrl = AppConstants.baseURL;

  Future<Map<String, dynamic>> submitRegistration({
    required String authId,
    required String accountType,
    required String initialDeposit,
    required String branch,
    required String motherName,
    required String state,
    required String documentName,
    required String customerInfoInitialDeposit,
    Uint8List? signature,
  }) async {
    try {
      String? token = await storage.read(key: "token");

      if (token == null) {
        throw Exception("Token not found");
      }

      print("tokecn");
      print(token);
      // Create multipart request
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/api/v1/accounts/individual/$authId'),
      );

      // Add headers
      request.headers['Authorization'] = '$token'; // Replace with actual token

      // Add form fields
      request.fields['customerInfo.state'] = state;
      request.fields['customerInfo.initialdeposit'] =
          customerInfoInitialDeposit;
      request.fields['customerInfo.documentName'] = documentName;
      request.fields['customerInfo.motherName'] = motherName;
      request.fields['accountType'] = accountType;
      request.fields['initialdeposit'] = initialDeposit;
      request.fields['branch'] = branch;

      // Add signature file if available
      if (signature != null) {
        // Create a temporary file for the signature
        final tempDir = Directory.systemTemp;
        final tempFile = File('${tempDir.path}/signature.png');
        await tempFile.writeAsBytes(signature);

        request.files.add(
          await http.MultipartFile.fromPath(
            'customerInfo.signature',
            tempFile.path,
          ),
        );
      }

      // Send the request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Response status: ${response.statusCode}');
      print('Response body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(responseBody);
      } else {
        throw Exception(
            'Registration failed with status: ${response.statusCode}. Response: $responseBody');
      }
    } catch (e) {
      print('Error submitting registration: $e');
      rethrow;
    }
  }
}
