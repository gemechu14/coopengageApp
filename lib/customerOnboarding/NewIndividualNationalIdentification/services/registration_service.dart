// }

import 'package:coopengageplus/features/onboarding/pages/home/HomePage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:coopengageplus/constants/config/config.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

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
      String? legalId,
      required String issueAuthority,
      required String expirayDate,
      required String issueDate}) async {
    print("dfkdfdkfhdhkfdkhkdddfddfdfdfddfk");
    print(photo);
    try {
      String? token = await storage.read(key: "token");

      if (token == null) {
        throw Exception("Token not found");
      }

      print(token);
      print(expirayDate);
      print(initialDeposit);
      print("dfhkdfhdkfdkdkfhkdkhdkhdffdfdfdfkhfkhdhkfkd");
      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/v1/accounts/individual'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // Add form fields
      request.fields['accountType'] = accountType;
      request.fields['initialDeposit'] = initialDeposit;
      request.fields['branch'] = branch;
      request.fields['customerInfo.state'] = state;
      request.fields['customerInfo.initialdeposit'] = initialDeposit;
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

      request.fields['customerInfo.issueDate'] = issueDate ?? '';
      request.fields['customerInfo.issueAuthority'] = issueAuthority ?? 'ET';
      request.fields['customerInfo.expiryDate'] = expirayDate ?? '';

      request.fields['customerInfo.documentName'] = 'NATIONALID';

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

      print("photooo ");
      print(photo);
      print("signatladdfdkfjkdkfkd");
      print(signature);

      if (signature != null && signature is Uint8List) {
        try {
          final appDir = await getApplicationDocumentsDirectory();

          // Save as PNG
          final pngPath = '${appDir.path}/signature.png';
          final pngFile = File(pngPath);
          await pngFile.writeAsBytes(signature);

          // Upload PNG by default
          request.files.add(
            await http.MultipartFile.fromPath(
              'customerInfo.signature',
              pngFile.path,
              filename: 'signature.png',
              contentType: MediaType('image', 'png'),
            ),
          );

          print("✅ Signature uploaded as PNG");

          // --- If backend only accepts JPG, also create JPG version ---
          final decoded = img.decodeImage(signature);
          if (decoded != null) {
            final jpgBytes = img.encodeJpg(decoded, quality: 90);
            final jpgPath = '${appDir.path}/signature.jpg';
            final jpgFile = File(jpgPath);
            await jpgFile.writeAsBytes(jpgBytes);
          }
        } catch (e) {
          print("❌ Error saving signature: $e");
        }
      }
      if (photo != null && photo.isNotEmpty) {
        final photoFile = File(photo);
        if (await photoFile.exists()) {
          final mediaType = _getMediaType(photoFile.path);
          request.files.add(
            await http.MultipartFile.fromPath(
              'customerInfo.photo',
              photoFile.path,
              filename: photoFile.path.split('/').last,
              contentType: mediaType,
            ),
          );
          print("✅ Photo added successfully");
        } else {
          print("⚠️ Photo file not found: $photo");
        }
      }

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
        print("dfjkdjfdkfjkdkjfjdkfjieeireirieirieirieirieir");
        // print(responseBody);
        var decoded = json.decode(responseBody);
        // print(decoded['accountNumber']);
        print('Full Name: ${decoded['fullName']}');
        print('Phone: ${decoded['phone']}');
        print('Account Number: ${decoded['accountNumber']}');
        print('Branch: ${decoded['branch']}');
        print('Currency: ${decoded['IssuedAuthorithy']}');
        return json.decode(responseBody);
      } else {
        try {
          final errorData = json.decode(responseBody);
          print(errorData);
          // Try to extract backend-provided message
          final errorMessage = errorData['message'] ??
              errorData['error_message'] ??
              errorData['detail'] ??
              'Unknown server error occurred';
          throw Exception(errorMessage);
        } catch (decodeError) {
          // If response isn’t JSON, fallback to extract readable text
          final regex = RegExp(r'"error_message"\s*:\s*"([^"]+)"');
          final match = regex.firstMatch(responseBody);
          final extractedMessage = match != null
              ? match.group(1)
              : 'Registration failed (${response.statusCode}): $responseBody';
          throw Exception(extractedMessage);
        }
      }
    } catch (e) {
      print(e.toString());
      print('Error submitting registration: $e');
      rethrow;
    }
  }

  MediaType _getMediaType(String filePath) {
    final ext = filePath.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'pdf':
        return MediaType('application', 'pdf');
      case 'doc':
        return MediaType('application', 'msword');
      case 'docx':
        return MediaType('application',
            'vnd.openxmlformats-officedocument.wordprocessingml.document');
      case 'xls':
        return MediaType('application', 'vnd.ms-excel');
      case 'xlsx':
        return MediaType('application',
            'vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      case 'txt':
        return MediaType('text', 'plain');
      default:
        return MediaType('application', 'octet-stream');
    }
  }
}
