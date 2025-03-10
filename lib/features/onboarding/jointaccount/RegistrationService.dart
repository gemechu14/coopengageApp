// // import 'dart:convert';
// // import 'dart:typed_data';
// // import 'package:http/http.dart' as http;
// // import 'package:path/path.dart';

// // class RegistrationService {
// //   static const String _baseUrl =
// //       "http://10.2.125.41:9060/api/v1/accounts/joint";

// //   Future<Map<String, dynamic>> registerCustomers(
// //       Map<String, dynamic> requestData) async {
// //     try {
// //       var uri = Uri.parse(_baseUrl);
// //       var request = http.MultipartRequest("POST", uri);

// //       print("request saaaa");
// //       print(requestData);
// //       // Add text fields
// //       request.fields["primaryPhone"] = '094753988';
// //       request.fields["branch"] = requestData["branch"];
// //       request.fields["currency"] = 'ETB';
// //       request.fields["accountType"] = requestData["accountType"];
// //       request.fields["initialDeposit"] =
// //           requestData["initialDeposit"].toString();
// //       request.fields["percentageCompleted"] =
// //           requestData["percentageCompleted"].toString();

// //       // Add customer details
// //       for (int i = 0; i < requestData["customers"].length; i++) {
// //         var customer = requestData["customers"][i];
// //         String index = i.toString(); // Index for multiple customers

// //         request.fields["customers[$index][fullName]"] = customer["fullName"];
// //         request.fields["customers[$index][surname]"] = customer["surname"];
// //         request.fields["customers[$index][motherName]"] =
// //             customer["motherName"];
// //         request.fields["customers[$index][email]"] = customer["email"];
// //         request.fields["customers[$index][phone]"] = customer["phone"];
// //         request.fields["customers[$index][dateOfBirth]"] =
// //             customer["dateOfBirth"];
// //         request.fields["customers[$index][country]"] = customer["country"];
// //         request.fields["customers[$index][state]"] = customer["state"];
// //         request.fields["customers[$index][occupation]"] =
// //             customer["occupation"];
// //         request.fields["customers[$index][title]"] = customer["title"];
// //         request.fields["customers[$index][maritalStatus]"] =
// //             customer["maritalStatus"];
// //         request.fields["customers[$index][legalId]"] = customer["legalId"];
// //         request.fields["customers[$index][issueDate]"] = customer["issueDate"];
// //         request.fields["customers[$index][expiryDate]"] =
// //             customer["expiryDate"];
// //         request.fields["customers[$index][monthlyIncome]"] =
// //             customer["monthlyIncome"];
// //         request.fields["customers[$index][sex]"] = customer["sex"];
// //         request.fields["customers[$index][percentageCompleted]"] =
// //             customer["percentageCompleted"].toString();

// //         // Attach files
// //         if (customer["photo"] is Uint8List) {
// //           request.files.add(http.MultipartFile.fromBytes(
// //             "customers[$index][photo]",
// //             customer["photo"],
// //             filename: "photo_$index.jpg",
// //           ));
// //         }

// //         if (customer["signature"] is Uint8List) {
// //           request.files.add(http.MultipartFile.fromBytes(
// //             "customers[$index][signature]",
// //             customer["signature"],
// //             filename: "signature_$index.png",
// //           ));
// //         }

// //         if (customer["residenceCard"] is Uint8List) {
// //           request.files.add(http.MultipartFile.fromBytes(
// //             "customers[$index][residenceCard]",
// //             customer["residenceCard"],
// //             filename: "residence_card_$index.jpg",
// //           ));
// //         }

// //         if (customer["residenceCardBack"] is Uint8List) {
// //           request.files.add(http.MultipartFile.fromBytes(
// //             "customers[$index][residenceCardBack]",
// //             customer["residenceCardBack"],
// //             filename: "residence_card_back_$index.jpg",
// //           ));
// //         }
// //       }

// //       // print(token);
// //       // Send request
// //       var response = await request.send();
// //       var responseBody = await response.stream.bytesToString();

