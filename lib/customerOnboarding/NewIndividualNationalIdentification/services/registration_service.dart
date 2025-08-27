// // import 'package:coopengageplus/features/onboarding/corporateCustomer/update/corporate_account_riverpod.dart';
// import 'package:coopengageplus/features/onboarding/pages/home/HomePage.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:coopengageplus/constants/config/config.dart';

// class RegistrationService {
//   static const String baseUrl = AppConstants.baseURL;

//   Future<Map<String, dynamic>> submitRegistration({
//     required String accountType,
//     required String initialDeposit,
//     required String branch,
//     required String motherName,
//     required String state,
//     required String documentName,
//     required String phone,
//     required String fullName,
//     required String Sex,
//     String? title,
//     required String customerInfoInitialDeposit,
//     Uint8List? signature,
//     String? email,
//     String? dateOfBirth,
//     String? country,
//     String? zoneSubCity,
//     String? streetAddress,
//     String? photo,
//   }) async {
//     print("dfkdfdkfhdhkfdkhkdfk");
//     print(photo);
//     try {
//       String? token = await storage.read(key: "token");

//       if (token == null) {
//         throw Exception("Token not found");
//       }

//       print(token);
//       // Create multipart request
//       final request = http.MultipartRequest(
//         'POST',
//         Uri.parse('$baseUrl/api/v1/accounts/individual'),
//       );

//       request.headers['Authorization'] = 'Bearer $token';

//       // Add form fields
//       request.fields['accountType'] = accountType;
//       request.fields['initialdeposit'] = initialDeposit;
//       request.fields['branch'] = branch;
//       request.fields['customerInfo.state'] = state;
//       request.fields['customerInfo.initialdeposit'] =
//           customerInfoInitialDeposit;
//       request.fields['customerInfo.motherName'] = motherName;
//       request.fields['customerInfo.phone'] = phone;
//       request.fields['customerInfo.fullName'] = fullName;
//       request.fields['customerInfo.sex'] = Sex;
//       request.fields['customerInfo.title'] = title ?? '';
//       request.fields['customerInfo.email'] = email ?? '';
//       request.fields['customerInfo.dateOfBirth'] = dateOfBirth ?? '';
//       request.fields['customerInfo.country'] = country ?? '';
//       request.fields['customerInfo.zoneSubCity'] = zoneSubCity ?? '';
//       request.fields['customerInfo.streetAddress'] = streetAddress ?? '';

//       // Add signature file if available
//       if (signature != null) {
//         // Create a temporary file for the signature
//         final tempDir = Directory.systemTemp;
//         final tempFile = File('${tempDir.path}/signature.png');
//         await tempFile.writeAsBytes(signature);

//         request.files.add(
//           await http.MultipartFile.fromPath(
//             'customerInfo.signature',
//             tempFile.path,
//           ),
//         );
//       }

//       // Add photo file if available
//       if (photo != null && photo.isNotEmpty) {
//         final photoFile = File(photo);
//         if (await photoFile.exists()) {
//           request.files.add(
//             await http.MultipartFile.fromPath(
//               'customerInfo.photo',
//               photoFile.path,
//             ),
//           );
//         }
//       }

//       // Send the request
//       final response = await request.send();
//       final responseBody = await response.stream.bytesToString();

//       print('Response status: ${response.statusCode}');
//       print('Response body: $responseBody');

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return json.decode(responseBody);
//       } else {
//         throw Exception(
//             'Registration failed with status: ${response.statusCode}. Response: $responseBody');
//       }
//     } catch (e) {
//       print('Error submitting registration: $e');
//       rethrow;
//     }
//   }
// }

import 'package:coopengageplus/features/onboarding/pages/home/HomePage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:coopengageplus/constants/config/config.dart';
import 'package:intl/intl.dart';

class RegistrationService {
  static const String baseUrl = AppConstants.baseURL;

