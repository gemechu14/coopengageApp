import 'package:coopengageplus/features/onboarding/pages/home/HomePage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:coopengageplus/core/config/config.dart';
import 'package:flutter/material.dart';
import 'package:coopengageplus/shared/services/token_service.dart';
import 'package:http_parser/http_parser.dart';

class RegistrationService {
  static const String baseUrl = AppConstants.baseURL;

  /// Handle token expiration and session timeout
  Future<void> _handleTokenExpiration(
      BuildContext? context, String errorMessage) async {
    print('RegistrationService: Token expired - $errorMessage');

    try {
      // Clear stored token
      await storage.delete(key: "token");
      await storage.delete(key: "username");
      await storage.delete(key: "role");
      await storage.delete(key: "userId");

      print('RegistrationService: Cleared stored credentials');

      // Show session expired message if context is available
      if (context != null) {
        // Show snackbar or dialog about session expiration
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.warning, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Your session has expired. Please login again.'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Login',
              textColor: Colors.white,
              onPressed: () {
                // Navigate to login screen
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login', // Adjust this route name as needed
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ),
        );

        // Wait a moment for user to see the message
        await Future.delayed(Duration(seconds: 2));

        // Force logout and redirect to login
        await TokenService.forceLogoutWithContext(context);
      } else {
        // If no context, just clear data and let the app handle it
        print('RegistrationService: No context available, clearing data only');
      }
    } catch (e) {
      print('RegistrationService: Error handling token expiration: $e');
    }
  }

  /// Check if token is valid before making requests
  Future<bool> _isTokenValid() async {
    try {
      final token = await storage.read(key: "token");
      if (token == null || token.isEmpty) {
        return false;
      }

      // Use TokenService to check validity
      return await TokenService.isTokenValid();
    } catch (e) {
      print('RegistrationService: Error checking token validity: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> submitRegistration({
    required String authId,
    required String accountType,
    required String initialDeposit,
    required String branch,
    required String motherName,
    required String state,
    required String documentName,
    String? title,
    required String customerInfoInitialDeposit,
    Uint8List? signature,
    BuildContext? context, // Add context parameter for error handling
  }) async {
    try {
      // Check token validity first
      if (!await _isTokenValid()) {
        print('RegistrationService: Token is invalid, handling expiration');
        await _handleTokenExpiration(context, 'Token is invalid or expired');
        throw Exception('Session expired. Please login again.');
      }

      String? token = await storage.read(key: "token");

      if (token == null) {
        throw Exception("Token not found");
      }

      print(token);
      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/v1/accounts/individual'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // Add form fields
      request.fields['customerInfo.state'] = state;
      request.fields['customerInfo.initialdeposit'] =
          customerInfoInitialDeposit;
      // request.fields['customerInfo.documentName'] = "NATIONAILID";
      request.fields['customerInfo.motherName'] = motherName;
      request.fields['accountType'] = accountType;
      request.fields['initialdeposit'] = initialDeposit;
      request.fields['branch'] = branch;
      request.fields['title'] = title!;

      // Add signature file if available
      // if (signature != null) {
      //   // Create a temporary file for the signature
      //   final tempDir = Directory.systemTemp;
      //   final tempFile = File('${tempDir.path}/signature.png');
      //   await tempFile.writeAsBytes(signature);

      //   request.files.add(
      //     await http.MultipartFile.fromPath(
      //       'customerInfo.signature',
      //       tempFile.path,
      //     ),
      //   );
      // }

      // Send the request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Response status: ${response.statusCode}');
      print('Response body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(responseBody);
      } else {
        // Check for token expiration
        if (response.statusCode == 401) {
          final responseData = json.decode(responseBody);
          final errorMessage = responseData['error_message'] ?? 'Token expired';

          if (errorMessage.toString().toLowerCase().contains('token') &&
              (errorMessage.toString().toLowerCase().contains('expired') ||
                  errorMessage.toString().toLowerCase().contains('invalid'))) {
            print(
                'RegistrationService: Token expired detected in submitRegistration');
            await _handleTokenExpiration(context, errorMessage);
            throw Exception('Session expired. Please login again.');
          }
        }

        throw Exception(
            'Registration failed with status: ${response.statusCode}. Response: $responseBody');
      }
    } catch (e) {
      print('Error submitting registration: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> submitJointRegistration({
    required List<Map<String, dynamic>> members,
    required Map<String, String> otherFields,
    required List<Uint8List?>
        signatures, // Each member's signature as Uint8List (nullable)
    BuildContext? context, // Add context parameter for error handling
  }) async {
    try {
      print("BultidddddfdfdfdfdfdfdfBultidddddfdfdfdfdfdfdfBultidddddfdfdfdfdfdfdf");

      print(members);
      // Check token validity first
      if (!await _isTokenValid()) {
        print('RegistrationService: Token is invalid, handling expiration');
        await _handleTokenExpiration(context, 'Token is invalid or expired');
        throw Exception('Session expired. Please login again.');
      }

      String? token = await storage.read(key: "token");
      if (token == null) {
        throw Exception("Token not found");
      }

      print("Gemechu Bultidddddfdfdfdfdfdfdf");

      print(members);
      print(token);
      print("Members");
      print(members);
      print("others");
      print(otherFields);
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/v1/accounts/joint'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      // Add member fields
      for (int i = 0; i < members.length; i++) {
        final member = members[i];
        // member.forEach((key, value) {
        //   if (value != null) {
        //     request.fields['customers[$i].$key'] = value.toString();
        //   }
        // });

        // 1. Add all regular fields except photo & signature
        member.forEach((key, value) {
          if (value != null && key != 'photo' && key != 'signature') {
            request.fields['customers[$i].$key'] = value.toString();
          }
        });

// Attach signature if available
        if (signatures.length > i && signatures[i] != null) {
          final tempDir = Directory.systemTemp;
          final tempFile = File('${tempDir.path}/signature_$i.png');
          await tempFile.writeAsBytes(signatures[i]!);
          request.files.add(
            await http.MultipartFile.fromPath(
              'customers[$i].signature',
              tempFile.path,
              contentType: MediaType('image', 'png'),
            ),
          );
        }

        // Attach photo if available
        final photoData = member['photo'] as String?;
        if (photoData != null) {
          // Strip any data URL prefix
          final base64Str =
              photoData.contains(',') ? photoData.split(',').last : photoData;
          final bytes = base64Decode(base64Str);

          // Write to temp PNG file
          final tempFile = File('${Directory.systemTemp.path}/photo_$i.png');
          await tempFile.writeAsBytes(bytes);

          // Attach only as file
          request.files.add(
            await http.MultipartFile.fromPath(
              'customers[$i].photo', // make sure this matches the backend exactly
              tempFile.path,
              contentType: MediaType('image', 'png'),
            ),
          );
        }
        // // Attach signature as file if available
        // if (signatures.length > i && signatures[i] != null) {
        //   final tempDir = Directory.systemTemp;
        //   final tempFile = File('${tempDir.path}/signature_$i.png');
        //   await tempFile.writeAsBytes(signatures[i]!);
        //   request.files.add(
        //     await http.MultipartFile.fromPath(
        //       'customers[$i].signature',
        //       tempFile.path,
        //     ),
        //   );
        // }
      }
      // Add other fields (branch, currency, etc)
      otherFields.forEach((key, value) {
        request.fields[key] = value;
      });

      // Debug print: log all fields and files before sending
      print('==== Joint Registration Request Fields ====');
      request.fields.forEach((k, v) => print(' [32m$k: $v [0m'));
      print('==== Joint Registration Request Files ====');
      for (final f in request.files) {
        print(
            '\u001b[34m${f.field}: ${f.filename} (${f.length} bytes)\u001b[0m');
      }
      print('===========================================');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200 || response.statusCode == 201) {
        
        return json.decode(responseBody);
      } else {
        // Check for token expiration
        if (response.statusCode == 401) {
          final responseData = json.decode(responseBody);
          final errorMessage = responseData['error_message'] ?? 'Token expired';

          if (errorMessage.toString().toLowerCase().contains('token') &&
              (errorMessage.toString().toLowerCase().contains('expired') ||
                  errorMessage.toString().toLowerCase().contains('invalid'))) {
            print(
                'RegistrationService: Token expired detected in submitJointRegistration');
            await _handleTokenExpiration(context, errorMessage);
            throw Exception('Session expired. Please login again.');
          }
        }

        throw Exception(
            'Registration failed with status: ${response.statusCode}. Response: ${responseBody}');
      }
    } catch (e) {
      print('Error submitting joint registration: $e');
      rethrow;
    }
  }
}