// //       if (response.statusCode == 200) {
// //         return {
// //           "statusCode": 200,
// //           "message": "Registration successful",
// //           "data": jsonDecode(responseBody),
// //         };
// //       } else {
// //         print(response);
// //         return {
// //           "statusCode": response.statusCode,
// //           "message": "Registration failed",
// //           "error": responseBody,
// //         };
// //       }
// //     } catch (e) {
// //       return {
// //         "statusCode": 500,
// //         "message": "An error occurred",
// //         "error": e.toString(),
// //       };
// //     }
// //   }
// // }

// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class RegistrationService {
//   static const String _baseUrl =
//       "http://10.2.125.41:9060/api/v1/accounts/joint";

//   Future<Map<String, dynamic>> registerCustomers() async {
//     try {
//       var uri = Uri.parse(_baseUrl);
//       var request = http.MultipartRequest("POST", uri);

//       // Token to include in the headers
//       String token =
//           'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJNZWtlbGVCcmFuY2hBQzFAY29vcC5jb20iLCJyb2xlIjpbIkFDQ09VTlQtQ1JFQVRPUiJdLCJjbGllbnRJZCI6MjAyLCJtYWluQnJhbmNoIjp7ImJyYW5jaENvZGUiOiJFVDAwMTAwODYiLCJjb21wYW55TmFtZSI6Ik1la2VsZSBCcmFuY2giLCJpZCI6ODZ9LCJleHAiOjE3NDE5MzgwMjcsImlhdCI6MTc0MTMzMzIyNywidXNlcklkIjo3NTUsImJyYW5jaCI6W3siYnJhbmNoQ29kZSI6IkVUMDAxMDEyMyIsImNvbXBhbnlOYW1lIjoiU2hpcmUgQnJhbmNoIiwiaWQiOjEyM30seyJicmFuY2hDb2RlIjoiRVQwMDEwMzg5IiwiY29tcGFueU5hbWUiOiJBa3N1bSBCcmFuY2giLCJpZCI6Mzg5fV19.l1Gce0_C8-Nh_rkwkd8WW-QOGyy8KLCaBO0_vDLOWpo';

//       // Add token to request headers
//       request.headers['Authorization'] = 'Bearer $token';

//       // Static data for the request
//       Map<String, dynamic> requestData = {
//         "customers": [
//           {
//             "id": 0,
//             "fullName": "string",
//             "surname": "string",
//             "motherName": "string",
//             "email": "string",
//             "emailVerified": true,
//             "phone": "string",
//             "dateOfBirth": "2025-03-07",
//             "country": "string",
//             "state": "string",
//             "city": "string",
//             "streetAddress": "string",
//             "zipCode": "string",
//             "occupation": "string",
//             "title": "MR",
//             "maritalStatus": "Marital",
//             "postCode": 0,
//             "zoneSubCity": "string",
//             "houseNo": "string",
//             "documentName": "KEBELEID",
//             "issueAuthority": "string",
//             "issueDate": "2025-03-07",
//             "expiryDate": "2025-03-07",
//             "employeeStatus": "OTHER",
//             "legalId": "string",
//             "salary": 0,
//             "sector": "string",
//             "industry": "string",
//             "employerName": "string",
//             "monthlyIncome": 1,
//             "sex": "FEMALE",
//             "photo": "string",
//             "signature": "string",
//             "residenceCard": "string",
//             "residenceCardBack": "string",
//             "passport": "string",
//             "confirmationForm": "string",
//             "percentageCompleted": 0
//           }
//         ],
//         "primaryPhone": "string",
//         "branch": "string",
//         "currency": "string",
//         "accountType": "string",
//         "initialDeposit": 1,
//         "percentageCompleted": 0
//       };

//       // Add text fields
//       request.fields["primaryPhone"] = requestData["primaryPhone"];
//       request.fields["branch"] = requestData["branch"];
//       request.fields["currency"] = requestData["currency"];
//       request.fields["accountType"] = requestData["accountType"];
//       request.fields["initialDeposit"] =
//           requestData["initialDeposit"].toString();
//       request.fields["percentageCompleted"] =
//           requestData["percentageCompleted"].toString();

//       // Add customer details
//       for (int i = 0; i < requestData["customers"].length; i++) {
//         var customer = requestData["customers"][i];
//         String index = i.toString(); // Index for multiple customers

