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
    String? title,
    required String customerInfoInitialDeposit,
    Uint8List? signature,
  }) async {
    try {
      String? token = await storage.read(key: "token");

      if (token == null) {
        throw Exception("Token not found");
      }

      print(token);
      // Create multipart request
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/api/v1/accounts/individual/$authId'),
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

  Future<Map<String, dynamic>> submitJointRegistration({
    required List<Map<String, dynamic>> members,
    required Map<String, String> otherFields,
    required List<Uint8List?>
        signatures, // Each member's signature as Uint8List (nullable)
  }) async {
    try {
      String? token = await storage.read(key: "token");
      if (token == null) {
        throw Exception("Token not found");
      }

     
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/v1/accounts/joint'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      // Add member fields
      for (int i = 0; i < members.length; i++) {
        final member = members[i];
        member.forEach((key, value) {
          if (value != null) {
            request.fields['customers[$i].$key'] = value.toString();
          }
        });
        // Attach signature as file if available
        if (signatures.length > i && signatures[i] != null) {
          final tempDir = Directory.systemTemp;
          final tempFile = File('${tempDir.path}/signature_$i.png');
          await tempFile.writeAsBytes(signatures[i]!);
          request.files.add(
            await http.MultipartFile.fromPath(
              'customers[$i].signature',
              tempFile.path,
            ),
          );
        }
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
        print('\u001b[34m${f.field}: ${f.filename} (${f.length} bytes)\u001b[0m');
      }
      print('===========================================');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(responseBody);
      } else {
        throw Exception(
            'Registration failed with status: \\${response.statusCode}. Response: \\${responseBody}');
      }
    } catch (e) {
      print('Error submitting joint registration: $e');
      rethrow;
    }
  }
}