  Future<Map<String, dynamic>> submitRegistration(
      {required String accountType,
      required String initialDeposit,
      required String branch,
      required String motherName,
      required String state,
      required String documentName,
      required String phone,
      required String fullName,
      required String Sex,
      String? title,
      required String customerInfoInitialDeposit,
      Uint8List? signature,
      String? email,
      String? dateOfBirth,
      String? country,
      String? zoneSubCity,
      String? streetAddress,
      String? photo,
      String? legalId}) async {
    print("dfkdfdkfhdhkfdkhkdfk");
    print(photo);
    try {
      String? token = await storage.read(key: "token");

      if (token == null) {
        throw Exception("Token not found");
      }

      print(token);
      print("dfhkdfhdkfdkdkfhkdkhdkhdkhfkhdhkfkd");
      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/v1/accounts/individual'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // Add form fields
      request.fields['accountType'] = accountType;
      request.fields['initialdeposit'] = initialDeposit;
      request.fields['branch'] = branch;
      request.fields['customerInfo.state'] = state;
      request.fields['customerInfo.initialdeposit'] =
          customerInfoInitialDeposit;
      request.fields['customerInfo.phone'] = phone;
      request.fields['customerInfo.fullName'] = fullName;
      request.fields['customerInfo.sex'] = Sex;
      request.fields['customerInfo.email'] = email ?? '';
      request.fields['customerInfo.country'] = country ?? '';
      request.fields['customerInfo.zoneSubCity'] = zoneSubCity ?? '';
      request.fields['customerInfo.streetAddress'] = streetAddress ?? '';
      request.fields['customerInfo.title'] = title ?? '';
      request.fields['customerInfo.legalId'] = legalId ?? '';
      request.fields['customerInfo.motherName'] = motherName ?? '';

      // Format dateOfBirth to yyyy-MM-dd
      if (dateOfBirth != null && dateOfBirth.isNotEmpty) {
        try {
          // Replace slashes with dashes if needed and parse
          DateTime parsedDate =
              DateTime.parse(dateOfBirth.replaceAll('/', '-'));
          String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
          request.fields['customerInfo.dateOfBirth'] = formattedDate;
        } catch (e) {
          throw Exception("Invalid date format for dateOfBirth: $dateOfBirth");
        }
      } else {
        request.fields['customerInfo.dateOfBirth'] = '';
      }

      // Add signature file if available
      // if (signature != null) {
      //   print("Processing signature");
      //   try {
      //     final tempDir = Directory.systemTemp;
      //     final tempFile = File('${tempDir.path}/signature.png');
      //     await tempFile.writeAsBytes(signature);

      //     // Check signature file size
      //     final fileSize = await tempFile.length();
      //     final fileSizeKB = fileSize / 1024;
      //     print("Signature file size: ${fileSizeKB.toStringAsFixed(2)} KB");

      //     // Check if signature is too large (common limit is 5MB)
      //     if (fileSizeKB > 5120) {
      //       print("Warning: Signature file is very large (${fileSizeKB.toStringAsFixed(2)} KB)");
      //       print("This might cause server issues");
      //     }

      //     request.files.add(
      //       await http.MultipartFile.fromPath(
      //         'customerInfo.signature',
      //         tempFile.path,
      //         filename: 'signature.png',
      //       ),
      //     );
      //     print("Signature added successfully to request");
      //   } catch (e) {
      //     print("Error adding signature to request: $e");
      //     throw Exception("Failed to add signature to request: $e");
      //   }
      // } else {
      //   print("No signature provided");
      // }

      // // Add photo file if available
      // if (photo != null && photo.isNotEmpty) {
      //   print("Processing photo: $photo");
      //   final photoFile = File(photo);

      //   if (await photoFile.exists()) {
      //     print("Photo file exists, adding to request");

      //     // Check file size
      //     final fileSize = await photoFile.length();
      //     final fileSizeMB = fileSize / (1024 * 1024);
      //     print("Photo file size: ${fileSizeMB.toStringAsFixed(2)} MB");

      //     // Check if file is too large (common limit is 10MB)
      //     if (fileSizeMB > 10) {
      //       print("Warning: Photo file is very large (${fileSizeMB.toStringAsFixed(2)} MB)");
      //       print("This might cause server issues");
      //     }

      //     try {
      //       request.files.add(
      //         await http.MultipartFile.fromPath(
      //           'customerInfo.photo',
      //           photoFile.path,
      //           filename: photoFile.path.split('/').last, // Use original filename
      //         ),
      //       );
      //       print("Photo added successfully to request");
      //     } catch (e) {
      //       print("Error adding photo to request: $e");
      //       throw Exception("Failed to add photo to request: $e");
      //     }
      //   } else {
      //     print("Warning: Photo file does not exist at path: $photo");
      //   }
      // } else {
      //   print("No photo provided or photo path is empty");
      // }

      // Log request details before sending
      print("=== REQUEST DETAILS ===");
      print("Fields count: ${request.fields.length}");
      print("Files count: ${request.files.length}");
      print("Fields: ${request.fields}");
      print(
          "Files: ${request.files.map((f) => '${f.field}: ${f.filename}').toList()}");

      // Additional file debugging
      for (var file in request.files) {
        print("File: ${file.field} - ${file.filename} - ${file.length} bytes");
      }

      print("=== END REQUEST DETAILS ===");

      // Verify files are added
      if (request.files.isEmpty) {
        print("⚠️ WARNING: No files added to request!");
        if (signature != null)
          print("   - Signature data exists but not added");
        if (photo != null && photo.isNotEmpty)
          print("   - Photo path exists but not added");
      } else {
        print("✅ Files successfully added to request");
      }

      // Send the request
      print("Sending request with timeout...");
      final response = await request.send().timeout(
        const Duration(seconds: 120), // 2 minutes timeout
        onTimeout: () {
          throw Exception("Request timed out after 120 seconds");
        },
      );
      final responseBody = await response.stream.bytesToString();

      print('Response status: ${response.statusCode}');
      print('Response body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(responseBody);
      } else {
        throw Exception(
          'Registration failed with status: ${response.statusCode}. Response: $responseBody',
        );
      }
    } catch (e) {
      print(e.toString());
      print('Error submitting registration: $e');
      rethrow;
    }
  }
}