//         request.fields["customers[$index][fullName]"] = customer["fullName"];
//         request.fields["customers[$index][surname]"] = customer["surname"];
//         request.fields["customers[$index][motherName]"] =
//             customer["motherName"];
//         request.fields["customers[$index][email]"] = customer["email"];
//         request.fields["customers[$index][phone]"] = customer["phone"];
//         request.fields["customers[$index][dateOfBirth]"] =
//             customer["dateOfBirth"];
//         request.fields["customers[$index][country]"] = customer["country"];
//         request.fields["customers[$index][state]"] = customer["state"];
//         request.fields["customers[$index][occupation]"] =
//             customer["occupation"];
//         request.fields["customers[$index][title]"] = customer["title"];
//         request.fields["customers[$index][maritalStatus]"] =
//             customer["maritalStatus"];
//         request.fields["customers[$index][legalId]"] = customer["legalId"];
//         request.fields["customers[$index][issueDate]"] = customer["issueDate"];
//         request.fields["customers[$index][expiryDate]"] =
//             customer["expiryDate"];
//         request.fields["customers[$index][monthlyIncome]"] =
//             customer["monthlyIncome"].toString();
//         request.fields["customers[$index][sex]"] = customer["sex"];
//         request.fields["customers[$index][percentageCompleted]"] =
//             customer["percentageCompleted"].toString();

//         // Attach files (use actual file data for photo, signature, etc.)
//         // Here, just assuming as string placeholders
//         if (customer["photo"] == "string") {
//           // You can replace this with actual file data or Uint8List
//           request.files.add(http.MultipartFile.fromBytes(
//             "customers[$index][photo]",
//             [],
//             filename: "photo_$index.jpg",
//           ));
//         }

//         if (customer["signature"] == "string") {
//           request.files.add(http.MultipartFile.fromBytes(
//             "customers[$index][signature]",
//             [],
//             filename: "signature_$index.png",
//           ));
//         }

//         if (customer["residenceCard"] == "string") {
//           request.files.add(http.MultipartFile.fromBytes(
//             "customers[$index][residenceCard]",
//             [],
//             filename: "residence_card_$index.jpg",
//           ));
//         }

//         if (customer["residenceCardBack"] == "string") {
//           request.files.add(http.MultipartFile.fromBytes(
//             "customers[$index][residenceCardBack]",
//             [],
//             filename: "residence_card_back_$index.jpg",
//           ));
//         }
//       }

//       // Send the request
//       var response = await request.send();
//       var responseBody = await response.stream.bytesToString();

//       // Handle response
//       if (response.statusCode == 200) {
//         return {
//           "statusCode": 200,
//           "message": "Registration successful",
//           "data": jsonDecode(responseBody),
//         };
//       } else {
//         return {
//           "statusCode": response.statusCode,
//           "message": "Registration failed",
//           "error": responseBody,
//         };
//       }
//     } catch (e) {
//       return {
//         "statusCode": 500,
//         "message": "An error occurred",
//         "error": e.toString(),
//       };
//     }
//   }
// }

// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:http/http.dart' as http;

// class RegistrationService {
//   static const String _baseUrl =
//       "http://10.2.125.41:9060/api/v1/accounts/joint";

//   Future<Map<String, dynamic>> registerCustomers(
//       Map<String, dynamic> requestData) async {
//     try {
//       var uri = Uri.parse(_baseUrl);
//       var request = http.MultipartRequest("POST", uri);

//       // Token to include in the headers
//       String token =
//           'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJNZWtlbGVCcmFuY2hBQzFAY29vcC5jb20iLCJyb2xlIjpbIkFDQ09VTlQtQ1JFQVRPUiJdLCJjbGllbnRJZCI6MjAyLCJtYWluQnJhbmNoIjp7ImJyYW5jaENvZGUiOiJFVDAwMTAwODYiLCJjb21wYW55TmFtZSI6Ik1la2VsZSBCcmFuY2giLCJpZCI6ODZ9LCJleHAiOjE3NDIyMDMwNjMsImlhdCI6MTc0MTU5ODI2MywidXNlcklkIjo3NTUsImJyYW5jaCI6W3siYnJhbmNoQ29kZSI6IkVUMDAxMDEyMyIsImNvbXBhbnlOYW1lIjoiU2hpcmUgQnJhbmNoIiwiaWQiOjEyM30seyJicmFuY2hDb2RlIjoiRVQwMDEwMzg5IiwiY29tcGFueU5hbWUiOiJBa3N1bSBCcmFuY2giLCJpZCI6Mzg5fV19.HuxJLoaYdW3TzraV4e7bbWm6rIXlMWFX9daAT1CpMck';

