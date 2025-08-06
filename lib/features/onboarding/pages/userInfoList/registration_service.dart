import 'package:coopengageplus/constants/config/config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:coopengageplus/constants/kconstant.dart';

class RegistrationService {
  final storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
  );
  // Use a getter for baseUrl to avoid const error
  static String get _baseUrl => AppConstants
      .baseURL; // fallback, replace with AppConstants.baseUrl if available

  Future<Map<String, dynamic>> sendRegistrationLink(
      String accountId, int expirationHours) async {
    final url =
        '$_baseUrl/api/registration/create-link?accountId=$accountId&expirationHours=$expirationHours';
    try {
      String? token = await storage.read(key: "token");
      var uri = Uri.parse(url);

      print("token");
      print("datata");
      var response = await http.post(
        uri,
        headers: {
          "Content-type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
        body: json.encode({}),
      );
      print(url);
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        return {"success": true, "message": "Email sent successfully"};
      } else {
        String errorMsg = 'Failed to send email. Please try again.';
        final Map<String, dynamic> body = json.decode(response.body);
        if (body['message'] != null) {
          errorMsg = body['message'];
        }
        return {"success": false, "message": errorMsg};
      }
    } catch (e) {
      return {"success": false, "message": "An error occurred: $e"};
    }
  }
}
