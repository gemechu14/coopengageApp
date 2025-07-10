import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:coopengageplus/constants/config/config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class RegistrationService {
  // static const String _baseUrl =
  //     "http://10.2.125.41:9060/api/v1/accounts/organizational";
  final storage = FlutterSecureStorage();
  static const String _baseUrl =
      "${AppConstants.baseUrl}/accounts/organizational";

  Future<Map<String, dynamic>> registerCustomers(
      Map<String, dynamic> requestData) async {
    try {
      var uri = Uri.parse(_baseUrl);
      var request = http.MultipartRequest("POST", uri);
      String? token = await storage.read(key: "token");

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'multipart/form-data';

      // **Add company details**
      request.fields["companyName"] = requestData["companyName"] ?? "";
      request.fields["email"] = requestData["email"] ?? "";
      request.fields["phoneNumber"] = requestData["phoneNumber"] ?? "";
      // request.fields["tinNumber"] = requestData["tinNumber"] ?? "";
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

      // **Handle personal information (Representatives)**
      List<Map<String, dynamic>> personalInfo = requestData["customers"] ?? [];
      for (int i = 0; i < personalInfo.length; i++) {
        var person = personalInfo[i];

        request.fields["personalInfo[$i].fullName"] = person["fullName"] ?? "";
        request.fields["personalInfo[$i].email"] = person["email"] ?? "";
        request.fields["personalInfo[$i].phone"] = person["phone"] ?? "";
        request.fields["personalInfo[$i].title"] = person["title"] ?? "";
        request.fields["personalInfo[$i].documentNumber"] =
            person["legalId"] ?? "";
        request.fields["personalInfo[$i].documentType"] =
            person["documentName"] ?? "";
        request.fields["personalInfo[$i].issueDate"] =
            person["issueDate"] ?? "";
        request.fields["personalInfo[$i].expiryDate"] =
            person["expiryDate"] ?? "";
      }

      // **Handle files (if provided)**
      if (requestData["letterOfRequest"] != null) {
        request.files.add(http.MultipartFile.fromBytes(
            "letterOfRequest", requestData["letterOfRequest"],
            filename: "letter.pdf"));
      }

      if (requestData["tradeLicense"] != null) {
        request.files.add(http.MultipartFile.fromBytes(
            "tradeLicense", requestData["tradeLicense"],
            filename: "license.pdf"));
      }

      if (requestData["articlesOfAssociation"] != null) {
        request.files.add(http.MultipartFile.fromBytes(
            "articlesOfAssociation", requestData["articlesOfAssociation"],
            filename: "articles.pdf"));
      }

      print("Final request payload: ${request.fields}");

      // var response = await request.send();
      var response = await request.send().timeout(
        Duration(seconds: 15), // Timeout after 30 seconds
        onTimeout: () {
          throw TimeoutException("Request timed out. Please try again.");
        },
      );
      var responseBody = await response.stream.bytesToString();
      // var responseJson = json.decode(responseBody);

      if (response.statusCode == 200) {
        return {
          "statusCode": 200,
          "message": "Registration successful",
          "data": jsonDecode(responseBody),
        };
      } else {
        print(responseBody);
        Map<String, dynamic> responseMap = json.decode(responseBody);

        // Access the 'message' field from the decoded Map
        String message = responseMap['message'] ?? 'No message available';
        return {
          "statusCode": response.statusCode,
          "message": message,

          // "message": "Internal server error",
          "error": responseBody,
        };
      }
    } on TimeoutException {
      return {
        "statusCode": 408, // 408 is the standard timeout HTTP status
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