//       // Add token to request headers
//       request.headers['Authorization'] = 'Bearer $token';
//       print("dataaa");
//       print(requestData['primaryPhone']);
//       // Add text fields
//       // request.fields["primaryPhone"] = '0947539988';
//       // request.fields["branch"] = requestData["branch"];
//       // request.fields["currency"] = requestData["currency"];
//       // request.fields["accountType"] = requestData["accountType"];
//       request.fields["initialDeposit"] = '100';
//       // requestData["initialDeposit"].toString();
//       request.fields["percentageCompleted"] = '100';
//       //  request.fields["customers"[0]["fullName"]"] ="Gwme";
//       // request.fields["customers[0].fullName"] = "Jibril Hagos";
//       // request.fields["customers[0].phone"] = "0946537637";

//       // request.fields["customers[1].fullName"] = "Girma D";
//       // request.fields["customers[1].phone"] = "0946537637";

//       print("Gemechuuuu");
//       print(requestData["customers"].length);
//       // Add customer details dynamically
//       for (int i = 0; i < 2; i++) {
//         var customer = requestData["customers"][i];

//         print("customer");

//         print(customer["fullName"]);
//         int index = i; // Index for multiple customers
//         // print("customers[$index][fullName]");
//         // request.fields["customers[$index][fullName]"] = customer["fullName"];
//         // request.fields["customers[$index][surname]"] = customer["surname"];
//         // request.fields["customers[$index][motherName]"] = "geme@gmail.com";
//         // // customer["motherName"];
//         // request.fields["customers[$index][email]"] = "geme@gmail.com";
//         // request.fields["customers[$index][phone]"] = '0947539988';
//         // request.fields["customers[$index][dateOfBirth]"] =
//         //     customer["dateOfBirth"];
//         // request.fields["customers[$index][country]"] = customer["country"];
//         // request.fields["customers[$index][state]"] = customer["state"];
//         // request.fields["customers[$index][occupation]"] =
//         //     customer["occupation"];
//         // request.fields["customers[$index][title]"] = customer["title"];
//         // request.fields["customers[$index][maritalStatus]"] =
//         //     customer["maritalStatus"];
//         // request.fields["customers[$index][legalId]"] = customer["legalId"];
//         // request.fields["customers[$index][issueDate]"] = customer["issueDate"];
//         // request.fields["customers[$index][expiryDate]"] =
//         //     customer["expiryDate"];
//         // request.fields["customers[$index][monthlyIncome]"] =
//         //     customer["monthlyIncome"];
//         // request.fields["customers[$index][sex]"] = customer["sex"];
//         // request.fields["customers[$index][percentageCompleted]"] =
//         //     customer["percentageCompleted"].toString();

//         // // Attach files dynamically
//         // if (customer["photo"] is Uint8List) {
//         //   request.files.add(http.MultipartFile.fromBytes(
//         //     "customers[$index][photo]",
//         //     customer["photo"],
//         //     filename: "photo_$index.jpg",
//         //   ));
//         // }

//         // if (customer["signature"] is Uint8List) {
//         //   request.files.add(http.MultipartFile.fromBytes(
//         //     "customers[$index][signature]",
//         //     customer["signature"],
//         //     filename: "signature_$index.png",
//         //   ));
//         // }

//         // if (customer["residenceCard"] is Uint8List) {
//         //   request.files.add(http.MultipartFile.fromBytes(
//         //     "customers[$index][residenceCard]",
//         //     customer["residenceCard"],
//         //     filename: "residence_card_$index.jpg",
//         //   ));
//         // }

//         // if (customer["residenceCardBack"] is Uint8List) {
//         //   request.files.add(http.MultipartFile.fromBytes(
//         //     "customers[$index][residenceCardBack]",
//         //     customer["residenceCardBack"],
//         //     filename: "residence_card_back_$index.jpg",
//         //   ));
//         // }
//       }

//       print(request.fields);
//       // Send request
//       var response = await request.send();
//       var responseBody = await response.stream.bytesToString();

