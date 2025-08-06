

import 'dart:async';
import 'dart:convert';
import 'package:coopengageplus/constants/config/config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class RegistrationService {
  final storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
        storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
  );
  static const String _baseUrl =
      "${AppConstants.baseUrl}/accounts/organizational";

  Future<Map<String, dynamic>> registerCustomers(
      Map<String, dynamic> requestData) async {
    try {
      print("Incoming customer data:");
      print(requestData);

      final uri = Uri.parse(_baseUrl);
      final request = http.MultipartRequest("POST", uri);

      String? token = await storage.read(key: "token");
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'multipart/form-data';

      // ✅ Company details
      request.fields["companyName"] = requestData["companyName"] ?? "";
      request.fields["email"] = requestData["email"] ?? "";
      request.fields["phoneNumber"] = requestData["phoneNumber"] ?? "";
      request.fields["residence"] = requestData["residence"] ?? "";
      request.fields["state"] = requestData["state"] ?? "";
      request.fields["zone"] = requestData["zone"] ?? "";
      request.fields["subCity"] = requestData["subCity"] ?? "";
      request.fields["woreda"] = requestData["woreda"] ?? "";
      request.fields["branch"] = requestData["branch"] ?? "";
      request.fields["currency"] = requestData["currency"] ?? "ETB";
      request.fields["accountType"] = requestData["accountType"] ?? "1";
      request.fields["initialDeposit"] =
          requestData["initialDeposit"]?.toString() ?? "1000";
      request.fields["percentageCompleted"] =
          requestData["percentageCompleted"]?.toString() ?? "0";
      request.fields["target"] = requestData["target"] ?? "";

      // ✅ Representatives using personalInfo[0].fieldName format
      List<Map<String, dynamic>> personalInfo = requestData["customers"] ?? [];
      for (int i = 0; i < personalInfo.length; i++) {
        final person = personalInfo[i];
        request.fields["personalInfo[$i].fullName"] = person["fullName"] ?? "";
        request.fields["personalInfo[$i].email"] = person["email"] ?? "";
        request.fields["personalInfo[$i].phone"] = person["phone"] ?? "";
        request.fields["personalInfo[$i].title"] = person["title"] ?? "";
        request.fields["personalInfo[$i].documentNumber"] =
            person["legalId"] ?? "";
        request.fields["personalInfo[$i].documentName"] =
            person["documentName"] ?? "";
        request.fields["personalInfo[$i].issueDate"] =
            person["issueDate"] ?? "";
        request.fields["personalInfo[$i].expiryDate"] =
            person["expiryDate"] ?? "";

        // Optional image file uploads
        // if (person["photo"] != null) {
        //   request.files.add(http.MultipartFile.fromBytes(
        //     "personalInfo[$i].photo",
        //     person["photo"],
        //     filename: "photo_$i.jpg",
        //   ));
        // }

        if (person["photo"] != null) {
          final bytes = (person["photo"] as List<dynamic>).cast<int>();
          request.files.add(http.MultipartFile.fromBytes(
            "personalInfo[$i].photo",
            bytes,
            filename: "photo_$i.jpg",
          ));
        }

// ✅ Inside loop for each representative
        if (person["residenceCard"] != null) {
          request.files.add(http.MultipartFile.fromBytes(
            "personalInfo[$i].residenceCard",
            (person["residenceCard"] as List<dynamic>).cast<int>(),
            filename: "residence_$i.jpg",
          ));
        }

        if (person["residenceCardBack"] != null) {
          request.files.add(http.MultipartFile.fromBytes(
            "personalInfo[$i].residenceCardBack",
            (person["residenceCardBack"] as List<dynamic>).cast<int>(),
            filename: "residence_back_$i.jpg",
          ));
        }

        if (person["signature"] != null) {
          request.files.add(http.MultipartFile.fromBytes(
            "personalInfo[$i].signature",
            (person["signature"] as List<dynamic>).cast<int>(),
            filename: "signature_$i.jpg",
          ));
        }
// ✅ Optional organization documents
        if (requestData["letterOfRequest"] != null) {
          request.files.add(http.MultipartFile.fromBytes(
            "letterOfRequest",
            (requestData["letterOfRequest"] as List<dynamic>).cast<int>(),
            filename: "letter.pdf",
          ));
        }

        if (requestData["tradeLicense"] != null) {
          request.files.add(http.MultipartFile.fromBytes(
            "tradeLicense",
            (requestData["tradeLicense"] as List<dynamic>).cast<int>(),
            filename: "license.pdf",
          ));
        }

        if (requestData["articlesOfAssociation"] != null) {
          request.files.add(http.MultipartFile.fromBytes(
            "articlesOfAssociation",
            (requestData["articlesOfAssociation"] as List<dynamic>).cast<int>(),
            filename: "articles.pdf",
          ));
        }

        //   if (person["residenceCard"] != null) {
        //     request.files.add(http.MultipartFile.fromBytes(
        //       "personalInfo[$i].residenceCard",
        //       person["residenceCard"],
        //       filename: "residence_$i.jpg",
        //     ));
        //   }
        //   if (person["residenceCardBack"] != null) {
        //     request.files.add(http.MultipartFile.fromBytes(
        //       "personalInfo[$i].residenceCardBack",
        //       person["residenceCardBack"],
        //       filename: "residence_back_$i.jpg",
        //     ));
        //   }
        //   if (person["signature"] != null) {
        //     request.files.add(http.MultipartFile.fromBytes(
        //       "personalInfo[$i].signature",
        //       person["signature"],
        //       filename: "signature_$i.jpg",
        //     ));
        //   }
        // }

        // // ✅ Optional organization documents
        // if (requestData["letterOfRequest"] != null) {
        //   request.files.add(http.MultipartFile.fromBytes(
        //     "letterOfRequest",
        //     requestData["letterOfRequest"],
        //     filename: "letter.pdf",
        //   ));
        // }

        // if (requestData["tradeLicense"] != null) {
        //   request.files.add(http.MultipartFile.fromBytes(
        //     "tradeLicense",
        //     requestData["tradeLicense"],
        //     filename: "license.pdf",
        //   ));
        // }

        // if (requestData["articlesOfAssociation"] != null) {
        //   request.files.add(http.MultipartFile.fromBytes(
        //     "articlesOfAssociation",
        //     requestData["articlesOfAssociation"],
        //     filename: "articles.pdf",
        //   ));
      }

      print("Final request fields: ${request.fields}");

      final response = await request.send().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException("Request timed out. Please try again.");
        },
      );

      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return {
          "statusCode": 200,
          "message": "Registration successful",
          "data": jsonDecode(responseBody),
        };
      } else {
        print("Error response body: $responseBody");
        final Map<String, dynamic> responseMap = json.decode(responseBody);
        return {
          "statusCode": response.statusCode,
          "message": responseMap['message'] ?? 'An error occurred',
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
