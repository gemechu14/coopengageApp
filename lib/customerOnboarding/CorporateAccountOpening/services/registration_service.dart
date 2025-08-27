import 'package:coopengageplus/features/onboarding/pages/home/HomePage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:coopengageplus/constants/config/config.dart';
import 'dart:async';

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
    try {
      print("incoming dataaaaa");
      // print(requestData.);
      String? token = await storage.read(key: "token");
      if (token == null) {
        throw Exception("Token not found");
      }
      final uri = Uri.parse('$baseUrl/api/v1/accounts/organizational');
      final request = http.MultipartRequest("POST", uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'multipart/form-data';

      // Add company details
      request.fields["companyName"] = requestData["companyName"] ?? "";
      request.fields["email"] = requestData["email"] ?? "";
      request.fields["tinNumber"] = requestData["tinNumber"] ?? "";
      request.fields["legalId"] = requestData["legalId"] ?? "";
      // request.fields["phoneNumber"] = 0+ requestData["phoneNumber"] ?? "";
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

      // Handle personal information (Representatives)
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

        // Handle resident card front
        if (person["residenceCard"] != null) {
          request.files.add(await http.MultipartFile.fromBytes(
            "personalInfo[$i].residenceCard",
            person["residenceCard"],
            filename: "residence_front_$i.jpg",
          ));
        }

        // Handle resident card back
        if (person["residenceCardBack"] != null) {
          request.files.add(await http.MultipartFile.fromBytes(
            "personalInfo[$i].residenceCardBack",
            person["residenceCardBack"],
            filename: "residence_back_$i.jpg",
          ));
        }

        // Handle signature
        if (person["signature"] != null) {
          request.files.add(await http.MultipartFile.fromBytes(
            "personalInfo[$i].signature",
            person["signature"],
            filename: "signature_$i.jpg",
          ));
        }

        // Handle photo
        if (person["photo"] != null) {
          request.files.add(await http.MultipartFile.fromBytes(
            "personalInfo[$i].photo",
            person["photo"],
            filename: "photo_$i.jpg",
          ));
        }
      }

      // Handle files (if provided)
      if (requestData["letterOfRequest"] != null) {
        request.files.add(await http.MultipartFile.fromBytes(
            "letterOfRequest", requestData["letterOfRequest"],
            filename: "letter.pdf"));
      }
      if (requestData["tradeLicense"] != null) {
        request.files.add(await http.MultipartFile.fromBytes(
            "tradeLicense", requestData["tradeLicense"],
            filename: "license.pdf"));
      }
      if (requestData["articlesOfAssociation"] != null) {
        request.files.add(await http.MultipartFile.fromBytes(
            "articlesOfAssociation", requestData["articlesOfAssociation"],
            filename: "articles.pdf"));
      }

      if (requestData["tinNumberFile"] != null) {
        request.files.add(await http.MultipartFile.fromBytes(
            "tinNumberFile", requestData["tinNumberFile"],
            filename: "tinNumberFile.pdf"));
      }
    
      

      print("Final request payload: ");
      print("Fields:");
      request.fields.forEach((k, v) => print('  $k: $v'));
      print("Files:");
      for (final file in request.files) {
        print('  ${file.field}: ${file.filename} (${file.length} bytes)');
      }

      final response = await request.send().timeout(
        const Duration(seconds: 30),
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
        print(responseBody);
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
      return {
        "statusCode": 500,
        "message": "An error occurred",
        "error": error.toString(),
      };
    }
  }


}