//       if (response.statusCode == 200) {
//         return {
//           "statusCode": 200,
//           "message": "Registration successful",
//           "data": jsonDecode(responseBody),
//         };
//       } else {
//         return {
//           "statusCode": response.statusCode,
//           "message": "Registration failed",
//           "error": responseBody,
//         };
//       }
//     } catch (e) {
//       return {
//         "statusCode": 500,
//         "message": "An error occurred",
//         "error": e.toString(),
//       };
//     }
//   }
// }

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class RegistrationService {
  static const String _baseUrl =
      "http://10.2.125.41:9060/api/v1/accounts/joint";

  Future<Map<String, dynamic>> registerCustomers(
      Map<String, dynamic> requestData) async {
    try {
      var uri = Uri.parse(_baseUrl);
      var request = http.MultipartRequest("POST", uri);

      // Token to include in the headers
      String token =
          'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJNZWtlbGVCcmFuY2hBQzFAY29vcC5jb20iLCJyb2xlIjpbIkFDQ09VTlQtQ1JFQVRPUiJdLCJjbGllbnRJZCI6MjAyLCJtYWluQnJhbmNoIjp7ImJyYW5jaENvZGUiOiJFVDAwMTAwODYiLCJjb21wYW55TmFtZSI6Ik1la2VsZSBCcmFuY2giLCJpZCI6ODZ9LCJleHAiOjE3NDIyMDMwNjMsImlhdCI6MTc0MTU5ODI2MywidXNlcklkIjo3NTUsImJyYW5jaCI6W3siYnJhbmNoQ29kZSI6IkVUMDAxMDEyMyIsImNvbXBhbnlOYW1lIjoiU2hpcmUgQnJhbmNoIiwiaWQiOjEyM30seyJicmFuY2hDb2RlIjoiRVQwMDEwMzg5IiwiY29tcGFueU5hbWUiOiJBa3N1bSBCcmFuY2giLCJpZCI6Mzg5fV19.HuxJLoaYdW3TzraV4e7bbWm6rIXlMWFX9daAT1CpMck';

      // Add token to request headers
      request.headers['Authorization'] = 'Bearer $token';
      print("Starting request...");

      // Add static fields
      request.fields["initialDeposit"] = '100';
      request.fields["percentageCompleted"] = '100';

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
        // request.fields["customers[$i].maritalStatus"] =
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
        request.fields["customers[$i].employeeStatus"] =
            customer["employeeStatus"];
        request.fields["customers[$i].legalId"] = customer["legalId"] ?? "";
        request.fields["customers[$i].salary"] = customer["salary"].toString();
        request.fields["customers[$i].sector"] = customer["sector"] ?? "";
        request.fields["customers[$i].industry"] = customer["industry"] ?? "";
        request.fields["customers[$i].employerName"] =
            customer["employerName"] ?? "";
        request.fields["customers[$i].monthlyIncome"] =
            customer["monthlyIncome"].toString();
        // request.fields["customers[$i].photo"] = customer["photo"];
        // customer["sex"] === ''
        //     ? request.fields["customers[$i].sex"] = customer["sex"]
        //     : '';
        if (customer["sex"] != null && customer["sex"] != '') {
          request.fields["customers[$i].sex"] = customer["sex"];
        }
        // Attach files dynamically (uncomment if necessary)

        // if (customer["photo"] is Uint8List) {
        //   print("Gemechuuuddddu");
        //   request.files.add(http.MultipartFile.fromBytes(
        //     "[customers[$i].photo]",
        //     customer["photo"],
        //     filename: "photo_$i.jpg",
        //   ));
        // }
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
          print("Gemechuuuddddu");
          print(customer['signature']);
          request.files.add(http.MultipartFile.fromBytes(
            "customers[$i].signature", // Remove the extra brackets in the string
            customer["signature"],
            filename: "signature_$i.jpg",
          ));
        }
        if (customer["residenceCard"] is Uint8List) {
          print("Gemechuuuddddu");
          print(customer['residenceCard']);
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
      var response = await request.send();
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
          "error": responseBody,
        };
      }
    } catch (e) {
      return {
        "statusCode": 500,
        "message": "An error occurred",
        "error": e.toString(),
      };
    }
  }
}
