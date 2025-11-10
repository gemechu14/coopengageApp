import 'package:coopengageplus/features/onboarding/pages/home/HomePage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:coopengageplus/constants/config/config.dart';
import 'dart:async';
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

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
        print(
            '\u001b[34m${f.field}: ${f.filename} (${f.length} bytes)\u001b[0m');
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

  Future<Map<String, dynamic>> submitOrganizationalRegistration({
    required Map<String, dynamic> requestData,
  }) async {
    Future<void> _addImageFile({
      required http.MultipartRequest request,
      required String fieldName,
      required Uint8List? bytes,
      required String filename,
    }) async {
      if (bytes == null || bytes.isEmpty) return;

      try {
        final appDir = await getApplicationDocumentsDirectory();

        // Save as PNG
        final pngPath = '${appDir.path}/$filename.png';
        final pngFile = File(pngPath);
        await pngFile.writeAsBytes(bytes);

        // Add PNG to request
        request.files.add(await http.MultipartFile.fromPath(
          fieldName,
          pngFile.path,
          filename: '$filename.png',
          contentType: MediaType('image', 'png'),
        ));

        print("✅ $fieldName uploaded as PNG");

        // Optional: Also create JPG version if backend requires JPG
        final decoded = img.decodeImage(bytes);
        if (decoded != null) {
          final jpgBytes = img.encodeJpg(decoded, quality: 90);
          final jpgPath = '${appDir.path}/$filename.jpg';
          final jpgFile = File(jpgPath);
          await jpgFile.writeAsBytes(jpgBytes);

          // Uncomment below if your backend accepts only JPG
          /*
        request.files.add(await http.MultipartFile.fromPath(
          fieldName,
          jpgFile.path,
          filename: '$filename.jpg',
          contentType: MediaType('image', 'jpeg'),
        ));
        print("✅ $fieldName also available as JPG");
        */
        }
      } catch (e) {
        print("❌ Error saving $fieldName: $e");
      }
    }

    try {
      print("📩 Preparing organizational registration data......");
      String? token = await storage.read(key: "token");

      print(token);
      if (token == null) throw Exception("Token not found");
      print(requestData);
      final uri = Uri.parse('$baseUrl/api/v1/accounts/organizational');
      final request = http.MultipartRequest("POST", uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'multipart/form-data';

      // 🏢 Company details
      request.fields["companyName"] = requestData["companyName"] ?? "";
      request.fields["email"] = requestData["email"] ?? "";
      request.fields["tinNumber"] = requestData["tinNumber"] ?? "";
      request.fields["legalId"] = requestData["legalId"] ?? "";
      request.fields["phoneNumber"] = '0${requestData["phoneNumber"] ?? ""}';
      request.fields["dateOfEstablishment"] =
          requestData["dateOfEstablishment"] ?? "";
      request.fields["residence"] = requestData["residence"] ?? "";
      request.fields["state"] = requestData["state"] ?? "";
      request.fields["zone"] = requestData["zone"] ?? "";
      request.fields["woreda"] = requestData["woreda"] ?? "";
      request.fields["branch"] = requestData["branch"] ?? "";
      request.fields["currency"] = requestData["currency"] ?? "ETB";
      request.fields["accountType"] = requestData["accountType"] ?? "1";
      request.fields["initialDeposit"] =
          requestData["initialDeposit"]?.toString() ?? "1000";
      request.fields["percentageCompleted"] =
          requestData["percentageCompleted"]?.toString() ?? "0";

      // 👥 Representatives / Customers
      List<Map<String, dynamic>> personalInfo = requestData["customers"] ?? [];
      for (int i = 0; i < personalInfo.length; i++) {
        var person = personalInfo[i];
        request.fields["personalInfo[$i].fullName"] = person["fullName"] ?? "";
        request.fields["personalInfo[$i].email"] = person["email"] ?? "";
        request.fields["personalInfo[$i].phone"] = '0${person["phone"] ?? ""}';
        request.fields["personalInfo[$i].title"] = person["title"] ?? "";
        request.fields["personalInfo[$i].legalId"] = person["legalId"] ?? "";
        request.fields["personalInfo[$i].documentName"] =
            person["documentName"] ?? "";
        request.fields["personalInfo[$i].issueDate"] =
            person["issueDate"] ?? "";
        request.fields["personalInfo[$i].expiryDate"] =
            person["expiryDate"] ?? "";
        request.fields["personalInfo[$i].zoneSubCity"] =
            person["zoneSubCity"] ?? "";
  request.fields["personalInfo[$i].state"] =
            person["state"] ?? "";
            request.fields["personalInfo[$i].country"] =
            person["country"] ?? "";
        // 🖼️ Attach images
        await _addImageFile(
          request: request,
          fieldName: "personalInfo[$i].residenceCard",
          bytes: person["residenceCard"],
          filename: "residence_front_$i",
        );

        await _addImageFile(
          request: request,
          fieldName: "personalInfo[$i].residenceCardBack",
          bytes: person["residenceCardBack"],
          filename: "residence_back_$i",
        );

        await _addImageFile(
          request: request,
          fieldName: "personalInfo[$i].signature",
          bytes: person["signature"],
          filename: "signature_$i",
        );

        await _addImageFile(
          request: request,
          fieldName: "personalInfo[$i].photo",
          bytes: person["photo"],
          filename: "photo_$i",
        );
      }

      // 📎 Company-related documents
      if (requestData["letterOfRequest"] != null) {
        request.files.add(await http.MultipartFile.fromBytes(
          "letterOfRequest",
          requestData["letterOfRequest"],
          filename: "letter.pdf",
          contentType: MediaType('application', 'pdf'),
        ));
      }

      if (requestData["tradeLicense"] != null) {
        request.files.add(await http.MultipartFile.fromBytes(
          "tradeLicense",
          requestData["tradeLicense"],
          filename: "license.pdf",
          contentType: MediaType('application', 'pdf'),
        ));
      }

      if (requestData["articlesOfAssociation"] != null) {
        request.files.add(await http.MultipartFile.fromBytes(
          "articlesOfAssociation",
          requestData["articlesOfAssociation"],
          filename: "articles.pdf",
          contentType: MediaType('application', 'pdf'),
        ));
      }

      if (requestData["tinNumberFile"] != null) {
        request.files.add(await http.MultipartFile.fromBytes(
          "tinNumberFile",
          requestData["tinNumberFile"],
          filename: "tinNumberFile.pdf",
          contentType: MediaType('application', 'pdf'),
        ));
      }

      // 📎 Other files (array of files)
      if (requestData["otherFiles"] != null) {
        List<dynamic> otherFiles = requestData["otherFiles"];
        if (otherFiles.isNotEmpty) {
          for (int i = 0; i < otherFiles.length; i++) {
            var otherFile = otherFiles[i];
            if (otherFile is Map<String, dynamic> && otherFile["file"] != null) {
              Uint8List? fileBytes = otherFile["file"] is Uint8List
                  ? otherFile["file"] as Uint8List
                  : null;
              
              if (fileBytes != null && fileBytes.isNotEmpty) {
                String description = otherFile["description"] ?? "Document ${i + 1}";
                String filename = "other_file_$i.pdf";
                
                // Determine file extension based on content or default to PDF
                if (fileBytes.length > 4) {
                  // Check PDF magic number
                  if (fileBytes[0] == 0x25 && fileBytes[1] == 0x50 && 
                      fileBytes[2] == 0x44 && fileBytes[3] == 0x46) {
                    filename = "other_file_$i.pdf";
                  } else {
                    // Default to PDF for other file types
                    filename = "other_file_$i.pdf";
                  }
                }
                
                request.files.add(await http.MultipartFile.fromBytes(
                  "otherFiles[$i].file",
                  fileBytes,
                  filename: filename,
                  contentType: MediaType('application', 'pdf'),
                ));
                
                // Add description if backend supports it
                if (description.isNotEmpty) {
                  request.fields["otherFiles[$i].description"] = description;
                }
                
                print("✅ Added otherFiles[$i]: $filename (${fileBytes.length} bytes) - $description");
              }
            }
          }
        }
      }


      // 🧾 Debug print
      print("📤 Final request payload:");
      print("Fields:");
      request.fields.forEach((k, v) => print('  $k: $v'));
      print("Files:");
      for (final file in request.files) {
        print('  ${file.field}: ${file.filename}');
      }

      // 🚀 Send request
      final response = await request.send().timeout(
        const Duration(seconds: 100),
        onTimeout: () {
          throw TimeoutException("Request timed out. Please try again.");
        },
      );

      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "statusCode": response.statusCode,
          "message": "Registration successful",
          "data": jsonDecode(responseBody),
        };
      } else {
        print("❌ Error response: $responseBody");
        Map<String, dynamic> responseMap = json.decode(responseBody);
        String message = responseMap['message'] ?? 'No message available';
        return {
          "statusCode": response.statusCode,
          "message": message,
          "error": responseBody,
        };
      }
    } on TimeoutException {
      return {
        "statusCode": 408,
        "message": "Request timed out. Please try again.",
        "data": null,
      };
    } catch (error) {
      print("❌ Exception: $error");
      return {
        "statusCode": 500,
        "message": "An error occurred",
        "error": error.toString(),
      };
    }
  }
}
