import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:coopengageplus/constants/config/config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class RegistrationService {
  static const String _baseUrl = "${AppConstants.baseUrl}/accounts/joint";

  // print("kjhgfghjkl");

  // "http://10.2.125.41:9060/api/v1/accounts/joint";
  final storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
  );
  Future<Map<String, dynamic>> registerCustomers(
      Map<String, dynamic> requestData) async {
    try {
      var uri = Uri.parse(_baseUrl);
      var request = http.MultipartRequest("POST", uri);
      String? token = await storage.read(key: "token");
      request.headers['Authorization'] = 'Bearer $token';
      print("Starting request...");

      // Add static fields
      request.fields["initialDeposit"] = requestData["initialDeposit"];
      request.fields["percentageCompleted"] = '100';
      request.fields["accountType"] = requestData["accountType"];

      // Add customer details dynamically
      for (int i = 0; i < requestData["customers"].length; i++) {
        var customer = requestData["customers"][i];

        print("Adding customer $i");
        print(customer["maritalStatus"]);

        // Add customer fields dynamically
        request.fields["customers[$i].fullName"] = customer["fullName"];
        request.fields["customers[$i].phone"] = customer["phone"] ?? "";

        request.fields["customers[$i].surname"] = customer["surname"] ?? "";
        request.fields["customers[$i].motherName"] =
            customer["motherName"] ?? "";
        request.fields["customers[$i].dateOfBirth"] =
            customer["dateOfBirth"] ?? "";
        request.fields["customers[$i].country"] = customer["country"] ?? "";
        request.fields["customers[$i].state"] = customer["state"] ?? "";
        request.fields["customers[$i].city"] = customer["city"] ?? "";
        request.fields["customers[$i].streetAddress"] =
            customer["streetAddress"] ?? "";
        request.fields["customers[$i].zipCode"] = customer["zipCode"] ?? "";
        request.fields["customers[$i].occupation"] =
            customer["occupation"] ?? "";
        request.fields["customers[$i].title"] = customer["title"] ?? "";
        // // request.fields["customers[$i].maritalStatus"] =
        //     customer["maritalStatus"];

        // if (customer["maritalStatus"] != null &&
        //     customer["maritalStatus"] != '') {
        //   request.fields["customers[$i].maritalStatus"] =
        //       customer["maritalStatus"];
        // }

        request.fields["customers[$i].postCode"] = customer["postCode"] ?? "";
        request.fields["customers[$i].zoneSubCity"] =
            customer["zoneSubCity"] ?? "";
        request.fields["customers[$i].houseNo"] = customer["houseNo"] ?? "";
        request.fields["customers[$i].documentName"] =
            customer["documentName"] ?? "";
        request.fields["customers[$i].issueAuthority"] =
            customer["issueAuthority"] ?? "";
        request.fields["customers[$i].issueDate"] = customer["issueDate"] ?? "";
        request.fields["customers[$i].expiryDate"] =
            customer["expiryDate"] ?? "";
        // request.fields["customers[$i].employeeStatus"] =
        //     customer["employeeStatus"];
        request.fields["customers[$i].legalId"] = customer["legalId"] ?? "";
        // request.fields["customers[$i].salary"] = customer["salary"].toString();
        request.fields["customers[$i].sector"] = customer["sector"] ?? "";
        request.fields["customers[$i].industry"] = customer["industry"] ?? "";

        // request.fields["customers[$i].monthlyIncome"] =
        //     customer["monthlyIncome"].toString();
        // request.fields["customers[$i].photo"] = customer["photo"];
        // customer["sex"] === ''
        //     ? request.fields["customers[$i].sex"] = customer["sex"]
        //     : '';
        if (customer["sex"] != null && customer["sex"] != '') {
          request.fields["customers[$i].sex"] = customer["sex"];
        }

        if (customer["photo"] is Uint8List) {
          print("Gemechuuuddddu");
          print(customer['photo']);
          request.files.add(http.MultipartFile.fromBytes(
            "customers[$i].photo", // Remove the extra brackets in the string
            customer["photo"],
            filename: "photo_$i.jpg",
          ));
        }
        if (customer["signature"] is Uint8List) {
          request.files.add(http.MultipartFile.fromBytes(
            "customers[$i].signature",
            customer["signature"],
            filename: "signature_$i.jpg",
          ));
        }
        if (customer["residenceCard"] is Uint8List) {
          request.files.add(http.MultipartFile.fromBytes(
            "customers[$i].residenceCard", // Remove the extra brackets in the string
            customer["residenceCard"],
            filename: "residenceCard_$i.jpg",
          ));
        }
        if (customer["residenceCardBack"] is Uint8List) {
          print("Gemechuuuddddu");
          print(customer['residenceCardBack']);
          request.files.add(http.MultipartFile.fromBytes(
            "customers[$i].residenceCardBack", // Remove the extra brackets in the string
            customer["residenceCardBack"],
            filename: "residenceCardBack_$i.jpg",
          ));
        }

        // if (customer["residenceCard"] is Uint8List) {
        //   request.files.add(http.MultipartFile.fromBytes(
        //     "customers[$i].residenceCard]",
        //     customer["residenceCard"],
        //     filename: "residence_card_$i.jpg",
        //   ));
        // }
        // if (customer["signature"] is Uint8List) {
        //   request.files.add(http.MultipartFile.fromBytes(
        //     "customers[$i].signature]",
        //     customer["signature"],
        //     filename: "signature_$i.png",
        //   ));
        // }

        // if (customer["residenceCard"] is Uint8List) {
        //   request.files.add(http.MultipartFile.fromBytes(
        //     "customers[$i].residenceCard]",
        //     customer["residenceCard"],
        //     filename: "residence_card_$i.jpg",
        //   ));
        // }
      }

      print("Finished adding fields.");
      print(request.fields);

      // Send request after the loop is done
      // var response = await request.send();

      var response = await request.send().timeout(
        Duration(seconds: 100), // Timeout after 30 seconds
        onTimeout: () {
          throw TimeoutException("Request timed out. Please try again.");
        },
      );
      var responseBody = await response.stream.bytesToString();

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
    } catch (e) {
      return {
        "statusCode": 500,
        "message": "An error occurred",
        "error": e.toString(),
      };
    }
  }
}
