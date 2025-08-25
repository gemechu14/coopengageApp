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
      request.fields['customerInfo.motherName'] = motherName;
      request.fields['customerInfo.phone'] = phone;
      request.fields['customerInfo.fullName'] = fullName;
      request.fields['customerInfo.sex'] = Sex;
      request.fields['customerInfo.title'] = title ?? '';
      request.fields['customerInfo.email'] = email ?? '';
      request.fields['customerInfo.country'] = country ?? '';
      request.fields['customerInfo.zoneSubCity'] = zoneSubCity ?? '';
      request.fields['customerInfo.streetAddress'] = streetAddress ?? '';

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

      // // Add signature file if available
      // if (signature != null) {
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

      // // Add photo file if available
      // if (photo != null && photo.isNotEmpty) {
      //   final photoFile = File(photo);
      //   if (await photoFile.exists()) {
      //     request.files.add(
      //       await http.MultipartFile.fromPath(
      //         'customerInfo.photo',
      //         photoFile.path,
      //       ),
      //     );
      //   }
      // }

      // Send the request
      final response = await request.send();
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
